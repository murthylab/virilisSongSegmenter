function [catVar_final,catVar_median] = concatVarFromFiles(vName)
%% import single variables from multiple mat files from variables in a single folder

fList = what;
fList = fList.mat;
clear num;
for i = 1:length(fList);
    fStr = fList{i};
%     num(i,1) = str2double(fStr(strfind(fStr, 'female_workspace')+17:strfind(fStr,'.mat')-1));%for ground truthing files
    num(i,1) = str2double(fStr(strfind(fStr, 'ch')+2:strfind(fStr, '.mat')-1));
    %num(i,1) = str2double(fStr(strfind(fStr, 'ch')+2:strfind(fStr, '.mat')-3)); % for split files
end
%%
 %num=unique(num);
numSort = sort(num);
catVar = cell(length(fList)/2);
%i = 1:length(fList);
for i = 1:length(fList);
    load(fList{i}', vName);
    eval(['catVar{(num(i) == numSort)} = ' vName ';']); 
end

%%remove irrelevant channels

for n=[1:length(fList)]; % channels within daq for manipulation of interest
catVar_final{n}=catVar{n};
end
%% cut values above a threshold
% u_threshold = 5000;
% l_threshold = -100;
for i=1:length(catVar_final);
%     a=catVar_final{i}<u_threshold;
%     b=catVar_final{i}>l_threshold;
    catVar_final{i}=catVar_final{i};%(a & b);
end
%% find median for each channel
catVar_median=[];
for i=1:length(catVar_final);
    catVar_median(i,1)=median(catVar_final{i});
end
