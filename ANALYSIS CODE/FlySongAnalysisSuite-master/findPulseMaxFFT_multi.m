function findPulseMaxFFT_multi(pI,folder)
%USAGE findPulseMaxFFT_multi('culled_pulseInfo','/Users/sternd/Documents/Projects/courtship_song_analysis.w.t.-forpaper/WT_species/mel-all-6Mar/')
if strcmp(folder(end),'/') == 0
    folder = [folder '/'];
end
dir_list = dir(folder);

file_num = length(dir_list);
% pI = eval(pI);

for y = 1:file_num
    file = dir_list(y).name; %pull out the file name
    [~,root,ext] = fileparts(file);
    path_file = [folder file];
    TG = strcmp(ext,'.mat');
    if TG == 1
            W = who('-file',path_file);
            varstruc =struct;
            load(path_file);
            for ii = 1:numel(W)
                varstruc.(W{ii}) = eval(W{ii});
            end
            
            fprintf([root '\n']);
            %calc sine fund freq
            pMFFT = findPulseMaxFFT(eval(pI));
            
            varstruc.pMFFT = pMFFT;
            
            varstruc.pMFFT.variables.date = date;
            varstruc.pMFFT.variables.time = clock;
            save(path_file,'-struct','varstruc','-mat')%save all variables in original file

    end
end

% check_close_pool(poolavail,isOpen);
