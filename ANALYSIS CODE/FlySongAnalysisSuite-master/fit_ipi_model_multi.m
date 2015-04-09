function fit_ipi_model_multi(folder,pulseInfo_name)
%USAGE fit_ipi_model_multi(folder,pulseInfo_name)
%pulseInfo_name can take 'pulseInfo', 'pulseInfo2', etc.

if strcmp(folder(end),'/') == 0
    folder = [folder '/'];
end

dir_list = dir(folder);
file_num = length(dir_list);

pI_name = char(pulseInfo_name);

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
            
            pI_data = varstruc.(pI_name);
            
            fprintf([root '\n']);
            ipi = fit_ipi_model(pI_data.wc);
            
            varstruc.ipi = ipi;
            varstruc.ipi.variables.pulseInfo_ver = pI_name;
            varstruc.ipi.variables.date = date;
            varstruc.ipi.variables.time = clock;
            save(path_file,'-struct','varstruc','-mat')%save all variables in original file

            
    end
end

