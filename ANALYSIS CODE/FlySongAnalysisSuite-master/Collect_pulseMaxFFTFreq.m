function [file_names, PulseTrainStart, PulseTrainStop,pulseFFTfreq, pulseFFTtimes,BoutsStart,BoutsStop] = Collect_pulseMaxFFTFreq(folder)
%USAGE  [file_names, PulseTrainStart, PulseTrainStop,pulseFFTfreq, pulseFFTtimes,BoutsStart,BoutsStop] = Collect_pulseMaxFFTFreq(folder)

if strcmp(folder(end),'/') == 0
    folder = [folder '/'];
end
dir_list = dir(folder);
file_num = length(dir_list);
i=0;

PulseTrainStart = cell(1,file_num);
PulseTrainStop = cell(1,file_num);
pulseFFTfreq = cell(1,file_num);
pulseFFTtimes = cell(1,file_num);
file_names = cell(1,file_num);
BoutsStart = cell(1,file_num);
BoutsStop = cell(1,file_num);

%get file names and sample sizes for fhZ and shZ
fprintf('Grabbing file names and data sizes\n');
for y = 1:file_num
    file = dir_list(y).name; %pull out the file name
    [~,root,ext] = fileparts(file);
    path_file = [folder file];
    TG = strcmp(ext,'.mat');
    
    if TG == 1 %if it is a .mat file
        i = i+1;
            %get plot data and limits
            load(path_file,'pMFFT','bouts','culled_pulseInfo','ipiBouts');
            file_names{i} = file;
            PulseTrainStart{i} = cellfun(@(c) c(1),ipiBouts.t);
            PulseTrainStop{i} = cellfun(@(c) c(end),ipiBouts.t) + cellfun(@(c) c(end),ipiBouts.d);
            pulseFFTfreq{i} = pMFFT.freqAll;
            pulseFFTtimes{i} = pMFFT.timeAll;
            BoutsStart{i} = bouts.Start;
            BoutsStop{i} = bouts.Stop;
    end
end

PulseTrainStart(cellfun('isempty',PulseTrainStart))=[];
PulseTrainStop(cellfun('isempty',PulseTrainStop))=[];
pulseFFTfreq(cellfun('isempty',pulseFFTfreq))=[];
pulseFFTtimes(cellfun('isempty',pulseFFTtimes))=[];
file_names(cellfun('isempty',file_names))=[];
BoutsStart(cellfun('isempty',BoutsStart))=[];
BoutsStop(cellfun('isempty',BoutsStop))=[];

%Bouts=cat(1,Bouts{:});









