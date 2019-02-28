function svmErr = FuncClassifySVM(model,Utest,Ltest)

% === NOTE: 'svmpredict' doesn't take zero-imputation as a default pre-step,
% ===  so the below line of code is necessary.
nanIdx = isnan(Utest); Utest(nanIdx) = 0;

%Lpred = svmpredict(Ltest, Utest', model);
Utest = Utest'; [~,Lpred] = evalc('svmpredict(Ltest, Utest, model)');

svmErr = sum(Ltest~=Lpred) / length(Ltest);
fprintf('SVM: Accuracy = %.4f%%\n',(1-svmErr)*100);
