function [ female_response_times] = frt_by_hand( file, channels )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

 load(file, 'FPULSE', 'MPULSE','OVERLAP');
channel_num=length(channels);

female_response_times= NaN(length(MPULSE(:,1)),(max(channels)));
  for i=1:channel_num;
  
  femalepulses= FPULSE(:,1)==channels(i);
  femalepulses=sort(FPULSE(femalepulses,2),'ascend');
  
  malebouts=MPULSE(:,1)==channels(i);
  malebouts_start=sort(MPULSE(malebouts,2),'ascend');
  malebouts_stop=sort(MPULSE(malebouts,3),'ascend');
  malebouts=horzcat(malebouts_start,malebouts_stop);
  
  overlaps=OVERLAP(:,1)==channels(i);
  overlaps=sort(OVERLAP(overlaps,2),'ascend');
  
  
  j=1;
 for n=1:length(malebouts(:,1));
 male_end=round(malebouts(n,2));
 next_female=find(femalepulses>male_end,1,'first');
 next_female=round(femalepulses(next_female));
 if isempty(next_female) ||  isempty(find((next_female-male_end)<1500))
     continue
 else
     female_response_times(j,channels(i))=next_female-male_end;
     j=j+1;
 end
 end
  end

  

