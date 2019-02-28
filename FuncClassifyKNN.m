function [knnErr, Lpred2] = FuncClassifyKNN(model, Utest, Ltest, imputeFlag)
% Function of KNN-classifier using 'model'
%
% imputeFlag:   0, default zero-imputation
%               1, reduced-feature prediction/classification

if nargin == 3; imputeFlag = 0; end


if ~imputeFlag % zero-imputation KNN
    % === NOTE: 'predict' takes zero-imputation as a default pre-step,
    % ===  so the below line of code is not necessary.
    nanIdx = isnan(Utest); Utest(nanIdx) = 0;
    
    [Lpred2,~,~] = predict(model,Utest');
    
else % reduced-feature KNN
    Lpred2 = zeros( size(Ltest) );
    
    for j = 1:size(Utest,2)
        selFeat = ~( isnan(Utest(:,j)) );
        dist = EuclideanDistance( model.X(:,selFeat), Utest(selFeat,j)' );
        
        [~, idx] = sort(dist, 'ascend');
        
        lab_K = model.Y( idx( 1:model.NumNeighbors ) );
        
        [lab_K_uni, uni_idx] = unique( sort(lab_K) );
        count = diff( [uni_idx; length(lab_K)+1] ); % number of unique labels
        
        prob = zeros( size(model.Prior) );
        prob( lab_K_uni ) = count ./ sum(count);
        [~, max_idx] = max( model.Prior .* prob ); % considering label distribution
        
        Lpred2(j) = model.ClassNames( max_idx ); % assign label of max posterior
        
    end
    
end

knnErr = sum(Ltest~=Lpred2) / length(Ltest);
fprintf('%.2f%%|',(1-knnErr)*100);

