fprintf(1,'Loading Data Sets\n');

% load('../../virilis songs for GB/WTvirhand.mat')
load('../../virilis songs for GB/xempty.mat')

%daq_files = findAllImagesInFolders('/Users/gberman/Desktop/FSSV-manual_correction/','daq');
%mat_files = findAllImagesInFolders('/Users/gberman/Desktop/FSSV-manual_correction/','mat');
daq_files = findAllImagesInFolders('/Users/gberman/Desktop/Kelly_data/pulse_freq_analysis/','daq');
mat_files = findAllImagesInFolders('/Users/gberman/Desktop/Kelly_data/pulse_freq_analysis/','mat');
numFiles = length(daq_files);

noise_threshold = .25;
buffer_size = 20000;
variation_threshold = .99;
maxNumPeaks = 4;
maxNumPeaks_firstMode = 6;
gmm_replicates = 3;
max_num_doubles = 10000;
Fs = [1e4,1e4,7812.5,7812.5];
dts = 1 ./ Fs;
probModes = 41;
maxToSample = 20000;
maxNumGMM = 10000;
maxNoiseLength = 500000;
frequencies = 100:20:900;
saveRange = 25;

L = length(frequencies);

if length(xempty) > maxNoiseLength
    xempty = xempty(1:maxNoiseLength);
end


wav = 'fbsp2-1-2';



%% Find pulses

fprintf(1,'Finding Noise Spectrum\n');
dt = 1/10000;
K = scal2frq(1,wav,dt);
scales = K ./ frequencies;
C_noise = cwt(xempty,scales,wav);
P_noise = C_noise.*conj(C_noise);
%P_noise = bsxfun(@rdivide,P_noise,sum(P_noise));



%% Find wavelet transforms near peaks


 male_songs = cell(numFiles,32);
 female_songs = cell(numFiles,32);
% overlap_songs = cell(numFiles,32);
% 
 male_idx = cell(numFiles,32);
 female_idx = cell(numFiles,32);
% overlap_idx = cell(numFiles,32);

samplingFrequencies = zeros(numFiles,1);

