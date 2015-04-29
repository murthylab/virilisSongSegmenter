function likelihoodModels = find_songs_from_hand_annotations(male_songs,female_songs,overlap_songs)
%Inputs arrays of selected male, female, and overlap song and outputs
%likelihood models
%Inputs:
%   male_songs -> N_male x length(frequencies) array of male song wavelet amplitudes
%   female_songs -> N_female x length(frequencies) array of female song wavelet amplitudes
%   overlap_songs -> N_overlap x length(frequencies) array of overlapping song amplitudes
%
%Output:
%   likelihoodModels -> struct containing likelihood models needed to run
%                       segmentVirilisSong.m
%
% (C) Gordon J. Berman, Jan Clemens, Kelly M. LaRue, and Mala Murthy, 2015
%     Princeton University


    %load parameters
    segParams = params_virilis();
    
    probModes = segParams.probModes;
    maxNumPeaks = segParams.maxNumPeaks;
    maxNumPeaks_firstMode = segParams.maxNumPeaks_firstMode;
    frequencies = segParams.fc;
    gmm_replicates = segParams.gmm_replicates;
    maxNumGMM = segParams.maxNumGMM;
    
    fprintf(1,'Finding Male Principal Components\n');
    male_mean = mean(male_songs);
    [coeffs_male,scores_male,latent_male] = princomp(male_songs);
    
    
    fprintf(1,'Finding Female Principal Components\n');
    female_mean = mean(female_songs);
    [coeffs_female,scores_female,latent_female] = princomp(female_songs);
    
    
    if nargin >= 3 && isempty(overlap_songs)
        fprintf(1,'Finding Overlap Principal Components\n');
        both_mean = mean(overlap_songs);
        [coeffs_both,scores_both,latent_both] = princomp(overlap_songs);
    end

    

    fprintf(1,'Finding PDFs\n');
    
    malePDFs = cell(probModes,1);
    femalePDFs = cell(probModes,1);
    if nargin >= 3 && isempty(overlap_songs)
        bothPDFs = cell(probModes,1);
    end
    for i=1:probModes
        
        fprintf(1,'\t #%2i of %2i\n',i,probModes);
        if i == 1
            q = maxNumPeaks_firstMode;
        else
            q = maxNumPeaks;
        end
        
        malePDFs{i} = findBestGMM_AIC(scores_male(:,i),q,gmm_replicates,maxNumGMM);
        femalePDFs{i} = findBestGMM_AIC(scores_female(:,i),q,gmm_replicates,maxNumGMM);
        if nargin >= 3 && isempty(overlap_songs)
            bothPDFs{i} = findBestGMM_AIC(scores_both(:,i),q,gmm_replicates,maxNumGMM);
        end
    end
    
    
    likelihoodModels.malePDFs = malePDFs;
    likelihoodModels.femalePDFs = femalePDFs;
    likelihoodModels.noisePDFs = noisePDFs;    
    
    likelihoodModels.male_mean = male_mean;
    likelihoodModels.female_mean = female_mean;
    likelihoodModels.noise_mean = noise_mean;    
    
    likelihoodModels.coeffs_male = coeffs_male;
    likelihoodModels.coeffs_female = coeffs_female;
    likelihoodModels.coeffs_noise = coeffs_noise;
    
    likelihoodModels.latent_male = latent_male;
    likelihoodModels.latent_female = latent_female;
    likelihoodModels.latent_noise = latent_noise;
    
    likelihoodModels.probModes = probModes;
    likelihoodModels.frequencies = frequencies;
    
    K = scal2frq(1,wav,segParams.dt);
    scales = K ./ frequencies;
    likelihoodModels.scales = scales;
    
    
    if nargin >= 3 && isempty(overlap_songs)
        likelihoodModels.bothPDFs = bothPDFs;
        likelihoodModels.both_mean = both_mean;
        likelihoodModels.coeffs_both = coeffs_both;
        likelihoodModels.latent_both = latent_both;
    end
    

