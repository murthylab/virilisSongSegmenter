function [maleBoutInfo,femaleBoutInfo,run_data] = ANALYZE_VIRILIS_SONG(xsong)
%maxfreq_femalepulse,femaleBoutInfo_no_overlap,female_IPI_no_overlap,freq_femalepulse,freq_malepulse,maxfreq_malepulse,male_pulse_IPI,male_IBI,female_IPI,male_IBI_alone, male_IBI_partner, female_IPI_alone, female_IPI_partner, female_response_time, male_response_time, malebout_overlap_female_final, male_time_singing, female_time_singing, relative_time_singing]
[maleBoutInfo,femaleBoutInfo,run_data] = segmentVirilisSong(xsong);
end

%analyze male and female virilis song:

%pulse frequency and IPI analysis:
    % take male bouts, find regions that DO NOT overlap with female, take
    % those regions and find pulseInfoM within those regions - these are
    % the individual male pulses. Analyze these for pulse frequency and IPI
    % to show that male pulse freq and IPI is highly stereotyped
    
    %for female bouts (each "bout" is actually a female pulse), find all
    %female bouts that do not overlap with male bouts, take these, and run
    %pulse frequency analysis (IPI analysis done below)
    %to show that female pulse frequency is more variable
    
%times of male/female pulses
    %we have starts/stops of male bouts in maleBoutInfo (w0 and w1)
    %we have starts/stops of female pulses in femaleBoutInfo (w0 and w1)
    %for even those pulses that overlap with male bouts
    
    %from these two, we can get the IBIs of male song and IPIs of female
    %song
    
    %now we need a coordination score. how coordinated are male/female
    %song?
        %1)examine the difference in IBI or IPI for when male/female sings
        %alone (some definition - for example, for male song, look for several seconds that contain only male song) or with a partner
        
        %2)look at the variance in male IBI or female IPI when they sing
        %alone or with a partner
        
        %3)look at intervals between a male bout and the start of the
        %closest female song (and vice versa) - call this response time (want to calculate this reponse time both to the begining of the male or female song or to the end).
        %compare this to male IBI or female IPI.

%**all times returned are in ms**
        
