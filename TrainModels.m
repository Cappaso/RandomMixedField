% TrainModels
% Code to train RMF, KNN and SVM models
%       on no-missing and clean training sets.

% Malloc parallel tool
% delete(gcp); % kill previous local profile
% poolobj = parpool('local',2);


disp('Add path...');
addpath(genpath('../libsvm'));
addpath(genpath('../TFOCS'));
addpath(genpath('../UGM'));

%% Loading training data
% I. Datasets with default train-test split using MLC++ GenCVFiles (2/3, 1/3 random).
foldName{1} = '../AllDataset/UCI_Adult/adult.';
foldName{2} = '../AllDataset/UCI_CensusIncomeKDD/census-income.';

% II. Datasets without default train-test split, use 'randperm'.
foldName{3} = '../AllDataset/UCI_CMC/cmc.';
foldName{4} = '../AllDataset/UCI_Credit/crx.';
foldName{5} = '../AllDataset/UCI_Statlog_AU/australian.';
foldName{6} = '../AllDataset/UCI_Statlog_GE/german.';

% III. Toy experiment
foldName{7} = '../AllDataset/toy'; % synthetic data

splitRatio = 2/3; % train/test split ratio

for foldIdx = 7
    [ Utrain, Vtrain, ~, ~, L, lambda ] = FuncLoadData( foldName{foldIdx}, splitRatio );
    if foldIdx >= 1 && foldIdx <= 6
        [ ~, nanIdxC ] = FuncRemoveNanCol( [Utrain;Vtrain] );
        Utrain = Utrain(:,~nanIdxC); Vtrain = Vtrain(:, ~nanIdxC);
    else
        [ ~, nanIdxR ] = FuncRemoveNanCol( Utrain' );
        Utrain( nanIdxR, : ) = 0; % if one row are all missing, replace with 0.
        temp = knnimpute( [Utrain; Vtrain]', 3 )';
        Utrain = temp( 1:size(Utrain,1), : ); Vtrain = round( temp( size(Utrain,1)+1:end, : ) );
        Vtrain( isnan(Vtrain) ) = 0;
    end
    
    disp('Finish loading data...')

    [~,name,~] = fileparts( foldName{foldIdx} );

    %% Learn structure: with label, i.e., supervised learning
%     tic; canoParam = FuncTrainRMF( Utrain, Vtrain, L ); lambda = canoParam.lambda; toc; % Cross-validate lambda
%     
% %     canoParam = FuncLearnStruct(Utrain,Vtrain,L,lambda,0); canoParam.lambda = lambda;
% 
%     save ( sprintf('./AllTrainedModels/%s_Models_sRMF.mat', name), 'canoParam', 'lambda' );
%     
%     fprintf('Model saved: ./AllTrainedModels/%s_Models_sRMF.mat\n', name)
    
    %% Learn structure: without label, i.e., un-supervised learning
    lambda = 0.05; % fixed value
    canoParam = FuncLearnStruct( Utrain, Vtrain(1:end-1,:), L(1:end-1), lambda, 0 ); % label has been removed

    save ( sprintf('./AllTrainedModels/%s_Models_RMF.mat', name), 'canoParam', 'lambda' );
    
    fprintf('Model saved: ./AllTrainedModels/%s_Models_RMF.mat\n', name)
    
    %% Train KNN and linear-SVM
    VStrain = GetDummyDiscAttr( Vtrain(1:end-1,:), L(1:end-1) ); % transform disc attributes to dummy binary variables
    
    [model, knnTrainErr] = FuncTrainKNN( [Utrain;VStrain], Vtrain(end,:)', 3 );
    save ( sprintf('./AllTrainedModels/%s_Models_KNN.mat', name), 'model', 'knnTrainErr' );
    
    fprintf('Model saved: ./AllTrainedModels/%s_Models_KNN.mat\n', name)

    tic;[model_opt, svmTrainErr, C_opt] = FuncTrainSVM_linear_C([Utrain;VStrain], Vtrain(end,:)');toc;
    save ( sprintf('./AllTrainedModels/%s_Models_SVM_linear_C.mat', name), 'model_opt', 'svmTrainErr', 'C_opt' );
    
    fprintf('Model saved: ./AllTrainedModels/%s_Models_SVM_linear_C.mat\n', name)
    
end

% Release
% delete(poolobj);
