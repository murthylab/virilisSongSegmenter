function [probs,likelihoods,noiseP,P,CCs] = ...
    findProbabilities_wavelet(data,likelihoodModels,noiseModel,...
                                segmentParameters,plotsOn,plotData)
%Find posterior probabilities for wavelet data from likelihood models
%Inputs:
%   data -> 1d time series or num_time_points x length(frequencies) array of wavelet data
%           (wavelets performed in the case of the former, but not the latter)
%   likelihoodModels -> fitted likelihood models from 
%                   find_songs_from_hand_annotation.m (default:exampleLikelihoodModels)
%   noiseModel -> fitted noise likelihood model
%   segmentParameters -> struct containing parameters
%   plotsOn -> true if plot are desired (default = true)
%   plotData -> 1d song data to plot (only used if plotsOn = true)
%
%Outputs:
%   probs -> Nx4 array of posterior probabilities
%   likelihoods -> Nx4 array of log likelihood scores
%   noiseP -> probabilities that a particular point belongs to the noise
%               model
%   P -> wavelet amplitudes
%   CCs -> connected components from male and female data (only if plotsOn = true)
%
% (C) Gordon J. Berman, Jan Clemens, Kelly M. LaRue, and Mala Murthy, 2015
%     Princeton University

    if nargin < 4 || isempty(plotsOn)
        plotsOn = true;
    end
    
    
    probModes = segmentParameters.probModes;

    smoothParameter_male = segmentParameters.smoothParameter_male;
    smoothParameter_female = segmentParameters.smoothParameter_female;
    
    min_male_length = 1;
    min_female_length = 1;

    malePDFs = likelihoodModels.malePDFs;
    femalePDFs = likelihoodModels.femalePDFs;
    noisePDFs = noiseModel.noisePDFs;
    bothPDFs = likelihoodModels.bothPDFs;
       
    male_mean = likelihoodModels.male_mean;
    female_mean = likelihoodModels.female_mean;
    noise_mean = noiseModel.noise_mean;
    both_mean = likelihoodModels.both_mean;
       
    coeffs_male = likelihoodModels.coeffs_male;
    coeffs_female = likelihoodModels.coeffs_female;
    coeffs_noise = noiseModel.coeffs_noise;
    coeffs_both = likelihoodModels.coeffs_both;
    
        
    
    s = size(data);
    if min(s) == 1
        fprintf(1,'Performing Wavelet Transform\n');
        scales = likelihoodModels.scales;
        wav = 'fbsp2-1-2';
        C = cwt(data,scales,wav);
        P = C'.*conj(C');
        clear C;
    else
        P = data;
        if plotsOn && nargin == 5
            data = plotData;
        end
    end
    
    N = length(P(:,1));
    

    fprintf(1,'Calculating Projections\n');
    dataScores_male = bsxfun(@minus,P,male_mean) * coeffs_male(:,1:probModes);
    dataScores_female = bsxfun(@minus,P,female_mean) * coeffs_female(:,1:probModes);
    dataScores_noise = bsxfun(@minus,P,noise_mean) * coeffs_noise(:,1:probModes);
    dataScores_both = bsxfun(@minus,P,both_mean) * coeffs_both(:,1:probModes);
    
    
    fprintf(1,'Finding Likelihoods\n');
    likelihoods = zeros(N,4);

    for i=1:probModes
        
        likelihoods(:,1) = likelihoods(:,1) + log(pdf(malePDFs{i},dataScores_male(:,i)));
        likelihoods(:,2) = likelihoods(:,2) + log(pdf(femalePDFs{i},dataScores_female(:,i)));
        likelihoods(:,3) = likelihoods(:,3) + log(pdf(noisePDFs{i},dataScores_noise(:,i)));
        likelihoods(:,4) = likelihoods(:,4) + log(pdf(bothPDFs{i},dataScores_both(:,i)));
        
    end

    
    fprintf(1,'Computing Probabilities\n');
    maxVal = max(likelihoods(~isnan(likelihoods) & ~isinf(likelihoods)));
    minVal = min(likelihoods(~isnan(likelihoods) & ~isinf(likelihoods)));
    likelihoods(isnan(likelihoods) | isinf(likelihoods)) = minVal;
    
    if smoothParameter_male > 1
        likelihoods(:,1) = gaussianfilterdata(likelihoods(:,1),smoothParameter_male);
        likelihoods(:,4) = gaussianfilterdata(likelihoods(:,4),smoothParameter_male);
    end
    
    if smoothParameter_female > 1
        likelihoods(:,2) = gaussianfilterdata(likelihoods(:,2),smoothParameter_female);
        likelihoods(:,3) = gaussianfilterdata(likelihoods(:,3),smoothParameter_female);
    end
    
    probs = exp(likelihoods-maxVal);
    partition = sum(probs,2);
    probs = bsxfun(@rdivide,probs,partition);
    
    sumProbs = sum(probs)./N;
    
    maxVals = max(likelihoods,[],2);
    subLikes = exp(bsxfun(@minus,likelihoods,maxVals));
    partition = zeros(N,1);
    for i=1:4
        partition = partition + subLikes(:,i)*sumProbs(i);
    end
    
    probs = bsxfun(@rdivide,bsxfun(@times,subLikes,sumProbs),partition);
    noiseP = probs(:,3);

    
    probs = bsxfun(@rdivide,probs,sum(probs,2));

    
    if plotsOn || nargout == 5
        
        probs2 = probs(:,1:3);
        probs2(:,1) = probs2(:,1) + probs(:,4);
        
        [~,maxIdx] = max(probs2,[],2);
        
        
        CC_male = largeBWConnComp(maxIdx == 1 | maxIdx == 4,min_male_length);
        CC_female = largeBWConnComp(maxIdx == 2,min_female_length);
        
        CCs = {CC_male,CC_female};
        
        figure
        
        subplot(2,1,1)
        hold on
        for i=1:length(CC_male.PixelIdxList)
            rectangle('Position',...
                [CC_male.PixelIdxList{i}(1) -1 length(CC_male.PixelIdxList{i}) 2],...
                'facecolor','b','edgecolor','b');
        end
        
        for i=1:length(CC_female.PixelIdxList)
            rectangle('Position',...
                [CC_female.PixelIdxList{i}(1) -1 length(CC_female.PixelIdxList{i}) 2],...
                'facecolor','r','edgecolor','r');
        end
        
        plot(data,'k-')
                
        ylim([-.3 .3])
        
        
        
        subplot(2,1,2)
        plot(probs(:,1)+probs(:,4),'bo-');
        hold on
        plot(probs(:,2),'rs-');
        plot(probs(:,3),'k^-');
        ylim([-.02 1.02])
    end
