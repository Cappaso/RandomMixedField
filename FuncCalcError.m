function Err = FuncCalcError( X, Y )
% Function to calculate error between X and Y
%
% X: N*D; Y: 1*D
%
% Version: 10/04/2015

Err = sum( X ~= repmat(Y, [size(X,1), 1]), 2 ) ./ numel( Y );

end