fprintf(1,'Finding Peak Spectra\n');
for i=14:14
    
    fprintf(1,'\t Data Set #%1i\n',i);
    
    clear MPULSE FPULSE OVERLAP
    
    load(mat_files{i},'MPULSE','FPULSE','OVERLAP');
    
    if ~exist('OVERLAP','var')
        OVERLAP = [];
    end
    
    if ~exist('MPULSE','var')
        MPULSE = [];
    else
        if ~isempty(MPULSE)
            sM = length(MPULSE(:,1));
        else
            sM = 0;
        end
    end
    
    if ~exist('FPULSE','var')
        FPULSE = [];
        sF = 0;
    else
        if ~isempty(FPULSE)
            sF = length(FPULSE(:,1));
        else
            sF = 0;
        end
    end
    
    if ~isempty(MPULSE)
        
        if length(MPULSE(1,:)) == 3
            
            fullMaleBout = true;
            
            if ~isempty(OVERLAP)
                if ~isempty(FPULSE)
                    temp = [MPULSE ;FPULSE zeros(sF,1);OVERLAP zeros(size(OVERLAP(:,1)))];
                else
                    temp = [MPULSE ; OVERLAP zeros(size(OVERLAP(:,1)))];
                end
            else
                if ~isempty(FPULSE)
                    temp = [MPULSE ;FPULSE zeros(sF,1)];
                else
                    temp = MPULSE;
                end
            end
            
            
        else
            
            fullMaleBout = false;
            
            if ~isempty(OVERLAP)
                if ~isempty(FPULSE)
                    temp = [MPULSE zeros(sM,1);FPULSE zeros(sF,1);OVERLAP zeros(size(OVERLAP(:,1)))];
                else
                    temp = [MPULSE zeros(sM,1);OVERLAP zeros(size(OVERLAP(:,1)))];
                end
            else
                if ~isempty(FPULSE)
                    temp = [MPULSE zeros(sM,1);FPULSE zeros(sF,1)];
                else
                    temp = [MPULSE zeros(sM,1)];
                end
            end
            
                            
        end
        
        
    else

            
            fullMaleBout = false;
            
            if ~isempty(OVERLAP)
                if ~isempty(FPULSE)
                    temp = [FPULSE zeros(sF,1);OVERLAP zeros(size(OVERLAP(:,1)))];
                else
                    temp = [OVERLAP zeros(size(OVERLAP(:,1)))];
                end
            else
                if ~isempty(FPULSE)
                    temp = [FPULSE zeros(sF,1)];
                else
                    temp = [];
                end
            end
            
            
            
    end
    
    if ~isempty(temp)
        
        currentPulses = zeros(length(temp(:,1)),4);
        currentPulses(:,1:3) = temp;
        if ~isempty(OVERLAP)
            currentPulses(:,4) = [ones(sM,1);ones(sF,1)+1;ones(size(OVERLAP(:,1)))+2];
        else
            currentPulses(:,4) = [ones(sM,1);ones(sF,1)+1];
        end
        
        daqChannelsToRead = unique(currentPulses(:,1));
        daqinfo = daqread(daq_files{i},'info');
        daqChannelsToRead = daqChannelsToRead(daqChannelsToRead <= length(daqinfo.ObjInfo.Channel));
        
        
        
        for kk=1:length(daqChannelsToRead)
            
            j = daqChannelsToRead(kk);
            fprintf(1,'\t\t Channel #%2i\n',j);
            
            fprintf(1,'\t\t\t Loading Data...\n');
            [song,~,~,~,info] = daqread(daq_files{i},'Channel',j);
            songLength = length(song);
            Fs = info.ObjInfo.SampleRate;
            dt = 1 / Fs;
            if samplingFrequencies(i) == 0
                samplingFrequencies(i) = Fs;
            end
            
            K = scal2frq(1,wav,dt);
            scales = K ./ frequencies;
            maxScale = scales(1);
            
            channelPulses = currentPulses(currentPulses(:,1)==j,:);
            
            firstPulse = min(channelPulses(:,2));
            lastPulse = max([max(channelPulses(:,2)) max(channelPulses(:,3))]);
            
            firstIdx = floor(firstPulse/(1000*dt)) - buffer_size;
            firstIdx = max([1 firstIdx]);
            lastIdx = ceil(lastPulse/(1000*dt)) + buffer_size;
            lastIdx = min([lastIdx songLength]);
            
            channelPulses(:,2:3) = round(channelPulses(:,2:3)./(1000*dt));
            
            fprintf(1,'\t\t\t Computing Wavelets...\n');
            C = cwt(song(firstIdx:lastIdx),scales,wav);
            
            
            maleLength = sum(channelPulses(:,4) == 1);
            if maleLength > 0
                
                if fullMaleBout
                    
                    malePulses = channelPulses(channelPulses(:,4)==1,:);
                    totalMaleIndices = sum(malePulses(:,3) - malePulses(:,2) + 1);
                    male_idx{i,j} = zeros(totalMaleIndices,1);
                    count = 0;
                    for k=1:maleLength
                        currentLength = malePulses(k,3) - malePulses(k,2) + 1;
                        male_idx{i,j}((1:currentLength) + count) = malePulses(k,2):malePulses(k,3);
                        count = count + currentLength;
                    end
                    
                else
                    
                    malePulses = channelPulses(channelPulses(:,4)==1,:);
                    totalMaleIndices = maleLength*(2*saveRange + 1);
                    male_idx{i,j} = zeros(totalMaleIndices,1);
                    idx = (-saveRange:saveRange)';
                    for k=1:maleLength
                        male_idx{i,j}((2*saveRange+1)*(k-1) + (1:(2*saveRange+1))) = malePulses(k,2) + idx;
                    end
                    
                end
                
                male_songs{i,j} = C(:,male_idx{i,j}-firstIdx+1)' .* conj(C(:,male_idx{i,j}-firstIdx+1)');
                
            end
            
            
            femaleLength = sum(channelPulses(:,4) == 2);
            if femaleLength > 0
                femalePulses = channelPulses(channelPulses(:,4)==2,:);
                totalFemaleIndices = femaleLength*(2*saveRange + 1);
                female_idx{i,j} = zeros(totalFemaleIndices,1);
                idx = (-saveRange:saveRange)';
                for k=1:femaleLength
                    female_idx{i,j}((2*saveRange+1)*(k-1) + (1:(2*saveRange+1))) = femalePulses(k,2) + idx;
                end
                
                female_songs{i,j} = C(:,female_idx{i,j}-firstIdx+1)' .* conj(C(:,female_idx{i,j}-firstIdx+1)');
                
            end
            
            
            overlapLength = sum(channelPulses(:,4) == 3);
            if overlapLength > 0
                overlapPulses = channelPulses(channelPulses(:,4)==3,:);
                totalOverlapIndices = overlapLength*(2*saveRange + 1);
                overlap_idx{i,j} = zeros(totalOverlapIndices,1);
                for k=1:overlapLength
                    overlap_idx{i,j}((2*saveRange+1)*(k-1) + (1:(2*saveRange+1))) = overlapPulses(k,2) + idx;
                end
                
                overlap_songs{i,j} = C(:,overlap_idx{i,j}-firstIdx+1)' .* conj(C(:,overlap_idx{i,j}-firstIdx+1)');
                
            end
            
            
            clear C firstIdx lastIdx channelPulses malePulses femalePulses overlapPulses idx song
            
        end
        
    end
    
    clear currentPulses daqChannelsToRead MPULSE FPULSE OVERLAP temp
    
    
