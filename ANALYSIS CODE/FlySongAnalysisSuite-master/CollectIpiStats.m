function [ipiStatsAll,file_names,ipiTrainsData,ipiStatsAll.TrainsD,ipiTrainsTime,ipiStatsAll.TrainsT]  = CollectIpiStats(folder)


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
            load(path_file,'ipiStatsLomb','ipiTrains');
            file_names{i} = file;
          
            ipiStats = ipiStatsLomb.ipiStats;
            culled_ipi = ipiStatsLomb.culled_ipi;
            
            mu1(i) = ipiStats.mu1;
            mu2(i) = ipiStats.mu2;
            Sigma1(i) = ipiStats.S1;
            Sigma2(i) = ipiStats.S2;
            N(i) = numel(culled_ipi.d);
            ipiTrainsData{i} = ipiTrains.d;
            ipiTrainsTime{i} = ipiTrains.t;
%         end
    end
end

ipiStatsAll.mu1 = mu1(mu1~=0);
ipiStatsAll.mu2 = mu2(mu2~=0);
ipiStatsAll.Sigma1 = Sigma1(Sigma1~=0);
ipiStatsAll.Sigma2 = Sigma2(Sigma2~=0);
ipiStatsAll.N = N(Sigma2~=0);
file_names(cellfun('isempty',file_names))=[];
ipiTrainsData(cellfun('isempty',ipiTrainsData))=[];
ipiStatsAll.TrainsD = ipiTrainsData;
ipiTrainsTime(cellfun('isempty',ipiTrainsTime))=[];
ipiStatsAll.TrainsT = ipiTrainsTime;