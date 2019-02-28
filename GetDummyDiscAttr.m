function D = GetDummyDiscAttr(V,L)
% Input: V, discNodeNum * sampSize, real discrete attributes data.
%        L, levels in each categorical variable.
%
% Output: D, sum(L) * sampSize, dummy binary matrix,
%         To get each column of Di, we apply one-hot encoding.

D = [];
sampRange = 1:size(V,2);

for i = 1:size(V,1)
    Di = zeros(L(i), size(V,2));
    
    nanIdx = isnan( V(i,:) );
    if ~sum(nanIdx(:))
        Ind_i = sub2ind(size(Di), V(i,:), sampRange);
        Di(Ind_i) = 1;
    else
        Ind_i = sub2ind(size(Di), V(i, ~nanIdx), sampRange(~nanIdx));
        Di(Ind_i) = 1;
        
        ix = repmat( [1:L(i)]', [1,sum(nanIdx)] );
        iy = repmat( sampRange(nanIdx), [L(i),1] );
        Ind_i = sub2ind(size(Di), ix, iy);
        Di(Ind_i) = NaN;
    end
    
    D = [D; Di];
end