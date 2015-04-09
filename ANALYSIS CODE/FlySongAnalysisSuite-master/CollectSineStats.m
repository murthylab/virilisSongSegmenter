function [file_names sineStats] = CollectSineStats(folder)
%USAGE [file_names sineStats] = CollectSineStats(folder)

if strcmp(folder(end),'/') == 0
    folder = [folder '/'];
end

dir_list = dir(folder);
file_num = length(dir_list);
i= 0;

%sinePower = zeros(1,file_num);
freq = zeros(1,file_num);
sine2pulse = zeros(1,file_num);
file_names = cell(1,file_num);

%get file names and sample sizes for fhZ and shZ
fprintf('Grabbing file names and data sizes\n');
for y = 1:file_num
    file = dir_list(y).name; %pull out the file name
    [~,root,ext] = fileparts(file);
    path_file = [folder file];
    TG = strcmp(ext,'.mat');
    
    if TG == 1
        i = i+1;
            load(path_file,'maxFFT','winnowed_sine','culled_pulseInfo');
            %power = winnowed_sine.powerMat;
            FFT = maxFFT.freqAll;
            numSine = numel(winnowed_sine.start);
            numPulse = numel(culled_pulseInfo.w0);
            file_names{i} = file;
            %sinePower(i) = mean(abs(power));
            freq(i) = mean(FFT);
            sine2pulse(i) = numSine /  numPulse;
    end
end

file_names(cellfun('isempty',file_names))=[];

%sineStats.sinePower = sinePower(sinePower ~=0);
sineStats.freq = freq(freq~=0);
sineStats.sine2pulse = sine2pulse(sine2pulse~=0);