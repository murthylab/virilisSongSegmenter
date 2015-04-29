function [ female_response_time_final] = permutresponse( file, numperms )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

 load(file, 'femaleBoutInfo', 'femaleBoutInfo_no_overlap','maleBoutInfo', 'run_data');
 femalepulses=femaleBoutInfo.wMax;
 %femalepulses= femaleBoutInfo_no_overlap;
 femaleIPI=diff(femalepulses);
%female_response_time_final= NaN(numperms,length(femalepulses));
female_response_time = [];
  for i=1;%:numperms;
%      %femalepulses_perm = max(femalepulses)*rand(length(femalepulses),1);
%      femaleIPI_perm = randperm(length(femaleIPI)); %shuffling IPIs 
%      femalepulses_perm = cumsum(femaleIPI(femaleIPI_perm));
  r=1;
 for n=1:length(femalepulses);
    if n==1;
        continue
    end
    A=femalepulses(n); %female bout center
    AA=femalepulses(n-1); %previous female bout center
    
    B = find(maleBoutInfo.wc < A & maleBoutInfo.wc > AA); %find the male bout between these two female pulses (if there is one)
    C = isempty(B);
    if C == 0; %if B is not empty
    m = length(B);
    mm = B(m); %take the last male bout from the ones found - this would be the one closest to the female pulse, A
    zz=find(run_data.pulseInfo.wc>maleBoutInfo.w0(mm) & run_data.pulseInfo.wc<maleBoutInfo.wc(mm));%find all pulses from beginning to middle of male bout
    if isempty(zz) 
        continue 
    else
    z=run_data.pulseInfo.wc(zz(1,1)); %use the first pulse of the bout as start time of male call
    %z=run_data.pulseInfo.wc(zz(1,end)); %use the last pulse of the bout
    female_response_time(r) = (A - z)./10; %finds the time between each female pulse and the closest male bout before it. This is the female response time relative to each male song
    r=r+1;
    end
    end
 end

a = find(female_response_time < 3000);
female_response_time_final(i,1:length(a)) = female_response_time(a);
%female_response_time_final(1,1:length(a)) = female_response_time(a);
end

