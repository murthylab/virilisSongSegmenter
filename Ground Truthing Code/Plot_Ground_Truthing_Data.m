%Plot GROUND TRUTHING data:

a=figure(1);
b=figure(2);
c=figure(3);
d=figure(4);
e=figure(5);
f=figure(6);
%%
%=======sine song lengths:
SINE_LENGTHS=[];
for QQ=1:9;
    name = ['workspace_' int2str(QQ) '.mat'];
    load(name);
    
    SINE_LENGTHS(1,QQ) = mean(sine_song_lengths);
    SINE_LENGTHS(2,QQ) = mean(sine_song_lengths_comp);
    SINE_LENGTHS(3,QQ) = length(sine_song_lengths); %gives you the number of sine trains found
    SINE_LENGTHS(4,QQ) = length(sine_song_lengths_comp);
    SINE_LENGTHS(5,QQ) = sum(sine_song_lengths); %gives you the total amount of sine song
    SINE_LENGTHS(6,QQ) = sum(sine_song_lengths_comp);
end

save('SINE_LENGTHS.mat','SINE_LENGTHS');

%%
%=======number pulses found (relative to manual):
DIFFS = [];
for QQ=1:9;
    name = ['workspace_' int2str(QQ) '.mat'];
    load(name);
    
    DIFFS(1,QQ) = -DIFF2; %pulseInfo
    DIFFS(2,QQ) = -DIFF; %pulseInfo2
    DIFFS(3,QQ) = -DIFF4; %culled pulseInfo
    DIFFS(4,QQ) = -DIFF3; %culled pulseInfo2
end

save('DIFFS.mat','DIFFS');
%%
%======meanIPI
MEAN_IPI_ALL = [];
for QQ=1:9;
    name = ['workspace_' int2str(QQ) '.mat'];
    load(name);
    
    MEAN_IPI_ALL(1,QQ) = meanIPI;
    MEAN_IPI_ALL(2,QQ) = meanIPI_pulseInfo2;
    MEAN_IPI_ALL(3,QQ) = meanIPI_pulseInfo;
    MEAN_IPI_ALL(4,QQ) = meanIPI_culled_pulseInfo;
    MEAN_IPI_ALL(5,QQ) = meanIPI_culled1_pulseInfo;
end

save('MEAN_IPI_ALL.mat','MEAN_IPI_ALL');

%%
%==========IPI
MEAN_IPI_lomb = [];
for QQ=1:9;
    name = ['workspace_' int2str(QQ) '.mat'];
    load(name);
    
    MEAN_IPI_lomb(1,QQ) = culled_ipi_byhand.u(1,1);
    MEAN_IPI_lomb(2,QQ) = culled_ipi_pulseInfo2.u(1,1);
    MEAN_IPI_lomb(3,QQ) = culled_ipi_pulseInfo.u(1,1);
    MEAN_IPI_lomb(4,QQ) = culled_ipi_culled_pulseInfo2.u(1,1);
    MEAN_IPI_lomb(5,QQ) = culled_ipi_culled_pulseInfo.u(1,1);
end

save('MEAN_IPI_lomb.mat','MEAN_IPI_lomb');
%%
%=======modeIPI
MODE_IPI_ALL = [];
for QQ=1:9;
    name = ['workspace_' int2str(QQ) '.mat'];
    load(name);
    
    MODE_IPI_ALL(1,QQ) = modeIPI;
    MODE_IPI_ALL(2,QQ) = modeIPI_pulseInfo2;
    MODE_IPI_ALL(3,QQ) = modeIPI_pulseInfo;
    MODE_IPI_ALL(4,QQ) = modeIPI_culled_pulseInfo;
    MODE_IPI_ALL(5,QQ) = modeIPI_culled1_pulseInfo;
end

save('MODE_IPI_ALL.mat','MODE_IPI_ALL');

%%
%=======correlations
XCORR = [];
XCORR_score =[];

for QQ=1:9;
    name = ['workspace_' int2str(QQ) '.mat'];
    load(name);
    
    XCORR(QQ,:,1) = pulse_c;
    XCORR(QQ,:,2) = pulse_c1; 
    XCORR(QQ,:,3) = pulse_cu;
    XCORR(QQ,:,4) = pulse_cu1;
    XCORR(QQ,:,5) = sine_c;
    
    XCORR_score(1,QQ) = max(pulse_c);
    XCORR_score(2,QQ) = max(pulse_c1);
    XCORR_score(3,QQ) = max(pulse_cu);
    XCORR_score(4,QQ) = max(pulse_cu1);
    XCORR_score(5,QQ) = max(sine_c);
