function [file_names, SineStart,SineStop,sinemaxFFTfreq,sinemaxFFTtime,SINEFFTfreqall, SINEFFTtimesall,BoutsStart,BoutsStop] = Collect_sineMaxFFTFreq(folder,strain)
%USAGE  [file_names, SineStart,SineStop,sinemaxFFTfreq,sinemaxFFTtime,SINEFFTfreqall, SINEFFTtimesall,BoutsStart,BoutsStop] = Collect_sineMaxFFTFreq(folder,strain)

if strcmp(folder(end),'/') == 0
    folder = [folder '/'];
end
dir_list = dir(folder);
file_num = length(dir_list);
i=0;

SineStart = cell(1,file_num);
SineStop = cell(1,file_num);
sinemaxFFTfreq = cell(1,file_num);
sinemaxFFTtime = cell(1,file_num);
SINEFFTfreqall = cell(1,file_num);
SINEFFTtimesall = cell(1,file_num);
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
    if nargin == 2
        strainMatch = strfind(root,strain);
    else
        strainMatch = 'all';
    end
    
    if TG == 1 %if it is a .mat file
        if ~isempty(strainMatch)
            fprintf([file '\n']);
            i = i+1;
            %get plot data and limits
            load(path_file,'maxFFT','bouts','winnowed_sine');
            file_names{i} = file;
            SineStart{i} = winnowed_sine.start;
            SineStop{i} = winnowed_sine.stop;
            sinemaxFFTfreq{i} = maxFFT.freq;
            sinemaxFFTtime{i} = maxFFT.time;
            SINEFFTfreqall{i} = maxFFT.freqAll;
            SINEFFTtimesall{i} = maxFFT.timeAll;
            BoutsStart{i} = bouts.Start;
            BoutsStop{i} = bouts.Stop;
        end
    end
end

SineStart(cellfun('isempty',SineStart))=[];
SineStop(cellfun('isempty',SineStop))=[];
sinemaxFFTfreq(cellfun('isempty',sinemaxFFTfreq))=[];
sinemaxFFTtime(cellfun('isempty',sinemaxFFTtime))=[];
SINEFFTfreqall(cellfun('isempty',SINEFFTfreqall))=[];
SINEFFTtimesall(cellfun('isempty',SINEFFTtimesall))=[];
file_names(cellfun('isempty',file_names))=[];
BoutsStart(cellfun('isempty',BoutsStart))=[];
BoutsStop(cellfun('isempty',BoutsStop))=[];

%Bouts=cat(1,Bouts{:});









