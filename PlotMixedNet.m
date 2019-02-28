function [hE,hV]=PlotMixedNet(Adj,coord,varargin)
%function [hE,hV]=PlotMixedNet(Adj,coord,varargin)
%
% Mixed-net Graph Plot from adjacency matrix [Adj] and vertices
% coordinate [coord].
%
% INPUT:
%    [Adj] = N x N sparse square adjacency matrix. 
%     [coord] = N x 2 matrix of vertex coordinates of the graph to be plotted.
%  [varargin] = are specified as parameter value pairs where the parameters are
%     'edgeColorMap' = m1 x 3 edge colormap for coloring edges by their 
%                      weight, {default=cool}
%        'edgeWidth' = scalar specifying the width of the edges. {default=0.1}
%     'vertexMarker' = single char, can be {.ox+*sdv^<>ph} as in plot {default='.'}
%   'vertexColorMap' = m2 x 3 vertex color map for coloring vertices by their
%                      weight, {default=summer}
%     'vertexWeight' = N x 1 vector of vertex weight that overrides using the
%                      diagonal of [adjMat] for specifying vertex size.
% OUTPUT:
%  [hE] = vector/scalar of handles to edges of the drawn graph (1 per color).
%  [hV] = scalar handles to vertices of the drawn graph.
% 
% SEE ALSO: wgPlot, gplot, treeplot, spy, plot
%
% By: Qiang Li  --  leetsiang.cloud@gmail.com (Nov. 2014)
% Modified @ 27/08/2015
%
%====================


% Set default parameter values
%--------------------
h = gca; prh; hold on; axis off;
axesArea(h,[6 7 5 5]);
plotParm={'lineWidth',0.1,'markerSize',6,'marker','.','MarkerEdgeColor',[1,0.5,0.2]};
sizU = size(Adj.UU);
sizV = size(Adj.VV);

edgeMap = [1 0 0; 0 0 0; 0.5,0.5,0.5]; % red, black, gray
vrtxMap.cont = hsv;
vrtxMap.cont = vrtxMap.cont(17:4:64,:); % select a subset
vrtxMap.disc = gray;
vrtxMap.disc = vrtxMap.disc(1:3:48,:); % select a subset


