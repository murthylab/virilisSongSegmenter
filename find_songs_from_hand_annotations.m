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
maxToSample = 20000;
maxNumGMM = 10000;
maxNoiseLength = 500000;
calculateProbModes = 20;

if length(xempty) > maxNoiseLength
    xempty = xempty(1:maxNoiseLength);
end


wav = 'fbsp2-1-2';
frequencies = 100:20:900;
K = scal2frq(1,wav,dt);
scales = K ./ frequencies;
maxScale = scales(1);
L = length(scales);
saveRange = 25;

male_pulses = {MPULSE1*10,MPULSE5*10,MPULSE6*10,MPULSE8*10,MPULSE9*10,MPULSE10*10};
female_pulses = {FPULSE1*10,FPULSE5*10,FPULSE6*10,FPULSE8*10,FPULSE9*10,FPULSE10*10};




%% Find pulses

fprintf(1,'Finding Noise Spectrum\n');
C_noise = cwt(xempty,scales,wav);
P_noise = C_noise.*conj(C_noise);

%%

male_songs = cell(6,1);
female_songs = cell(6,1);
%male_cwts = cell(6,1);
%female_cwts = cell(6,1);

male_sequences = cell(6,1);
female_sequences = cell(6,1);

fprintf(1,'Finding Peak Spectra\n');
for i=1:6
            
    fprintf(1,'\t Data Set #%1i\n',i);
    firstIdx = min(min(round(male_pulses{i})),min(round(female_pulses{i}))) - buffer_size;
    lastIdx = max(max(round(male_pulses{i})),max(round(female_pulses{i}))) + buffer_size;
    
    
    C = cwt(songs(firstIdx:lastIdx,i),scales,wav);
    
    male_idx = zeros(length(male_pulses{i})*(2*saveRange+1),1);
    for j=1:length(male_pulses{i})
        midPoint = round(male_pulses{i}(j)-firstIdx+1);
        male_idx((1:2*saveRange+1) + (j-1)*(2*saveRange+1)) = (midPoint-saveRange):(midPoint + saveRange);
    end
    
    %male_cwts{i} = C(:,round(male_pulses{i}-firstIdx+1));
    male_songs{i} = C(:,male_idx)' .* conj(C(:,male_idx)');
    
    male_sequences{i} = cell(length(male_pulses{i}),1);
    for j=1:length(male_pulses{i})
        xx = round(male_pulses{i}(j));
        male_sequences{i}{j} = songs((xx-maxScale):(xx+maxScale),i);
    end
    
    female_idx = zeros(length(female_pulses{i})*(2*saveRange+1),1);
    for j=1:length(female_pulses{i})
        midPoint = round(female_pulses{i}(j)-firstIdx+1);
        female_idx((1:2*saveRange+1) + (j-1)*(2*saveRange+1)) = (midPoint-saveRange):(midPoint + saveRange);
    end
    
    %female_cwts{i} = C(:,round(male_pulses{i}-firstIdx+1));
    female_songs{i} = C(:,female_idx)' .* conj(C(:,female_idx)');
    
    female_sequences{i} = cell(length(female_pulses{i}),1);
    for j=1:length(female_pulses{i})
        xx = round(female_pulses{i}(j));
        female_sequences{i}{j} = songs((xx-maxScale):(xx+maxScale),i);
    end

    
end


clear i firstIdx lastIdx C xx 


num_male = 0;
num_female = 0;
num_male_sequences = 0;
num_female_sequences = 0;
for i=1:6
    num_male = num_male + length(male_songs{i}(:,1));
    num_female = num_female + length(female_songs{i}(:,1));
    num_male_sequences = num_male_sequences + length(male_sequences{i});
    num_female_sequences = num_female_sequences + length(female_sequences{i});
end


%% Run PCAs

fprintf(1,'Finding Male Principal Components\n');


all_male = zeros(num_male,L);
all_male_sequences = cell(num_male_sequences,1);
%all_male_cwts = zeros(num_male,2*maxScale+1);
count = 1;
for i=1:6
    all_male(count:count+length(male_songs{i}(:,1))-1,:) = male_songs{i};
    count = count + length(male_songs{i}(:,1));
end

count = 1;
for i=1:6
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
all_female_sequences = cell(num_female_sequences,1);
%all_male_cwts = zeros(num_male,2*maxScale+1);
count = 1;
for i=1:6
    all_female(count:count+length(female_songs{i}(:,1))-1,:) = female_songs{i};
    count = count + length(female_songs{i}(:,1));
end

