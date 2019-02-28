function [ X, Y, omegaX, omega ] = FuncAddRatioMissing( U, V, missRatio, mask )
% Function to randomly missing values to cont/disc nodes defined by mask
%
% U, V:     Cont/Disc sample matrix, contNodeNum/(discNodeNum+1) * allSampSize
% missRatio:    percentage of missing of each node (label excepted);
% mask:     define which samples/instances and which nodes/variables are to be corrupted.
%       structure, mask.cont, mask.disc
%
% Version:  09/04/2015
% 
% Msg: This inplementation may cause samples with all NaNs.

if size(U,2) == size(V,2)
    nSample = size(U,2);
else
    error('Inconsistent sample size between Cont & Disc matrix....');
end

contNodeNum = size(U,1);
discNodeNum = size(V,1) - 1;

if nargin == 3
    missNum = round( missRatio * nSample ); % get # missing values
    
    mask.cont.row = (1:contNodeNum)' * ones( 1, missNum(1) );
    mask.cont.col = zeros( contNodeNum, missNum(1) );      % missing-value mask of cont nodes
    if missNum(1)
        for j = 1:contNodeNum
            temp = randperm( nSample );
            mask.cont.col(j,:) = sort( temp(1:missNum(1)) );
        end
    end
    
    mask.disc.row = (1:discNodeNum)' * ones( 1, missNum(2) );
    mask.disc.col = zeros( discNodeNum, missNum(2) );      % missing-value mask of disc nodes
    if missNum(2)
        for j = 1:discNodeNum
            temp = randperm( nSample );
            mask.disc.col(j,:) = sort( temp(1:missNum(2)) );
        end
    end
end

%% Missing target attribute (regression value/classification label) of test instances

% missing value of cont nodes
nanIdx = sub2ind( size(U), mask.cont.row(:), mask.cont.col(:) );
omegaX = 1:numel(U); omegaX(nanIdx) = [];

X = nan( size(U) );
X(omegaX) = U(omegaX);

% missing value of disc nodes
nanIdx = sub2ind( size(V), mask.disc.row(:), mask.disc.col(:) );

% annihilate label
[ix, iy] = meshgrid( discNodeNum+1, 1:nSample );
nanIdxL = sub2ind( size(V), ix(:), iy(:) );

omega = 1:numel(V); omega( [nanIdx(:); nanIdxL(:)] ) = [];

Y = nan( size(V) );
Y(omega) = V(omega);

end

