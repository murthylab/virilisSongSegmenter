function [ maletrain, femalewithmale, all_pulses, all_pulsesbin, duet_start_malepercent ] = extract_duet( maletimes, femaletimes )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
 duet_start_malepercent=NaN(2,94);
for i=1:length(maletimes);
    
    if ~isempty(maletimes{i}) & ~isempty(femaletimes{i})
        
        %define male train
        malebouts_start=maletimes{i}(:,1);
         maleIBI_all=diff(maletimes{i}(:,1));
        splittrain=find(maleIBI_all>5000);
  if isempty(splittrain);
  maletrain{i}=[];
  femalewithmale{i}=[];
  all_pulses{i}=[];
  all_pulsebin{i}=[];
  else
      maletrain{i}=NaN(length(splittrain)+1,50);
  femalewithmale{i}=NaN(length(splittrain)+1,250);
  all_pulses{i}=NaN(length(splittrain)+1,300);
  all_pulsesbin{i}=NaN(length(splittrain)+1,300);
     
  tr1=malebouts_start(1:splittrain(1));
  trend=malebouts_start(splittrain(end)+1:end);
  maletrain{i}(1,1:length(tr1))=tr1;
  g=2;
  for p=1:length(splittrain)-1;
tr=malebouts_start(splittrain(p)+1:splittrain(p+1));
if length(tr)~=1;
maletrain{i}(g,1:length(tr))=tr;
g=g+1;
end
  end
  end
   
 if ~isempty(maletrain{i})
maletrain{i}(g,1:length(trend))=trend;
        
%find duetting sections
for n=1:sum(~isnan(maletrain{i}(:,1)));
    maletrainregion=maletrain{i}(n,find(~isnan(maletrain{i}(n,:))));
    femalewith=femaletimes{i}(find(femaletimes{i}>(maletrainregion(1,1)-1000) & femaletimes{i}<(maletrainregion(1,end)+1000)));
    if ~isempty(femalewith)
        femalewithmale{i}(n, 1:length(femalewith))=femalewith;
    end
end

 %categorize exhanges
 for n=1:sum(~isnan(maletrain{i}(:,1)));
     if sum(~isnan(maletrain{i}(n,:)))>1 & sum(~isnan(femalewithmale{i}(n,:)))>1
     tmppulse=horzcat(maletrain{i}(n,find(~isnan(maletrain{i}(n,:)))), femalewithmale{i}(n,find(~isnan(femalewithmale{i}(n,:)))));
all_pulses{i}(n,1:length(tmppulse))=sort(tmppulse, 'ascend');
for h=1:length(tmppulse);
if ~isempty(find(maletimes{i}==all_pulses{i}(n,h)))
    all_pulsesbin{i}(n,h)=0;
else
    all_pulsesbin{i}(n,h)=1;
end
end
if sum(diff(all_pulsesbin{i}(n,:)))<=3
    all_pulsesbin{i}(n,:)=NaN;
end
     end
 end
    

 if sum(~isnan(all_pulsesbin{i}(:,1)))>=3
duet_start_malepercent(1,i)= nansum(all_pulsesbin{i}(:,1))/sum(~isnan(all_pulsesbin{i}(:,1)));
duet_start_malepercent(2,i)= sum(~isnan(all_pulsesbin{i}(:,1)));
 end
 end
end
end

