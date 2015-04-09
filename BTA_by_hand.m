function [ femaletimes_BTA, BTAtimes_Mperm, BTAtimes_Fperm ] = BTA_by_hand( maletimes, femaletimes , channels, numperms);
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

 channel_num=length(channels);
 BTAtimes=cell(1,channel_num); 
 BTAtimes_Mperm=cell(1,channel_num);
 BTAtimes_Fperm=cell(1,channel_num);
 
 for i=1:channel_num;
      
     
     femalepulses= femaletimes{i};
 
 malebouts= maletimes{i};
 if ~isempty(malebouts) && ~isempty(femalepulses);
     
 BTAtimes{i}=NaN(100,length(malebouts(:,1)));
     BTAtimes_Mperm{i}=NaN(100,length(malebouts(:,1))*numperms);
     BTAtimes_Fperm{i}=NaN(100,length(malebouts(:,1))*numperms);
 
 j=1;
 for n=2:(size(malebouts,1)-1);
 a=round(malebouts(n,1));
 aa=round(malebouts(n,2));
 center=(aa+a)/2;
 x=find(femalepulses<(center+2000)& femalepulses>center & femalepulses<(round(malebouts(n+1,1))));
 xx= find(femalepulses>(center-2000)& femalepulses<center & femalepulses>(round(malebouts(n-1,2))));
 if isempty(xx) && isempty(x)
     continue
 else
 
 if isempty(xx) && ~isempty(x)
     c=round(femalepulses(x))-center;
      BTAtimes{i}(1:length(c),j)=c;
     j=j+1;
 end
 if ~isempty(xx) && isempty(x);
     c=round(femalepulses(xx))-center;
      BTAtimes{i}(1:length(c),j)=c;
     j=j+1;
 end
 if ~isempty(xx) && ~isempty(x);
     c=round(femalepulses(x))-center;
     cc=round(femalepulses(xx))-center;
     final=vertcat(c,cc);
      BTAtimes{i}(1:length(final),j)=final;
     j=j+1;
    
 end
 end
 end
 
%randomize both or true randomization?
 for z=1:numperms; %randomize female 
%      num_pulses=length(femalepulses); 
%      femalepulses_perm=rand(num_pulses,1)*max(femalepulses);
    femaleIPI=diff(femalepulses);
     femaleIPI_perm = randperm(length(femaleIPI)); %shuffling IPIs 
     femalepulses_perm = cumsum(femaleIPI(femaleIPI_perm));
%      
 j=1;
 for n=2:(size(malebouts,1)-1);
 a=round(malebouts(n,1));
 aa=round(malebouts(n,2));
 center=(aa+a)/2;
 x=find(femalepulses_perm<(center+2000)& femalepulses_perm>center & femalepulses_perm<(round(malebouts(n+1,1))));
 xx= find(femalepulses_perm>(center-2000)& femalepulses_perm<center & femalepulses_perm>(round(malebouts(n-1,2))));
 if isempty(xx) && isempty(x)
     continue
 else
 
 if isempty(xx) && ~isempty(x)
     c=round(femalepulses(x))-center;
      BTAtimes_Fperm{i}(1:length(c),j)=c;
     j=j+1;
 end
 if ~isempty(xx) && isempty(x);
     c=round(femalepulses(xx))-center;
      BTAtimes_Fperm{i}(1:length(c),j)=c;
     j=j+1;
 end
 if ~isempty(xx) && ~isempty(x);
     c=round(femalepulses(x))-center;
     cc=round(femalepulses(xx))-center;
     final=vertcat(c,cc);
      BTAtimes_Fperm{i}(1:length(final),j)=final;
     j=j+1;
    
 end
 end
 end
 end
j=1;
 for z=1:numperms; %randomize male 
%      num_bouts=length(malebouts(:,1));
%      malebouts_perm=rand(num_bouts,1)*max(malebouts(:,1));
     MBL=round(diff(maletimes{i},1,2));
    maleIBI1=diff(malebouts(:,1));
    
     maleIBI_perm = randperm(length(maleIBI1)); %shuffling IPIs 
     malebouts_perm1 = cumsum(maleIBI1(maleIBI_perm));
     MBL2= MBL(maleIBI_perm);
     malebouts_perm2=malebouts_perm1+MBL2(1:length(malebouts_perm1));
     malebouts_perm=horzcat(malebouts_perm1, malebouts_perm2);
     
 for n=2:(size(malebouts_perm,1)-1);
 a=round(malebouts_perm(n,1));
 aa=round(malebouts_perm(n,2));
 center=(aa+a)/2;
%center=malebouts_perm(n);
 x=find(femalepulses<(center+2000)& femalepulses>center & femalepulses<(round(malebouts_perm(n+1,1))));
 xx= find(femalepulses>(center-2000)& femalepulses<center & femalepulses>(round(malebouts_perm(n-1,1))));
 if isempty(xx) && isempty(x)
     continue
 else
 
 if isempty(xx) && ~isempty(x)
     c=round(femalepulses(x))-center;
      BTAtimes_Mperm{i}(1:length(c),j)=c;
     j=j+1;
 end
 if ~isempty(xx) && isempty(x);
     c=round(femalepulses(xx))-center;
      BTAtimes_Mperm{i}(1:length(c),j)=c;
     j=j+1;
 end
 if ~isempty(xx) && ~isempty(x);
     c=round(femalepulses(x))-center;
     cc=round(femalepulses(xx))-center;
     final=vertcat(c,cc);
      BTAtimes_Mperm{i}(1:length(final),j)=final;
     j=j+1;
    
 end
 end
 end
 end





 end
 end
 
 femaletimes_BTA=group_hist(BTAtimes);
  BTAtimes_Mperm=group_hist(BTAtimes_Mperm);
  BTAtimes_Fperm=group_hist(BTAtimes_Fperm);
end
