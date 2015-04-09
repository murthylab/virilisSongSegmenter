folder  = '/Users/sternd/Documents/Projects/mel-all-14Sept12/';
dir_list = dir(folder);
file_num = length(dir_list);
allipi = cell(1,file_num);

for y = 1:file_num
    file = dir_list(y).name; %pull out the file name
    [~,root,ext] = fileparts(file);
    path_file = [folder file];
    TG = strcmp(ext,'.mat');
    
    if TG == 1 %if it is a .mat file
        i = i+1;
            %get plot data and limits
            load(path_file,'ipi');
            allipi{i} = ipi.d;
    end
end

allipi = cell2mat(allipi);
ipi = allipi(allipi<.2e4);
[obj,residuals,Z] = gmixPlot(ipi',4,[],1000,[],1);

den = sum(obj.PComponents([3 4]));
mixprops = obj.PComponents([3 4]) / den;
mu = obj.mu([3 4]);
std= obj.Sigma([3 4]);
objnew = gmdistribution(mu,std,mixprops);
prob = cdf(objnew,ipi');
culled_ipi = (ipi(prob > .025 & prob < .975));
min(culled_ipi)

ans =

   293

max(culled_ipi)

ans =

   495
   
%%%
%clear old ipiStats
%%%
folder  = '/Users/sternd/Documents/Projects/mel-all-14Sept12/';
dir_list = dir(folder);
file_num = length(dir_list);

for y = 1:file_num
    file = dir_list(y).name; %pull out the file name
    [~,root,ext] = fileparts(file);
    path_file = [folder file];
    TG = strcmp(ext,'.mat');
    
    if TG == 1 %if it is a .mat file
        i = i+1;
            %get plot data and limits
            %load(path_file,'ipiStats');
            ipiStats = [];
            save(path_file,'ipiStats','-append')%save all variables in original file
    end
end

   

   
   
   
%%%
%cull ipis
%%%
folder  = '/Users/sternd/Documents/Projects/mel-all-14Sept12/';
dir_list = dir(folder);
file_num = length(dir_list);


for y = 1:file_num
    file = dir_list(y).name; %pull out the file name
    [~,root,ext] = fileparts(file);
    path_file = [folder file];
    TG = strcmp(ext,'.mat');
    
    if TG == 1 %if it is a .mat file
        i = i+1;
            %get plot data and limits
            load(path_file);
            culled_ipi.d = ipi.d(ipi.d > 293 & ipi.d < 495);
            culled_ipi.t = ipi.t(ipi.d > 293 & ipi.d < 495);
            
            W = who('-file',path_file);
            varstruc =struct;
            for ii = 1:numel(W)
                varstruc.(W{ii}) = eval(W{ii});
            end
            
            varstruc.ipiStats.culled_ipi.d= culled_ipi.d;
            varstruc.ipiStats.culled_ipi.t= culled_ipi.t;
            
            varstruc.ipiStats.variables.date = date;
            varstruc.ipiStats.variables.time = clock;
            save(path_file,'-struct','varstruc','-mat')%save all variables in original file

    end
end

   
   