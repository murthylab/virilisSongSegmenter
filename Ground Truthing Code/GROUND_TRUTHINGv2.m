function GROUND_TRUTHINGv2(RR,PULSE)

%take hand segmented data (from 5-6min of songs: 9 different songs; 
%PULSE times and SINE starts and stops are in ms (relative to the start of the full song))
%compare to pulseInfo2 (following heuristic winnow), pulseInfo,
%culled_pulseInfo_1 (pulse model winnow on pulseInfo) and culled_pulseInfo (pulse model winnow on
%pulseInfo2)

%the comparison should transform the pulse times or sine times into a
%smoothed vector of ones and zeros - then use various metrics to look at relationships.  Some sort of smoothing is critical
%because the exact pulse and sine times won't be the same for hand
%segmentation versus automated....

%%

for RR=RR
    
    if RR==1; %each hand annotated workspace contains both the hand segmeneted data and the automated data (including following culling with the pulse model)
        load('PS_ch1.mat');
    elseif RR==2;
        load('PS_ch2.mat');
    elseif RR==3;
        load('PS_ch3.mat');
    elseif RR==4;
        load('PS_ch4.mat');
    elseif RR==5;
        load('PS_ch5.mat');
    elseif RR==6;
        load('PS_ch6.mat');
    elseif RR==7;
        load('PS_ch7.mat');
    elseif RR==8;
        load('PS_ch8.mat');
    elseif RR==9;
        load('PS_ch9.mat');
    elseif RR==10;
        load('PS_ch10.mat');
    end
%%    

RR

% addpath('/Users/malamurthy/Desktop/OLD_FlySongSegmenter/FlySongAnalysisSuite');

%Guassian filter:
Fs=10000;
effwidth = 20; 
efftk = -3*effwidth:3*effwidth ; 
effkernel = (exp(-(efftk/effwidth).^2/2)/(effwidth*sqrt(2*pi)));
halfWidth=(numel(efftk)/2);

%first make a spike train out of the SINE and PULSE information:
leng = length(run_data.likelihoods);


vector_manual = zeros(1,leng);
vector_manual = vector_manual + 0.1;
%vector_manual_sine = vector_manual_pulse;
ch=PULSE(:,1)==RR;
ch=PULSE(ch,2);
ch= round(ch.*Fs/1000); %to get data back into points from ms (there is only data between 5-6min)
B = ch';
IPI = (diff(B)); %in points
index = find(IPI < 1000 & IPI > 0); 
meanIPI = mean(IPI(index)); %mean IPI
modeIPI = mode(IPI(index)); %mode IPI
varIPI = var(IPI(index)); %variance IPI
stdIPI = std(IPI(index)); %standard deviation IPI
h=figure(11); hist(IPI(index),100); title('IPI histogram');
name = ['female_IPI_hist_manual_' int2str(RR) '.fig'];
saveas(h,name); 

ipi_byhand = fit_ipi_model(B,2); %guassian mixture model - fit to IPI distribution
%[ipiStats_byhand lombStats_byhand culled_ipi_byhand] = cullIPILomb(ipi_byhand);

% SINE(:,2) = round(SINE(:,2).*Fs/1000);
% SINE(:,3) = round(SINE(:,3).*Fs/1000);

for i=1:length(B); %for each pulse
    a = round(B(i));
    vector_manual(1,a) = 1; %put a 1 where each pulse peak is
end

% sine_song_lengths = [];
% 
% n=1;
% for i=1:length(SINE(:,2)); %for each sine
%     a = SINE(i,2);
%     b = SINE(i,3);
%     vector_manual_sine(a:b) = ones; %put a 1 where each sine song is
%     sine_song_lengths(n) = length(vector_manual_sine(a:b)); %collect sine song lengths
%     n=n+1;
% end

x=vector_manual; %get rid of the zeros outside 5-6min of data
%y=vector_manual_sine(3000001:3600000);

vector_manual_pulse_guass = conv(x,effkernel); %convolve with the guassian kernel
VMPG=vector_manual_pulse_guass(halfWidth:end-halfWidth);
% vector_manual_sine_guass = conv(y,effkernel);
% VMSG = vector_manual_sine_guass(halfWidth:end-halfWidth);

%%
%Now create a vector of 0.1s and ones for pulseInfo:


vector_comp1_pulse = zeros(1,leng);
vector_comp1_pulse = vector_comp1_pulse + 0.1;

