function [model_opt, svmErr, C_opt] = FuncTrainSVM_linear_C(U,Ltrain)
% == Train SVM with LIBSVM, cross validation
% linear kernel, tuning C.

% Cross validation, log-scale search
%C = 2 .^ (-5:2:15); % 11 values
C = 2 .^ (-5:2:8); % 7 values
accuracy = svm_linear_wrap( C, U', Ltrain );

% Cross validation, fine-scale search
[~,ind] = max(accuracy(:));

Cnew = 2 .^ ( log2(C(ind)) + (-2:0.25:2) );
acc = svm_linear_wrap( Cnew, U', Ltrain );

% Get best model and training error
[~,ind] = max(acc(:));
C_opt = Cnew(ind);

model_opt = svmtrain( Ltrain, U', ['-q -t 0 -h 0 -c ' num2str(C_opt)] );
svmErr = 1 - max(acc)/100; % Best CV error


function accuracy = svm_linear_wrap(C, X, Y)
% X:    numSampTrain * featDim
% Y:    numSampTrain * 1

% gamma = numel(Y)/numel(X); % repcical of # attributes.

accuracy = zeros(length(C), 1);

for i = 1:length(C)
    accuracy(i,1) = svmtrain( Y, X, ['-q -t 0 -h 0 -v 5 -c ' num2str(C(i))] );
end