end


%% calculate the total number of bouts


num_male = 0;
num_female = 0;
num_overlap = 0;
for i=1:numFiles
    for j=1:32
        if ~isempty(male_songs{i,j})
            num_male = num_male + length(male_songs{i,j}(:,1));
        end
        if ~isempty(female_songs{i,j})
            num_female = num_female + length(female_songs{i,j}(:,1));
        end
        if ~isempty(overlap_songs{i,j})
            num_overlap = num_overlap + length(overlap_songs{i,j}(:,1));
        end
    end
end


%% Run PCAs

fprintf(1,'Finding Male Principal Components\n');


all_male = zeros(num_male,L);

count = 1;
for i=1:numFiles
    for j=1:32
        if ~isempty(male_songs{i,j})
            all_male(count:count+length(male_songs{i,j}(:,1))-1,:) = male_songs{i,j};
            count = count + length(male_songs{i,j}(:,1));
        end
    end
end

male_mean = mean(all_male);
[coeffs_male,scores_male,latent_male] = princomp(all_male);


%%

fprintf(1,'Finding Female Principal Components\n');


all_female = zeros(num_female,L);

count = 1;
for i=1:numFiles
    for j=1:32
        if ~isempty(female_songs{i,j})
            all_female(count:count+length(female_songs{i,j}(:,1))-1,:) = female_songs{i,j};
            count = count + length(female_songs{i,j}(:,1));
        end
    end
end

female_mean = mean(all_female);
[coeffs_female,scores_female,latent_female] = princomp(all_female);


%%

fprintf(1,'Finding Overlap Principal Components\n');


all_both = zeros(num_overlap,L);

count = 1;
for i=1:numFiles
    for j=1:32
        if ~isempty(overlap_songs{i,j})
            all_both(count:count+length(overlap_songs{i,j}(:,1))-1,:) = overlap_songs{i,j};
            count = count + length(overlap_songs{i,j}(:,1));
        end
    end
end

both_mean = mean(all_both);
[coeffs_both,scores_both,latent_both] = princomp(all_both);

%% Noise PCA


fprintf(1,'Finding Noise Principal Components\n');

%Pnoise_norm = Pnoise' ./ repmat(sum(Pnoise)',1,Nfft/2+1);
P_noise = P_noise';
noise_mean = mean(P_noise);
[coeffs_noise,scores_noise,latent_noise] = princomp(P_noise);


%%  Find PDFs

fprintf(1,'Finding PDFs\n');

%numMaleModes = find(cumsum(latent_male)./sum(latent_male) >= variation_threshold,1,'first');
%numFemaleModes = find(cumsum(latent_female)./sum(latent_female) >= variation_threshold,1,'first');
%numBothModes = find(cumsum(latent_both)./sum(latent_both) >= variation_threshold,1,'first');

%probModes = min(maxProbModes,max([numMaleModes,numFemaleModes]));
malePDFs = cell(probModes,1);
femalePDFs = cell(probModes,1);
noisePDFs = cell(probModes,1);
bothPDFs = cell(probModes,1);
parfor i=1:probModes
    
    fprintf(1,'\t #%2i of %2i\n',i,probModes);
    if i == 1
        q = maxNumPeaks_firstMode;
    else
        q = maxNumPeaks;
    end
    
    malePDFs{i} = findBestGMM_AIC(scores_male(:,i),q,gmm_replicates,maxNumGMM);
    femalePDFs{i} = findBestGMM_AIC(scores_female(:,i),q,gmm_replicates,maxNumGMM);
    noisePDFs{i} = findBestGMM_AIC(scores_noise(:,i),q,gmm_replicates,maxNumGMM);
    bothPDFs{i} = findBestGMM_AIC(scores_both(:,i),q,gmm_replicates,maxNumGMM);
    
end


likelihoodModels.malePDFs = malePDFs;
likelihoodModels.femalePDFs = femalePDFs;
likelihoodModels.noisePDFs = noisePDFs;
likelihoodModels.bothPDFs = bothPDFs;

likelihoodModels.male_mean = male_mean;
likelihoodModels.female_mean = female_mean;
likelihoodModels.noise_mean = noise_mean;
likelihoodModels.both_mean = both_mean;

likelihoodModels.coeffs_male = coeffs_male;
likelihoodModels.coeffs_female = coeffs_female;
likelihoodModels.coeffs_noise = coeffs_noise;
likelihoodModels.coeffs_both = coeffs_both;

likelihoodModels.latent_male = latent_male;
likelihoodModels.latent_female = latent_female;
likelihoodModels.latent_noise = latent_noise;
likelihoodModels.latent_both = latent_both;


likelihoodModels.probModes = probModes;
likelihoodModels.frequencies = frequencies;
likelihoodModels.scales = scales;


