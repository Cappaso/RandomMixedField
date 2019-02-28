function [ Y, nanIdxC ] = FuncRemoveNanCol( X )
% Function to remove columns which cantain NaN
%
% X:    featDim * sampNum
% Y:    featDim * sampNumNew

nanIdx = isnan(X);
nanIdxC = logical(sum(nanIdx,1));
Y = X(:,~nanIdxC);


