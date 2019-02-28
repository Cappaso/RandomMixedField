function canoParam = FuncLearnStruct(U,V,L,lambda,quiet)
% Function to learn structure
%
% U:	contNodeNum * sampSize, real/noisy continuous attributes data.
% V:	discNodeNum * sampSize, real/noisy discrete attributes data.
% L:    levels in each categorical variable

% Requires UGM at http://www.di.ens.fr/~mschmidt/Software/UGM_2009.zip
% Requires TFOCS at http://tfocs.stanford.edu

if nargin==3; lambda = 1; quiet = 0; end
if nargin==4; quiet = 0; end

% Graph parameters
p = size(U,1); % number of cts variables
q = size(V,1); % number of discrete variables
n = size(U,2); % sample size
if q~=length(L); error('Wrong cardinalities'); end
Ltot = sum(L);

D=[];
for i=1:q
    Di=zeros(L(i),n);
    for j=1:n
        Di(V(i,j),j)=1;
    end
    D=[D; Di];
end


%% Init opt variables
theta=zeros(Ltot,p); % cts-dis params
beta=zeros(p,p); % negative of the precision matrix
betad=ones(p,1); % diagonal of the precision matrix
alpha1=zeros(p,1); % cts node potential param
alpha2=zeros(Ltot,1); % dis node potential param
phi=zeros(Ltot,Ltot); % dis edge potential params
Lsum=[0;cumsum(L)];
x=paramToVecv5(beta,betad,theta,phi,alpha1,alpha2,L,n,p,q);

%% call TFOCS
lam=lambda*sqrt(log(p+q)/n);
smoothF= @(x)lhoodTfocsv5(x,D',U',V',L,n,p,q);
nonsmoothH=@(varargin) tfocsProxGroupv6(lam,L,n,p,q, varargin{:} ); % only returns value of nonsmooth
opts.alg='N83';  opts.maxIts=800; opts.printEvery=100; opts.saveHist=true;
opts.restart=-10^4;
opts.tol=1e-10;
[xopt out opts]=tfocs(smoothF, {}, nonsmoothH, x,opts);
[beta betad theta phi alpha1 alpha2]= vecToParamv5(xopt,L,n,p,q);

if quiet
%% Plot parameters
close all;
%figure(1); imagesc(triu(thcts-diag(diag(thcts)))); title('cts truth'); colorbar;
figure(2); imagesc(-beta); title('cts recover'); colorbar;
%figure(3); imagesc(maskDis); title('discrete truth');colorbar;
figure(4); imagesc(phi); title('dis recover');colorbar;
%figure(5); imagesc(maskDisCts); title('cts-dis truth');colorbar;
figure(6); imagesc(theta'); title('cts-dis recover');colorbar;
drawnow
end


%% SAVE to canoParam
beta=triu(beta); phi=triu(phi);
beta=beta+beta'; phi=phi+phi';
canoParam.B = beta + diag(betad);
canoParam.alpha = alpha1;
canoParam.rho = mat2cell(theta', ones(1,p), L);
phi = phi + diag(alpha2);
canoParam.phi = mat2cell(phi, L, L);


