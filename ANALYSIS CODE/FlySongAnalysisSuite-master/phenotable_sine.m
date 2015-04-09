function [phenotable] = phenotable_sine(folder, names_file, output_file)

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
        load(path_file, 'maxFFT', 'winnowed_sine'); %Variables to be loaded
		
		%%%%%Add here whatever you want the code to do

       
        for i = 1:length(fly_names)
            
            parsed_filename = textscan(char(fly_names{i}(6:length(fly_names{i}))),'%s','Delimiter','_');
            ind_name = textscan(char(name), '%s', 'Delimiter', '_');
            
            if (isequal(char(parsed_filename{1}(1)),char(ind_name{1}(2)))) == 1
                
                %maxFFT kernel mode
                phenotable(1,i) = kernel_mode(maxFFT.freqAll, 140:0.01:250);  
                
                %sine_traons_length
                phenotable(2,i) = kernel_mode(winnowed_sine.stop./11 - winnowed_sine.start./11, 1:1:5000);
                
                continue
            end
        end
        
		
       
        

    end
    
end


tblwrite(phenotable', genvarname({'sine_max_FFT_mode', 'sine_train_lengths'}), char(fly_names'), output_file, ',');

