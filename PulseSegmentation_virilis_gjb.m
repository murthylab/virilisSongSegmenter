function [pulseInfoF, pulseInfoM, pulseInfo,male_song_times_final,Ps] = PulseSegmentation_virilis_gjb(xsong, xempty, segParams)

%========PARAMETERS=================
% segParams.fc = a; % frequencies examined. These will be
%                   % converted to CWT scales later on.
% 
% segParams.fs = b; % sample rate (in Hz)
% 
% segParams.pulsewindow = c; %factor for computing window around pulse peak (this determines how much of the signal before and after the peak is included in the pulse.)
% 
% xn = xempty;
% noise = d*mean(abs(xn)); %d is set in params file                        
% segParams.wnwMinAbsVoltage = noise; %Minimum Absolute Value of the Voltage = g times the mean
% 
% segParams.mpf = e; %male pulse carrier frequency
% 
% segParams.male = f;
% segParams.female = g;
% segParams.bout = h;
                 
Fs = segParams.fs;

xn = xempty;
noise = segParams.noiseFactor*mean(abs(xn)); %d is set in params file                        
segParams.wnwMinAbsVoltage = noise; %Minimum Absolute Value of the Voltage = g times the mean

sp = segParams;

%% Load the Signals

xs = xsong; %no downsampling
xs  = xs(:);

%% Prepare for CWT
fprintf('PREPARING FOR CWT.\n');

fc  = sp.fc;
fs  = sp.fs;
%Fs = sp.fs;

wvlt = cell(1,1);
%wvlt{1} = 'morl';
wvlt{1} = 'fbsp2-1-2';

sc = zeros(2,numel(fc));

for i = 1:numel(wvlt)
    fprintf('\tComputing scales for %s.\n',wvlt{i});
    sc(i,:) = scales_for_freqs(fc,1/fs,wvlt{i});
end
fprintf('DONE.\n');

%% Perform CWT on Signal
fprintf('PERFORMING CWT SUITE.\n');

cmo = zeros(1,numel(xs)); % Storage for the maximum morlet wavelet
                          % coefficient for each bin.

%cmf = cmo;                % Storage for the maximum frequency b-spline
                          % wavelet coefficient for each bin.

%cmo_sc = cmo;             % Storage for the scale at which the
                          % highest coefficient occured for each bin (morlet).

cmf_sc = cmo;             % Storage for the scale at which the
                          % highest frequency b-spline coefficient occured.
                          
for i= 1:numel(wvlt) %for the two wavelets (now just one)
    fprintf('\t%s\n',wvlt{i});
    tic;
    fprintf('\t\t...on Signal\n');
    Cs = cwt(xs,sc(i,:),wvlt{i}); %wavelet transformation on signal for that scale and that wavelet
    fprintf('\t\tComputing power.\n');
    Ps = Cs.*conj(Cs);
    
    fprintf('\t\tFinding the maximum coefficient for each bin.\n');
    [cs,ci] = max(abs(Cs));    
    if (isequal(wvlt{i},'morl')) %========NOT USED========
        %cmo = cs;
        %[b,a] = butter(7,200/(Fs/2),'low'); %first lowpass filter to get peaks (order 7, 200Hz)
        %cmo_filt = filtfilt(b,a,cmo); %filter
        %cmo_sc = ci;  %best cmo scale
        %[b,a] = butter(7,20/(Fs/2),'low'); %second lowpass filter to get peaks (order 7, 20Hz)
        %cmo_filt_2 = filtfilt(b,a,cmo); %filter
    else %if a frequency b-spline wavelet ====USED====
        cmf = cs;
        cmf_sc = ci;
        [b,a] = butter(7,sp.male/(Fs/2),'low'); %for male song peak detection
        cmf_filt_male = filtfilt(b,a,cmf); %filter
        [b,a] = butter(7,sp.female/(Fs/2),'low'); %for female song peak detection 
        cmf_filt_female = filtfilt(b,a,cmf); %filter
        [b,a] = butter(7,sp.bout/(Fs/2),'low'); %for male song bout detection
        cmf_filt_malebout = filtfilt(b,a,cmf); %filter
        
    end
    tend = toc;
    fprintf('\tDONE after %2.3f sec.\n',tend);