for  n=1:numel(femaleBoutInfo.wMax); %n=1:numel(maleBoutInfo.wc); %for each pulse 
%      A=maleBoutInfo.w0(n); %male bout center
%      AA=maleBoutInfo.w1(n); %previous male bout center
%      zz=find(run_data.pulseInfo.wc>A & run_data.pulseInfo.wc<AA);
%      pulsetime=run_data.pulseInfo.wc(zz);
%     a = pulsetime; 
     a= femaleBoutInfo.wMax(n);
    vector_comp1_pulse(a) = 1;
end

%find IPIs:
B=[];

B = find(vector_comp1_pulse==1); %femaleBoutInfo.wMax'; %times for pulse peaks

IPI=[];
IPI = (diff(B)); %in points
index = find(IPI < 1000); 
meanIPI_pulseInfo = mean(IPI(index)); %mean IPI
modeIPI_pulseInfo = mode(IPI(index));
varIPI_pulseInfo = var(IPI(index));
stdIPI_pulseInfo = std(IPI(index)); %standard deviation
g=figure(12); hist(IPI(index),100); title('IPI histogram pulseInfo');
name = ['female_IPI_hist_pulseInfo_' int2str(RR) '.fig'];
saveas(g,name); 

ipi_pulseInfo = fit_ipi_model(B,2);
%[ipiStats_pulseInfo lombStats_pulseInfo culled_ipi_pulseInfo] = cullIPILomb(ipi_pulseInfo);

x=[];
x=vector_comp1_pulse;

vector_comp1_pulse_guass = conv(x,effkernel);
VC1PG=vector_comp1_pulse_guass(halfWidth:end-halfWidth);
%%
%Now create a vector of 0.1s and ones for pulseInfo2 and twos for winnowed_sine
%start and stop times

% vector_comp_pulse = zeros(1,leng);
% vector_comp_pulse = vector_comp_pulse + 0.1;
% vector_comp_sine = vector_comp_pulse;
% 
% for i=1:numel(pulseInfo2.wc); %for each pulse
%     a = pulseInfo2.wc(i);
%     vector_comp_pulse(a) = 1;
% end
% 
% sine_song_lengths_comp=[];
% 
% n=1;
% for i=1:numel(winnowed_sine.start); %go ahead and collect sine song info now
%     a = winnowed_sine.start(i);
%     b = winnowed_sine.stop(i);
%     vector_comp_sine(a:b) = ones;
%     if winnowed_sine.start(i) > 3000000 && winnowed_sine.stop(i) < 3600001;
%     sine_song_lengths_comp(n) = length(vector_comp_sine(a:b));
%     n=n+1;
%     end
% end
% 
% %find IPIs:
% B=[];
% B = pulseInfo2.wc; %times for pulse peaks
% A=[];
% A = find(B>3000000 & B<3600001);
% C=[];
% C = B(A);
% IPI=[];
% IPI = (diff(C)); %in points
% index = find(IPI < 1000); 
% meanIPI_pulseInfo2 = mean(IPI(index)); %mean IPI
% modeIPI_pulseInfo2 = mode(IPI(index));
% varIPI_pulseInfo2 = var(IPI(index));
% stdIPI_pulseInfo2 = std(IPI(index)); %standard deviation
% %f=figure(13); hist(IPI(index),100); title('IPI histogram pulseInfo2');
% %saveas(g,'IPI_hist_pulseInfo2.fig');
% 
% ipi_pulseInfo2 = fit_ipi_model(C,2);
% %[ipiStats_pulseInfo2 lombStats_pulseInfo2 culled_ipi_pulseInfo2] = cullIPILomb(ipi_pulseInfo2);
% 
% x=vector_comp_pulse(3000001:3600000);
% y=vector_comp_sine(3000001:3600000);
% 
% vector_comp_pulse_guass = conv(x,effkernel);
% VCPG=vector_comp_pulse_guass(halfWidth:end-halfWidth);
% vector_comp_sine_guass = conv(y,effkernel);
% VCSG = vector_comp_sine_guass(halfWidth:end-halfWidth);
% 
% %%
% %run culled pulses - then take out the pulses from there:
% 
% folder = '/Users/malamurthy/Desktop/FLY SONG SEGMENTATION/CS-Tully hand segmeneted/keep 2';
% pulse_model = '/Users/malamurthy/Desktop/FlySongWMTSegment'
% 
% addpath('/Users/malamurthy/Desktop/FlySongWMTSegment');
% 
% Z_2_pulse_model_multi(folder,'pulseInfo2','/Users/malamurthy/Desktop/FlySongWMTSegment/mel_pm_24ii12.mat');  
% cull_pulses_multi(folder,'pulseInfo2','Lik_pulse','LLR_fh',0);

