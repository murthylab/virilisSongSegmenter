files = findImagesInFolder('/Volumes/FantomHD/FlySongSegmenterVirilis/KellyData/','.daq');
files2 = findAllImagesInFolders('/Volumes/Data_Disk2/Kelly_data/new_daq/','.daq');
files = [files;files2];



save_path = '/Volumes/Data_Disk2/Kelly_data/';

L = length(files);
splits = zeros(L,1);
splits(25) = 1.26e7;
splits(26) = 1.106e7;
splits(27) = 1.357e7;
splits(29) = 1.2e7;
splits(30) = 1.094e7;

%unix('osascript /Users/gberman/checkCPU.scpt');

L = length(files);
for i=43:43
    
    if i ~= 12 && i ~= 23 && i~=24 && i~=28
        
        if splits(i) == 0
            
            fprintf(1,['Running #%3i out of ' num2str(L) '\n\t'],i);
            tic;
            Process_daq_Song_virilis(files{i},[],save_path);
            b = toc;
            b = b/60;
            fprintf(1,'\t\t Running Time = %6f minutes\n',b);
            
        else
            
            fprintf(1,['Running #%3i out of ' num2str(L) ', Split #1\n\t'],i);
            tic;
            Process_daq_Song_virilis(files{i},[1 splits(i)],save_path);
            b = toc;
            b = b/60;
            fprintf(1,'\t\t Running Time = %6f minutes\n',b);
            
            
            fprintf(1,['Running #%3i out of ' num2str(L) ', Split #2\n\t'],i);
            tic;
            name = Process_daq_Song_virilis(files{i},splits(i)+1,save_path,2);
            b = toc;
            b = b/60;
            fprintf(1,'\t\t Running Time = %6f minutes\n',b);
                        
            
        end
    end
end