end

save('XCORR.mat','XCORR');

figure; hold on;
for i=1:9;
plot((XCORR(i,:,1)),'r');
plot((XCORR(i,:,2)),'g');
plot((XCORR(i,:,3)),'b');
plot((XCORR(i,:,4)),'c');
end   


figure; hold on;
for i=1:9;
plot(XCORR(i,:,5),'k');
end  
%%
%get and plot F scores:
F_ALL = [];
for QQ=1:9;
    name = ['workspace_' int2str(QQ) '.mat'];
    load(name);
    
    F_ALL(1,QQ) = FC1; %pulseInfo
    F_ALL(2,QQ) = FC; %pulseInfo2
    F_ALL(3,QQ) = FCu; %culled pulseInfo
    F_ALL(4,QQ) = FCu2; %culled pulseInfo2
end

save('Fscores_ALL.mat','F_ALL');

%%
%get sensitivity scores:
SEN_ALL = [];
for QQ=1:9;
      name = ['workspace_' int2str(QQ) '.mat'];
    load(name);
    
    SEN_ALL(1,QQ) = VC1PG_sen; %pulseInfo
    SEN_ALL(2,QQ) = VCPG_sen; %pulseInfo2
    SEN_ALL(3,QQ) = VCu1PG_sen; %culled pulseInfo
    SEN_ALL(4,QQ) = VCuPG_sen; %culled pulseInfo2
end

save('SEN_ALL.mat','SEN_ALL');

%%
%get sensitivity scores:
PPV_ALL = [];
for QQ=1:9;
      name = ['workspace_' int2str(QQ) '.mat'];
    load(name);
    
    PPV_ALL(1,QQ) = VC1PG_ppv; %pulseInfo
    PPV_ALL(2,QQ) = VCPG_ppv; %pulseInfo2
    PPV_ALL(3,QQ) = VCu1PG_ppv; %culled pulseInfo
    PPV_ALL(4,QQ) = VCuPG_ppv; %culled pulseInfo2
end

save('PPV_ALL.mat','PPV_ALL');
    
%%

%plot is from workspace_5

h=figure; plot((data.d(3250001:3310000)./2),'k'); %plot in gray
a=[];
a=find(VMPG(2.5e5:3.1e5)>0.1176);
b=length(a);
c=ones(1,b);
c=c-0.8;
hold on
plot(a,c,'.k');

% a=[];
% a=find(VC1PG(2.5e5:3.1e5)>0.1176); %pulseInfo
% b=length(a);
% c=ones(1,b);
% c=c-0.78;
% hold on
% plot(a,c,'.c');

a=[];
a=find(VCPG(2.5e5:3.1e5)>0.1176); %pulseInfo2
b=length(a);
c=ones(1,b);
c=c-0.78;
hold on
plot(a,c,'.b');

% a=[];
% a=find(VCuPG(2.5e5:3.1e5)>0.1176); %culled_pulseInfo
% b=length(a);
% c=ones(1,b);
% c=c-0.74;
% hold on
% plot(a,c,'.m');

a=[];
a=find(VCuP2G(2.5e5:3.1e5)>0.1176); %culled_pulseInfo2
b=length(a);
c=ones(1,b);
c=c-0.76;
hold on
plot(a,c,'.r');

a=[];
a=find(VMSG(2.5e5:3.1e5)>0.997);
b=length(a);
c=ones(1,b);
c=c-0.87;
hold on
plot(a,c,'.k');

a=[];
a=find(VCSG(2.5e5:3.1e5)>0.997);
b=length(a);
c=ones(1,b);
c=c-0.85;
hold on
plot(a,c,'.r');

ylim([-0.1 0.3]);
%%
%=======
%IPI distribution
%collect all IPIs for each method and pool:

clear all

IPI_ALL = NaN(5,6000);

m=1;
mm=1;
mmm=1;
mmmm=1;
mmmmm=1;

for QQ=1:9;
    name = ['workspace_' int2str(QQ) '.mat'];
    load(name);
    
B=[];
B = PULSE(:,2)'; %times for pulse peaks
n=length(B);
IPI_ALL(1,m:m+n-1) = B;
m=m+n;
    
    
B=[];
B = pulseInfo.wc; %times for pulse peaks
A=[];
C=[];
A = find(B>3000000 & B<3600001);
C = B(A);
n=length(C);
IPI_ALL(2,mm:mm+n-1) = C;
mm=mm+n;

    
B=[];
B = pulseInfo2.wc; %times for pulse peaks
A=[];
C=[];
A = find(B>3000000 & B<3600001);
C = B(A);
n=length(C);
IPI_ALL(3,mmm:mmm+n-1) = C;
mmm=mmm+n;