% %SOME PARAMETERS:
% Fs=10000;
% T = 1/Fs;
% samples=length(xsong);
% 
% A = exist('maleBoutInfo');
% B = exist('femaleBoutInfo');
% if A==1 & B==1;    
% %%
% %collect all male bouts and find those female bouts that overlap with male:
% r=1;
% femalepulse_in_male=[];
% malebout_overlap_female =[];
% for n=1:length(maleBoutInfo.x);
% w0 = maleBoutInfo.w0(n);
% w1 = maleBoutInfo.w1(n);
% I = find(femaleBoutInfo.wMax > w0 & femaleBoutInfo.wMax < w1);
% a = isempty(I);
% if a == 1;
%     continue
% else
% for m = 1:length(I);    
% femalepulse_in_male(r) = I(m); %these are the indices of femaleBoutInfo that have female pulses that overlap with male song
% r=r+1;
% end
% malebout_overlap_female(r) = n; %these are the indices of maleBoutInfo that also contain female song
% end
% end
% malebout_overlap_female_final = find(malebout_overlap_female);
% %collect male pulses:
% r=1;
% malepulses_times=[];
% for n=1:length(maleBoutInfo.x);   
%     a = malebout_overlap_female;
%     M = find(a==n);
%     MM = isempty(M);
%     if MM == 0; %if a==n %is female pulse overlap
%         continue
%     else
%         w0 = maleBoutInfo.w0(n);
%         w1 = maleBoutInfo.w1(n);
%         I = find(run_data.pulseInfo.wc > w0 & run_data.pulseInfo.wc < w1);
%         malepulses_times(r:r+length(I)-1) = run_data.pulseInfo.wc(I); %these are the wc's of pulseInfoM that contain true male pulses, without overlaps with female pulses
%         r = r + length(I);
%     end
% end
% 
% A = isempty(malepulses_times);
% if A == 1; 
%     %collect male pulses regardless of overlap:
%     r=1;
%     malepulses_times=[];
%     for n=1:length(maleBoutInfo.x);   
%             w0 = maleBoutInfo.w0(n);
%             w1 = maleBoutInfo.w1(n);
%             I = find(run_data.pulseInfo.wc > w0 & run_data.pulseInfo.wc < w1);
%             malepulses_times(r:r+length(I)-1) = run_data.pulseInfo.wc(I); %these are the wc's of pulseInfoM that contain true male pulses, without overlaps with female pulses
%             r = r + length(I);
%     end
% end
%     
% 
% %analyze these male pulses (for pulse frequency and IPI):
% r=1;
% freq_malepulse=[];
% maxfreq_malepulse=[];
% for n=1:length(malepulses_times);
%     a = malepulses_times(n);
%     I = find(run_data.pulseInfo.wc == a); %index of pulseInfoM
%     P = run_data.pulseInfo.x{I}; %one male pulse at a time
%     %first frequency:
%     L = length(P);
%     t = (0:L-1)*T;
%     %NFFT = 2^nextpow2(L);
%     NFFT = 10000;
%     y = fft(P,NFFT);
%     f = Fs/2*linspace(0,1,NFFT/2+1);
%     %figure(2); hold on
%     %plot(f,2*abs(y(1:NFFT/2+1)),'.-b');
%     [~,maxidx] = max(2*abs(y(1:NFFT/2+1)));
%     maxfreq_malepulse(r) = f(maxidx);
%     freq_malepulse(r) = run_data.pulseInfo.fcmx(I(1));
%     r=r+1;
% end
% 
% %Now IPI:
% male_pulse_IPI=[];
% if exist('malepulses_times') == 1;
% male_pulse_IPI = diff(malepulses_times)./10; %in points -- want in ms, so divide by 10
% a = find(male_pulse_IPI < 200);
% male_pulse_IPI = male_pulse_IPI(a);
% end
% %time_singing
% bout_length=[];
% male_time_singing=[];
% for i=1:length(maleBoutInfo.x);
% bout_length(:,i)=length(maleBoutInfo.x{i});
% male_time_singing=sum(bout_length)/Fs;
% end
% %male_PPM=length(run_data.pulseInfoM.wc)/(samples/Fs/60); % want total male pulses
% %%
% %analyze these female pulses (that do not overlap with male song) for frequency:
% maxfreq_femalepulse=[];
% freq_femalepulse=[];
% femaleBoutInfo_no_overlap=[];
% r=1;
% rr=1;
% for n=1:length(femaleBoutInfo.wMax);
%     a = femalepulse_in_male;
%     M = find(a==n);
%     MM = isempty(M);
%     if MM == 0; %if a==n %if there is female pulse in male
%         continue
%     else
%     A = femaleBoutInfo.x{n};
%     w0 = femaleBoutInfo.w0(n);
%     w1 = femaleBoutInfo.w1(n);
%     
%     I = find(run_data.pulseInfo.wc > w0 & run_data.pulseInfo.wc < w1);
%     if isempty(I) == 0;
%         b = I(1);
%         freq_femalepulse(rr) = run_data.pulseInfo.fcmx(b);
%         rr=rr+1;
%     end
%     
%     L = length(A);
%     t = (0:L-1)*T;
%     %NFFT = 2^nextpow2(L);
%     NFFT=10000;
%     y = fft(A,NFFT)/L;
%     f = Fs/2*linspace(0,1,NFFT/2+1);
%     %figure(2); hold on
%     %plot(f,2*abs(y(1:NFFT/2+1)),'.-m');
%     [~,maxidx] = max(2*abs(y(1:NFFT/2+1)));
%     maxfreq_femalepulse(r) = f(maxidx);
%     femaleBoutInfo_no_overlap(r) = femaleBoutInfo.wMax(n);
%     r=r+1;
%     end
% end
% 
% %%
% %female IPI and male IBI
% female_IPI = [];
% male_IBI = [];
% male_IBI = (diff(maleBoutInfo.wc)./10)';
% a = find(male_IBI < 3000);
% male_IBI = male_IBI(a);
% female_IPI = (diff(femaleBoutInfo.wMax)./10)';
% b = find(female_IPI<500);
% female_IPI = female_IPI(b);
% female_IPI_no_overlap = (diff(femaleBoutInfo_no_overlap)./10)';
% b = find(female_IPI_no_overlap<500);
% female_IPI_no_overlap = female_IPI_no_overlap(b);
% 
% %%
% %======coordination scores========:
%     
% %1) look for several seconds when male sings alone:
% %for each maleBoutInfo.wc, search femaleBoutInfo.wc to see if there is one
% %that is within 2s of it:
% r=1;
% rr=1;
% male_bouts_alone=[];
% male_start_alone=[];
% male_stop_alone=[];
% male_bouts_with_female=[];
% male_start_with_female=[];
% male_stop_with_female=[];
% 
% for n=1:length(maleBoutInfo.wc);
%     A = maleBoutInfo.wc(n);
%     B = find(femaleBoutInfo.wMax < (A + 20000) & femaleBoutInfo.wMax > (A - 20000)); %femaleBoutInfo centers within 2s of this male bout
%     C = isempty(B);
%     if C == 1; %if B is empty, then there is no female song within 2s either side of this male bout, so for this male bout, male is singing alone:
%         male_bouts_alone(r) = n; %index of male bouts where he sings alone
%         male_start_alone(r) = maleBoutInfo.w0(n); %male bout start
%         male_stop_alone(r) = maleBoutInfo.w1(n); %male bout stop
%         r=r+1;
%     elseif C == 0; %if B is not empty, then male is not singing alone
%         male_bouts_with_female(rr) = n;
%         male_start_with_female(rr) = maleBoutInfo.w0(n); %male bout start
%         male_stop_with_female(rr) = maleBoutInfo.w1(n); %male bout stop
%         rr=rr+1;
%     end
% end
% 
% %male IBI for when he sings alone or with a partner:
% male_IBI_alone=[];
% male_IBI_partner=[];
% male_IBI_alone = diff(male_start_alone)./10;
% a = find(male_IBI_alone < 3000);
% male_IBI_alone = male_IBI_alone(a);
% male_IBI_partner = diff(male_start_with_female)./10;
% b = find(male_IBI_partner < 3000);
% male_IBI_partner = male_IBI_partner(b);
% %2) look for several seconds when female sings alone:
% %for each femaleBoutInfo.wc, search maleBoutInfo.wc to see if there is one
% %that is within 2s of it:
% r=1;
% rr=1;
% female_pulses_alone=[];
% female_pulses_with_male=[];
% 
% for n=1:length(femaleBoutInfo.wMax);
%     A = femaleBoutInfo.wMax(n);
%     B = find(maleBoutInfo.wc < (A + 20000) & maleBoutInfo.wc > (A - 20000)); %femaleBoutInfo centers within 2s of this male bout
%     C = isempty(B);
%     if C == 1; %if B is empty, then there is no male song within 2s either side of this female pulse, so for this female pulse, female is singing alone:
%         female_pulses_alone(r) = A; %centers of female pulses where she sings alone
%         r=r+1;
%     elseif C == 0; %if B is not empty, then female is not singing alone
%         female_pulses_with_male(rr) = A;
%         rr=rr+1;
%     end
% end
% 
% %female IPI for when she sings alone or with a partner:
% female_IPI_alone = [];
% female_IPI_partner = [];
% female_PPM_no_overlap=[];
% female_IPI_alone = diff(female_pulses_alone)./10;
% a = find(female_IPI_alone<500);
% female_IPI_alone = female_IPI_alone(a);
% female_IPI_partner = diff(female_pulses_with_male)./10;
% a = find(female_IPI_partner<500);
% female_IPI_partner = female_IPI_partner(a);
% %time_singing
% female_bout_length=[];
% female_time_singing=[];
% for i=1:length(femaleBoutInfo.x);
% female_bout_length(:,i)=length(femaleBoutInfo.x{i});
% female_time_singing=sum(female_bout_length)/Fs;
% end
% 
% if ~isempty(male_time_singing) & ~isempty(female_time_singing);
% relative_time_singing=female_time_singing/male_time_singing;
% else 
%     relative_time_singing=[];
% end
% % female_PPM=length(femaleBoutInfo.wMax)/(samples/Fs/60);
% % female_PPM_no_overlap = length(femaleBoutInfo_no_overlap)/(samples/Fs/60);
% 
% %3)female response time:
% %time between first pulse in male bout and closest next female pulse center
% %overlaps are included here
% female_response_time=[];
% r=1;
% for n=1:length(femaleBoutInfo.wMax);
%     if n==1;
%         continue
%     end
%     A=femaleBoutInfo.wMax(n); %female bout center
%     AA=femaleBoutInfo.wMax(n-1); %previous female bout center
%     
%     B = find(maleBoutInfo.wc < A & maleBoutInfo.wc > AA); %find the male bout between these two female pulses (if there is one)
%     C = isempty(B);
%     if C == 0; %if B is not empty
%     m = length(B);
%     mm = B(m); %take the last male bout from the ones found - this would be the one closest to the female pulse, A
%     zz=find(run_data.pulseInfo.wc>maleBoutInfo.w0(mm) & run_data.pulseInfo.wc<maleBoutInfo.wc(mm));%find all pulses from beginning to middle of male bout
%     if isempty(zz) 
%         continue 
%     else
%     z=run_data.pulseInfo.wc(zz(1,1)); %use the first pulse of the bout as start time of male call
%     female_response_time(r) = (A - z)./10; %finds the time between each female pulse and the closest male bout before it. This is the female response time relative to each male song
%     r=r+1;
%     end
%     end
% end
% a = find(female_response_time < 3000);
% female_response_time = female_response_time(a);
% %4)Do the same thing for male response time - time from female pulse to
% %first pulse center of closest male bout
% male_response_time = [];
% r=1;
% for n=1:length(maleBoutInfo.wc);
%     if n==1;
%         continue
%     end
%     A=maleBoutInfo.w0(n); %male bout center
%     AA=maleBoutInfo.w0(n-1); %previous male bout center
%     zz=find(run_data.pulseInfo.wc>maleBoutInfo.w0(n) & run_data.pulseInfo.wc<maleBoutInfo.wc(n));
%     if isempty(zz) 
%         continue 
%     else
%     z=run_data.pulseInfo.wc(zz(1,1));% first pulse of male bout
%     B = find(femaleBoutInfo.wMax < A & femaleBoutInfo.wMax > AA); %find the female pulse between these two male bouts(if there is one)
%     C = isempty(B);
%     if C == 0; %if B is not empty
%     m = length(B);
%     mm = B(m); %take the last female pulse from the ones found - this would be the one closest to the male bout, A
%     male_response_time(r) = (z - femaleBoutInfo.wMax(mm))./10; %finds the time between each male bout and the closest female pulse before it. This is the male response time relative to each female pulse
%     r=r+1;
%     end
%     end
% end
% a = find(male_response_time < 3000);
% male_response_time = male_response_time(a);
% %%
% %Plot some Things:
% % figure; hist(maxfreq_malepulse,100); title('maxfreq male pulse');
% % figure; hist(male_pulse_IPI,100); title('male pulse IPI');
% % figure; hist(maxfreq_femalepulse,100); title('maxfreq female pulse');
% % 
% % figure; hist(female_IPI,900); title('female IPI all');
% % figure; hist(male_IBI,900); title('male IBI all');
% % 
% % figure; hist(male_IBI_alone,900); title('male IBI alone');
% % figure; hist(male_IBI_partner,900); title('male IBI partner');
% % 
% % figure; hist(female_IPI_alone,900); title('female IPI alone');
% % figure; hist(female_IPI_partner,900); title('female IPI partner');
% % 
% % figure; hist(female_response_time,900); title('female response time');
% % figure; hist(male_response_time,900); title('male response time');
% end
%         