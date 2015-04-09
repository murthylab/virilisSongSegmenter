function name = Process_daq_Song_virilis(song_daq_file,song_range,save_path,splitNum)
disp(song_daq_file);
%old - when require noise file
%function Process_daq_Song(song_daq_file,song_range)
% taskID = str2num(getenv('SGE_TASK_ID'));
% disp(taskID);
% current_directory = cd;
% addpath(genpath([current_directory '/KellyProg']));
%% cd to location number 'taskID'

song_daqinfo = daqread(song_daq_file,'info');
%noise_daqinfo = daqread(noise_daq_file,'info');

if nargin < 2
    song_range = [];
else
    if length(song_range) == 1
        song_range = [song_range song_daqinfo.ObjInfo.SamplesAcquired];
    end
end

if nargin < 3 || isempty(save_path)
    [save_path, ~, ~] = fileparts(song_daq_file);
    save_path = [save_path '\'];
end

if nargin < 4
    splitNum = [];
end

% if nargin == 3
%     song_range = song_range;
% elseif nargin == 4
%     song_range = song_range;
%     noise_range = noise_range;
% end

%Produce batch process file, with daq 

nchannels_song = length(song_daqinfo.ObjInfo.Channel);
%nchannels_noise = length(noise_daqinfo.ObjInfo.Channel);

%make directory for output
[~, name, ~] = fileparts(song_daq_file); 
newDir = [save_path name '_out'];
mkdir(newDir);
%unix(['mkdir ' newDir]);

%sep = filesep;
%[pathstr, name, ext] = fileparts(song_daq_file); 
%new_dir = [pathstr name '_out'];
%mkdir(new_dir);

% if nchannels_song ~= nchannels_noise
%     fprintf('Number of channels of song and noise daqs do not agree.\n');
%     return
% else
for y=[1:23];
    if isempty(splitNum)
        outfile = [save_path name '_out/PS_ch' num2str(y) '.mat'];
    else
        outfile = [save_path name '_out/PS_ch' num2str(y) '_' num2str(splitNum) '.mat'];
    end
    
    %outfile = [new_dir sep 'PS_ch' num2str(y) '.mat'];
    file_exist = exist(outfile,'file');
    if file_exist == 0;%if file exists, skip
        %grab song and noise from each channel
        fprintf(1,'Grabbing song and noise from daq file channel %3i out of %3i .\n', y,nchannels_song);
        if ~isempty(song_range)%nargin==2;
           song=daqread(song_daq_file,'Channels',y,'Samples',[1 length(song_range)]);
        else
            song=daqread(song_daq_file,'Channels',y);
        end
        
        %grab sample rate from daq and replace value in params, with
        %warning
        fs = song_daqinfo.ObjInfo.SampleRate;
        fprintf('Using sample rate from daq file\n')
        
        addpath(genpath('./chronux'))
        %fprintf('Running multitaper analysis on signal.\n')
        %[ssf] = sinesongfinder(song,10000,12,20,0.1,0.01,0.5); %returns ssf, which is structure containing the following fields:
        %xempty = segnspp(ssf);
        
        
        
        
        %run Process_Song on selected channel
        fprintf('Processing song.\n')
        [maleBoutInfo,femaleBoutInfo,run_data] = ANALYZE_VIRILIS_SONG(song);
        %,maxfreq_femalepulse,femaleBoutInfo_no_overlap,...
%            female_IPI_no_overlap,freq_femalepulse,freq_malepulse,...
%             maxfreq_malepulse,male_pulse_IPI,male_IBI,female_IPI,male_IBI_alone, male_IBI_partner,...
%             female_IPI_alone, female_IPI_partner, female_response_time, male_response_time,...
%            malebout_overlap_female_final, male_time_singing, female_time_singing, relative_time_singing]
        %[maleBoutInfo,femaleBoutInfo,run_data,maxfreq_femalepulse,freq_femalepulse,freq_malepulse,maxfreq_malepulse,male_pulse_IPI,male_IBI,female_IPI,male_IBI_alone, male_IBI_partner, female_IPI_alone, female_IPI_partner, female_response_time, male_response_time, female_PPM, male_PPM, malebout_overlap_female] = ANALYZE_VIRILIS_SONG(song,xempty);
        %save data
        
        fprintf(1,'Saving Data File\n');
        
        save(outfile, 'maleBoutInfo','femaleBoutInfo','run_data','-v7.3')
%         'maxfreq_femalepulse','freq_femalepulse',...
%             'freq_malepulse','maxfreq_malepulse','male_pulse_IPI','male_IBI','female_IPI','male_IBI_alone',...
%             'male_IBI_partner', 'female_IPI_alone', 'female_IPI_partner', 'female_response_time', ...
%             'male_response_time', 'malebout_overlap_female_final','femaleBoutInfo_no_overlap',...
%             'female_IPI_no_overlap','male_time_singing', 'female_time_singing', 'relative_time_singing', '-v7.3')
        %clear workspace
        clear song maleBoutInfo femaleBoutInfo run_data 
%         maxfreq_femalepulse femaleBoutInfo_no_overlap
%         clear     female_IPI_no_overlap freq_femalepulse freq_malepulse
%         clear    maxfreq_malepulse male_pulse_IPI male_IBI female_IPI male_IBI_alone male_IBI_partner
%         clear     female_IPI_alone  female_IPI_partner  female_response_time male_response_time
%         clear       malebout_overlap_female_final male_time_singing female_time_singing relative_time_singing;
        
    close all
    else
        fprintf('File %s exists. Skipping.\n',   outfile)
    end
end
%end