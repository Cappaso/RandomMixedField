%% Does the sampling, this code needs to be cleaned up

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
