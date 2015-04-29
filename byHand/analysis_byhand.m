function [femaletimes, overlaps, femaleIPI, femaleIPIalone, femaleIPIwith,...
    femalePPS, maletimes, maletimesalone,maletimeswith, femaletimesalone,...
    femaletimeswith, maleIBI, maletimesaloneIBI, maletimeswithIBI,maleboutlength, ...
    femaleBTA, femaleRT,maleRT, femalePN, maleBN] = analysis_byhand(file,...
    channels, samples, Fs, split);
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here



load(file,'FPULSE', 'MPULSE','OVERLAP');
channel_num=length(channels);
femaletimes=[];
overlap=[];
overlaps=NaN(1,max(channel_num));
femaleIPI=[];
femalePPS=[];
maletimes=cell(1,channel_num);
femaletimes=cell(1,channel_num);
maleIBI=[];
maletrain=[];
maleboutlength=[];
femaleBTA=[];
femaleRT=[];
femalepulses=[];
malebouts=[];
maletimesalone=[];
maletimeswith=[];
maletimesaloneIBI=[];
maletimeswithIBI=[];
 femaleIPIalone=[];
 femaleIPIwith=[];
 femaletimesalone=[]; 
 femaletimeswith=[];
 femalePN=NaN(1,max(channel_num));
 maleRT=[];
 maleBN=NaN(1,max(channel_num));
 
 time=samples/Fs;
 
  for i=1:channel_num; 
  
  % female parameters
  if ~isempty(FPULSE);
  femalepulses= FPULSE(:,1)==channels(i);
  femalepulses=sort(FPULSE(femalepulses,2),'ascend');
  if ~isempty(OVERLAP);
  overlap=OVERLAP(:,1)==channels(i);
  overlap=sort(OVERLAP(overlap,2),'ascend');
  femalepulses=sort(vertcat(femalepulses,overlap),'ascend');
  end
  if nargin==5
          femalepulses=femalepulses(femalepulses>split(1) & femalepulses<split(end));
  end
  if ~isempty(femalepulses);
femaletimes{i}=femalepulses;
femaleIPI_all=diff(femaletimes{i})';
femaleIPI{i}=femaleIPI_all(femaleIPI_all<500);
femalePPS{i}=(length(femaletimes{i}))/(((femaletimes{i}(end,1))-(femaletimes{i}(1,1)))./1000);

  end
  end
  
  % male parameters
  if ~isempty(MPULSE);
  malebouts=MPULSE(:,1)==channels(i);
  malebouts_start=sort(MPULSE(malebouts,2),'ascend');
  malebouts_stop=sort(MPULSE(malebouts,3),'ascend');
  if nargin==5
      malebouts_start=malebouts_start(malebouts_start>split(1) & malebouts_start<split(end));
      malebouts_stop=malebouts_stop(malebouts_stop>split(1) & malebouts_stop<split(end));
      malebouts=horzcat(malebouts_start,malebouts_stop);
  end
  malebouts=horzcat(malebouts_start,malebouts_stop);
  if isempty(malebouts);
      continue
  else     
  maletimes{i}=malebouts;
  maleIBI_all=diff(malebouts_start)';
  maleIBI{i}=maleIBI_all(maleIBI_all<5000);
  %split male starts into trains
  splittrain=find(maleIBI_all>5000);
  if ~isempty(splittrain);
  maletrain=NaN(length(splittrain)+1,50);
  tr1=malebouts_start(1:splittrain(1));
  trend=malebouts_start(splittrain(end)+1:end);
  maletrain(1,1:length(tr1))=tr1;
  g=2;
  for p=1:length(splittrain)-1;
tr=malebouts_start(splittrain(p)+1:splittrain(p+1));
if length(tr)~=1;
maletrain(g,1:length(tr))=tr;
g=g+1;
end
  end
maletrain(g,1:length(trend))=trend;
  maleboutlength{i}=(malebouts(:,2)-malebouts(:,1))';
  
  
  else
      maletrain=malebouts_start;
      
  end
  end
  end
  
  
  %separate male song alone versus together
  if ~isempty(maletrain);
  maletimesalone{i}= NaN(length(maletrain(:,1)),50);
 maletimeswith{i}= NaN(length(maletrain(:,1)),50);
 maletimesaloneIBI{i}= NaN(length(maletrain(:,1)),50);
 maletimeswithIBI{i}= NaN(length(maletrain(:,1)),50);
 
 if isempty(femalepulses);
         maletimesalone{i}= maletrain;
         for e=1:size(maletrain);
         maletimesaloneIBI{i}(e,1:length(maletrain(e,:))-1)= diff(maletrain(e,:));
         end
 else
 for m=1:size(maletrain,1);
         if isnan(maletrain(m,:));
         maletimesalone{i}(m)=maletrain(m);
     else
       malestop=find(~isnan(maletrain(m,:)),1,'last');
     b=find(femalepulses>(maletrain(m,1)-1000) & femalepulses<(maletrain(m,malestop)+1000));
    if isempty(b);
        trainalone=maletrain(m,1:end);
        maletimesalone{i}(m,1:length(trainalone))=trainalone;
        maletimesaloneIBI{i}(m,1:length(trainalone)-1)=diff(trainalone);
  
    else
        trainwith=maletrain(m,1:end);
        maletimeswith{i}(m,1:length(trainwith))=trainwith;
        maletimeswithIBI{i}(m,1:length(trainwith)-1)=diff(trainwith);
    end
         end
 end
 end
 end
 

  
 %separate female song alone versus together
 femaletimesalone{i}=NaN(length(femalepulses),1);
 femaletimeswith{i}=NaN(length(femalepulses),1);
 if ~isempty(malebouts);
 for c=1:size(femalepulses,1);
     if isempty(femalepulses);
         femaletimeswith=[];
         femaletimesalone=[];
     else
          b=find(malebouts(:,2)>(femalepulses(c)-2000) & malebouts(:,1)<(femalepulses(c)+2000));
    if isempty(b);
        femaletimesalone{i}(c,1)=femalepulses(c,1);
  
    else
        femaletimeswith{i}(c,1)=femalepulses(c,1);
    end
     end
 end

