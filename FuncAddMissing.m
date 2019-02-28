function [ U, V ] = FuncAddMissing( U, V, missRatio, mask )
% Function to randomly missing values to cont/disc nodes defined by mask
%
% U, V:     Cont/Disc sample matrix, contNodeNum/(discNodeNum+1) * allSampSize
% missRatio:    missing # featDim (label excepted);
% mask:     define which samples/instances and which nodes/variables are to be corrupted.
%       structure, mask.row, mask.col
%
% Version:  09/04/2015
% Updated:  27/04/2015

if size(U,2) == size(V,2)
    nSample = size(U,2);
else
    error('Inconsistent sample size between Cont & Disc matrix....');
end

contNodeNum = size(U,1);
discNodeNum = size(V,1) - 1;

if nargin == 3    
    mask.row = zeros( missRatio, nSample );
    mask.col = ones( missRatio, 1 ) * (1:nSample); % missing-value mask of cont nodes
    if missRatio
        for j = 1:nSample
            temp = randperm( contNodeNum + discNodeNum, missRatio ); % return 'missRatio' random integers
            mask.row(:,j) = sort( temp ); % Set value of each column
        end
    end
end

%% Missing target attribute (regression value/classification label) of test instances
UV = [U;V(1:end-1,:)];

nanIdx = sub2ind( size(UV), mask.row(:), mask.col(:) );

UV(nanIdx) = nan;

U = UV(1:contNodeNum,:);
V = [UV(contNodeNum+1:end,:); nan(1,nSample)];

end

