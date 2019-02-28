function US = GetScaledContAttr(U,trainParam)
% U:	discNodeNum * sampSize, real discrete attributes data.
% trainParam:    discNodeNum * 1, ranges of each cont variable.
%
% US:	discNodeNum * sampSize, scaled to [0,1].

U = max( U, repmat(trainParam.Min,[1,size(U,2)]) );
U = min( U, repmat(trainParam.Max,[1,size(U,2)]) );
US = ( U - repmat(trainParam.Min,[1,size(U,2)]) ) ./ repmat(trainParam.Rng,[1,size(U,2)]);