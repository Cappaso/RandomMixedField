% Demo to run learn structure on real UCI Adult dataset
%
% U:	contNodeNum * sampSize, real/noisy continuous attributes data.
% V:	discNodeNum * sampSize, real/noisy discrete attributes data.
% L:    levels in each categorical variable

% Requires UGM at http://www.di.ens.fr/~mschmidt/Software/UGM_2009.zip
% Requires TFOCS at http://tfocs.stanford.edu
% Based on Jason Lee's MGM code
% http://www-bcf.usc.edu/~lee715/syntheticExp/syntheticExp.zip


%% UCI datasets
foldName{1} = './AllDataset/UCI_Adult/adult.';
foldName{2} = './AllDataset/UCI_Credit/crx.';
foldName{3} = './AllDataset/UCI_Statlog_AU/australian.';
foldName{4} = './AllDataset/UCI_Statlog_GE/german.';
foldName{5} = './AllDataset/toy'; % synthetic data

%% Loading data
foldIdx = 2; %%% MODIFY this to choose dataset!!!

splitRatio = 2/3;

[ ~, ~, U, V, L, ~ ] = FuncLoadData( foldName{foldIdx}, splitRatio );

[ ~, nanIdxC ] = FuncRemoveNanCol( [U;V] );
U = U(:,~nanIdxC); V = V(:, ~nanIdxC); % instances without missing values
    
[~, name, ~] = fileparts( foldName{foldIdx} );

% Learn structure
lambda = 0.05;
canoParam = FuncLearnStruct(U,V,L,lambda,1);

save(sprintf('%s_Models_RMF.mat', name), 'lambda', 'canoParam');