end

%figure; plot(cmo_filt,'g'); hold on; plot(xsong,'k');


%% Peak Finder and Collect Pulses
%findpeaks
%adjust the values after 'minpeakdistance' to change number of peaks detected (could make this a user-defined param)

height = sp.wnwMinAbsVoltage;
%height = height;

[pk_cmf_male,pk_cmf_male_i] = findpeaks(cmf_filt_male,'minpeakheight',height,'minpeakdistance',45); %male pulse peaks should be at least 4.5ms apart

cmf_filt_malebout = smooth(cmf_filt_malebout,751); %was 551 %this smoothing factor is somewhat arbitrary

[~,pk_cmf_bout_i] = findpeaks(cmf_filt_malebout,'minpeakheight',height,'minpeakdistance',600); %male bout peaks should be at least 60ms apart %was 30ms before

cmf_values = sort(cmf_filt_malebout);
baseline = mean(cmf_values(1:2000));

%for debugging:
%figure; plot(xs); hold on; plot(cmf_filt_malebout, 'm'); 
%plot(pk_cmf_bout_i, pk_cmf_bout,'.c');
%hold on; plot(cmf_filt_female, 'g'); plot(pk_cmf_female_i,pk_cmf_female,'.r');

%%
%Make structure arrays for male pulses
np = length(pk_cmf_male);

    zz = zeros(1,np);
    pulseInfo = struct('scmx',zz,'fcmx',zz,'w0',zz,'w1',zz,'wc',zz);
    pulseInfo.scmx = zz;
    pulseInfo.fcmx = zz;
    pulseInfo.wc = zz; % location of peak correlation
    pulseInfo.w0 = zz; % start of window centered at wc
    pulseInfo.w1 = zz; % end of window centered at wc
    pulseInfo.x = cell(1,np); % the signals themselves
    
    %pulseInfo.freq = zz;
%%    
%Collect pulses:

fprintf('COLLECTING ALL PULSES.\n');

nOk=0;
for i=1:length(pk_cmf_male_i);
    a = pk_cmf_male_i(i); %the location of the peak of each pulse
   pulseInfo.wc(i) = a; 
   sc_at_max = sc(2,cmf_sc(a));
   fc_at_max = fc(cmf_sc(a));
   pulseInfo.fcmx(i) = fc_at_max;
   pulseInfo.scmx(i) = sc_at_max;
   m = sp.pulsewindow/2; 
   m = round(m/2);
   
   pulseInfo.w0(i) = round(a-m); 
   if pulseInfo.w0(i) < 0;
       pulseInfo.w0(i) = 1;
   end
  
   pulseInfo.w1(i) = round(a+m);
   if pulseInfo.w1(i) > length(xs);
       pulseInfo.w1(i) = length(xs);
   end

   nOk = nOk+1;
   j0 = max(pulseInfo.w0(i),1);
   j1 = min(pulseInfo.w1(i),numel(xs));
   pulseInfo.x{i} = xs(j0:j1); 
   
end

if (nOk)
  pulseInfo.fcmx = pulseInfo.fcmx(1:nOk);
  pulseInfo.scmx = pulseInfo.scmx(1:nOk);
  pulseInfo.wc = pulseInfo.wc(1:nOk);
  pulseInfo.w0 = pulseInfo.w0(1:nOk);
  pulseInfo.w1 = pulseInfo.w1(1:nOk);
  pulseInfo.x = pulseInfo.x(1:nOk);
end

if pulseInfo.w0==0;
    fprintf('no pulses made it through amplitude winnowing.\n');
    return
end



%%
%(ONLY CRITERIA for finding male song: 3 IPIs in a row < 250 pts)
%pulse_peaks = [];
pulse_peaks = pulseInfo.wc;
IPI = diff(pulse_peaks); %one less than pulse_peaks
m=1;
index_male_pulse_2 = zeros(length(IPI)-4,1);
for n=1:(length(IPI)-4)
    if IPI(n)<250 && IPI(n+1)<250 && IPI(n+2)<250 && IPI(n+3)<250;
        index_male_pulse_2(m) = pulse_peaks(n+1);
        m=m+1;
    end