femaleIPIalone_all=diff(femaletimesalone{i})';
femaleIPIalone{i}=femaleIPIalone_all(femaleIPIalone_all<500);
femaleIPIwith_all=diff(femaletimeswith{i})';
femaleIPIwith{i}=femaleIPIwith_all(femaleIPIwith_all<500);
 
  
  

  
  
  %coordination parameters
  if ~isempty(femalepulses) || ~isempty(malebouts);
     
      
 
 
      
      femaleBTA{i}= NaN(100,length(malebouts(:,1)));
 %female BTA on bout center
 j=1;
 for n=2:(size(malebouts,1)-1);
 a=round(malebouts(n,1));
 aa=round(malebouts(n,2));
 center=(aa+a)/2;
 x=find(femalepulses<(center+2000)& femalepulses>center & femalepulses<(round(malebouts(n+1,1))));
 xx= find(femalepulses>(center-2000)& femalepulses<center & femalepulses>(round(malebouts(n-1,2))));
 if isempty(xx) || isempty(x);
     continue
 else
     c=round(femalepulses(x))-center;
     cc=round(femalepulses(xx))-center;
     final=vertcat(c,cc);
      femaleBTA{i}(1:length(final),j)=final;
     j=j+1;
    
 end
 end
  

  %female response time on bout start
  femaleRT{i}= NaN(1,length(malebouts(:,1)));
   k=1;
 for z=1:(length(malebouts(:,1))-1);
 male_start=round(malebouts(z,1));
 male_nextstart=round(malebouts(z+1,1));
 next_female=find(femalepulses>male_start & femalepulses<male_nextstart,1,'first');
 next_female=round(femalepulses(next_female));
 
 if isempty(next_female) ||  isempty(find((next_female-male_start)<1500))
     continue
 else
     femaleRT{i}(1,k)=next_female-male_start;
     male_end=round(malebouts(z,2));
    % FRT_MBL{i}(1,k)=male_end-male_start;
     k=k+1;
 end
 end
 
 %male response time on previous female pulse
 h=1;
 for u=2:(size(malebouts,1));
 d=round(malebouts(u,1));
 dd= find( femalepulses<d & femalepulses>round(malebouts(u-1,2)),1, 'last');
 if isempty(dd)
     continue
 else
     w=d-femalepulses(dd);
     if w<1500;
      maleRT{i}(1,h)=w;
     h=h+1;
     end
 end
 end
  end
 
  end
  
  %pulse numbers
  for y=1:length(femaletimes);
if isempty(femaletimes{y}) && ~isempty(maletimes{y});
      courtship_time= max(maletimes{y}(:,2))-min(maletimes{y}(:,1));
      if courtship_time>=20000;
      maleBN(y)=((length(maletimes{y}(:,2))/((courtship_time/1000))));
      femalePN(y)=0;
      overlaps(y)=0;
      else
          maleBN(y)=0;
      femalePN(y)=0;
      overlaps(y)=0;
      end
  end
  if isempty(maletimes{y}) && ~isempty(femaletimes{y});
      courtship_time=max(femaletimes{y})-min(femaletimes{y});
      if courtship_time>=20000;
      femalePN(y)=((length(femaletimes{y})/((courtship_time/1000))));
      maleBN(y)=0;
      overlaps(y)=0;
      else
          maleBN(y)=0;
      femalePN(y)=0;
      overlaps(y)=0;
      end
  end
  if ~isempty(femaletimes{y}) && ~isempty(maletimes{y});
  courtship_start = min(maletimes{y}(1,1),femaletimes{y}(1,1));
  courtship_end = max (maletimes{y}(end,2), femaletimes{y}(end,1));
  courtship_time=courtship_end-courtship_start;
  if courtship_time>=20000;
  maleBN(y)=((length(maletimes{y}(:,2))/((courtship_time/1000))));
  femalePN(y)=((length(femaletimes{y})/((courtship_time/1000))));
  if ~isempty(overlap);
  overlaps(y)=length(overlap)/length(maletimes{y}(:,2));
  end
  
 if length(maletimes{y}(:,2))>=5 || length(femaletimes{y}(:,1))>=15;
     maleBN(y)=maleBN(y);
     femalePN(y)=femalePN(y);
     overlaps(y)=overlaps(y);
 else
     maleBN(y)=0;
     femalePN(y)=0;
     overlaps(y)=0;
 end
 else
          maleBN(y)=0;
      femalePN(y)=0;
      overlaps(y)=0;
 end
  end
  
  end
  end
  
