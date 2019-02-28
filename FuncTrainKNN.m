function [ model, knnErr ] = FuncTrainKNN( U, Ltrain, K_range )

if nargin == 2; K_range = 1:20; end

% == Cross-validate KNN
cvErr = ones(length(K_range), 1); % cross-validation errors
for k = 1:length(K_range)
    cvmodel = ClassificationKNN.fit(U',Ltrain,'NumNeighbors',K_range(k),'KFold',10);
    cvErr(k) = kfoldLoss(cvmodel);
end
[~,optIdx] = min(cvErr); K_opt = K_range(optIdx);

% == Train KNN with cross-validated NumNeighbors
model = ClassificationKNN.fit(U',Ltrain,'NumNeighbors',K_opt);

[Lpred2,~,~] = predict(model,U');
knnErr = sum(Ltrain~=Lpred2) / length(Ltrain);