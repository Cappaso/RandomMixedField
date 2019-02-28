% Evaluates the negative-log-likelihood w/o the regularizer
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

function fval= flhoodv5(beta,betad,theta,phi,alpha1,alpha2,D,X,Y,L,n,p,q)

if sum(betad<0)>0
     fval=10^50;
     return;
end
fval=0;
sqloss=0;
e=ones(n,1);
Lsum=[0;cumsum(L)];

    
%% zero out  diagonal
beta=beta-diag(diag(beta));
for r=1:q
    phi(Lsum(r)+1:Lsum(r+1),Lsum(r)+1:Lsum(r+1))=0;
end
beta=triu(beta); phi=triu(phi);
beta=beta+beta';
phi=phi+phi';
%% cache quantities
Xbeta=X*beta*diag(1./betad);
Dtheta=D*theta*diag(1./betad);
%% square loss 

sqloss=-n/2*sum(log(betad))+...
    .5*norm((X-e*alpha1'-Xbeta-Dtheta)*diag(sqrt(betad)),'fro')^2; % the matrix is n by p
%% Do categorical loss
catloss=0;
wxprod=X*(theta')+D*phi+e*alpha2'; %this is n by Ltot
for r=1:q    
    wxtemp=wxprod(:,Lsum(r)+1:Lsum(r)+L(r));
    denom= logsumexp(wxtemp,2); %this is n by 1  
    catloss=catloss-sum(wxtemp(sub2ind([n L(r)],(1:n)',Y(:,r))));    
    catloss=catloss+sum(denom);     
end

fval=(sqloss+catloss)/n; 











