fprintf(1,'Loading Data Sets\n');

load('../../virilis songs for GB/WTvirhand.mat')
load('../../virilis songs for GB/xempty.mat')


noise_threshold = .25;
buffer_size = 20000;
variation_threshold = .99;
maxNumPeaks = 4;
maxNumPeaks_firstMode = 6;
gmm_replicates = 3;
max_num_doubles = 10000;
Fs = 1e4;
dt = 1 / Fs;
probModes = 41;
maxNumGMM = 10000;


wav = 'fbsp2-1-2';
frequencies = 100:20:900;
K = scal2frq(1,wav,dt);
scales = K ./ frequencies;
maxScale = scales(1);
L = length(scales);

male_pulses = {MPULSE1*10,MPULSE5*10,MPULSE6*10,MPULSE8*10,MPULSE9*10,MPULSE10*10};
female_pulses = {FPULSE1*10,FPULSE5*10,FPULSE6*10,FPULSE8*10,FPULSE9*10,FPULSE10*10};




%% Find pulses

fprintf(1,'Finding Noise Spectrum\n');
C_noise = cwt(xempty,scales,wav);
P_noise = C_noise.*conj(C_noise);


male_songs = cell(6,1);
female_songs = cell(6,1);
%male_cwts = cell(6,1);
%female_cwts = cell(6,1);

male_sequences = cell(6,1);
female_sequences = cell(6,1);

fprintf(1,'Finding Peak Spectra\n');
for i=1:6
            
    i
    firstIdx = min(min(round(male_pulses{i})),min(round(female_pulses{i}))) - buffer_size;
    lastIdx = max(max(round(male_pulses{i})),max(round(female_pulses{i}))) + buffer_size;
    
    
    C = cwt(songs(firstIdx:lastIdx,i),scales,wav);
    
    %male_cwts{i} = C(:,round(male_pulses{i}-firstIdx+1));
    male_songs{i} = C(:,round(male_pulses{i}-firstIdx+1))' .* conj(C(:,round(male_pulses{i}-firstIdx+1)))';
    
    male_sequences{i} = cell(length(male_pulses{i}),1);
    for j=1:length(male_pulses{i})
        xx = round(male_pulses{i}(j));
        male_sequences{i}{j} = songs((xx-maxScale):(xx+maxScale),i);
    end
    
    %female_cwts{i} = C(:,round(male_pulses{i}-firstIdx+1));
    female_songs{i} = C(:,round(female_pulses{i}-firstIdx+1))' .* conj(C(:,round(female_pulses{i}-firstIdx+1)))';
    
    female_sequences{i} = cell(length(female_pulses{i}),1);
    for j=1:length(female_pulses{i})
        xx = round(female_pulses{i}(j));
        female_sequences{i}{j} = songs((xx-maxScale):(xx+maxScale),i);
    end
    
    
end


clear i firstIdx lastIdx C xx 


num_male = 0;
num_female = 0;
for i=1:6
    num_male = num_male + length(male_songs{i}(:,1));
    num_female = num_female + length(female_songs{i}(:,1));
end


%% Run PCAs

fprintf(1,'Finding Male Principal Components\n');


all_male = zeros(num_male,L);
all_male_sequences = cell(num_male,1);
%all_male_cwts = zeros(num_male,2*maxScale+1);
count = 1;
for i=1:6
    all_male(count:count+length(male_songs{i}(:,1))-1,:) = male_songs{i};
    for j=1:length(male_sequences{i})
        all_male_sequences(count) = male_sequences{i}(j);
        count = count + 1;
    end
end

male_mean = mean(all_male);
[coeffs_male,scores_male,latent_male] = princomp(all_male);

%%

fprintf(1,'Finding Female Principal Components\n');


all_female = zeros(num_female,L);
all_female_sequences = cell(num_female,1);
%all_female_cwts = zeros(num_female,2*maxScale+1);
count = 1;
for i=1:6
    all_female(count:count+length(female_songs{i}(:,1))-1,:) = female_songs{i};
    for j=1:length(female_sequences{i})
        all_female_sequences(count) = female_sequences{i}(j);
        count = count + 1;
    end
end

female_mean = mean(all_female);
[coeffs_female,scores_female,latent_female] = princomp(all_female);

%%

fprintf(1,'Finding Combination Principal Components\n');

num_doubles = min(max_num_doubles,num_male*num_female);
%both_wavelets = cell(num_doubles,1);
both_wavelets = zeros(num_doubles,L);
random_males = all_male_sequences(randi(num_male,[num_doubles 1]));
random_females = all_female_sequences(randi(num_female,[num_doubles 1]));
parfor i=1:num_doubles
    if mod(i,100) == 0
        fprintf(1,'\t Combination #%6i\n',i);
    end
    %     L1 = length(random_males{i});
    %     L2 = length(random_females{i});
    %     if L1 > L2
    %         q = L1 - L2;
    %         if mod(q,2) == 0
    %             z = random_females{i} + random_males{i}((q/2+1):(L1 - q/2));
    %         else
    %             q = q + 1;
    %             z = random_females{i} + random_males{i}((q/2):(L1 - q/2));
    %         end
    %     else
    %         if L2 > L1
    %             q = L2 - L1;
    %             if mod(q,2) == 0
    %                 z = random_males{i} + random_females{i}((q/2+1):(L2 - q/2));
    %             else
    %                 q = q + 1;
    %                 z = random_males{i} + random_females{i}((q/2):(L2 - q/2));
    %             end
    %         else
    %             z = random_males{i} + random_females{i};
    %         end
    %     end
    z = random_males{i} + random_females{i};
    
    C = cwt(z,scales,wav);
    C = C(:,maxScale:(2*maxScale))';
    P = C.*conj(C);
    %both_wavelets{i} = C'.*conj(C');
    tempAmps = sum(P,2);
    [~,maxIdx] = max(tempAmps);
    both_wavelets(i,:) = P(maxIdx,:);
    
    %w = fft(z);
    %all_both(i,:) = abs(w(1:257)).^2 ./ (Nfft/2);
