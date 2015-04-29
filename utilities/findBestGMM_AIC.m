function [obj,AICs] = findBestGMM_AIC(data,maxPeaks,replicates,maxNum)

    addpath(genpath('./argmax_argmin'))
    if nargin < 3 || isempty(replicates)
        replicates = 1;
    end

    
    N = length(data(:,1));
    if nargin < 4 || isempty(maxNum)
        maxNum = N;
    end
    
    if maxNum < N
        idx1 = randperm(N); %kelly fix for debug
        idx = idx1(1:maxNum);
        data = data(idx,:);
    end
    
    
    AICs = zeros(maxPeaks,1);
    objs = cell(maxPeaks,1);
    for i=1:maxPeaks
        %objs{i} = gmdistribution.fit(data,i,'Options',options,'Replicates',replicates,'Regularize',1e-30);
        objs{i} = gmixPlot(data,i,[],[],true,[],[],[],replicates);
        AICs(i) = objs{i}.AIC;
    end
    
    minIdx = argmin(AICs);
   
    
    obj = objs{minIdx};