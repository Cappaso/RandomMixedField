%% study recovery probability w.r.t. samples
sampsize=linspace(200,2000,10); sslen=length(sampsize);
nTrials=5;

thctsrall=cell(sslen,nTrials);
thctsdisrall=cell(sslen,nTrials);
thdisrall=cell(sslen,nTrials);

%% Start Code  inside iter
for ss=1:length(sampsize)
    
    fprintf('At sampsize: %i\n',sampsize(ss));
    for it=1:nTrials
        p=10; q=10; n=sampsize(ss);
        e=ones(n,1);
        L=2*ones(q,1); % levels in each categorical variable
        Ltot=sum(L);
        %% Create params
        %thcts- inverse covariance
        rhocts=.25;
        thcts=eye(p);
        for i=1:p-1
            thcts(i,i+1)=rhocts;
            thcts(i+1,i)=rhocts;
        end
        
        %thdiscts
        thdiscts=cell(p,q);
        maskDisCts=sparse(p,q);
        %make empty thdiscts , uncomment to have these potentials
        for i=1:min(p,q)
            rhocd=.5;
            maskDisCts(i,i)=1;
            thdiscts{i,i}=[rhocd; -rhocd];
        end
        
        %thdis
        thdis=cell(q,q);
        maskDis = mk_2D_lattice(q,1); maskDis=triu(maskDis);
        maskDis=sparse(maskDis);
        %thdis{1,q}=.5*[1 -1; -1 1];
        %maskDis(1,q)=1;
        for r=1:q
            for j=1:q
                if r<j
                    if maskDis(r,j)==1
                        thdis{r,j}=.5*[1 -1; -1 1]; % attractive
                    end
                    %         if r==j
                    %             thdis{r,r}=[ 1 ; 1];
                    %             maskDis(r,j)=1;
                    %         end
                end
            end
        end
        
        %thdis{1,2}=.5*[1 -1; -1 1];
        %% compute marginal graph p(y) potential. Marginalize out cts var
        Sigma=inv(thcts); % covariance matrix
        edgePotMarg=cell(q,q); % includes both node and edge potentials.
        maskMarg=sparse(q,q);
        for r=1:q
            for j=1:q
                potrj=zeros(L(r),L(j));
                if maskDis(r,j)==1
                    potrj=potrj+thdis{r,j};
                end 
                if r<=j
                    for s=1:p
                        for t=1:p
                            if maskDisCts(s,j)==1 && maskDisCts(t,r)==1
                                thsj=thdiscts{s,j};
                                thtr=thdiscts{t,r};
                                potrj=potrj+Sigma(s,t)*thtr*thsj';
                            end
                        end
                    end
                end
                if norm(potrj)~=0
                    maskMarg(r,j)=1;
                    edgePotMarg{r,j}=potrj;
                end
            end
        end
        %% Make UGM structures
         tic;
        [nodePot, edgePot, edgeStruct] = ToUGM(maskMarg, edgePotMarg,L(1));
        burnIn=1000;
        edgeStruct.maxIter = n;
        edgeStruct.useMex=0;
        Y = UGM_Sample_Gibbs(nodePot,edgePot,edgeStruct,burnIn);
        Y =Y';
        
        %% sample cts, then make
        X= zeros(n,p);% n by p matrix of cts variables
        R=chol(Sigma,'lower');
        for i=1:n
            idx=Y(i,:);
            phi=zeros(p,1); % this is a funtion of idx i.e. discrete labels
            ind=find(maskDisCts);
            for ii=1:length(ind)
                [s j]=ind2sub(size(maskDisCts),ind(ii));
                thsj=thdiscts{s,j};
                phi(s)=phi(s)+thsj(idx(j));
            end
            mu=Sigma*phi;
            X(i,:)=(mu+R*randn(p,1))';
        end
        
        D=[];
        for j=1:q
            Dj=zeros(n,L(j));
            for i=1:n
                Dj(i,Y(i,j))=1;
            end
            D=[D Dj];
        end
        
        %% Init opt variables
        theta=zeros(Ltot,p);
        beta=zeros(p,p);        
        betad=ones(p,1);
        alpha1=zeros(p,1);
        alpha2=zeros(Ltot,1);
        phi=zeros(Ltot,Ltot);
        Lsum=[0;cumsum(L)];      
        x=paramToVecv5(beta,betad,theta,phi,alpha1,alpha2,L,n,p,q); 
        
        %% call optimizer
        lam=5*sqrt(log(p+q)/n);
        smoothF= @(x)lhoodTfocsv5(x,D,X,Y,L,n,p,q );
        nonsmoothH=@(x) tfocsProxGroupv6(lam,L,n,p,q, x ); % only returns value of nonsmooth
        proxH=@(x,t) QNProxGroupv6(lam,L,n,p,q,x,t); %only does prox
        options.BBSTiters=100;
        options.maxIter=500;
        options.progTol=1e-9;
        options.verbose=0;

       
        [xopt ,f_qn,funEvals] = minConf_QNST(smoothF,nonsmoothH,x,proxH,options);
        