B=[];
B = culled_pulseInfo_1.wc; %times for pulse peaks
A=[];
C=[];
A = find(B>3000000 & B<3600001);
C = B(A);
n=length(C);
IPI_ALL(4,mmmm:mmmm+n-1) = C;
mmmm=mmmm+n;

B=[];
B = culled_pulseInfo.wc; %times for pulse peaks
A=[];
C=[];
A = find(B>3000000 & B<3600001);
C = B(A);
n=length(C);
IPI_ALL(5,mmmmm:mmmmm+n-1) = C;
mmmmm=mmmmm+n;
end

IPI_ALL_2=NaN(5,6000);

for i=1:5;
    a=[];
    a=diff(IPI_ALL(i,:));
    b=[];
    b=find(a<600 & a>200);
    %b = b-1;
    c=[];
    aa=IPI_ALL(i,:);
    c=aa(b);
    IPI_ALL_2(i,1:length(c)) = c;
end

save('IPI_ALL.mat','IPI_ALL','IPI_ALL_2');

%%
clear all

load IPI_ALL.mat

addpath('/Users/malamurthy/Desktop/FlySongAnalysisSuite');

MEAN = [];

ipi_byhand = fit_ipi_model(IPI_ALL(1,:),2);
%[ipiStats_byhand lombStats_byhand culled_ipi_byhand] = cullIPILomb(ipi_byhand);
figure; gmixPlot(ipi_byhand.d',2,100,100,0,1)
figure(11); hold on; errorbar(1,ipi_byhand.u,ipi_byhand.S, ipi_byhand.S);
MEAN(1,1) = ipi_byhand.u;
MEAN(1,2) = ipi_byhand.S;

ipi_pulseInfo = fit_ipi_model(IPI_ALL(2,:),2);
%[ipiStats_culled_pulseInfo2 lombStats_culled_pulseInfo2 culled_ipi_culled_pulseInfo2] = cullIPILomb(ipi_culled_pulseInfo2);
figure; gmixPlot(ipi_pulseInfo.d',2,100,100,0,1)
figure(11); hold on; errorbar(2,ipi_pulseInfo.u,ipi_pulseInfo.S, ipi_pulseInfo.S);
MEAN(2,1) = ipi_pulseInfo.u;
MEAN(2,2) = ipi_pulseInfo.S;

ipi_pulseInfo2 = fit_ipi_model(IPI_ALL(3,:),2);
%[ipiStats_culled_pulseInfo2 lombStats_culled_pulseInfo2 culled_ipi_culled_pulseInfo2] = cullIPILomb(ipi_culled_pulseInfo2);
figure; gmixPlot(ipi_pulseInfo2.d',2,100,100,0,1)
figure(11); hold on; errorbar(3,ipi_pulseInfo2.u,ipi_pulseInfo2.S, ipi_pulseInfo2.S);
MEAN(3,1) = ipi_pulseInfo2.u;
MEAN(3,2) = ipi_pulseInfo2.S;

ipi_culled_pulseInfo = fit_ipi_model(IPI_ALL(4,:),2);
%[ipiStats_culled_pulseInfo2 lombStats_culled_pulseInfo2 culled_ipi_culled_pulseInfo2] = cullIPILomb(ipi_culled_pulseInfo2);
figure; gmixPlot(ipi_culled_pulseInfo.d',2,100,100,0,1)
figure(11); hold on; errorbar(4,ipi_culled_pulseInfo.u,ipi_culled_pulseInfo.S, ipi_culled_pulseInfo.S);
MEAN(4,1) = ipi_culled_pulseInfo.u;
MEAN(4,2) = ipi_culled_pulseInfo.S;

ipi_culled_pulseInfo2 = fit_ipi_model(IPI_ALL(5,:),2);
%[ipiStats_culled_pulseInfo2 lombStats_culled_pulseInfo2 culled_ipi_culled_pulseInfo2] = cullIPILomb(ipi_culled_pulseInfo2);
figure; gmixPlot(ipi_culled_pulseInfo2.d',2,100,100,0,1)
figure(11); hold on; errorbar(5,ipi_culled_pulseInfo2.u,ipi_culled_pulseInfo2.S, ipi_culled_pulseInfo2.S);
MEAN(5,1) = ipi_culled_pulseInfo2.u;
MEAN(5,2) = ipi_culled_pulseInfo2.S;







