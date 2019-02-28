%theta=randn(Ltot,p); % Ltot by p matrix
% beta=zeros(p,p); mantain only s<t upper triangular
% betad= zeros(p,1) diagonal of beta
% alpha1=zeros(p,1);
% alpha2 is Ltot by 1
%phi is Ltot by Ltot, should only have upper triangular
% X= randn(n,p);% n by p matrix of cts variables
% Y=zeros(n,q); % n by q matrix of categorical variables
% L is q-length vector of the numlevels of the jth categorial
%D=n by Ltot matrix
function [gradbeta gradbetad gradtheta gradphi gradalpha1 gradalpha2  ]= fgradlhoodv5(beta,betad,theta,phi,alpha1,alpha2,D,X,Y,L,n,p,q)
%%
Ltot=sum(L);
Lsum=[0;cumsum(L)];
%% zero out phi diagonal
beta=beta-diag(diag(beta));
for r=1:q
    phi(Lsum(r)+1:Lsum(r+1),Lsum(r)+1:Lsum(r+1))=0;
end
beta=triu(beta); phi=triu(phi);
beta=beta+beta';
phi=phi+phi';
%% cache quantities
e=ones(n,1);
Xbeta=X*beta*diag(1./betad);
Dtheta=D*theta*diag(1./betad);
res=Xbeta-X+e*alpha1'+Dtheta;
%% compute gradbeta
gradbeta=zeros(p,p);
gradbeta=X'*(res);
gradbeta=gradbeta-diag(diag(gradbeta)); % zero out diag
gradbeta=tril(gradbeta)'+triu(gradbeta);
%% compute gradalpha1
gradalpha1=zeros(p, 1);
%gradalpha1=-diag(betad)*sum(X-Xbeta-Dtheta,1)'+diag(betad)*alpha1*n;
gradalpha1=diag(betad)*sum(res,1)';
%% compute gradtheta
gradtheta=zeros(sum(L),p);
gradtheta=D'*(res);
%% compute gradalpha2,gradw, gradphi
gradalpha2=zeros(Ltot,1);
gradphi=zeros(Ltot,Ltot);
wxprod=X*(theta')+D*phi+e*alpha2'; %this is n by Ltot
Lsum=[0;cumsum(L)];
for r=1:q
    idx=Lsum(r)+1:Lsum(r)+L(r);
    wxtemp=wxprod(:,idx); %n by L(r)
    denom=sum(exp(wxtemp),2); % this is n by 1
    wxtemp=diag(sparse(1./denom))*exp(wxtemp);
    wxtemp(sub2ind(size(wxtemp),(1:n)',Y(:,r)))=wxtemp(sub2ind(size(wxtemp),(1:n)',Y(:,r)))-1;
    wxprod(:,idx)=wxtemp;    
end
%% assign gradients
gradalpha2=sum(wxprod,1)';
gradw=X'*wxprod;
gradtheta=gradtheta+gradw';
gradphi=D'*wxprod;
%% zero out gradphi diagonal
for r=1:q
    gradphi(Lsum(r)+1:Lsum(r+1),Lsum(r)+1:Lsum(r+1))=0;
end
%% 
gradphi=tril(gradphi)'+triu(gradphi);
%% gradbetad
gradbetad=zeros(p,1);
for s=1:p
    gradbetad(s)=-n/(2*betad(s))+1/2*norm(res(:,s))^2-res(:,s)'*(Xbeta(:,s)+Dtheta(:,s));
end
%gradbetad=-1./(2*betad)+1/2*sum(res.^2,1)'+diag((-res)'*(Xbeta+Dtheta));
gradbeta=gradbeta/n;
gradbetad=gradbetad/n;
gradtheta=gradtheta/n;
gradphi=gradphi/n;
gradalpha1=gradalpha1/n;
gradalpha2=gradalpha2/n;