%%
% %Now create a vector of 0.1s and ones for culled_pulseInfo2:
% leng = length(xsongsegment);
% 
% vector_culled_pulse2 = zeros(1,leng);
% vector_culled_pulse2 = vector_culled_pulse2 + 0.1;
% 
% for i=1:numel(culled_pulseInfo2.wc); %for each pulse
%     a = culled_pulseInfo2.wc(i);
%     vector_culled_pulse2(a) = 1;
% end
% 
% %find IPIs:
% B=[];
% B = culled_pulseInfo2.wc; %times for pulse peaks
% A=[];
% C=[];
% A = find(B>3000000 & B<3600001);
% C = B(A);
% IPI=[];
% IPI = (diff(C)); %in points
% index = find(IPI < 1000); 
% meanIPI_culled_pulseInfo2 = mean(IPI(index)); %mean IPI
% modeIPI_culled_pulseInfo2 = mode(IPI(index));
% varIPI_culled_pulseInfo2 = var(IPI(index));
% stdIPI_culled_pulseInfo2 = std(IPI(index)); %standard deviation
% g=figure(12); hist(IPI(index),100); title('IPI histogram culled_pulseInfo2');
% name = ['IPI_hist_culled_pulseInfo2_' int2str(RR) '.fig'];
% saveas(g,name); 
% 
% ipi_culled_pulseInfo2 = fit_ipi_model(C,2);
% %[ipiStats_culled_pulseInfo2 lombStats__culled_pulseInfo2 culled_ipi_culled_pulseInfo2] = cullIPILomb(ipi_culled_pulseInfo2);
% 
% x=[];
% x=vector_culled_pulse2(3000001:3600000);
% 
% vector_culled_pulse2_guass = conv(x,effkernel);
% VCuP2G=vector_culled_pulse2_guass(halfWidth:end-halfWidth);
% 
% %%
% %Now create a vector of 0.1s and ones for culled_pulseInfo:
% leng = length(xsongsegment);
% 
% vector_culled_pulse = zeros(1,leng);
% vector_culled_pulse = vector_culled_pulse + 0.1;
% 
% for i=1:numel(culled_pulseInfo.wc); %for each pulse
%     a = culled_pulseInfo.wc(i);
%     vector_culled_pulse(a) = 1;
% end
% 
% %find IPIs:
% B=[];
% B = culled_pulseInfo.wc; %times for pulse peaks
% A=[];
% C=[];
% A = find(B>3000000 & B<3600001);
% C = B(A);
% IPI=[];
% IPI = (diff(C)); %in points
% index = find(IPI < 1000); 
% meanIPI_culled_pulseInfo = mean(IPI(index)); %mean IPI
% modeIPI_culled_pulseInfo = mode(IPI(index));
% varIPI_culled_pulseInfo = var(IPI(index));
% stdIPI_culled_pulseInfo = std(IPI(index)); %standard deviation
% 
% ipi_culled_pulseInfo = fit_ipi_model(C,2);
% %[ipiStats_culled_pulseInfo lombStats__culled_pulseInfo culled_ipi_culled_pulseInfo] = cullIPILomb(ipi_culled_pulseInfo);
% 
% x=[];
% x=vector_culled_pulse(3000001:3600000);
% 
% vector_culled_pulse_guass = conv(x,effkernel);
% VCuPG=vector_culled_pulse_guass(halfWidth:end-halfWidth);
%%
% pulse_cu2 = xcorr(VMPG,VCuP2G,100,'coeff'); %with maxlags of 100 points %culled_pulseInfo2
% pulse_cu = xcorr(VMPG,VCuPG,100,'coeff'); %with maxlags of 100 points %culled_pulseInfo
% pulse_c = xcorr(VMPG,VCPG,100,'coeff'); %with maxlags of 100 points %pulseInfo2
% pulse_c1 = xcorr(VMPG,VC1PG,100,'coeff'); %pulseInfo
% sine_c = xcorr(VMSG,VCSG,100,'coeff');

%%
%Need to find the points that VMPG and other vectors (VCuP2G, VCPG, VCuPG,
%and VC1PG) have in common:

%The peaks in VMPG are the "trues" - the true pulses found by hand segmentation

