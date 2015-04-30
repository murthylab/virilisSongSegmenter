function [noiseModel,obj,posts,threshold,idx] = findNoiseModel(P,amps,segmentParameters)
%Generates noise likelihood model from data
%Inputs:
%   P -> wavelet transform of data 
%   amps -> wavelet amplitudes
%   segmentParameters -> struct containing run parameters
%
%Output:
%   noiseModel -> struct containing noise likelihood model information
%   obj -> amplitude gaussian mixture model output
%   posts -> posterior probabilities for noise model based on GMM
%   threshold -> amplitude threshold for noise calls
%   idx -> regions chosen to model noise behavior
%
% (C) Gordon J. Berman, Jan Clemens, Kelly M. LaRue, and Mala Murthy, 2015
%     Princeton University

    fprintf(1,'Creating Noise Model...\n');
    
    ampsToTest = 50000;
    maxNumGMM = 10000;
    replicates = 3;
    gmm_replicates = 3;
    
    ampPostThreshold = segmentParameters.ampPostThreshold;
    maxNumNoise = segmentParameters.maxNumNoise;
    probModes = segmentParameters.probModes;
    maxNumPeaks = segmentParameters.maxNumPeaks;
    maxNumPeaks_firstMode = segmentParameters.maxNumPeaks_firstMode;
    
    
    fprintf(1,'\t Finding Noise Selections\n');
    amps = gaussianfilterdata(amps,segmentParameters.smoothParameter_amplitudes);
    obj = gmixPlot(log(sampleFromMatrix(amps,ampsToTest))./log(10),2,[],1000,true,[],[],[],replicates);
    [~,minIdx] = min(obj.mu);
    meanValue = mean(obj.mu);
    
    posts = posterior(obj,log(amps)./log(10));
    posts = posts(:,minIdx);
    
    [sortVals,idx] = unique(log(amps)./log(10));
    qq = posts(idx);
    [sortVals,sortIdx] = sort(sortVals);
    f = fit(sortVals,qq(sortIdx),'linearinterp');
    threshold = fzero(@(x) f(x) - ampPostThreshold,meanValue);
    threshold = 10^threshold;
    
    idx = find(amps < threshold); 
    
    if length(idx) > maxNumNoise
        qq = randperm(length(idx)); 
        q = qq(1:maxNumNoise);
        P = P(idx(q),:);
    else
        P = P(idx,:);
    end
    
    fprintf(1,'\t Finding Noise PCA\n');
    noise_mean = mean(P);
    [coeffs_noise,scores_noise,latent_noise] = princomp(P);

    fprintf(1,'\t Finding Noise PDFs\n');
    noisePDFs = cell(probModes,1);
    parfor i=1:probModes    
        if i == 1
            q = maxNumPeaks_firstMode;
        else
            q = maxNumPeaks;
        end
        
        noisePDFs{i} = findBestGMM_AIC(scores_noise(:,i),q,gmm_replicates,maxNumGMM);     
    end
    
    
    clear P
    
    noiseModel.noisePDFs = noisePDFs;
    noiseModel.scores_noise = scores_noise;
    noiseModel.probModes = probModes;
    noiseModel.coeffs_noise = coeffs_noise;
    noiseModel.noise_mean = noise_mean;
    noiseModel.latent_noise = latent_noise;