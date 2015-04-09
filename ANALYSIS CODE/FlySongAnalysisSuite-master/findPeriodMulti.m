function [fileNames, periodsMulti] = findPeriodMulti(folder,pulseModel_name)
%USAGE [fileNames, periodsMulti] = findPeriodMulti(folder,pulseModel_name)
%calculate dominant frequency in each pulse model in a folder
%pulseModel_name = e.g. 'pulse_model'


%grab models in a folder and put in cell array

pM_name = char(pulseModel_name);

if strcmp(folder(end),'/') == 0
    folder = [folder '/'];
end
dir_list = dir(folder);
file_num = length(dir_list);
i= 0;

fileNames = cell(1,file_num);
periodsMulti = zeros(file_num,1);

%get file names and sample sizes for fhZ and shZ
fprintf('Grabbing file names and calculating trough-to-trough periods\n');
for y = 1:file_num
    file = dir_list(y).name; %pull out the file name
    [~,root,ext] = fileparts(file);
    path_file = [folder file];
    TG = strcmp(ext,'.mat');
    
    if TG == 1
        i = i+1;
%         if strfind(root,'pm') ~= 0
            %get plot data and limits
            
            pMData = load(path_file,pM_name);
            pulse_model = pMData.(pM_name);

%             load(path_file,'pulse_model');
            fileNames{i} = file;
            periodsMulti(i) = findPeriod(pulse_model.fhM);
%         end
    end
end

fileNames(cellfun('isempty',fileNames))=[];
periodsMulti = periodsMulti(periodsMulti~=0);