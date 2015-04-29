function [maleBoutInfo,femaleBoutInfo,run_data,maxfreq_femalepulse,maxfreq_malepulse,male_pulse_IPI] = ANALYZE_VIRILIS_SONG(xsong,xempty)


[maleBoutInfo,femaleBoutInfo,run_data] = segmentVirilisSong(xsong,xempty);

%analyze male and female virilis song:

%pulse frequency and IPI analysis:
    % take male bouts, find regions that DO NOT overlap with female, take
    % those regions and find pulseInfoM within those regions - these are
    % the individual male pulses. Analyze these for pulse frequency and IPI
    % show that male pulse freq and IPI is highly stereotyped
    
    %for female bouts (each "bout" is actually a female pulse), find all
    %female bouts that do not overlap with male bouts, take these, and run
    %pulse frequency analysis (IPI analysis done below)
    %show that female pulse frequency is more variable
    
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

%SOME PARAMETERS:
Fs=10000;
T = 1/Fs;
%%
%collect all male bouts and find those female bouts that overlap with male:
r=1;
femalepulse_in_male=[];
malebout_overlap_female =[];
for n=1:length(maleBoutInfo.x);
w0 = maleBoutInfo.w0(n);
w1 = maleBoutInfo.w1(n);
I = find(femaleBoutInfo.wc > w0 & femaleBoutInfo.wc < w1);
a = isempty(I);
if a == 1;
    continue
else
femalepulse_in_male(r) = I; %these are the indices of femaleBoutInfo that have female pulses that overlap with male song
malebout_overlap_female(r) = n; %these are the indices of maleBoutInfo that also contain female song
r=r+1;
end
end

%collect male pulses:
r=1;
malepulses_times=[];
for n=1:length(maleBoutInfo.x);   
    a = malebout_overlap_female;
    M = find(a==n);
    MM = isempty(M);
    if MM == 0; %if a==n
        continue
    else
        w0 = maleBoutInfo.w0(n);
        w1 = maleBoutInfo.w1(n);
        I = find(run_data.pulseInfoM.wc > w0 & run_data.pulseInfoM.wc < w1);
        malepulses_times(r:r+length(I)-1) = run_data.pulseInfoM.wc(I); %these are the wc's of pulseInfoM that contain true male pulses, without overlaps with female pulses
        r = r + length(I);
    end
end

%analyze these male pulses (for pulse frequency and IPI):
r=1;
maxfreq_malepulse=[];
for n=1:length(malepulses_times);
    a = malepulses_times(n);
    I = find(run_data.pulseInfoM.wc == a); %index of pulseInfoM
    P = run_data.pulseInfoM.x{I}; %one male pulse at a time
    %first frequency:
    L = length(P);
    t = (0:L-1)*T;
    NFFT = 2^nextpow2(L);
    y = fft(P,NFFT);
    f = Fs/2*linspace(0,1,NFFT/2+1);
    %figure(2); hold on
    %plot(f,2*abs(y(1:NFFT/2+1)));
    [~,maxidx] = max(2*abs(y(1:NFFT/2+1)));
    maxfreq_malepulse(r) = f(maxidx);
    r=r+1;
end

%Now IPI:
male_pulse_IPI = diff(malepulses_times)./10; %in points -- want in ms, so divide by 10

%%
%analyze these female pulses (that do not overlap with male song) for frequency:
maxfreq_femalepulse=[];
r=1;
for n=1:length(femaleBoutInfo.wc);
    a = femalepulse_in_male;
    M = find(a==n);
    MM = isempty(M);
    if MM == 0; %if a==n
        continue
    else
    A = femaleBoutInfo.x{n};
    L = length(A);
    t = (0:L-1)*T;
    NFFT = 2^nextpow2(L);
    y = fft(A,NFFT)/L;
    f = Fs/2*linspace(0,1,NFFT/2+1);
    %hold on
    %plot(f,2*abs(y(1:NFFT/2+1)),'m');
    [~,maxidx] = max(2*abs(y(1:NFFT/2+1)));
    maxfreq_femalepulse(r) = f(maxidx);
    r=r+1;
    end
end
%%

% %%
% figure(2); title('malebout frequency');
% maxfreq_malebout=[];
% for n=1:length(maleBoutInfo.x);
% A = maleBoutInfo.x{n};
% figure(4); hold on; plot(A);
% L = length(A);
% t = (0:L-1)*T;
% NFFT = Fs/10;%2^nextpow2(L);
% y = fft(A,NFFT);
% f = Fs/2*linspace(0,1,NFFT/2+1);
% figure(2); hold on
% plot(f,2*abs(y(1:NFFT/2+1)));
% [~,maxidx] = max(2*abs(y(1:NFFT/2+1)));
% maxfreq_malebout(n) = f(maxidx);
% end
% %%
% %figure(3); title('femalebout frequency');
% maxfreq_femalebout=[];
% for n=1:length(femaleBoutInfo.x);
% A = femaleBoutInfo.x{n};
% L = length(A);
% t = (0:L-1)*T;
% NFFT = 2^nextpow2(L);
% y = fft(A,NFFT)/L;
% f = Fs/2*linspace(0,1,NFFT/2+1);
% hold on
% plot(f,2*abs(y(1:NFFT/2+1)),'m');
% [~,maxidx] = max(2*abs(y(1:NFFT/2+1)));
% maxfreq_femalebout(n) = f(maxidx);
% end
% %%