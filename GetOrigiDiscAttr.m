function V = GetOrigiDiscAttr(D,L)
% Input: L, levels in each categorical variable.
%        D, sum(L) * sampSize, dummy (almost) binary matrix,
%        For each column in Di, we apply one-hot decoding.
%
% Output: V, discNodeNum * sampSize, real discrete attributes data.

V = zeros( length(L), size(D,2) );

Ltot = [0; cumsum(L)];

for i = 1:length(L)
    Di = D(Ltot(i)+1:Ltot(i+1), :);
    
    % one-hot decoding
    [~, Row_i] = max(Di,[],1); % find max entry of each column
    Ind_i = sub2ind(size(Di), Row_i, [1:size(Di,2)]);
    Di_ = zeros(size(Di)); Di_(Ind_i) = 1;
    
    V(i,:) = [1:L(i)] * Di_;
end