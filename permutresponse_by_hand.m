function [ mrt, frt, frt_Fperm_total,mrt_Fperm_total,frt_Mperm_total,mrt_Mperm_total,FPPB]...
    = permutresponse_by_hand( maletimes, femaletimes, numperms, channels, trigger )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

 channel_num=length(channels);
 frt_Fperm=cell(channel_num,1);
 mrt_Fperm=cell(channel_num,1);
 frt_Mperm=cell(channel_num,1);
 mrt_Mperm=cell(channel_num,1);
  mrt=cell(channel_num,1);
 FPPB=nan(94,205);
 for i=1:channel_num;
     
 femalepulses= femaletimes{i};
 
 malebouts= maletimes{i};

 if ~isempty(malebouts) && ~isempty(femalepulses);
 femaleIPI=diff(femalepulses);
 
    %male response time
    h=1;
   for u=2:(size(malebouts,1)-1); 
 d=round(malebouts(u,1));
 dd= find( femalepulses<d & femalepulses>round(malebouts(u-1,2)),trigger, 'last');
 if malebouts(u,1)-malebouts(u-1,1)<5000;
    if ~isempty(find(femalepulses<d & femalepulses>round(malebouts(u-1,2))));
 FPPB(i,u)= length(find(femalepulses<d & femalepulses>round(malebouts(u-1,2))));
    else FPPB(i,u)=NaN;
    end
 else FPPB(i,u)=NaN;
 end

 if isempty(dd)
     continue
 else
     if length(dd)>=trigger
     w=d-femalepulses(dd(trigger,1));
     if w<1500;
      mrt{i}(h,1)=w;
     h=h+1;
     end
     end
 end
   end
   
   j=1;
    for n=1:length(malebouts(:,1))-1; %female response time
    male_start=round(malebouts(n,1)+210);
    male_nextstart=round(malebouts(n+1,1));
    next_female=find(femalepulses>male_start & femalepulses<male_nextstart,1,'first');
    next_female=round(femalepulses(next_female));
    if isempty(next_female) ||  isempty(find((next_female-male_start)<1500))
     continue
     else
     frt{i}(j,1)=next_female-male_start;
     j=j+1;
    end
    end

 
  frt_Fperm{i}= NaN(length(malebouts(:,1)),numperms);
  mrt_Fperm{i}= NaN(length(malebouts(:,1)),numperms);
%   femaletimes_perm{i}= NaN(100*length(malebouts(:,1)),numperms);
for z=1:numperms; %randomize female 
    
     femaleIPI_perm = randperm(length(femaleIPI)); %shuffling IPIs 
     femalepulses_perm = cumsum(femaleIPI(femaleIPI_perm));

 j=1;
    for n=1:length(malebouts(:,1))-1; %female response time
    male_start=round(malebouts(n,1)+210);
    male_nextstart=round(malebouts(n+1,1));
    next_female=find(femalepulses_perm>male_start & femalepulses_perm<male_nextstart,1,'first');
    next_female=round(femalepulses_perm(next_female));
    if isempty(next_female) ||  isempty(find((next_female-male_start)<1500))
     continue
     else
     frt_Fperm{i}(j,z)=next_female-male_start;
     j=j+1;
    end
    end
    
    h=1;
 for u=2:(size(malebouts,1)-1); %male response time
 d=round(malebouts(u,1));
 dd= find( femalepulses_perm<d & femalepulses_perm>round(malebouts(u-1,2)),trigger, 'last');
 if isempty(dd)
     continue
 else
     if length(dd)>=trigger;
     w=d-femalepulses_perm(dd(trigger,1));
     if w<1500;
      mrt_Fperm{i}(h,1)=w;
     h=h+1;
     end
     end
    
 end
 end

% k=1;
%  for t=1:length(malebouts);
%  a=round(malebouts(t,1));
%  aa=round(malebouts(t,2));
%  x=find(femalepulses_perm<(aa+2000)& femalepulses_perm>aa);
%  xx= find(femalepulses_perm>(a-2000)& femalepulses_perm<a);
%  if isempty(xx) || isempty(x)
%      continue
%  else
%      c=round(femalepulses_perm(x))-aa;
%      cc=round(femalepulses_perm(xx))-a;
%      final=vertcat(c,cc);
%       femaletimes_perm{i}(k:k+length(final)-1,z)=final;
%      k=length(find(~isnan(femaletimes_perm{i}(:,z))));
%     
%  end
%  end


end

maleIBI=diff(malebouts(:,1));
frt_Mperm{i}= NaN(length(malebouts(:,1)),numperms);
  mrt_Mperm{i}= NaN(length(malebouts(:,1)),numperms);
 if ~isempty(maleIBI);
for z=1:numperms; % randomize male
     maleIBI_perm = randperm(length(maleIBI)); %shuffling IPIs 
     malebouts_perm = cumsum(maleIBI(maleIBI_perm));
    
     j=1;
    for n=1:length(malebouts_perm(:,1))-1; %female response time
    male_start=round(malebouts_perm(n,1));
    male_nextstart=round(malebouts_perm(n+1,1));
    next_female=find(femalepulses>male_start & femalepulses<male_nextstart,1,'first');
    next_female=round(femalepulses(next_female));
    if isempty(next_female) ||  isempty(find((next_female-male_start)<1500))
     continue
     else
     frt_Mperm{i}(j,z)=next_female-male_start;
     j=j+1;
    end
    end
    
    h=1;
 for u=2:(size(malebouts_perm,1)-1); %male response time
 d=round(malebouts_perm(u,1));
 dd= find(femalepulses>round(malebouts_perm(u-1)) & femalepulses<d, trigger, 'first');
 if isempty(dd)
     continue
 else
     if length(dd)>=trigger;
     w=d-femalepulses(dd(trigger,1));
     if w<1500;
      mrt_Mperm{i}(h,1)=w;
     h=h+1;
     end
     end
 end
 end

end
 end
 end
 end
frt_Fperm_total=cell2mat(frt_Fperm);
frt_Fperm_total=frt_Fperm_total(:);
a=~isnan(frt_Fperm_total);
frt_Fperm_total=frt_Fperm_total(a);
frt_Mperm_total=cell2mat(frt_Mperm);
frt_Mperm_total=frt_Mperm_total(:);
b=~isnan(frt_Mperm_total);
frt_Mperm_total=frt_Mperm_total(b);
mrt_Fperm_total=cell2mat(mrt_Fperm);
mrt_Fperm_total=mrt_Fperm_total(:);
c=~isnan(mrt_Fperm_total);
mrt_Fperm_total=mrt_Fperm_total(c);
mrt_Mperm_total=cell2mat(mrt_Mperm);
mrt_Mperm_total=mrt_Mperm_total(:);
d=~isnan(mrt_Mperm_total);
mrt_Mperm_total=mrt_Mperm_total(d);
mrt=cell2mat(mrt);
frt=cell2mat(frt');

% femaletimes_perm_total=cell2mat(femaletimes_perm);
% femaletimes_perm_total=femaletimes_perm_total(:);



