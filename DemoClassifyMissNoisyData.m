% Demo to run classification on Miss-Noisy dataset
%
% U:	contNodeNum * sampSize, real continuous attributes data.
% V:	discNodeNum * sampSize, real discrete attributes data.
% X:	miss-noisy version of U.
% Y:	miss-noisy version of V.
% Xden: restored version of X.
% Yden: restored version of Y.
%
% To run SVM_linear_C classifier, requires LIBSVM.
% To run missForest, requires running R from MATLAB.

clear;

%% Setting
% I. Datasets with default train-test split using MLC++ GenCVFiles (2/3, 1/3 random).
foldName{1} = './AllDataset/UCI_Adult/adult.';

% II. Datasets without default train-test split, use 'randperm'.
foldName{2} = './AllDataset/UCI_Credit/crx.';
foldName{3} = './AllDataset/UCI_Statlog_AU/australian.';
foldName{4} = './AllDataset/UCI_Statlog_GE/german.';
foldName{5} = './AllDataset/toy'; % synthetic data

% Imputation methods.
imputMethod = {'KNNI'; 'REMI'; 'missForest'; 'RMFI'};

missRange = { 0:13; 0:14; 0:13; 0:19; 0:24 }; % missing with # featDim
noiseRange = 0:5;
randNum = 10;

flag.IgnoreFileCheck = true; % true: replace the file. false: skip if the file exist.
flag.CalRmfPlus = false; % true: run RMF+KNNI, RMF+REMI, RMF+missF.

for foldIdx = 2