count = 1;
for i=1:6
    for j=1:length(female_sequences{i})
        all_female_sequences(count) = female_sequences{i}(j);
        count = count + 1;
    end
end


female_mean = mean(all_female);
[coeffs_female,scores_female,latent_female] = princomp(all_female);

%%

fprintf(1,'Finding Combination Principal Components\n');

num_doubles = min(max_num_doubles,num_female_sequences*num_male_sequences);
both_wavelets = cell(num_doubles,1);
random_males = all_male_sequences(randi(num_male_sequences,[num_doubles 1]));
random_females = all_female_sequences(randi(num_female_sequences,[num_doubles 1]));
parfor i=1:num_doubles
    if mod(i,100) == 0
        fprintf(1,'\t Combination #%6i\n',i);
    end
   
    z = random_males{i} + random_females{i};
    
    C = cwt(z,scales,wav);
    C = C(:,maxScale:(2*maxScale))';
    both_wavelets{i} = C.*conj(C);
    
end

num_both = 0;
for i=1:num_doubles
    num_both = num_both + length(both_wavelets{i}(:,1));
end
all_both = zeros(num_both,L);
count = 1;
for i=1:num_doubles
    all_both(count:(-1+count+length(both_wavelets{i}(:,1))),:) = both_wavelets{i};
    count = count + length(both_wavelets{i}(:,1));
end


both_mean = mean(all_both);
[coeffs_both,scores_both,latent_both] = princomp(all_both);

%% Noise PCA


fprintf(1,'Finding Noise Principal Components\n');

%Pnoise_norm = Pnoise' ./ repmat(sum(Pnoise)',1,Nfft/2+1);
P_noise = P_noise';
noise_mean = mean(P_noise);
[coeffs_noise,scores_noise,latent_noise] = princomp(P_noise);
num_noise = length(scores_noise(:,1));


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

%% 
fprintf(1,'Calculating Cross-Scores\n');

calcProbModes = 20;
crossScores = cell(4,4);

crossScores{1,1} =  scores_male(:,1:calcProbModes);
crossScores{1,2} =  bsxfun(@minus,all_male,female_mean) * coeffs_female(:,1:calcProbModes);
crossScores{1,3} =  bsxfun(@minus,all_male,noise_mean) * coeffs_noise(:,1:calcProbModes);
crossScores{1,4} =  bsxfun(@minus,all_male,both_mean) * coeffs_both(:,1:calcProbModes);

crossScores{2,2} =  scores_female(:,1:calcProbModes);
crossScores{2,1} =  bsxfun(@minus,all_female,male_mean) * coeffs_male(:,1:calcProbModes);
crossScores{2,3} =  bsxfun(@minus,all_female,noise_mean) * coeffs_noise(:,1:calcProbModes);
crossScores{2,4} =  bsxfun(@minus,all_female,both_mean) * coeffs_both(:,1:calcProbModes);


crossScores{3,3} =  scores_noise(:,1:calcProbModes);
crossScores{3,2} =  bsxfun(@minus,P_noise,female_mean) * coeffs_female(:,1:calcProbModes);
crossScores{3,1} =  bsxfun(@minus,P_noise,male_mean) * coeffs_male(:,1:calcProbModes);
crossScores{3,4} =  bsxfun(@minus,P_noise,both_mean) * coeffs_both(:,1:calcProbModes);


crossScores{4,4} =  scores_both(:,1:calcProbModes);
crossScores{4,2} =  bsxfun(@minus,all_both,female_mean) * coeffs_female(:,1:calcProbModes);
crossScores{4,3} =  bsxfun(@minus,all_both,noise_mean) * coeffs_noise(:,1:calcProbModes);
crossScores{4,1} =  bsxfun(@minus,all_both,male_mean) * coeffs_male(:,1:calcProbModes);





%% 




fprintf(1,'Calculating Cross-Likelihoods\n');

crossLikelihoods = cell(4,1);
crossLikelihoods{1} = zeros(num_male,4);
crossLikelihoods{2} = zeros(num_female,4);
crossLikelihoods{3} = zeros(num_noise,4);
crossLikelihoods{4} = zeros(num_both,4);



for i=1:calcProbModes
    
    i
    
    for j=1:4
        
        crossLikelihoods{j}(:,1) = crossLikelihoods{j}(:,1) + log(rectify(pdf(malePDFs{i},crossScores{j,1}(:,i)),1e-323));
        crossLikelihoods{j}(:,2) = crossLikelihoods{j}(:,2) + log(rectify(pdf(femalePDFs{i},crossScores{j,2}(:,i)),1e-323));
        crossLikelihoods{j}(:,3) = crossLikelihoods{j}(:,3) + log(rectify(pdf(noisePDFs{i},crossScores{j,3}(:,i)),1e-323));
        crossLikelihoods{j}(:,4) = crossLikelihoods{j}(:,4) + log(rectify(pdf(bothPDFs{i},crossScores{j,4}(:,i)),1e-323));
        
        
    end
    
