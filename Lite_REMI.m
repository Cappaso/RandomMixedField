function [Xden,YSden] = Lite_REMI(Utrain,Vtrain,Xj,Yj,L)
% wrapper function

DiscMat = GetDummyDiscAttr( [Vtrain(1:end-1,:), Yj(1:end-1,:)], L(1:end-1) );
temp = regem( [Utrain, Xj; DiscMat]' )';
if ~isreal(temp); temp = real(temp); end
Xden = temp( 1:size(Utrain,1), size(Utrain,2)+1:end );
YSden = temp( size(Utrain,1)+1:end, size(Utrain,2)+1:end ); clear DiscMat temp;
YSden = GetDummyDiscAttr( GetOrigiDiscAttr(YSden,L(1:end-1)), L(1:end-1) ); % dummy variable constraint