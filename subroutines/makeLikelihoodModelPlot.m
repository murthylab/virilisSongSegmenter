function outputStats = makeLikelihoodModelPlot(likelihoodModels,confidenceInterval,numSamples)

    maleColors = 'bc'; %blue and cyan
    femaleColors = 'rm'; %red and magenta
    bothColors = 'gg'; %dark and light green
    noiseColors = 'kg'; %black and gray
    
    probModes = likelihoodModels.probModes;
    numFreqs = length(likelihoodModels.frequencies);
    freqs = likelihoodModels.frequencies;
    
    
    if ~isempty(likelihoodModels.coeffs_male)
        
        fprintf(1,'Processing Male PDF Models\n');
        
        randNums = rand(numSamples,probModes);
        malePDFs = likelihoodModels.malePDFs;
        for i=1:probModes     
            
            
            q = zeros(numSamples,1);
            a = malePDFs{i};
            parfor j=1:numSamples
                f = @(x) cdf(a,x) - randNums(j,i);
                q(j) = fzero(f,0);
            end
            
            randNums(:,i) = q;
            
        end
        
        
        currentSamples = repmat(likelihoodModels.male_mean,numSamples,1);
        maleCoeffs = likelihoodModels.coeffs_male;
        parfor i=1:numSamples
            
            x = currentSamples(i,:);
            y = randNums(i,:);
            
            
            for j=1:probModes
                x = x + y(j)*maleCoeffs(:,j)';
            end
            
            currentSamples(i,:) = x;
                        
        end
        
        outputStats.currentSamples = currentSamples;
        outputStats.medianMale = median(currentSamples);
        dx = (1-confidenceInterval)/2;
        outputStats.maleBounds = quantile(currentSamples,[dx,1 - dx]);
        
        
        
%         area([freqs fliplr(freqs) freqs(1)],[outputStats.maleBounds(1,:) flipud(outputStats.maleBounds(2,:)) outputStats.maleBounds(1,1)],'color','c')
%         hold on
%         plot(freqs,outputStats.medianMale,'b-','linewidth',2)
%         
%         drawnow;
%         keyboard
        
        clear randNums maleCoeffs currentSamples
        
        
    end