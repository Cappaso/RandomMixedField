function [Xden,Yden] = FuncInferMixedNet(X,Y,canoParam,sigma2,varphi,param,mask)
% Function to denoise data in mixed-net structure
%
% X, Y:     noisy, Cont/Disc sample matrix, contNodeNum/discNodeNum * testSampSize
% sigma2:   additive white Gaussian noise variance.
% varphi:   impulsive flipping parameters, one cell for each node.
% param:    graphical parameters
% mask:     define which samples/instances and which nodes/variables are to be corrupted.
%   If mask ~= []; add noise as guided by mask.cont & mask.disc
%   If mask = []; add noise to all nodes (default)
%
% Version:  16/04/2015

if nargin == 6; mask = []; end

Xden = X;
Yden = Y;

nStates = param.discNodeCard;

NoiseTol = [0.000001, 0.000001];

% Pre-update noise param of cont nodes
ContNoiseInv = ones(param.contNodeNum,1) ./ sigma2;
if ~isempty(mask)
    contCleanRange = 1:param.contNodeNum;
    contCleanRange(mask.cont) = [];
    ContNoiseInv(contCleanRange) = 1 ./ NoiseTol(1)^2;
end

% Pre-update noise param of disc nodes
if ~isempty(mask)
    discCleanRange = 1:param.discNodeNum;
    discCleanRange(mask.disc) = [];
    % ==== Replace 'varphi' param of clean disc nodes with very small value.
    prob = 1 - NoiseTol(2);
    for j = discCleanRange
        varphi{j} = log( diag( (prob - (1-prob)/(nStates(j)-1)) * ones(nStates(j),1) )...
            + ones(nStates(j), nStates(j)) * (1-prob)/(nStates(j)-1) ); % prob --> energy.
    end
end

% Handle missing values
nanIdx = isnan(X(:));
if sum(nanIdx); X(nanIdx) = 0; end

nanIdx = isnan(Y(:));
if sum(nanIdx); Y(nanIdx) = 0; end

% ==== Construct node connections
edgeStruct = UGM_makeEdgeStruct(param.Adj.VV, nStates);

% ==== Initialization terms
for j = 1:param.discNodeNum
	temp = ones(nStates(j), 1);
	suffStats.discNodeMarginals{j,1} = temp ./ sum(temp(:));
end


for glbObsIdx = 1:size(X,2)
    % ==== Variational E-STEP using Mean Field approximation

    discNodeMarginals = suffStats.discNodeMarginals; % random initialization

    for iterMF = 1:param.maxIterMF
        % Inference moments of q(u)
        BHat = canoParam.B + diag( ContNoiseInv );
%         contCov = inv(BHat);

%         Eqv_rho = zeros(param.contNodeNum,1);
%         for j = 1:param.discNodeNum
%             temp = cell2mat(canoParam.rho(:,j)) * discNodeMarginals{j};
%             Eqv_rho = Eqv_rho + temp;
%         end
        Eqv_rho = cell2mat(canoParam.rho) * cell2mat(discNodeMarginals);
        
        gammaHat = canoParam.alpha + Eqv_rho + 1 * (X(:,glbObsIdx) .* ContNoiseInv);
        contMean = BHat \ gammaHat;

        % Inference marginals of q(v): a different factor graph
        nodePot = zeros(param.discNodeNum, max(nStates));
        for j = 1:param.discNodeNum
            if Y(j,glbObsIdx) == 0 % Consider missing data case. Updated by 27/02/2015.
                nodePot(j,1:nStates(j)) = diag(canoParam.phi{j,j})';
            else
                nodePot(j,1:nStates(j)) = varphi{j}(Y(j,glbObsIdx),:) + diag(canoParam.phi{j,j})';
            end
        end
        for s = 1:param.contNodeNum
            for j = 1:param.discNodeNum
                if param.Adj.UV(s,j) % cont node 's' is connected to disc node 'j'
                    nodePot(j,1:nStates(j)) = nodePot(j,1:nStates(j)) + contMean(s) .* canoParam.rho{s,j};
                end
            end
        end
        nodePot = exp( nodePot ); % NOTE: log potential --> potential

        edgePot = zeros(max(nStates), max(nStates), edgeStruct.nEdges);
        for j = 1:edgeStruct.nEdges    
            a = edgeStruct.edgeEnds(j,1);
            b = edgeStruct.edgeEnds(j,2);   
            edgePot(1:nStates(a), 1:nStates(b), j) = exp(canoParam.phi{a,b});
        end

        [nodeBelLBP,~,~] = UGM_Infer_LBP(nodePot,edgePot,edgeStruct);

        for j = 1:param.discNodeNum
            discNodeMarginals{j} = nodeBelLBP(j,1:nStates(j))';
        end

    end
    % Save denoised data
    Xden(:,glbObsIdx) = contMean;
    Yden(:,glbObsIdx) = UGM_Decode_LBP(nodePot,edgePot,edgeStruct);
	
% 	if ~mod(glbObsIdx,1000)
%         fprintf(sprintf( ['%d samples denoised...\n'], glbObsIdx ));
% 	end
end

% fprintf(sprintf(['%d samples denoised...\n'], size(X,2) ));

