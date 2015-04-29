function [ MMRT, MMRTM1perm, MMRTM2perm ] = malemaleRT( male1times, male2times , channels)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% load(file, 'MIPI1', 'MIPI2');


for i=1:channels;
   male1pulses=male1times{i};
   male2pulses=male2times{i};
   
% male1pulses= MIPI1(:,1)==channels(i);
% 
% male2pulses= MIPI2(:,1)==channels(i);
% male2times{i}=male2pulses;
%   male1pulses=sort(MIPI1(male1pulses,2),'ascend');
%   male2pulses=sort(MIPI2(male2pulses,2),'ascend');
%   male1times{i}=male1pulses;
%   male2times{i}=male2pulses;

  %%for full bout annotations
%   maleIBI=diff(male1pulses)';
% if ~isempty(male1pulses) && ~isempty(male2pulses) 
%   %split male starts into trains
%   splittrain=find(maleIBI>100);
%   if ~isempty(splittrain);
%   malebout=NaN(length(splittrain)+1,50);
%   tr1=male1pulses(1:splittrain(1));
%   trend=male1pulses(splittrain(end)+1:end);
%   malebout(1,1:length(tr1))=tr1;
%   g=2;
%   for p=1:length(splittrain)-1;
% tr=male1pulses(splittrain(p)+1:splittrain(p+1));
% if length(tr)~=1;
% malebout(g,1:length(tr))=tr;
% g=g+1;
% end
%   end
% malebout(g,1:length(trend))=trend;
% 
%   end
  
% k=1;
%  for n=1:(size(malebout(:,1))-1);
%   malebout_start=round(malebout(n,1)); 
%   malebout_nextstart=round(malebout(n+1,1)); 
%    next_male2=find(male2pulses>malebout_start & male2pulses<malebout_nextstart,1,'first'); 
% if isempty(next_male2) ||  isempty(find((round(male2pulses(next_male2))-malebout_start)<1500))
%      continue
%  else
%      MMRT{i}(1,k)=round(male2pulses(next_male2))-malebout_start;
%      k=k+1;
%  end
%  end
 
%% for male bout start annotation
 k=1;
 for n=1:(length(male1pulses)-1);
  malebout_start=round(male1pulses(n,1)); 
 
   next_male2=find(male2pulses>malebout_start,1,'first'); 
if isempty(next_male2) ||  isempty(find((round(male2pulses(next_male2))-malebout_start)<1500))
     continue
 else
     MMRT{i}(1,k)=round(male2pulses(next_male2))-malebout_start;
     k=k+1;
 end
 end
 
 %% randomize
 diff1=diff(male1pulses);
 diff2=diff(male2pulses);
 diff1len = randperm(length(diff1));
 diff2len = randperm(length(diff2));%shuffling IPIs 
     male1_perm = cumsum(diff1(diff1len));
     male2_perm = cumsum(diff2(diff2len));
     
k=1; % male2 perm
 for n=1:(length(male1pulses)-1);
  malebout_start=round(male1pulses(n,1)); 
 
   next_male2=find(male2_perm>malebout_start,1,'first'); 
if isempty(next_male2) ||  isempty(find((round(male2_perm(next_male2))-malebout_start)<1500))
     continue
 else
     MMRTM1perm{i}(1,k)=round(male2_perm(next_male2))-malebout_start;
     k=k+1;
 end
 end
 
 k=1; % male1 perm
 for n=1:(length(male1_perm)-1);
  malebout_start=round(male1_perm(n,1)); 
 
   next_male2=find(male2pulses>malebout_start,1,'first'); 
if isempty(next_male2) ||  isempty(find((round(male2pulses(next_male2))-malebout_start)<1500))
     continue
 else
     MMRTM2perm{i}(1,k)=round(male2pulses(next_male2))-malebout_start;
     k=k+1;
 end
 end
end