%         smoothF = @(x) lhoodTfocNoIntersv5(x,D,X,Y,L,n,p,q ); % this needs to return [f,g]
%         nonsmoothH=@(varargin) tfocsProxGroupv5(lam,L,n,p,q, varargin{:} );
%         clear opts;
%         opts.alg='AT';  opts.maxIts=800; opts.printEvery=100; opts.saveHist=true;
%         opts.restart=200;
%         opts.tol=1e-20;
%         [xopt out opts]=tfocs(smoothF, {}, nonsmoothH, x,opts);

        
        [beta betad theta phi alpha1 alpha2]= vecToParamv5(xopt,L,n,p,q);
        x=xopt;
        thctsrall{ss,it}=diag(betad)-beta-beta';
        thctsdisrall{ss,it}=theta;
        thdisrall{ss,it}=phi;
        toc;
    end
end

%% evaluate success prob
tol=1e-2; %% if average of the block
succplot=zeros(sslen,1);
for ss=1:sslen
    for it=1:nTrials
        err=0;
        %% check thcts
        thctsr=thctsrall{ss,it};
        theta=thctsdisrall{ss,it};
        phi=thdisrall{ss,it};
        for s=1:p
            for t=s:p
                if thcts(s,t)==0
                    if abs(thctsr(s,t))>tol
                        err=1;
                        
                    end
                else
                    if abs(thctsr(s,t))<tol
                        err=1;
                        
                    end
                end
            end
        end
        %% check thctsdis, assumesL(r)=...=L(q) same number of levels
        for s=1:p
            for j=1:q
                if maskDisCts(s,j)==0
                    if norm(theta(2*j-1:2*j,s) ) / sqrt(L(j))>tol
                        err=1;
                        
                    end
                else
                    if norm(theta(2*j-1:2*j,s))/sqrt(L(j))<tol
                        err=1;
                        
                    end
                end
            end
        end
        
        %% check thdis
        for r=1:q
            for j=r:q
                if maskDis(r,j)==0
                    if norm(phi(2*r-1:2*r,2*j-1:2*j) ) / sqrt(L(r))>tol
                        err=1;
                        
                    end
                else
                    if norm(phi(2*r-1:2*r,2*j-1:2*j) ) / sqrt(L(r))<tol
                        err=1;
                        
                    end
                end
            end
        end
        
        if err~=1
            fprintf('success at sampsize %i iter %i\n',ss,it)
            succplot(ss)=succplot(ss)+1;
        end
    end
end
%%
%  close all;
figure(1); imagesc(thcts-diag(diag(thcts))); title('cts truth'); colorbar;
figure(2); imagesc(-beta); title('cts recover'); colorbar;
figure(3); imagesc(maskDis); title('discrete truth');colorbar;
figure; imagesc(phi); title('dis recover');colorbar;
figure; imagesc(maskDisCts); title('cts-dis truth');colorbar;
figure; imagesc(theta'); title('cts-dis recover');colorbar;
%%
% filename=strcat('recoveryProbExpNewStruct10sizes100trials ',datestr(now,'mm_dd_yy.HH_MM_SS'),' .mat');
 %save(filename)
% 
% 

