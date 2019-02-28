function GenMissNoisyData
% Function to generate all testing datasets.

% I. Datasets with default train-test split using MLC++ GenCVFiles (2/3, 1/3 random).
foldName{1} = './AllDataset/UCI_Adult/adult.';

% II. Datasets without default train-test split, use 'randperm'.
foldName{2} = './AllDataset/UCI_Credit/crx.';
foldName{3} = './AllDataset/UCI_Statlog_AU/australian.';
foldName{4} = './AllDataset/UCI_Statlog_GE/german.';
foldName{5} = './AllDataset/toy'; % synthetic data

missRange = { 0:13; 0:14; 0:13; 0:19; 0:25 }; % missing with # featDim
noiseRange = 0:5;
randNum = 10;

if ~exist('./AllMissNoisyTest/data', 'dir')
    mkdir('./AllMissNoisyTest','data');
end

%%% MODIFY this to choose dataset!!!
for foldIdx = 2
    
    splitRatio = 2/3; % train/test split ratio

    [ ~, ~, U, V, L, ~ ] = FuncLoadData( foldName{foldIdx}, splitRatio );

    [ ~, nanIdxC ] = FuncRemoveNanCol( [U;V] );
    U = U(:,~nanIdxC); V = V(:, ~nanIdxC); % instances without missing values
    
    [~,name,~] = fileparts( foldName{foldIdx} );
    
    %%% MODIFY this to choose corruption strength!!!
    for m_i = 1:length(missRange{foldIdx})
    	for n_j = 1:length(noiseRange)
            missRatio = missRange{foldIdx}(m_i);
            noiseRatio = [0.1, 0.1] * noiseRange(n_j);

            [ X, Y ] = SubGenMissNoisyData( U, V, L, missRatio, noiseRatio, randNum );
            save ( sprintf('./AllMissNoisyTest/data/%s_M_%02d_N_%0.1f_%0.1f.mat', name, missRatio, noiseRatio), 'X', 'Y' );

            fprintf('MissNoisyTest_%s_M_%02d_N_%0.1f_%0.1f...\n', name, missRatio, noiseRatio)
    	end
    end
    
end

function [ X, Y ] = SubGenMissNoisyData( U, V, L, missRatio, noiseRatio, randNum )
% Function to generate testing datasets with missing value and/or noise.
%
% U, V:     cont/disc attr data matrix, featDim * sampSize
% L:    cardinality of disc nodes
% X, Y:     cont/disc corrupted data cell.
%
% missRatio:   missing # featDim
% noiseRatio:  (cont) noise magnitude ratio, (disc) flipping ratio
% randNum:     number of random tests
%
% Version:  12/04/2015


% Setting
param.discNodeCard = L;         % cardinality of each discrete node
param.discNodeNum = length(L);          % number of discrete nodes
param.contNodeNum = size(U,1);          % number of continuous nodes
param.contSignalSigma = std(U,0,2);     % std of cont signal.
                                        % eg: [0.1799; 0.1347; 0.17; 0.1222]

nStates = param.discNodeCard;

% ==== Param Gaussian noise to cont nodes. 
sigma = noiseRatio(1) * param.contSignalSigma; sigma2 = sigma .* sigma;

% ==== Param of impulsive noise to disc nodes.
prob = 1 - noiseRatio(2); varphi = cell(param.discNodeNum,1);
for j = 1:param.discNodeNum
	varphi{j} = log( diag( (prob - (1-prob)/(nStates(j)-1)) * ones(nStates(j),1) )...
		+ ones(nStates(j), nStates(j)) * (1-prob)/(nStates(j)-1) ); % prob --> energy.
end

% Generate corrupted datasets
X = cell(randNum,1);
Y = cell(randNum,1);
for j = 1:randNum
    % Adding AWGN/flip to cont/disc nodes
    if any( noiseRatio )
        [ X{j}, Y{j} ] = FuncAddNoise( U, V, sigma2, varphi, param);
    else
        X{j} = U; Y{j} = V; % Specially-treat "noiseRatio = [0 0]" case
    end

    % Adding missing values
    %   NOTE: if missRatio = 0, "FuncAddMissing" will only annihilate labels.
    [ X{j}, Y{j} ] = FuncAddMissing( X{j}, Y{j}, missRatio );
    
end


