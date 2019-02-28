function [ sigma2,varphi,param ] = FuncParamSetting( canoParam, L, noiseRatio, U )
% Function to set noise and inference params of Random Mixed Field models
%
% canoParam:    params that define the generic RMF prior.
% L:    cardinality of each discrete node
% noiseRatio:   strength of noise.
% U:    Disc sample matrix, contNodeNum * testSampSize
%
% Version:  10/04/2015

param.maxSampNum = 1000;        % number of trial samples
param.discNodeCard = L;         % cardinality of each discrete node
param.discNodeNum = length(L);          % number of discrete nodes
param.contNodeNum = size(canoParam.B,1);% number of continuous nodes
param.contSignalSigma = std(U,0,2);     % std of cont signal.
                                        % eg: [0.1799; 0.1347; 0.17; 0.1222]
param.tol = 1e-4;           % tolerance ratio
param.delta = 1e-5;         % gradient step size
param.maxIterEM = 5000;		% maximum EM iterations
param.maxIterMF = 10;		% maximum Mean-Field approximation iterations
param.maxIterGA = 1;		% maximum gradient ascent steps
param.Adj = GetAdjFromParam(canoParam, 1e-8);

nStates = param.discNodeCard;

% Avoid unpleasant numerical instability.
if isequal(noiseRatio, [0 0]); noiseRatio = [0.000001, 0.000001]; end

% Avoid unpleasant zero contSignalSigma.
idx = (param.contSignalSigma == 0);
if sum(idx); param.contSignalSigma(idx) = 0.0001; end

% ==== Param Gaussian noise to cont nodes.
sigma = noiseRatio(1) * param.contSignalSigma; sigma2 = sigma .* sigma;

% ==== Param of impulsive noise to disc nodes.
prob = 1 - noiseRatio(2); varphi = cell(param.discNodeNum,1);
for j = 1:param.discNodeNum
	varphi{j} = log( diag( (prob - (1-prob)/(nStates(j)-1)) * ones(nStates(j),1) )...
		+ ones(nStates(j), nStates(j)) * (1-prob)/(nStates(j)-1) ); % prob --> energy.
end

end

