function [LongTermStats]  = CollectLongTermStats(folder)


if strcmp(folder(end),'/') == 0
    folder = [folder '/'];
end
dir_list = dir(folder);
file_num = length(dir_list);
i= 0;

sineTrainDuration = zeros(file_num,1);
pulseTrainDuration = zeros(file_num,1);
sineFreq = zeros(file_num,1);
pulseFreq  = zeros(file_num,1);
ipi = zeros(file_num,1);


%get file names and sample sizes for fhZ and shZ
fprintf('Grabbing file names and data sizes\n');
for y = 1:file_num
    file = dir_list(y).name; %pull out the file name
    [~,root,ext] = fileparts(file);
    path_file = [folder file];
    TG = strcmp(ext,'.mat');
    
    if TG == 1
        i = i+1;
%         if strfind(root,'_ipi_ipiStatsLomb') ~= 0
            %get plot data and limits
            load(path_file,'maxFFT','pMFFT','ipiStatsLomb','ipiStatsLomb','ipiTrains','winnowed_sine');
            file_names{i} = file;
                      
            sineTrainDuration(i) = corr(winnowed_sine.start,winnowed_sine.stop-winnowed_sine.start);
            pT.d = cell2mat(ipiTrains.d)';
            pT.t = cell2mat(ipiTrains.t)';
            pulseTrainDuration(i) = corr(pT.t,pT.d);
            sineFreq(i) = corr(maxFFT.timeAll',maxFFT.freqAll);
            pulseFreq(i)  = corr(pMFFT.timeAll,pMFFT.freqAll);
            ipi(i) = corr(ipiStatsLomb.culled_ipi.t',ipiStatsLomb.culled_ipi.d');

            
%         end
    end
end

LongTermStats.sineTrainDuration = sineTrainDuration(sineTrainDuration~=0);
LongTermStats.pulseTrainDuration = pulseTrainDuration(pulseTrainDuration~=0);
LongTermStats.sineFreq = sineFreq(sineFreq~=0);
LongTermStats.pulseFreq = pulseFreq(pulseFreq~=0);
LongTermStats.ipi = ipi(ipi~=0);
