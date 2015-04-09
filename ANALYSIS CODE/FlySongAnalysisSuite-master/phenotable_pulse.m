function [phenotable] = phenotable_pulse(folder, names_file, output_file)

%Read all the PS files produced by Process_wav_Song which are contained
%within a folder and builds an array with all the IPIs combined.


dir_list = dir(folder);
file_num = length(dir_list);
sep = filesep;

fly_names = names_file;


%%%Add variables here
%k = 1;
phenotable = zeros(2,length(fly_names));
%ind = [];

for y = 1:file_num
    file = dir_list(y).name;
    [path,name,ext] = fileparts(file);
    path_file = [folder sep file];
    TG = strcmp(ext,'.mat');
    if TG == 1
        fprintf(['Reading workspace from file %s.\n'], file)
        load(path_file, 'ipiStatsLomb', 'ipi', 'pMFFT'); %Variables to be loaded
		
		%%%%%Add here whatever you want the code to do

        for i = 1:length(fly_names)
            
            parsed_filename = textscan(char(fly_names{i}(6:length(fly_names{i}))),'%s','Delimiter','_');
            ind_name = textscan(char(name), '%s', 'Delimiter', '_');
            
            if (isequal(char(parsed_filename{1}(1)),char(ind_name{1}(2)))) == 1
                
                %mean culled ipi
                phenotable(1,i) = ipiStatsLomb.ipiStats.mu1./11;  
                
                %kernel mode ipi.d 
                phenotable(2,i) = kernel_mode(ipi.d./11, 20:1:180);
                
                %kernel mode pMFFT
                phenotable(3,i) = kernel_mode(pMFFT.freqAll, 1:0.01:1000);
                
                continue
            end
        end
        
		
       
        

    end
    
end


tblwrite(phenotable', genvarname({'mu1', 'kernel_modes_ipi_d', 'kernel_modes_pMFFT'}), char(fly_names'), output_file, ',');
