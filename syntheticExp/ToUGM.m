%% only supports the same number of states for all discrete vars
function  [nodePot, edgePot, edgeStruct] = ToUGM(maskMarg, edgePotMarg,nstates)
[n gar] = size(maskMarg);
maskMarg=maskMarg+maskMarg';
edgeStruct = UGM_makeEdgeStruct((maskMarg - diag(diag(maskMarg)))~=0, nstates);
%%
nodePot=zeros(n,nstates);
for i = 1:n
    if maskMarg(i,i)~=0
        nodePot(i, :) = exp(diag(edgePotMarg{i,i}));
    else
        nodePot(i,:) = 0;
    end
end
%%
edgePot = zeros(nstates, nstates, edgeStruct.nEdges);
for j = 1:edgeStruct.nEdges    
    a = edgeStruct.edgeEnds(j,1);
    b = edgeStruct.edgeEnds(j,2);   
    edgePot(:, :, j) = exp(edgePotMarg{a,b});
end