for imputIdx = [1,4]
method = imputMethod{imputIdx};

    %% Get dataset file name
    [~,name,~] = fileparts( foldName{foldIdx} );
    
    %% Load ground-truth test data (including labels)
    splitRatio = 2/3; % train/test split ratio

    [ Utrain, Vtrain, U, V, L, lambda ] = FuncLoadData( foldName{foldIdx}, splitRatio );
    [ ~, nanIdxC ] = FuncRemoveNanCol( [Utrain;Vtrain] );
    Utrain = Utrain(:,~nanIdxC); Vtrain = Vtrain(:, ~nanIdxC);

    [ ~, nanIdxC ] = FuncRemoveNanCol( [U;V] );
    U = U(:,~nanIdxC); V = V(:, ~nanIdxC); % instances without missing values
    
    %% Load pre-trained models
    if strcmp(method,'RMFI'); load ( sprintf('./AllTrainedModels/%s_Models_RMF.mat', name), 'canoParam' ); end
    load ( sprintf('./AllTrainedModels/%s_Models_KNN.mat', name), 'model' );
    load ( sprintf('./AllTrainedModels/%s_Models_SVM_linear_C.mat', name), 'model_opt' );
    
    for m_i = 1:length(missRange{foldIdx})
        missRatio = missRange{foldIdx}(m_i);
        fprintf('\n%s_Results_%s_M_%02d_N_0.X', name, method, missRatio);
        for n_j = 1:length(noiseRange)
            noiseRatio = [0.1, 0.1] * noiseRange(n_j);

            filePath.ExpData = sprintf('./AllMissNoisyTest/data/%s_M_%02d_N_%0.1f_%0.1f.mat', name, missRatio, noiseRatio);
            filePath.method = sprintf('./AllMissNoisyTest/%s_Results_%s_M_%02d_N_%0.1f_%0.1f.mat', name, method, missRatio, noiseRatio);

            if ~( exist(filePath.method, 'file') ) || flag.IgnoreFileCheck
                %fprintf('%s_Results_%s_M_%02d_N_%0.1f_%0.1f.\n', name, method, missRatio, noiseRatio);
                fprintf('\n');
                
                methodErr = [];
                save (filePath.method, 'methodErr');

                %% Load Miss-Noisy test data
                load (filePath.ExpData);
                
                switch method
                    case 'KNNI' % KNNimpute
                        methodErr = zeros( length(Y), 2 );
                        for j = 1:length(Y)
                            [Xden,YSden] = Lite_KNNI(Utrain,Vtrain,X{j},Y{j},L);
                            methodErr(j,1) = FuncClassifyKNN( model, [Xden;YSden], V(end,:)' );
                            %methodErr(j,2) = FuncClassifySVM( model_opt, [Xden;YSden], V(end,:)' );
                        end
                    case 'REMI' % RegEM imputation
                        methodErr = zeros( length(Y), 2 );
                        for j = 1:length(Y)
                            [Xden,YSden] = Lite_REMI(Utrain,Vtrain,X{j},Y{j},L);
							methodErr(j,1) = FuncClassifyKNN( model, [Xden;YSden], V(end,:)' );
                            %methodErr(j,2) = FuncClassifySVM( model_opt, [Xden;YSden], V(end,:)' );
                        end
                    case 'missForest' % missForest imputation
                        methodErr = zeros( length(Y), 2 );
                        for j = 1:length(Y)
                            [Xden,YSden] = Lite_missForest(Utrain,Vtrain,X{j},Y{j},L);
							methodErr(j,1) = FuncClassifyKNN( model, [Xden;YSden], V(end,:)' );
                            %methodErr(j,2) = FuncClassifySVM( model_opt, [Xden;YSden], V(end,:)' );
                        end
					case 'RMFI' % un-supervised RMF imputation
                        methodErr = zeros( length(Y), 2 );
                        if flag.CalRmfPlus; methodErrPlus = zeros( length(Y), 2 ); end
                        
                        for j = 1:length(Y)
                            [sigma2,varphi,param] = FuncParamSetting( canoParam, L(1:end-1), noiseRatio, U );
                            [Xden,Yden] = FuncInferMixedNet( X{j}, Y{j}(1:end-1,:), canoParam, sigma2, varphi, param );
                            
                            YSden = GetDummyDiscAttr( Yden, L(1:end-1) ); % RMFI
                            methodErr(j,1) = FuncClassifyKNN( model, [Xden;YSden], V(end,:)' );
                            %methodErr(j,2) = FuncClassifySVM( model_opt, [Xden;YSden], V(end,:)' );
                            
                            if flag.CalRmfPlus
                                Xden( isnan(X{j}) ) = nan; Yden( isnan(Y{j}(1:end-1,:)) ) = nan;
                                X{j} = Xden; Y{j}(1:end-1,:) = Yden; % save to cell 'X' and 'Y'
                                
                                % RMF-KNNI
                                [Xden,YSden] = Lite_KNNI(Utrain,Vtrain,X{j},Y{j},L);
								methodErrPlus(j,3) = FuncClassifyKNN( model, [Xden;YSden], V(end,:)' );
                                methodErrPlus(j,4) = FuncClassifySVM( model_opt, [Xden;YSden], V(end,:)' );
                                
                                % RMF-REMI
                                [Xden,YSden] = Lite_REMI(Utrain,Vtrain,X{j},Y{j},L);
								methodErrPlus(j,5) = FuncClassifyKNN( model, [Xden;YSden], V(end,:)' );
                                methodErrPlus(j,6) = FuncClassifySVM( model_opt, [Xden;YSden], V(end,:)' );
								
								% RMF-missForest
                                [Xden,YSden] = Lite_missForest(Utrain,Vtrain,X{j},Y{j},L);
								methodErrPlus(j,7-6) = FuncClassifyKNN( model, [Xden;YSden], V(end,:)' );
                                methodErrPlus(j,8-6) = FuncClassifySVM( model_opt, [Xden;YSden], V(end,:)' );
                            end
                            
                        end
                    otherwise
                        disp('Please choose a imputation method...');
                        return
                end
                
                save (filePath.method, 'methodErr');
                if exist('methodErrPlus','var'); save (filePath.method, 'methodErr', 'methodErrPlus'); end
                
                %fprintf('Saved to %s_Results_%s_M_%02d_N_%0.1f_%0.1f.mat\n', name, method, missRatio, noiseRatio);
                
            end % if ~exist(filePath.method, 'file')
        end
    end
    
end

end
