function findMaxFFTinBouts_multi(folder,sineORpulse)
%USAGE findMaxFFTinBouts_multi('/Users/sternd/Documents/Projects/courtship_song_analysis.w.t.-forpaper/WT_species/mel-all-6Mar/','pulse')



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
        fprintf([root '\n']);
        
        W = who('-file',path_file);
        varstruc =struct;
        load(path_file);
        for ii = 1:numel(W)
            varstruc.(W{ii}) = eval(W{ii});
        end
        
        data = varstruc.data;
        bouts = varstruc.bouts;
        
        if isempty(sineORpulse) || strcmp(sineORpulse,'sine') == 1
            maxFFT = 'maxFFT';
        elseif strcmp(sineORpulse,'pulse')==1
            maxFFT = 'pMFFT';
        end

        bout_maxFFT = findMaxFFTinBouts(bouts,eval(maxFFT));
        
        if strcmp(maxFFT,'maxFFT') == 1
            varstruc.bout_maxFFT = bout_maxFFT;
            varstruc.bout_maxFFT.variables.date = date;
            varstruc.bout_maxFFT.variables.time = clock;
        elseif strcmp(maxFFT,'pMFFT') == 1
            varstruc.bout_pmaxFFT = bout_maxFFT;
            varstruc.bout_pmaxFFT.variables.date = date;
            varstruc.bout_pmaxFFT.variables.time = clock;
        end
        
        save(path_file,'-struct','varstruc','-mat')%save all variables in original file
    end
end

