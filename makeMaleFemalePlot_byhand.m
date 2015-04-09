function makeMaleFemalePlot_byhand(data,maletimes,femaletimes)

    
    

% 
%     hold on
%     if ~isempty(malepulseInfo.w0)
%         cc = [0 0 1];
%         x = malepulseInfo.w0;
%         y = malepulseInfo.w1;
%         for i=1:length(x)
%             rectangle('Position',[x(i) -1 y(i)-x(i)+1 2],'facecolor',cc,'edgecolor',cc);
%         end
%     end
%     
%     if ~isempty(femalepulseInfo.w0)
%         cc = [1 0 0];
%         x = femalepulseInfo.w0;
%         y = femalepulseInfo.w1;
%         for i=1:length(x)
%             rectangle('Position',[x(i) -1 y(i)-x(i)+1 2],'facecolor',cc,'edgecolor',cc);
%         end
%     end
%     
%     plot(data,'k-')
%     
%     ylim([-.3 .3])


  
    Fs=10000;
    
    N = length(data);
    male_regions = false(N,1);
    female_regions = false(N,1);
    
  
   for i=1:length(maletimes);
        male_regions(maletimes(i,1)*10:maletimes(i,2)*10) = true;
   end
   for i=1:length(femaletimes);
        female_regions(femaletimes(i)*10:(femaletimes(i)*10)+10) = true;
   end
    
    male_pulses = bwconncomp(male_regions & ~female_regions);
    female_pulses = bwconncomp(female_regions & ~male_regions);
    both_pulses = bwconncomp(male_regions & female_regions);
    plot(data,'k-')
    
    hold on
    if male_pulses.NumObjects > 0
       
        for i=1:male_pulses.NumObjects
            x = (male_pulses.PixelIdxList{i}(1))*10;
            y = (male_pulses.PixelIdxList{i}(end))*10;
            plot(data(x:y), 'b')%rectangle('Position',[x -1 y-x+1 2],'facecolor',cc,'edgecolor',cc);
        end
    end
    
    if female_pulses.NumObjects > 0
        
        for i=1:female_pulses.NumObjects
            x = female_pulses.PixelIdxList{i}(1);
            y = female_pulses.PixelIdxList{i}(end);
            plot(data(x:y), 'r')%rectangle('Position',[x -1 y-x+1 2],'facecolor',cc,'edgecolor',cc);
        end
    end
    
    if both_pulses.NumObjects > 0
        cc = [0 1 0];
        for i=1:both_pulses.NumObjects
            x = both_pulses.PixelIdxList{i}(1);
            y = both_pulses.PixelIdxList{i}(end);
            plot(data(x:y), 'g'); %rectangle('Position',[x -1 y-x+1 2],'facecolor',cc,'edgecolor',cc);
        end
    end
    
   
    
    
    ylim([-.3 .3])