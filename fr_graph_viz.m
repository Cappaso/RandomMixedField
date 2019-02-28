function [coordinates, disps] = fr_graph_viz(A,labels,display,width,height,threshold,maxIterations,fixNodePos)
%
% Author: Scott White
% Uses Fruchterman-Rheingold force-directed layout algorithm to visualize a graph
%
% INPUTS:
%       A: n x n (possibly sparse and/or weighted) adjacency matrix
%       width: width of figure
%       height: height of figure
%       threshold: total displacement (over previous iteration) threshold. If the total displacement for a given
%       iteration exceeds this threshold, the algorithm will stop.
%       maxIterations: maximum number of iterations to iterate over. If this is reached, the algo. will stop.
%
% OUTPUTS:
%       coordinates: final coordinates vertices computed
%       lcoordinates: final coordinates of labels computed
%       disps: total change in displacement for each iteration


[n,m] = size(A);
if n ~= m
 error('Matrix should be square');
end

if nargin < 2 | length(labels) < 2
    labels = {};
    for i=1:n
        labels{i} = sprintf('%d',i);
    end
end

if nargin < 3
    display = 1
end

if nargin < 4
    height = 800;
    width = 800;
end

if nargin < 6
    threshold = .1*n;
end

if nargin < 7
    maxIterations = 200;
end


coordinates = zeros(n,2);
isfixed = zeros(n,1);
%initialize coordinates
for i=1:n
    coordinates(i,1) = rand*width;
    coordinates(i,2) = rand*height;   
end

if nargin == 8
    idxs = fixNodePos(:,1);
    isfixed(idxs) = 1;
    coordinates(idxs,1) = fixNodePos(:,2)*width;
    coordinates(idxs,2) = fixNodePos(:,3)*height;
end

forceConstant = 0.75*sqrt(height*width/n);
temperature = width / 10;
currentIteration = 1;
epsilon = 0.000001;

total_disp = 100000000000;
disps = [];

while and(currentIteration < maxIterations,total_disp > threshold)
    
    displacement = zeros(n,2);
    
    %calculate repulsions
    for i=1:n
        for j=1:n
            if i ==j  
                continue
            end
            delta = coordinates(i,:) - coordinates(j,:);
            deltaLen = max(epsilon,norm(delta));
            repulsionForce = (forceConstant^2)/deltaLen;
            displacement(i,:) = displacement(i,:) + delta/deltaLen*repulsionForce;
        end
    end
    
    %calculate attractions
    for u=1:n
        edges = find(A(u,:));
        numEdges = length(edges);
        for j=1:numEdges
            v = edges(j);
            delta = coordinates(u,:) - coordinates(v,:);
            deltaLen = max(epsilon,norm(delta));            
            attractionForce = (deltaLen^2)/forceConstant;
            displacement(u,:) = displacement(u,:) - delta/deltaLen*attractionForce;
            displacement(v,:) = displacement(v,:) + delta/deltaLen*attractionForce;
        end
    end
    
    %compute positions
    total_disp = 0;
    for i=1:n
        if isfixed(i)
            continue;
        end;
        deltaLen = max(epsilon,norm(displacement(i,:)));
        newDisp = displacement(i,:)/deltaLen*min(deltaLen,temperature);
        total_disp = total_disp + abs(norm(newDisp));
        coordinates(i,:) = coordinates(i,:) + newDisp;
        
        borderWidth = width/25.0;
        
        newXPos = coordinates(i,1);
        if newXPos < borderWidth
            newXPos = borderWidth + rand*borderWidth*2.0;
        elseif newXPos > (width - borderWidth)
            newXPos = width - borderWidth - rand*borderWidth*2.0;
        end
        coordinates(i,1) = newXPos;
        
        newYPos = coordinates(i,2);
        if newYPos < borderWidth
            newYPos = borderWidth + rand*borderWidth*2.0;
        elseif newYPos > (height - borderWidth)
            newYPos = height - borderWidth - rand*borderWidth*2.0;
        end
        coordinates(i,2) = newYPos;
    end
    disps = [disps total_disp];
    
    %cool
    temperature = temperature * (1 - currentIteration / 700);
    currentIteration = currentIteration + 1;
    
    %used for debugging
    status = sprintf('# Iterations: %d Total Displacement: %f\n',currentIteration,total_disp);
    
    if display
     newplot 
     axis([1,width,1,height])
     set(gca,'xtick',[])
     set(gca,'ytick',[])
     hold on;
     gplot(A,coordinates,'g');
     set(findobj('Type','line'),'Color',[.9 .9 .9]);
     set(findobj('Type','line'),'LineWidth',1.5);
     v1 = coordinates(:,1);
     v2 = coordinates(:,2);
     plot(v1',v2','g.','MarkerSize',16);
     text(1,1,status,'fontsize',8);
     hold off;
     pause(0.001);
    end
    
end

if display
 newplot
 hold on;
 set(gca,'xtick',[])
 set(gca,'ytick',[])
 gplot(A,coordinates,'b');
 set(findobj('Type','line'),'Color',[.9 .9 .9]);
 set(findobj('Type','line'),'LineWidth',1.5);
 v1 = coordinates(:,1);
 v2 = coordinates(:,2);
 plot(v1',v2','r.','MarkerSize',16);
 scale = 5; 
 for i = 1:length(labels)
     label = labels(i);
     %text(v1(i),v2(i),label,'fontsize',8);
     text(v1(i)+scale*rand,v2(i)+sign(randn)*scale*rand,label,'fontsize',8);
 end
 hold off;
end

     