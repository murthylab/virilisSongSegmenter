function [maleBoutInfo,femaleBoutInfo,run_data] = segmentVirilisSong(data,likelihoodModels,samplingFrequency)

    addpath('utilities');
    addpath('subroutines');

    if nargin < 2 || isempty(likelihoodModels)
        load('exampleLikelihoodModels.mat','likelihoodModels');
    end
    
    if nargin < 3 || isempty(samplingFrequency)
        samplingFrequency = 1e4;
    end 
    
    %initialize parameters
    segmentParameters = params_virilis(samplingFrequency);
    N = length(data);
    maleTestDuration = segmentParameters.maleTestDuration;
    
    
    wvlt = 'fbsp2-1-2';
    fc  = segmentParameters.fc;
    fs  = segmentParameters.fs;
    sc = scales_for_freqs(fc,1/fs,wvlt);
    likelihoodModels.scales = sc;
    
    
    fprintf('Computing Wavelet Transform\n');
    Cs = cwt(data,sc,wvlt); 
    fprintf('Computing Power\n');
    P = Cs.*conj(Cs);
    clear Cs
    amps = sum(P)';
    
    
    %find noise model for this particular data set
    [noiseModel,obj,posts,noiseThreshold,idx] = ...
        findNoiseModel(P',amps,segmentParameters);
    
    maxNoiseLength = 300000;
    if length(idx) > maxNoiseLength
        noiseData = data(idx(1:maxNoiseLength));
    else
        noiseData = data(idx);
    end
    
    %run pulse detector to find male bouts
    [pulseInfo,pulseInfoF,pulseInfoM,male_song_times_final] = ...
        Process_Song_virilis(data,P,noiseData,segmentParameters);
    P = P';
    amps = sum(P,2);
    
    initial_male_bouts = false(N,1);
    male_song_times_final = male_song_times_final(male_song_times_final(:,1)>0,:);
    for i=1:length(male_song_times_final(:,1))
        initial_male_bouts(male_song_times_final(i,1):male_song_times_final(i,2)) = true;
    end
   

    %find likelihood model projections
    [probs,likelihoods,noiseP] = ...
        findProbabilities_wavelet(P,likelihoodModels,noiseModel,segmentParameters,false);
        
        
    %find all contiguous sections that are not noise
    [~,maxIdx] = max(probs,[],2);
    isNoise = noiseP > segmentParameters.noiseThreshold | maxIdx == 3 ...
        | likelihoods(:,3) > segmentParameters.noiseLikelihoodThreshold;
    isSignal = ~isNoise;
    
    
    %end recording if pause time too large
    stop_time = segmentParameters.stop_recording_time*segmentParameters.fs;
    signalTimes = find(isSignal);
    firstTime = signalTimes(min([10 length(signalTimes)]));
    diffTimes = diff(signalTimes);
    stopIdx = find(diffTimes > stop_time & signalTimes(2:end) > firstTime,1,'first');
    if ~isempty(stopIdx)
        isSignal(signalTimes(stopIdx+1):end) = false;
    end
    
    %find male pulses
    tmp = probs(:,1:3);
    tmp(:,1) = tmp(:,1) + probs(:,4);
    [~,maxIdx] = max(tmp,[],2);
    isMale_initial = maxIdx == 1 & tmp(:,1) > segmentParameters.maleThreshold;
    
    isMale = (isMale_initial | initial_male_bouts) & isSignal;
    
    
    %fill in holes in male pulse detection
    midIdx = round(N/2);
    testVals = zeros(size(isMale));
    testVals(midIdx + (-maleTestDuration:maleTestDuration)) = 1;
    numL = 2*maleTestDuration + 1;
    out = fftshift(ifft(fft(isMale).*conj(fft(testVals)))) ./ numL;
    isMale(out >= segmentParameters.minMaleBoutFraction) = true;
    
    maleBouts = bwconncomp(isMale);
    lengths = returnCellLengths(maleBouts.PixelIdxList);
    isMaleBout = lengths >= segmentParameters.minMaleDuration;
    
    male_song_times_final = zeros(sum(isMaleBout),2);
    maleIdx = find(isMaleBout);
    isMale = false(size(isMale));
    for i=1:length(maleIdx)
        male_song_times_final(i,1) = maleBouts.PixelIdxList{maleIdx(i)}(1);
        male_song_times_final(i,2) = maleBouts.PixelIdxList{maleIdx(i)}(end);
        isMale(male_song_times_final(i,1):male_song_times_final(i,2)) = true;
    end
    
    
    isFemale = isSignal;
    for i=1:sum(isMaleBout)
        isFemale(male_song_times_final(i,1):male_song_times_final(i,2)) = false;
    end
    
    femaleBouts = bwconncomp(isFemale);
    lengths = returnCellLengths(femaleBouts.PixelIdxList);
    isFemaleBout = lengths >= segmentParameters.minFemalePulseSize;
    
    female_song_times = zeros(sum(isFemaleBout),2);
    femaleIdx = find(isFemaleBout);
    for i=1:length(femaleIdx)
        female_song_times(i,1) = femaleBouts.PixelIdxList{femaleIdx(i)}(1);
        female_song_times(i,2) = femaleBouts.PixelIdxList{femaleIdx(i)}(end);
    end
    
    
    %find female pulses during male song regions
    [female_pulses,run_data] = ...
        find_female_pulses_during_male(male_song_times_final,P,...
            likelihoodModels,female_song_times,amps,segmentParameters);
    
    female_pulses = break_up_female_pulses(female_pulses,amps,segmentParameters);
    
    
    % cull female pulses to remove abberant female pulses based on many "male IPI"s in a row
    numPulses = segmentParameters.num_female_IPI_limit;
    if mod(numPulses,2) == 0
        numPulses = numPulses + 1;
    end
    sideLength = floor(numPulses/2);
    pulseThreshold = segmentParameters.female_IPI_limit * segmentParameters.fs / 1000;
    numF = length(female_pulses(:,1));
    
    cull = [-1e10; diff(female_pulses(:,1))] < pulseThreshold;
    eliminatePulse = false(numF,1);
    for i=1:numF-numPulses+1
        if min(cull(i:i+numPulses-1)) == 1
            eliminatePulse(i:(i+2*sideLength)) = true;
        end
    end
    female_pulses = female_pulses(~eliminatePulse,:);
    
    
    %eliminate female pulses at the beginning and end of male bouts
    isPulse = true(length(female_pulses(:,1)),1);
    for i=1:length(female_pulses(:,1))
        if female_pulses(i,1) > 1
            currentVal = isMale(female_pulses(i,1));
            prevVal = isMale(female_pulses(i,1)-1);
            if currentVal && ~prevVal
                isPulse(i) = false;
            end
        end
        
        if female_pulses(i,2) < N
            currentVal = isMale(female_pulses(i,2));
            nextVal = isMale(female_pulses(i,2)+1);
            if currentVal && ~nextVal
                isPulse(i) = false;
            end
        end
        
    end
    female_pulses_final = female_pulses(isPulse,:);
    
    %format data structures
    L_male = length(male_song_times_final(:,1));
    L_female = length(female_pulses_final(:,1));
    
    maleBoutInfo.w0 = male_song_times_final(:,1);
    maleBoutInfo.w1 = male_song_times_final(:,2);
    maleBoutInfo.wc = mean(male_song_times_final,2);
        
    maleBoutInfo.scmx = zeros(L_male,1);
    maleBoutInfo.fcmx = zeros(L_male,1);
    maleBoutInfo.x = cell(L_male,1);
    maleBoutInfo.wMax = zeros(size(maleBoutInfo.w0));
    maleBoutInfo.wMean = zeros(size(maleBoutInfo.w0));
    
    for i=1:L_male
        maleBoutInfo.x{i} = data(male_song_times_final(i,1):male_song_times_final(i,2));
        q = male_song_times_final(i,1):male_song_times_final(i,2);
        [~,maleBoutInfo.wMax(i)] = max(amps(q));
        maleBoutInfo.wMax(i) = q(maleBoutInfo.wMax(i));
        maleBoutInfo.wMean(i) = sum(q.*amps(q)') / sum(amps(q));
    end
    
    
    femaleBoutInfo.w0 = female_pulses_final(:,1);
    femaleBoutInfo.w1 = female_pulses_final(:,2);
    femaleBoutInfo.wc = mean(female_pulses_final,2);
    
        
    femaleBoutInfo.x = cell(L_female,1);
    femaleBoutInfo.scmx = zeros(L_female,1);
    femaleBoutInfo.fcmx = zeros(L_female,1);
    femaleBoutInfo.wMax = zeros(size(femaleBoutInfo.w0));
    femaleBoutInfo.wMean = zeros(size(femaleBoutInfo.w0));
        
    for i=1:L_female
        femaleBoutInfo.x{i} = data(female_pulses_final(i,1):female_pulses_final(i,2));
        q = female_pulses_final(i,1):female_pulses_final(i,2);
        [~,femaleBoutInfo.wMax(i)] = max(amps(q));
        femaleBoutInfo.wMax(i) = q(femaleBoutInfo.wMax(i));
        femaleBoutInfo.wMean(i) = sum(q.*amps(q)') / sum(amps(q));
    end
    
    
    run_data.pulseInfo = pulseInfo;
    run_data.pulseInfoF = pulseInfoF;
    run_data.amps = amps;
    run_data.pulseInfoM = pulseInfoM;
    run_data.segmentParameters = segmentParameters;
    run_data.initial_male_bouts = initial_male_bouts;
    run_data.isSignal = isSignal;
    run_data.femaleBouts = femaleBouts;
    run_data.maleBouts = maleBouts;
    run_data.isMaleBout = isMaleBout;
    run_data.probs = probs;
    run_data.likelihoods = likelihoods;
    run_data.male_song_times_final = male_song_times_final;
    run_data.obj = obj;
    run_data.posts = posts;
    run_data.noiseThreshold = noiseThreshold;
    run_data.noiseP = noiseP;
    run_data.stoptime = stopIdx;
    
    clear pulseInfo pulseInfoF pulseInfoM male_song_times_final P ampGMM amps
    
    figure
    makeMaleFemalePlot(data,maleBoutInfo,femaleBoutInfo)