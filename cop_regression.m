function [ normFPNpre, normFPNpost, normMBNpre, normMBNpost, pre_bins, post_bins,FPN, MBN ] = ...
    cop_regression( maletimes, femaletimes, coptimes );
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
interval=10000;
normFPNpre=NaN(30,100);
normFPNpost=NaN(30,100); 
normMBNpre=NaN(30,100);
normMBNpost=NaN(30,100);
post_bins=NaN(30,100);
pre_bins=NaN(30,100);

for i=1:length(maletimes);
    if ~isnan(coptimes(i));
FPN=[];
MBN=[];
FPNp=[];
MBNp=[];
normFPNpre1=[];
normMBNpre1=[];
    malebouts=maletimes{i};
    femalepulses=femaletimes{i};
    
    cop_pre=max(femalepulses(find (femalepulses <coptimes(i),1,'last')), malebouts(find(malebouts(:,2)<coptimes(i),1,'last'),1));
   
    song_end=max(max(malebouts(:,2)),max(femalepulses));
  
    
    
    pre_binst=[1:interval:cop_pre];
    post_binst=[coptimes(i):interval:song_end];
    
    for n=1:length(pre_binst)-1;
        FPN(:,n)=length(find(femalepulses> pre_binst(n) & femalepulses<pre_binst(n+1)));
        MBN(:,n)=length(find(malebouts(:,1)> pre_binst(n) & malebouts(:,1)<pre_binst(n+1)));
    end
     
    normFPNpre1(i,1:n)=FPN/max(FPN);
    normFPNpre (i, 1:n)= normFPNpre1(i,fliplr(find(~isnan(normFPNpre1(i,:)))));
    normMBNpre1(i,1:n)=MBN/max(MBN);
    normMBNpre(i,1:n)= normMBNpre1(i,fliplr(find(~isnan(normMBNpre1(i,:)))));
    pre_bins(i,1:n)=fliplr(pre_binst(1:n)-cop_pre);
    
%     if ~isempty(post_binst);
%         for z=1:length(post_binst)-1;
%         FPNp(:,z)=length(find(femalepulses> post_binst(z) & femalepulses<post_binst(z+1)));
%         MBNp(:,z)=length(find(malebouts(:,1)> post_binst(z) & malebouts(:,1)<post_binst(z+1)));
%         end
%    
%     
%     normFPNpost(i,1:z)=(FPNp/max(FPNp));
%     normMBNpost(i,1:z)=(MBNp/max(MBNp));
%     post_bins(i,1:z)=(post_binst(1:z)-cop_pre);
%     
%     end
        
    

    figure(1); plot(pre_bins(i,1:length(normFPNpre(i,:))),normFPNpre(i,:),'r'); hold on;
    figure(2); plot(pre_bins(i,1:length(normMBNpre(i,:))),normMBNpre(i,:),'b'); hold on;
    
    
%     if ~isempty(post_binst);
%     figure(3); plot(post_bins{i}(1:length(normFPNpost{i})),normFPNpost{i},'r'); hold on;
%     figure(4); plot(post_bins{i}(1:length(normMBNpost{i})),normMBNpost{i},'b'); hold on;
%     end
    end
end
end

