function [probs,likelihoods,noiseP,P,CCs] = findProbabilities_wavelet(data,likelihoodModels,noiseModel,segmentParameters,plotsOn,plotData)


    if nargin < 4 || isempty(plotsOn)
        plotsOn = true;
    end
    
    
    probModes = segmentParameters.probModes;
    crossLikelihoodPDFs = likelihoodModels.crossLikelihoodPDFs;

    smoothParameter_male = segmentParameters.smoothParameter_male;
    smoothParameter_female = segmentParameters.smoothParameter_female;
    %noise_threshold = .05;
    
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
    
    %     tempLikelihoods = zeros(N,probModes);
    %
    %     parfor i=1:probModes
    %         tempLikelihoods(:,i) =
    %         log(pdf(malePDFs{i},dataScores_male(:,i)));B
    %     end
    %     likelihoods(:,1) = sum(tempLikelihoods,2);
    %
    %     parfor i=1:probModes
    %         tempLikelihoods(:,i) = log(pdf(femalePDFs{i},dataScores_female(:,i)));
    %     end
    %     likelihoods(:,2) = sum(tempLikelihoods,2);
    %
    %     parfor i=1:probModes
    %         tempLikelihoods(:,i) = log(pdf(noisePDFs{i},dataScores_noise(:,i)));
    %     end
    %     likelihoods(:,3) = sum(tempLikelihoods,2);
    %
    %     parfor i=1:probModes
    %         tempLikelihoods(:,i) = log(pdf(bothPDFs{i},dataScores_both(:,i)));
    %     end
    %     likelihoods(:,4) = sum(tempLikelihoods,2);
    %
    %     clear tempLikelihoods
    
    
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
    
    %probs(:,1) = gaussianfilterdata(probs(:,1),smoothParameter_male);
    %probs(:,2) = gaussianfilterdata(probs(:,2),smoothParameter_female);
    %probs(:,3) = gaussianfilterdata(probs(:,3),smoothParameter_female);
    
    probs = bsxfun(@rdivide,probs,sum(probs,2));
    
    if segmentParameters.usePDFProjections
        probs = CalculateProbs_PDF_Projection(likelihoods,crossLikelihoodPDFs,probs(:,3));
    end
    
    if plotsOn || nargout == 5
        
        probs2 = probs(:,1:3);
        probs2(:,1) = probs2(:,1) + probs(:,4);
        
        [~,maxIdx] = max(probs2,[],2);
        
        
        CC_male = largeBWConnComp(maxIdx == 1 | maxIdx == 4,min_male_length);
        CC_female = largeBWConnComp(maxIdx == 2,min_female_length);
        %CC_both = largeBWConnComp(maxIdx == 4,min_female_length);
        
        CCs = {CC_male,CC_female};
        
        figure
        
        subplot(2,1,1)
        hold on
        for i=1:length(CC_male.PixelIdxList)
            rectangle('Position',[CC_male.PixelIdxList{i}(1) -1 length(CC_male.PixelIdxList{i}) 2],'facecolor','b','edgecolor','b');
        end
        for i=1:length(CC_female.PixelIdxList)
            rectangle('Position',[CC_female.PixelIdxList{i}(1) -1 length(CC_female.PixelIdxList{i}) 2],'facecolor','r','edgecolor','r');
        end
        %for i=1:length(CC_both.PixelIdxList)
        %    rectangle('Position',[CC_both.PixelIdxList{i}(1) -1 length(CC_both.PixelIdxList{i}) 2],'facecolor','g','edgecolor','g');
        %end
        
        plot(data,'k-')
                
        ylim([-.3 .3])
        
        %subplot(3,1,2)
        %imagesc(1:length(P(:,1)),likelihoodModels.frequencies,P');set(gca,'ydir','normal')
        
        
        subplot(2,1,2)
        plot(probs(:,1)+probs(:,4),'bo-');
        hold on
        plot(probs(:,2),'rs-');
        plot(probs(:,3),'k^-');
        %plot(probs(:,4),'gp-');
        ylim([-.02 1.02])
    end
