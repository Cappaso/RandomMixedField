%% converts x to Parameter form
function [beta betad theta phi alpha1 alpha2]= vecToParamv5(x,L,n,p,q)
Ltot=sum(L);
sizes=[p^2 p p*Ltot Ltot^2 p Ltot];
sums=cumsum(sizes); 
beta=reshape(x(1:p^2),p,p);
betad=reshape(x(sums(1)+1:sums(2)),p,1);
theta=reshape(x(sums(2)+1:sums(3)),Ltot,p);
phi=reshape(x(sums(3)+1:sums(4)),Ltot,Ltot);
alpha1=reshape(x(sums(4)+1:sums(5)) ,p,1);
alpha2=reshape(x(sums(5)+1:sums(6)),Ltot,1);