end
index_male_pulse_2 = index_male_pulse_2(1:(m-1));

% hold on; plot(index_male_pulse_2,0.2,'.g');
% plot(pulseInfo.wc,0.22,'.k');

%%
fprintf('FINDING MALE SONG.\n');
%male_pulse_ind = [];
male_pulse_ind = intersect(pulseInfo.wc, index_male_pulse_2);

male_songs=cell(length(male_pulse_ind),1);
male_song_times=zeros(length(male_pulse_ind),1);
%male_song_reg=[];
%r=1;
for n=1:length(male_pulse_ind);
    f = male_pulse_ind(n);
    AAA=[];
    look_male_song = f-1000:f+1000; %look before and after the index 100ms
        for nn=1:length(look_male_song);
        a = find(pk_cmf_bout_i == look_male_song(nn));
        tf=isempty(a);
            if tf==1;
            continue
            else 
            AAA = a; %this has the index of pk_cmf_bout_i that contains male song
            end
        end
    male_song_loc = pk_cmf_bout_i(AAA);
  
    m = 1300; %look before and after the peak in the male song bout filter, 130ms
    male_song_reg = (male_song_loc-m:male_song_loc+m);
    aa = find(cmf_filt_malebout(male_song_reg)>(baseline)); 
    tf=isempty(aa);
    if tf==1;
        continue
    end
    male_song_reg = male_song_reg(aa);
    
    male_song_times(n,1) = male_song_reg(1);
    male_song_times(n,2) = male_song_reg(length(male_song_reg));
    
    male_songs{n} = xs(male_song_reg);
    %r=r+1;
end

%male_song_times_final=[];
male_song_times_final = unique(male_song_times,'rows');

%for debugging:
%  figure;
%  plot(xsong,'k');
%  hold on
%  plot(male_song_times_final(:,1),0.2,'.c');
%  plot(male_song_times_final(:,2),0.2,'.r');
% hold on; plot(cmf_filt_malebout,'g');
% hold on; plot(cmf_filt_female,'m');
% hold on; plot(cmf_filt_male,'b');
% 
% hold on; plot(male_pulse_ind,0.35,'.k');

%%
%Make structure arrays for male pulses (pulseInfoM)
np = length(pk_cmf_male);

    zz = zeros(1,np);
    pulseInfoM = struct('scmx',zz,'fcmx',zz,'w0',zz,'w1',zz,'wc',zz);
    pulseInfoM.scmx = zz;
    pulseInfoM.fcmx = zz;
    pulseInfoM.wc = zz; % location of peak correlation
    pulseInfoM.w0 = zz; % start of window centered at wc
    pulseInfoM.w1 = zz; % end of window centered at wc
    pulseInfoM.x = cell(1,np); % the signals themselves

m=1;
for i = 1:length(male_song_times_final);
    a=male_song_times_final(i,1); %start time
    b=male_song_times_final(i,2); %stop 
    %I = [];
    I = find(pulseInfo.wc > a & pulseInfo.wc < b);
    n=length(I);
    indices(m:m+n-1) = I;
    m = m+n;
end

m = m-1;

pulseInfoM.wc = pulseInfo.wc(indices);
pulseInfoM.w0 = pulseInfo.w0(indices);
pulseInfoM.w1 = pulseInfo.w1(indices);
pulseInfoM.fcmx = pulseInfo.fcmx(indices);
pulseInfoM.scmx = pulseInfo.scmx(indices);
pulseInfoM.x = pulseInfo.x(indices);

if (m)
  pulseInfoM.fcmx = pulseInfoM.fcmx(1:m);
  pulseInfoM.scmx = pulseInfoM.scmx(1:m);
  pulseInfoM.wc = pulseInfoM.wc(1:m);
  pulseInfoM.w0 = pulseInfoM.w0(1:m);
  pulseInfoM.w1 = pulseInfoM.w1(1:m);
  pulseInfoM.x = pulseInfoM.x(1:m);
end

%%

cmf_filt_female_2 = cmf_filt_female;

