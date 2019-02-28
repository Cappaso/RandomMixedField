%% version 6 does not penalize by sqrt(groupsize)
%%, instead Dummyvar should be normalized as 1/sqrt(n)
%%prox of group sparsity
%% vz is value of non-smooth at z
%% z is soft-thresholded value of x
function [vz z]=tfocsProxGroupv6(lam,L,n,p,q,x,t)

[beta betad theta phi alpha1 alpha2]= vecToParamv5(x,L,n,p,q);

Lsums=cumsum(L); Lsums=[ 0 ;Lsums];

if nargin>6 % do the shrinkage , else just return the val at x
    t=lam*t; % scale the shrinkage coeff
    vz=0;
    %% threshold beta
    betascale=zeros(size(beta));
    betascale=max(0,1-t./abs(beta));
    beta=beta.*betascale;        
    betanorms=sum(abs(beta(:)));
    %% threshold theta and w
    thetanorms=0;
    for s=1:p
        for j=1:q
            tempvec=theta(Lsums(j)+1:Lsums(j+1),s);
            tempvec=max(0,1-t/norm(tempvec))*tempvec;
            thetanorms=thetanorms+norm(tempvec);
            theta(Lsums(j)+1:Lsums(j+1),s)=tempvec(1:L(j));
        end
    end
    %% threshold phi
    phinorms=0;
    for r=1:q
        for j=1:q
            if r<j
                tempmat=phi(Lsums(r)+1:Lsums(r+1),Lsums(j)+1:Lsums(j+1));
                tempmat=max(0,1-t/norm(tempmat))*tempmat; % Lj by 2*Lr
                phinorms=phinorms+norm(tempmat,'fro');           
                phi( Lsums(r)+1:Lsums(r+1),Lsums(j)+1:Lsums(j+1) )=tempmat;
            end
        end
    end
    %%
    vz=lam*(phinorms+thetanorms+betanorms);
    z=paramToVecv5(beta,betad,theta,phi,alpha1,alpha2,L,n,p,q);    
else    
    %% evaluate group sparsity
    vz=0;
    %% threshold beta 
    betanorms=sum(abs(beta(:)));
    %% threshold theta and w
    thetanorms=0;
    for s=1:p
        for j=1:q
            tempvec=theta(Lsums(j)+1:Lsums(j+1),s);
            thetanorms=thetanorms+norm(tempvec);
        end
    end
    %% threshold phi
    phinorms=0;
    for r=1:q
        for j=1:q
            if r<j
                tempmat=phi(Lsums(r)+1:Lsums(r+1),Lsums(j)+1:Lsums(j+1));    
                phinorms=phinorms+norm(tempmat,'fro');          
            end
        end
    end
    %%
    vz=lam*(phinorms+thetanorms+betanorms);
    z=paramToVecv5(beta,betad,theta,phi,alpha1,alpha2,L,n,p,q);       
end



