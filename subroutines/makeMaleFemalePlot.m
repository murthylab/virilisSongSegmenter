function makeMaleFemalePlot(data,malepulseInfo,femalepulseInfo)
%Makes plot of called male/female regions
%Inputs:
%   data -> 1d time series
%   malepulseInfo -> male pulse information returned by segmentVirilisSong
%   femalepulseInfo -> female pulse information returned by segmentVirilisSong
%
% (C) Gordon J. Berman, Jan Clemens, Kelly M. LaRue, and Mala Murthy, 2015
%     Princeton University
    

    
    N = length(data);
    male_regions = false(N,1);
    female_regions = false(N,1);
    
    for i=1:length(malepulseInfo.w0)
        male_regions(malepulseInfo.w0(i):malepulseInfo.w1(i)) = true;
    end
    
    for i=1:length(femalepulseInfo.w0)
        female_regions(femalepulseInfo.w0(i):femalepulseInfo.w1(i)) = true;
    end
    
    
    male_pulses = bwconncomp(male_regions & ~female_regions);
    female_pulses = bwconncomp(female_regions & ~male_regions);
    both_pulses = bwconncomp(male_regions & female_regions);
    
    hold on
    if male_pulses.NumObjects > 0
        cc = [0 0 1];
        for i=1:male_pulses.NumObjects
            x = male_pulses.PixelIdxList{i}(1);
            y = male_pulses.PixelIdxList{i}(end);
            rectangle('Position',[x -1 y-x+1 2],'facecolor',cc,'edgecolor',cc);
        end
    end
    
    if female_pulses.NumObjects > 0
        cc = [1 0 0];
        for i=1:female_pulses.NumObjects
            x = female_pulses.PixelIdxList{i}(1);
            y = female_pulses.PixelIdxList{i}(end);
            rectangle('Position',[x -1 y-x+1 2],'facecolor',cc,'edgecolor',cc);
        end
    end
    
    if both_pulses.NumObjects > 0
        cc = [0 1 0];
        for i=1:both_pulses.NumObjects
            x = both_pulses.PixelIdxList{i}(1);
            y = both_pulses.PixelIdxList{i}(end);
            rectangle('Position',[x -1 y-x+1 2],'facecolor',cc,'edgecolor',cc);
        end
    end
    
    plot(data,'k-')
    
    
    ylim([-.3 .3])