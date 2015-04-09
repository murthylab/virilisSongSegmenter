function [ norm_overlaps,norm_fPPM ] = overlaps_fPPM( file , channels)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
load(file, 'FPULSE', 'MPULSE','OVERLAP');
channel_num=length(channels);
 norm_overlaps=cell(channel_num,1);
 norm_fPPM=cell(channel_num,1);


  for i=1:channel_num;
  
  femalepulses= FPULSE(:,1)==channels(i);
  femalepulses=sort(FPULSE(femalepulses,2),'ascend');
  
  malebouts=MPULSE(:,1)==channels(i);
  malebouts_start=sort(MPULSE(malebouts,2),'ascend');
  malebouts_stop=sort(MPULSE(malebouts,3),'ascend');
  malebouts=horzcat(malebouts_start,malebouts_stop);
  
  overlaps=OVERLAP(:,1)==channels(i);
  overlaps=sort(OVERLAP(overlaps,2),'ascend');
  
  norm_overlaps{i}=length(overlaps)/length(malebouts(:,1));
  norm_fPPM{i}=length(femalepulses)/(round(max(femalepulses))-round(min(femalepulses)));
 
 
 

end

