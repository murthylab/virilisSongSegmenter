function [pulseInfo,pulseInfoF,pulseInfoM,male_song_times_final] = ...
                            Process_Song_virilis(song,P,xempty,segParams)
%Runs heuristic male bout calling analysis
%Inputs:
%   song -> 1d time series containing song data
%   P -> wavelet amplitudes
%   xempty -> noise data
%   segParams -> struct containing run parameters
%
%Output:
%   pulseInfo -> struct containing information about all pulse calls
%   pulseInfoF -> struct containing information about female pulse calls
%   pulseInfoM -> struct containing information about male pulse calls
%   male_song_times_final -> start and end times of called male bouts
%
% (C) Gordon J. Berman, Jan Clemens, Kelly M. LaRue, and Mala Murthy, 2015
%     Princeton University
    addpath(genpath('./chronux'))
    
    fprintf('Running wavelet transformation.\n')
    [pulseInfoF, pulseInfoM, pulseInfo,male_song_times_final] = ...
        PulseSegmentation_virilis(song,P,xempty,segParams);
    
    if pulseInfoF.w0 == 0;
        fprintf('no female pulses found.\n');
    elseif pulseInfoM.w0 == 0;
        fprintf('no male pulses found. \n');
    end