% Parse parameter value pairs
%--------------------
nVarArgin=length(varargin);
for kk=1:2:nVarArgin
	switch lower(varargin{kk})
        case 'edgecolormap'
            edgeMap = varargin{kk+1};
        case 'edgewidth'
            plotParm{2} = varargin{kk+1};
        case 'markersize'
            plotParm{4} = varargin{kk+1};
        case 'markertype'
            plotParm{6} = varargin{kk+1};
        case 'markeredgecolor'
            plotParm{8} = varargin{kk+1};
        case 'vertexcolormap'
            vrtxMap=varargin{kk+1};
        case 'vertexweight'
            vrtxWt=varargin{kk+1};
        case 'vertexrange'
            vrtxRg=varargin{kk+1};
        case 'vertexscale'
            vrtxSiz = varargin{kk+1};
        otherwise
            error(['wgPlot >< Unknown parameter ''',varargin{kk},'''.']) ;
	end
end


% Determine if diagonal is weighted.
%--------------------
if exist('vrtxWt','var')
  vWt = vrtxWt; % user-defined vertex weight
  vRg = vrtxRg; % user-defined vertex range
else
  vWt.cont = diag(Adj.UU);
  vWt.disc = diag(Adj.VV);
  vRg.cont(1) = min(vWt.cont);
  vRg.cont(2) = max(vWt.cont);
  vRg.disc(1) = min(vWt.disc);
  vRg.disc(2) = max(vWt.disc);
end
vWeighted.cont = length(setdiff(unique(vWt.cont),0))>1;
vWeighted.disc = length(setdiff(unique(vWt.disc),0))>1;


% Remove non-zero diagonal elements
%--------------------
if ~all(vWt.cont==0); Adj.UU(speye(sizU)~=0)=0; end
if ~all(vWt.disc==0); Adj.VV(speye(sizV)~=0)=0; end


% Map vertex weight to vertex colormap
%--------------------
if vWeighted.cont
  nvColor.cont = size(vrtxMap.cont,1);
  vWt.cont = ceil((nvColor.cont-1)*(vWt.cont-vRg.cont(1))/(vRg.cont(2)-vRg.cont(1))+1);
end

if vWeighted.disc
  nvColor.disc = size(vrtxMap.disc,1);
  vWt.disc = ceil((nvColor.disc-1)*(vWt.disc-vRg.disc(1))/(vRg.disc(2)-vRg.disc(1))+1);
end


% Plot 3 types of edges using different colors
%--------------------
% Continuous type
[ix,iy] = find(Adj.UU);
nSegment = length(ix);
x = [coord(ix,1),coord(iy,1),nan(nSegment,1)]';
y = [coord(ix,2),coord(iy,2),nan(nSegment,1)]';
hE = plot(x(:),y(:),'color',edgeMap(1,:),plotParm{:});

% Discrete type
[ix,iy] = find(Adj.VV);
ix = ix + sizU(1); iy = iy + sizU(1);
nSegment = length(ix);
x = [coord(ix,1),coord(iy,1),nan(nSegment,1)]';
y = [coord(ix,2),coord(iy,2),nan(nSegment,1)]';
hE = [hE,plot(x(:),y(:),'color',edgeMap(2,:),plotParm{:})];

% Mixed type
[ix,iy] = find(Adj.UV);
iy = iy + sizU(1);
nSegment = length(ix);
x = [coord(ix,1),coord(iy,1),nan(nSegment,1)]';
y = [coord(ix,2),coord(iy,2),nan(nSegment,1)]';
hE = [hE,plot(x(:),y(:),'color',edgeMap(3,:),plotParm{:})];


% Plot vertices
%--------------------
if vWeighted.cont
  for kk = 1:nvColor.cont
    idx = find(vWt.cont==kk);
    hV = scatter(coord(idx,1),coord(idx,2),vrtxSiz,'filled','MarkerFaceColor',vrtxMap.cont(kk,:));
  end
end

if vWeighted.disc
  for kk = 1:nvColor.disc
    idx = find(vWt.disc==kk) + sizU(1); % NOTE: add sizU(1).
    hV = [hV,scatter(coord(idx,1),coord(idx,2),vrtxSiz,'filled','MarkerFaceColor',vrtxMap.disc(kk,:))];
  end
end


% Set axes
%--------------------
axis tight;
ax=axis;
dxRange=(ax(2)-ax(1))/500;
dyRange=(ax(4)-ax(3))/500;
axis([ax(1)-dxRange,ax(2)+dxRange,ax(3)-dyRange,ax(4)+dyRange]);



function H=prh(H)
%function H=prh(H)
%
% sets the current figure to print on full page in LANDSCAPE mode.
%
% By Michael Wu  --  waftingpetal@yahoo.com (Oct 2001)
%
% ====================

if ~exist('H','var');
  H = gcf;
end;

papMarg=0.1;
set(H,'PaperOrientation','landscape','PaperPosition',[0+papMarg, 0+papMarg, 11-2*papMarg, 8.5-2*papMarg]);


function [hAx]=axesArea(varargin)
%function [hAx]=axesArea(hAx,varargin)
%
% Set the margine of the axis by specifying a vector of distance to the figure edges.
%
% Input:
%  [varargin=hAx] = axis handle
%    [varargin=p] = position spec: 1, 2 or 4 element vector that specify the distance 
%                   from the edges of the figure by a percentage number between (0-49). 
%                   If 1 element it is used for all margins. 
%                   If 2 elements, p=[x-margins, y-margins].
%                   If 4 elements, p=[left, lower, right, upper] margins.
% Output:
%  [hAx] = axis handle of the axes.
%
% See also: axis, axes, ishandle, set
%
% By: Michael Wu  --  michael.wu@lithium.com (Mar 2009)
%
%====================


% Check if 1st input is axis handle
%--------------------
if ishghandle(varargin{1},'axes')
	hAx=varargin{1};
	p=varargin{2};
else
	hAx=gca;
	p=varargin{1};
end


% Process input arguments
%--------------------
p(p<0)=0;
p(p>49)=49;
p=p/100;


% Compute position property to be set
%--------------------
switch length(p)
	case 1
		xmin=p;
		ymin=xmin;
		xlen=1-2*p;
		ylen=xlen;
	case 2
		xmin=p(1);
		ymin=p(2);
		xlen=1-2*p(1);
		ylen=1-2*p(2);
	case 4
		xmin=p(1);
		ymin=p(2);
		xlen=1-p(1)-p(3);
		ylen=1-p(2)-p(4);	
	otherwise
		% Default Matlab position setting
		%--------------------
		xmin=0.13;
		ymin=0.11;
		xlen=0.775;
		ylen=0.815;	
end


% Set new position property of the axes
%--------------------
set(hAx,'position',[xmin ymin xlen ylen]);