for i = 2:length(male_song_times_final);
    a=male_song_times_final(i,1); %start time
    b=male_song_times_final(i,2); %stop time
     cmf_filt_female_2(a:b) = min(cmf_filt_female);
end

amp = sp.wnwMinAbsVoltage * 1.2;

    [pk_cmf_female,pk_cmf_female_i] = findpeaks(cmf_filt_female_2,'minpeakheight',amp,'minpeakdistance',200); %peaks should be at least 20ms apart, 
                                                                                                                        %and should have a minimum peak height of x times the noise 
                                                                                                                        
%hold on; plot(pk_cmf_female_i,pk_cmf_female,'.m');                                                                                                 
%%
%Make structure arrays for female pulses (pulseInfoF)
np = length(pk_cmf_female);

    zz = zeros(1,np);
    pulseInfoF = struct('scmx',zz,'fcmx',zz,'w0',zz,'w1',zz,'wc',zz);
    pulseInfoF.scmx = zz;
    pulseInfoF.fcmx = zz;
    pulseInfoF.wc = zz; % location of peak correlation
    pulseInfoF.w0 = zz; % start of window centered at wc
    pulseInfoF.w1 = zz; % end of window centered at wc
    pulseInfoF.x = cell(1,np); % the signals themselves
    
%%
%Collect female pulses:

fprintf('COLLECTING FEMALE PULSES.\n');

nOk=0;
for i=1:length(pk_cmf_female_i);
     m = pk_cmf_female_i(i);
    LLL = length(cmf_filt_female);
    if m<=200;
        q = min(m+200,LLL);
        [~, mi] = max(cmf_filt_female(1:q));
    else
        q = min(m+200,LLL);
        [~, mi] = max(cmf_filt_female(m-200:q));
    end
    a = m-200 + mi; %the location of each female pulse peak
    if a<1
        a=1;
    end
%     m = pk_cmf_female_i(i);
%     [~, mi] = max(cmf_filt_female(m-200:m+200));
%     a = m-200 + mi; %the location of each female pulse peak
    %a = pk_cmf_female_i(i); %the location of the peak of each pulse
   pulseInfoF.wc(i) = a; 
   sc_at_max = sc(2,cmf_sc(a));
   fc_at_max = fc(cmf_sc(a));
   pulseInfoF.fcmx(i) = fc_at_max;
   pulseInfoF.scmx(i) = sc_at_max;
   
   m = sp.pulsewindow; %sets the window around the pulse
   m = round(m/2);
   %pcndInfo.w0(i) = round(a-m*sc_at_max);
   pulseInfoF.w0(i) = round(a-m); 
   if pulseInfoF.w0(i) < 0;
       pulseInfoF.w0(i) = 1;
   end
   %pcndInfo.w1(i) = round(a+m*sc_at_max); 
   pulseInfoF.w1(i) = round(a+m);
   if pulseInfoF.w1(i) > length(xs);
       pulseInfoF.w1(i) = length(xs);
   end

   nOk = nOk+1;

   j0 = max(pulseInfoF.w0(i),1);
   j1 = min(pulseInfoF.w1(i),numel(xs));
   pulseInfoF.x{i} = xs(j0:j1); 
   
end

if (nOk)
  pulseInfoF.fcmx = pulseInfoF.fcmx(1:nOk);
  pulseInfoF.scmx = pulseInfoF.scmx(1:nOk);
  pulseInfoF.wc = pulseInfoF.wc(1:nOk);
  pulseInfoF.w0 = pulseInfoF.w0(1:nOk);
  pulseInfoF.w1 = pulseInfoF.w1(1:nOk);
  pulseInfoF.x = pulseInfoF.x(1:nOk);
end

if pulseInfoF.w0==0;
    fprintf('no female pulses made it through amplitude winnowing.\n');
    return
end

% hold on
% for i=1:length(pulseInfoF.wc);
% plot(pulseInfoF.w0(i):pulseInfoF.w1(i),pulseInfoF.x{i},'-m');
% end
% for i=1:length(pulseInfoM.wc);
% plot(pulseInfoM.w0(i):pulseInfoM.w1(i),pulseInfoM.x{i},'-b');
% end