%     crossLikelihoods{1}(:,1) = crossLikelihoods{1}(:,1) + log(rectify(pdf(malePDFs{i},scores_male(:,i)),1e-323));
%     crossLikelihoods{1}(:,2) = crossLikelihoods{1}(:,2) + log(rectify(pdf(femalePDFs{i},scores_male(:,i)),1e-323));
%     crossLikelihoods{1}(:,3) = crossLikelihoods{1}(:,3) + log(rectify(pdf(noisePDFs{i},scores_male(:,i)),1e-323));
%     crossLikelihoods{1}(:,4) = crossLikelihoods{1}(:,4) + log(rectify(pdf(bothPDFs{i},scores_male(:,i)),1e-323));
%     
% 
%     crossLikelihoods{2}(:,1) = crossLikelihoods{2}(:,1) + log(rectify(pdf(malePDFs{i},scores_female(:,i)),1e-323));
%     crossLikelihoods{2}(:,2) = crossLikelihoods{2}(:,2) + log(rectify(pdf(femalePDFs{i},scores_female(:,i)),1e-323));
%     crossLikelihoods{2}(:,3) = crossLikelihoods{2}(:,3) + log(rectify(pdf(noisePDFs{i},scores_female(:,i)),1e-323));
%     crossLikelihoods{2}(:,4) = crossLikelihoods{2}(:,4) + log(rectify(pdf(bothPDFs{i},scores_female(:,i)),1e-323));
%     
%     crossLikelihoods{3}(:,1) = crossLikelihoods{3}(:,1) + log(rectify(pdf(malePDFs{i},scores_noise(:,i)),1e-323));
%     crossLikelihoods{3}(:,2) = crossLikelihoods{3}(:,2) + log(rectify(pdf(femalePDFs{i},scores_noise(:,i)),1e-323));
%     crossLikelihoods{3}(:,3) = crossLikelihoods{3}(:,3) + log(rectify(pdf(noisePDFs{i},scores_noise(:,i)),1e-323));
%     crossLikelihoods{3}(:,4) = crossLikelihoods{3}(:,4) + log(rectify(pdf(bothPDFs{i},scores_noise(:,i)),1e-323));
%     
%     crossLikelihoods{4}(:,1) = crossLikelihoods{4}(:,1) + log(rectify(pdf(malePDFs{i},scores_both(:,i)),1e-323));
%     crossLikelihoods{4}(:,2) = crossLikelihoods{4}(:,2) + log(rectify(pdf(femalePDFs{i},scores_both(:,i)),1e-323));
%     crossLikelihoods{4}(:,3) = crossLikelihoods{4}(:,3) + log(rectify(pdf(noisePDFs{i},scores_both(:,i)),1e-323));
%     crossLikelihoods{4}(:,4) = crossLikelihoods{4}(:,4) + log(rectify(pdf(bothPDFs{i},scores_both(:,i)),1e-323));
    
    
end


%% 

fprintf(1,'Calculating Cross-Likelihood PDFs\n');

crossLikelihoodPDFs = cell(4,1);
numPoints = 500;
for i=1:4
    crossLikelihoodPDFs{i} = cell(4,1);
    for j=1:4 
        crossLikelihoodPDFs{i}{j} = estimatePDFfromData(crossLikelihoods{i}(:,j),numPoints);
    end
end

%crossLikelihoodPDFs{i}{j} is the PDF of likelihood j given being drawn
%from template i

%% 

% fprintf(1,'Calculating Cross-Likelihood CDFs\n');
% 
% crossLikelihoodCDFs = cell(4,1);
% numPoints = 10000;
% for i=1:4
%     crossLikelihoodCDFs{i} = cell(4,1);
%     for j=1:4 
%         crossLikelihoodCDFs{i}{j} = estimateCDFfromData(crossLikelihoods{i}(:,j),numPoints);
%     end
% end

%% 

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

likelihoodModels.crossLikelihoods = crossLikelihoods;
likelihoodModels.crossLikelihoodPDFs = crossLikelihoodPDFs;
%likelihoodModels.crossLikelihoodCDFs = crossLikelihoodCDFs;    


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
