function [pulseInfo,pulseInfoF, pulseInfoM,male_song_times_final,segParams] = Process_Song_virilis(song,P,xempty,segParams)

    addpath(genpath('./chronux'))
    
    fprintf('Running wavelet transformation.\n')
    [pulseInfoF, pulseInfoM, pulseInfo,male_song_times_final] = ...
        PulseSegmentation_virilis_gjb_v2(song,P,xempty,segParams);
    
    if pulseInfoF.w0 == 0;
        fprintf('no female pulses found.\n');
    elseif pulseInfoM.w0 == 0;
        fprintf('no male pulses found. \n');
    end