%for each vector, get rid of the first 80 and last 80 points, and jitter VMPG (by 45pts) relative to the other vectors 
%(the jitter is done because we don't want any peaks in VMPG to PERFECTLY overlap with the peaks in the other vectors) - the code here is looking for interesections between the two vectors:
VMPG = VMPG(81:end-80);
% VCPG = VCPG(81:end-80);
VC1PG = VC1PG(81:end-80);
% VCuP2G = VCuP2G(81:599920);
% VCuPG = VCuPG(81:599920);

%vector for the timepoints
t=1:leng-160;

%now use curveintersect.m to find the points where the vectors intersect:
% [VCPGi,VCPGv] = curveintersect(t,VMPG,t,VCPG); %i=indices, v=values
[VC1PGi,VC1PGv] = curveintersect(t,VMPG,t,VC1PG);
% [VCuP2Gi,VCuP2Gv] = curveintersect(t,VMPG,t,VCuP2G);
% [VCuPGi,VCuPGv] = curveintersect(t,VMPG,t,VCuPG);

%the intersections should be greater than 0.1 (see above, all of the vectors have 0.1 as their min value) - the length of this vector provides the value of
%"trues_found" - that is the pulses that were found by each algorithm that
%are ALSO in "trues"
% Ca=find(VCPGv>0.1);
C1a=find(VC1PGv>0.1);
aa=find(diff(C1a)~=1);
C1a=C1a(aa);
% Cu2a=find(VCuP2Gv>0.1);
% Cua=find(VCuPGv>0.1);

%for deugging: verify that the correct peaks were found:
g=figure(1); plot(VMPG(1:length(VC1PGi)), 'k'); hold on; plot(VC1PG(1:length(VC1PGi)),'r'); 
hold on; plot(VC1PGi(C1a),0.11,'.b');
title('female_intersection');
name = ['female_intersection' int2str(RR) '.fig'];
saveas(g,name); 
close(g)
%figure; plot(t(1:length(VC1PGv)),VMPG(1:length(VC1PGv)),'k',t(1:length(VC1PGv)),VC1PGv','r')
% hold on
% plot(VCuP2Gi(Cu2a),0.12,'.m');

%to get the number of pulses from each original vector, use findpeaks:
VMPG_peaks = findpeaks(VMPG,'minpeakheight',0.1);
% VCPG_peaks = findpeaks(VCPG,'minpeakheight',0.1);
VC1PG_peaks = findpeaks(VC1PG,'minpeakheight',0.1);
% VCuP2G_peaks = findpeaks(VCuP2G,'minpeakheight',0.1);
% VCuPG_peaks = findpeaks(VCuPG,'minpeakheight',0.1);

%Now I can calculate false positive and negative rates:
%sensitivity(sen) = trues_found/trues
%positive predictive value(ppv) = trues_found/found
%F=2*sen*ppv/(sen+ppv)

% VCPG_sen = length(Ca)/length(VMPG_peaks);
VC1PG_sen = length(C1a)/length(VMPG_peaks);
% VCuP2G_sen = length(Cu2a)/length(VMPG_peaks);
% VCuPG_sen = length(Cua)/length(VMPG_peaks);

% VCPG_ppv = length(Ca)/length(VCPG_peaks);
VC1PG_ppv = length(C1a)/length(VC1PG_peaks);
% VCuP2G_ppv = length(Cu2a)/length(VCuP2G_peaks);
% VCuPG_ppv = length(Cua)/length(VCuPG_peaks);

% FC = (2*VCPG_sen*VCPG_ppv)/(VCPG_sen+VCPG_ppv);
FC1 = (2*VC1PG_sen*VC1PG_ppv)/(VC1PG_sen+VC1PG_ppv);
% FCu2 = (2*VCuP2G_sen*VCuP2G_ppv)/(VCuP2G_sen+VCuP2G_ppv);
% FCu = (2*VCuPG_sen*VCuPG_ppv)/(VCuPG_sen+VCuPG_ppv);

%%

t=1:1:leng;

%compute times of pulses:
tSpike1 = t(find(vector_manual>0.1)); %will find just pulses
% tSpike2 = t(find(vector_comp_pulse(3000001:3600000)>0.1)); %pulseInfo2
tSpike3 = t(find(vector_comp1_pulse>0.1)); %pulseInfo
% tSpike4 = t(find(vector_culled_pulse2(3000001:3600000)>0.1)); %culled pulseInfo2
% tSpike5 = t(find(vector_culled_pulse(3000001:3600000)>0.1)); %culled pulseInfo
% DIFF = (length(tSpike1)-length(tSpike2))./length(tSpike1); %fraction not found (or false negative or positive rate)
DIFF2 = (length(tSpike1)-length(tSpike3))./length(tSpike1);
% DIFF3 = (length(tSpike1)-length(tSpike4))./length(tSpike1);
% DIFF4 = (length(tSpike1)-length(tSpike5))./length(tSpike1);

name = ['female_workspace_' int2str(RR) '.mat'];
save(name);


end


