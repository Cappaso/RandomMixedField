function [X,Y] = FuncAddNoise(U,V,sigma2,varphi,param,mask)
% Function to add AWGN/impulsive to cont/disc nodes defined by mask
%
% U, V:     Cont/Disc sample matrix, contNodeNum/discNodeNum * allSampSize
% sigma2:   additive white Gaussian noise variance.
% varphi:   impulsive flipping parameters, one cell for each node.
% param:    graphical parameters
% mask:     define which samples/instances and which nodes/variables are to be corrupted.
%       structure, mask.samp, mask.cont, mask.disc
%
% Version:  04/04/2015

if nargin == 5; mask = []; end

X = U;
Y = V;

if isempty(mask) % add noise to all nodes of all samples as default.
    for idx = 1:size(V,2)
        X(:,idx) = mvnrnd(U(:,idx), diag(sigma2.*ones(param.contNodeNum,1)), 1);
        for j = 1:param.discNodeNum
            probVec = exp( varphi{j}(:, V(j,idx)) ); % energy --> prob
            probVec = probVec / sum(probVec); % normalization
            Y(j,idx) = find(mnrnd(1,probVec));
        end
    end
else % add noise to masked nodes and samples.
    contSel = zeros(param.contNodeNum,1);
    contSel(mask.cont) = 1;
    for idx = 1:length(mask.samp)
        if sum(contSel)
            X(:,idx) = mvnrnd(U(:,idx), diag(sigma2.*contSel), 1);
        end
        for j = mask.disc
            probVec = exp( varphi{j}(:, V(j,idx)) ); % energy --> prob
            probVec = probVec / sum(probVec); % normalization
            Y(j,idx) = find(mnrnd(1,probVec));
        end
    end
end
