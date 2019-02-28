function [Xden,YSden] = Lite_missForest(Utrain,Vtrain,Xj,Yj,L)
% wrapper function

%cd missForest
temp = missForest_wrap( [Utrain, Xj]', [Vtrain(1:end-1,:), Yj(1:end-1,:)]' )';
%cd ..

Xden = temp( 1:size(Utrain,1), size(Utrain,2)+1:end );
Yden = temp( size(Utrain,1)+1:end, size(Utrain,2)+1:end ); clear temp;
YSden = GetDummyDiscAttr( Yden, L(1:end-1) );