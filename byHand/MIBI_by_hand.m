function [ MIBIW, MIBIWvar, MIBIA, MIBIAvar]...
    = MIBI_by_hand( maletimes, femaletimes,channels );
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

 channel_num=length(channels);

MIBIW=NaN(1000,channel_num);
MIBIA=NaN(1000,channel_num);


 for i=1:channel_num;
     
 femalepulses= femaletimes{i};
 
 malebouts= maletimes{i};

 if ~isempty(malebouts) && ~isempty(femalepulses);
 maleIBI=diff(malebouts(:,1));

    %male response time
    h=1; j=1;
   for u=1:(size(malebouts,1)-1); 
 d=round(malebouts(u,1));
 dd=round(malebouts(u+1,1));
 if dd-d<4000;
 Fbetween= find( femalepulses>d & femalepulses<dd);
 if isempty(Fbetween)
     MIBIA(h,i)=maleIBI(u);
     h=h+1;
 else
     MIBIW(j,i)=maleIBI(u);
     j=j+1;
 end
 end
   end
   
   
 end
 
 if sum(~isnan(MIBIA(:,i)))>10
MIBIAvar(i)=nanvar(MIBIA(:,i));
 else MIBIAvar(i)=NaN;
 end
 if sum(~isnan(MIBIW(:,i)))>10
MIBIWvar(i)=nanvar(MIBIW(:,i));
 else MIBIWvar(i)=NaN;
 end
     
 end
 
 
 
   
   