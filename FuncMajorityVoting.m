function y = FuncMajorityVoting( x )
% Function to get the majority label
%
% x:    N*1 vector of labels
% y:    majority label
%
% Version:  10/04/2015

[x_uni, uni_idx] = unique( sort(x) );
count = diff( [uni_idx; length(x)+1] ); % number of unique labels

[~, max_idx] = max(count);

y = x_uni(max_idx);

end

