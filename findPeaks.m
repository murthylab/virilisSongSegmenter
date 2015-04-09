function [peaks,maxIdx,amps,obj,posts] = findPeaks(P,noiseProbs,segmentParameters)

    numToSample = 10000;
    numPeaks = 2;
    replicates = 3;

    %amps = gaussianfilterdata(sum(P,2),segmentParameters.smoothParameter_amplitudes);
    amps = sum(P,2);
    obj = gmixPlot(sampleFromMatrix(log(amps)./log(10),numToSample),numPeaks,[],[],true,[],[],[],replicates);
    posts = posterior(obj,log(amps)./log(10));
    [~,minIdx] = min(obj.mu);
    posts = posts(:,minIdx);
    
    %amps(posts > segmentParameters.amplitudeThreshold) = 0;
    amps(noiseProbs >= segmentParameters.noiseThreshold) = 0;
    %amps(noiseLikelihoods > segmentParameters.noiseLikelihoodThreshold) = 0;
    
    maxIdx = find(imregionalmax(amps) & amps > 0);
    minIdx = find(imregionalmin(amps));
    
    L = length(maxIdx);
    peaks = cell(L,1);
    parfor i=1:L
        a = find(minIdx>maxIdx(i),1,'first');
        b = find(minIdx<maxIdx(i),1,'last');
        peaks{i} = minIdx(b):minIdx(a);
    end
    