end

%num_both = 0;
%for i=1:num_doubles
%    num_both = num_both + length(both_wavelets{i}(:,1));
%end
%all_both = zeros(num_both,L);
%count = 1;
%for i=1:num_doubles
%    all_both(count:(-1+count+length(both_wavelets{i}(:,1))),:) = both_wavelets{i};
%    count = count + length(both_wavelets{i}(:,1));
%end
all_both = both_wavelets;


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



% %% Find Likelihoods for song1
% fprintf(1,'Calculating Data Projections\n');
% %[~,~,T,P] = spectrogram(song1,Nfft,Noverlap,[],1);
% C = cwt(song1,scales,wav);
% P = C'.*conj(C');
% 
% N = length(P(:,1));
% 
% dataScores_male = (P - repmat(male_mean,N,1)) * coeffs_male(:,1:probModes);
% dataScores_female = (P - repmat(female_mean,N,1)) * coeffs_female(:,1:probModes);
% dataScores_noise = (P - repmat(noise_mean,N,1)) * coeffs_noise(:,1:probModes);
% dataScores_both = (P - repmat(both_mean',1,N))' * coeffs_both(:,1:probModes);
% 
% 
% fprintf(1,'Finding Likelihoods\n');
% likelihoods = zeros(N,3);
% for i=1:probModes
%    
%     likelihoods(:,1) = likelihoods(:,1) + log(pdf(malePDFs{i},dataScores_male(:,i)));
%     likelihoods(:,2) = likelihoods(:,2) + log(pdf(femalePDFs{i},dataScores_female(:,i)));
%     likelihoods(:,3) = likelihoods(:,3) + log(pdf(noisePDFs{i},dataScores_noise(:,i)));
%     likelihoods(:,4) = likelihoods(:,4) + log(pdf(bothPDFs{i},dataScores_both(:,i)));
%     
% end
% 
% 
% maxVal = max(likelihoods(~isnan(likelihoods) & ~isinf(likelihoods)));
% minVal = min(likelihoods(~isnan(likelihoods) & ~isinf(likelihoods)));
% likelihoods(isnan(likelihoods) | isinf(likelihoods)) = minVal;
% 
% 
% partition = sum(exp(likelihoods-maxVal),2);
% probs = exp(likelihoods - maxVal) ./ repmat(partition,1,4);
% [~,maxIdx] = max(probs,[],2);
% 
% %% Make plot
% 
% signalIdx = find(probs(:,3) < noise_threshold);
% 
% CC_male = bwconncomp(probs(:,1) > noise_threshold & probs(:,2) < noise_threshold);
% CC_female = bwconncomp(probs(:,2) > noise_threshold & probs(:,1) < noise_threshold);
% CC_both = bwconncomp(probs(:,1) > noise_threshold & probs(:,2) > noise_threshold);
% 
% 
% figure
% subplot(2,1,1)
% hold on
% for i=1:length(CC_male.PixelIdxList)
%     rectangle('Position',[CC_male.PixelIdxList{i}(1) -1 length(CC_male.PixelIdxList{i}) 2],'facecolor','b','edgecolor','b');
% end
% for i=1:length(CC_female.PixelIdxList)
%     rectangle('Position',[CC_female.PixelIdxList{i}(1) -1 length(CC_female.PixelIdxList{i}) 2],'facecolor','r','edgecolor','r');
% end
% for i=1:length(CC_both.PixelIdxList)
%     rectangle('Position',[CC_both.PixelIdxList{i}(1) -1 length(CC_both.PixelIdxList{i}) 2],'facecolor','g','edgecolor','g');
% end
% plot(song1,'k-')
% 
% 
% male_color = [0 0 1];
% female_color = [1 0 0];
% noise_color = [1 1 1];
% %both_color = [0 1 0];
% %colors = {[0 0 1],[1 0 0],[1 1 1],[0 1 0]};
% 
% % subplot(2,1,1)
% % hold on
% % for i=1:length(signalIdx)
% %     q = male_color.*probs(signalIdx(i),1) + female_color.*probs(signalIdx(i),2) + noise_color.*probs(signalIdx(i),3);
% %     q = q ./ sum(q);
% %     %q = colors{maxIdx(signalIdx(i))};
% %     rectangle('Position',[signalIdx(i) -1 dt 2],'FaceColor',q,'edgecolor',q)
% % end
% % plot(song1,'k-')
% 
% ylim([-.3 .3])
% 
% 
% subplot(2,1,2)
% plot(probs(:,1),'bo-');
% hold on
% plot(probs(:,2),'rs-');
% %plot(T,probs(:,4),'g^-');
% ylim([-.05 1.05])
% 
% 
% 
% 
% 
% 
% 
% 
% 
