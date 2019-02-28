function dat = missForest_wrap(X,Y)
% Function to call r from matlab using BATCH mode
% This is achieved by reading/writing disk files.
% X, Y: n*p1, n*p2

p1 = repmat({'cont'},1,size(X,2));
p2 = repmat({'disc'},1,size(Y,2));
headers = {p1{:}, p2{:}};
csvwrite_with_headers('missForest/temp_in.csv', [X,Y], headers);
eval('!R CMD BATCH missForest/script.R')
dat = csvread('missForest/temp_out.csv', 1, 1);