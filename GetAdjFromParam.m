function Adj = GetAdjFromParam(canoParam, tol)
% Get adjacency matrix from the learned sparse params.

Adj.UU = logical( (canoParam.B - diag(diag(canoParam.B))) > tol);
Adj.UU = logical(Adj.UU + Adj.UU');
Adj.UV = logical( cellSum(canoParam.rho) > tol );
temp = cellSum(canoParam.phi);
Adj.VV = logical( (temp - diag(diag(temp))) > tol );
Adj.VV = logical(Adj.VV + Adj.VV');

function Y = cellSum(X)
if ~iscell(X)
    error('error....');
end

Y = zeros(size(X));
for i = 1:size(X,1)
    for j = 1:size(X,2)
        Y(i,j) = sum(sum( abs(X{i,j}) ));
    end
end