function likelihoodModels = findLikelihoodModelsFromSongs(male_songs,female_songs,overlap_songs,P_noise,dt)


    maxNumPeaks = 4;
    maxNumPeaks_firstMode = 6;
    gmm_replicates = 3;
    probModes = 41;
    wav = 'fbsp2-1-2';
    maxNumGMM = 10000;
    frequencies = 100:20:900;
    K = scal2frq(1,wav,dt);
    scales = K ./ frequencies;
    
    L = length(frequencies);
    
    
    
    numFiles = length(male_songs(:,1));
    
    
    
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
    
    
    % Run PCAs
    
    fprintf(1,'Finding Male Principal Components\n');
    
    
    all_male = zeros(num_male,L);
    keepMale = true;
    
    count = 1;
    for i=1:numFiles
        for j=1:32
            if ~isempty(male_songs{i,j})
                all_male(count:count+length(male_songs{i,j}(:,1))-1,:) = male_songs{i,j};
                count = count + length(male_songs{i,j}(:,1));
            end
        end
    end
    
    if count > 1
        male_mean = mean(all_male);
        [coeffs_male,scores_male,latent_male] = princomp(all_male);
    else
        keepMale = false;
        coeffs_male = [];
        scores_male = 0;
        latent_male = [];
    end
    
    
    %
    
    fprintf(1,'Finding Female Principal Components\n');
    
    
    all_female = zeros(num_female,L);
    keepFemale = true;
    
    count = 1;
    for i=1:numFiles
        for j=1:32
            if ~isempty(female_songs{i,j})
                all_female(count:count+length(female_songs{i,j}(:,1))-1,:) = female_songs{i,j};
                count = count + length(female_songs{i,j}(:,1));
            end
        end
    end
    
    if count > 1
        female_mean = mean(all_female);
        [coeffs_female,scores_female,latent_female] = princomp(all_female);
    else
        keepFemale = false;
        coeffs_female = [];
        scores_female = 0;
        latent_female = [];
    end
    
    
    %
    
    fprintf(1,'Finding Overlap Principal Components\n');
    
    
    all_both = zeros(num_overlap,L);
    keepBoth = true;
    
    count = 1;
    for i=1:numFiles
        for j=1:32
            if ~isempty(overlap_songs{i,j})
                all_both(count:count+length(overlap_songs{i,j}(:,1))-1,:) = overlap_songs{i,j};
                count = count + length(overlap_songs{i,j}(:,1));
            end
        end
    end
    
    if count > 1
        both_mean = mean(all_both);
        [coeffs_both,scores_both,latent_both] = princomp(all_both);
    else
        keepBoth = false;
        coeffs_both = [];
        scores_both = 0;
        latent_both = [];
    end
    
    % Noise PCA
    
    
    fprintf(1,'Finding Noise Principal Components\n');
    
    %Pnoise_norm = Pnoise' ./ repmat(sum(Pnoise)',1,Nfft/2+1);
    P_noise = P_noise';
    noise_mean = mean(P_noise);
    [coeffs_noise,scores_noise,latent_noise] = princomp(P_noise);
    
    
    %  Find PDFs
    
    fprintf(1,'Finding PDFs\n');
    

    malePDFs = cell(probModes,1);
    femalePDFs = cell(probModes,1);
    noisePDFs = cell(probModes,1);
    bothPDFs = cell(probModes,1);
    keepBoths = repmat(keepBoth,probModes,1);
    keepMales = repmat(keepMale,probModes,1);
    keepFemales = repmat(keepFemale,probModes,1);
    for i=1:probModes
        
        fprintf(1,'\t #%2i of %2i\n',i,probModes);
        if i == 1
            q = maxNumPeaks_firstMode;
        else
            q = maxNumPeaks;
        end
        
        if keepMales(i)
            malePDFs{i} = findBestGMM_AIC(scores_male(:,i),q,gmm_replicates,maxNumGMM);
        else
            malePDFs{i} = [];
        end
        
        if keepFemales(i)
            femalePDFs{i} = findBestGMM_AIC(scores_female(:,i),q,gmm_replicates,maxNumGMM);
        else
            femalePDFs{i} = [];
        end
        
        noisePDFs{i} = findBestGMM_AIC(scores_noise(:,i),q,gmm_replicates,maxNumGMM);
        
        if keepBoths(i)
            bothPDFs{i} = findBestGMM_AIC(scores_both(:,i),q,gmm_replicates,maxNumGMM);
        else
            bothPDFs{i} = [];
        end
        
    end
    
    
    if keepMale
        likelihoodModels.malePDFs = malePDFs;
        likelihoodModels.male_mean = male_mean;
        likelihoodModels.coeffs_male = coeffs_male;
        likelihoodModels.latent_male = latent_male;
    end
    
    if keepFemale
        likelihoodModels.femalePDFs = femalePDFs;
        likelihoodModels.female_mean = female_mean;
        likelihoodModels.coeffs_female = coeffs_female;
        likelihoodModels.latent_female = latent_female;
    end
    
    likelihoodModels.noisePDFs = noisePDFs;
    likelihoodModels.noise_mean = noise_mean;
    likelihoodModels.coeffs_noise = coeffs_noise;
    likelihoodModels.latent_noise = latent_noise;
    
    if keepBoth
        likelihoodModels.bothPDFs = bothPDFs;
        likelihoodModels.both_mean = both_mean;
        likelihoodModels.coeffs_both = coeffs_both;
        likelihoodModels.latent_both = latent_both;
    end
    
    likelihoodModels.probModes = probModes;
    likelihoodModels.frequencies = frequencies;
    likelihoodModels.scales = scales;
    likelihoodModels.dt = dt;
    likelihoodModels.wav = wav;
    
    
    