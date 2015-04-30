function [female_pulses,run_data] = ...
    find_female_pulses_during_male(male_song_times_final,P,...
            likelihoodModels,female_song_times,amps,segmentParameters)
%Finds female pulses within male regions
%Inputs:
%   male_song_times_final -> cell array containing many collections of female pulse regions
%   P -> wavelet values
%   likelihoodModels -> struct containing likelihood model information
%   female_song_times -> start and end times of female song
%   amps -> wavelet amplitudes
%   segmentParameters -> struct containing run parameters
%
%Outputs:
%   female_pulses -> times of all female pulses
%
% (C) Gordon J. Berman, Jan Clemens, Kelly M. LaRue, and Mala Murthy, 2015
%     Princeton University

    if nargin < 5 || isempty(segmentParameters)
        segmentParameters = params_virilis;
    end
    
    amps = gaussianfilterdata(amps,segmentParameters.smoothParameter_amplitudes);
    ampMaxIdx = imregionalmax(amps) & amps > segmentParameters.amplitudeThreshold;
    
    L = length(male_song_times_final(:,1));
    
    filterWindow = segmentParameters.filterWindow;
    probThreshold = segmentParameters.probThreshold;
    maxPulses = 1000000;
    minPulseSize = segmentParameters.minFemalePulseSize;
    probModes = segmentParameters.probModes;
    
    male_pulses = cell(L,1);
    maxVals = cell(size(male_pulses));
    for i=1:L
        male_pulses{i} = P(male_song_times_final(i,1):male_song_times_final(i,2),:);
        maxVals{i} = ampMaxIdx(male_song_times_final(i,1):male_song_times_final(i,2));
    end

    run_data.male_pulses = male_pulses;
    
    
    likes = cell(size(male_pulses));
    for i=1:L
        likes{i} = zeros(length(male_pulses{i}(:,1)),3);
        dataScores_male = bsxfun(@minus,male_pulses{i},...
            likelihoodModels.male_mean) * likelihoodModels.coeffs_male(:,1:probModes);
        dataScores_both = bsxfun(@minus,male_pulses{i},...
            likelihoodModels.both_mean) * likelihoodModels.coeffs_both(:,1:probModes);
        dataScores_female = bsxfun(@minus,male_pulses{i},...
            likelihoodModels.female_mean) * likelihoodModels.coeffs_female(:,1:probModes);
        for j=1:probModes
            likes{i}(:,1) = likes{i}(:,1) + ...
                log(pdf(likelihoodModels.malePDFs{j},dataScores_male(:,j)));
            likes{i}(:,2) = likes{i}(:,2) + ...
                log(pdf(likelihoodModels.bothPDFs{j},dataScores_both(:,j)));
            likes{i}(:,3) = likes{i}(:,3) + ...
                log(pdf(likelihoodModels.femalePDFs{j},dataScores_female(:,j)));
        end
    end
    
    run_data.likelihoods_male_both = likes;
    run_data.original_female_song_times = female_song_times;
    
    
    p_both = cell(L,1);
    for i=1:L
        maxLikes = max(likes{i},[],2);
        expLikes = exp(bsxfun(@minus,likes{i},maxLikes));
        p_both{i} = sum(expLikes(:,2:3),2) ./ sum(expLikes,2);
    end
    

    female_pulses = zeros(maxPulses,2);
    female_pulses(1:length(female_song_times(:,1)),:) = [female_song_times(:,1) female_song_times(:,2)];
    count = length(female_song_times(:,1)) + 1;
    
    
    for i=1:L
        a = gaussianfilterdata(p_both{i},filterWindow);
        CC = bwconncomp(a >= probThreshold);
        for j=1:length(CC.PixelIdxList)
            if length(CC.PixelIdxList{j}) > minPulseSize && sum(maxVals{i}(CC.PixelIdxList{j})) > 0 
                female_pulses(count,:) = ...
                    [CC.PixelIdxList{j}(1) CC.PixelIdxList{j}(end)] + male_song_times_final(i,1) - 1;
                count = count + 1;
            end
        end
        
    end
    
    
   
    female_pulses = female_pulses(1:count-1,:);
    female_pulses = sortrows(female_pulses);
    
    
    
    