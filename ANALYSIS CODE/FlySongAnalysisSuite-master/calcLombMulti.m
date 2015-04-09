function calcLombMulti(folder,alpha_thresh)
if strcmp(folder(end),'/') == 0
    folder = [folder '/'];
end

dir_list = dir(folder);
file_num = length(dir_list);

for y = 1:file_num
    file = dir_list(y).name; %pull out the file name
    [~,root,ext] = fileparts(file);
    path_file = [folder file];
    TG = strcmp(ext,'.mat');
    if TG == 1
%         if strfind(root,'ipi') ~= 0
            
            load(path_file);
            fs = data.fs;
            fprintf([root '\n']);
            %cull pulses using pulse_model
            [lomb] = calcLomb(ipiStats.culled_ipi,fs,alpha_thresh);
            
            W = who('-file',path_file);
            varstruc =struct;
%             load(path_file);
            for ii = 1:numel(W)
                varstruc.(W{ii}) = eval(W{ii});
            end
            varstruc.ipiStatsLomb.lomb= lomb;
            
            varstruc.ipiStatsLomb.variables.date = date;
            varstruc.ipiStatsLomb.variables.time = clock;
            save(path_file,'-struct','varstruc','-mat')%save all variables in original file

%         end
    end
end
