function [ Utr, Vtr, Uts, Vts, L, lambda ] = FuncLoadData( foldName, splitRatio )
% Function to load UCI dataset
%
% Note: Treat label as a disc node which is in the end of matrix.

% Default params of UCI dataset
[~,name,~] = fileparts( foldName);

removFlag = 0; % whether to remove duplicate instances

switch name
    case 'abalone'
        splitFlag = 0; scaleFlag = 0;
        contAttr = [2:8]; % continuous-valued attributes index
        discAttr = 1:9; discAttr(contAttr) = []; % discrete-valued attributes index
        L = [3 3]'; % levels in each categorical variable & label
        lambda = 0.5; % large lambda for small # training instances
    case 'adult'
        splitFlag = 0; scaleFlag = 1;
        contAttr = [1 3 5 11 12 13];
        discAttr = 1:15; discAttr(contAttr) = [];
        L = [8 16 7 14 6 5 2 41 2]';
        lambda = 0.0526;
    case 'census-income'
        removFlag = 1; % REMOVE duplicates
        splitFlag = 0; scaleFlag = 1; % NOTE: as suggested, remove 25-th attr (instance weight)
        contAttr = [1 6 17 18 19 31 40]; % 7 cont
        discAttr = 1:42; discAttr( [contAttr,25] ) = []; % 33 disc & 1 Label
        L = [9,52,47,17,3,7,24,15,5,10,2,3,6,8,6,6,50,38,8,9,8,9,3,3,5,42,42,42,5,3,3,3,2,2]';
        lambda = 0.05;
    case 'cmc'
        splitFlag = 1; scaleFlag = 1;
        contAttr = [1 4];
        discAttr = 1:10; discAttr(contAttr) = [];
        L = [4 4 2 2 4 4 2 3]';
        lambda = 0.0312;
    case 'crx'
        splitFlag = 1; scaleFlag = 1;
        contAttr = [2 3 8 11 14 15];
        discAttr = 1:16; discAttr(contAttr) = [];
        L = [2 4 3 14 9 2 2 2 3 2]';
        lambda = 0.1250;
    case 'australian'
        delimiter = {' '};
        splitFlag = 1; scaleFlag = 1;
        contAttr = [2 3 7 10 13 14];
        discAttr = 1:15; discAttr(contAttr) = [];
        L = [2,3,14,9,2,2,2,3,2]';
        lambda = 0.0312;
    case 'german'
        delimiter = {' '};
        splitFlag = 1; scaleFlag = 1;
        contAttr = [2 5 8 11 13 16 18];
        discAttr = 1:21; discAttr(contAttr) = [];
        L = [4,5,11,5,5,5,3,4,3,3,4,2,2,2]';
        lambda = 0.0884;
    case 'allbp'
        delimiter = {':',',','.|'};
        splitFlag = 0; scaleFlag = 1;
        contAttr = [1 18 20 22 24 26 28];
        discAttr = 1:30; discAttr(contAttr) = [];
        L = [2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,6,3]';
        lambda = 0.0005;
    case 'toy' % synthetic data
        load([foldName,'.mat']);
        nSamples = round( size(U, 2) * splitRatio );
        trainIdx = 1:nSamples;
        testIdx = 1:size(U, 2); testIdx(trainIdx) = [];
        Utr = U(:, trainIdx); Vtr = V(:, trainIdx); % Train set
        Uts = U(:, testIdx); Vts = V(:, testIdx); % Test set
        L = max(V,[],2); % Cardinalities (including label)
        lambda = 0.05;
        return;
    otherwise
        error('Unexpected dataset name. No data loaded.')
end

if splitFlag
    load ([foldName,'data.mat']); fileData = fileData';
    
    % Split into train/test set.
    nSamples = round( size(fileData, 2) * splitRatio ); % calculate the number of observed entries
    
%     rPerm = randperm( size(fileData, 2) ); % random split
%     trainIdx = sort( rPerm(1:nSamples) );
    
    trainIdx = 1:nSamples; % direct split
    
    testIdx = 1:size(fileData, 2); testIdx(trainIdx) = [];
    
    % Train set
    Utr = fileData(contAttr, trainIdx);
    Vtr = fileData(discAttr, trainIdx);
    
    % Test set
    Uts = fileData(contAttr, testIdx);
    Vts = fileData(discAttr, testIdx);
    clear fileData;
else
    % Train set
    load ([foldName,'data.mat']); fileData = fileData';
    
    Utr = fileData(contAttr,:);
    Vtr = fileData(discAttr,:);
    clear fileData;
    
    % Test set
    load ([foldName,'test.mat']); fileData = fileData';
    
    Uts = fileData(contAttr,:);
    Vts = fileData(discAttr,:);
    clear fileData;

end

% Remove duplicate samples
if removFlag
    [Utr,Vtr] = FuncRemDup(Utr,Vtr);
    [Uts,Vts] = FuncRemDup(Uts,Vts);
end

if scaleFlag % scale cont attributes to [0,1]
    % Handle missing values
    nanIdx = isnan(Utr(:));
    if sum(nanIdx); Utr(nanIdx) = 0; end
    
    % Train set
    trainParam.Min = min(Utr,[],2);
    trainParam.Max = max(Utr,[],2);
    trainParam.Rng = max(Utr,[],2) - min(Utr,[],2);
    trainParam.Rng( trainParam.Rng == 0 ) = 1; % avoid 0 dividend.
    
    Utr = GetScaledContAttr(Utr,trainParam); 
    
    % Test set
    Uts = GetScaledContAttr(Uts,trainParam);
end

function [X,Y] = FuncRemDup(U,V)
% Function to remove duplicate columns (i.e., instances)
X = U; Y = V;

nanElemVal = -1000;
U( isnan(U) ) = nanElemVal; % any const.
V( isnan(V) ) = nanElemVal; % any const.

[~,idx_uni] = unique([U;V]','rows');
idx_uni = sort(idx_uni);

X = X(:,idx_uni);
Y = Y(:,idx_uni);
