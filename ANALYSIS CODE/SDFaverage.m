function [SDFM, SDFF, STATS] = SDFaverage (dataM, dataF, time);

%****implies data is matrix containg spike timing over trials

%From this program we can look at spike number in response to stimulus,in
%addition we can align spikes to look for curve fitting and temporal codes
%in response to odor delivery.  Plots both the PSTH and also a Spike
%density plot for individual and averaged data across trials.   

%plot raw spikes
%and convolve spikes with gaussian

%data should be a column vector of pulse times in seconds
dataM=(dataM./1000)';
dataF=(dataF./1000)';
%time indicates length of recording in seconds
edges=0:0.01:time;
n_elementsM = histc(dataM,edges);
n_elementsF = histc(dataF,edges);

%set spike averaging width and make gaussian
Meffwidth = 5; %10*mSec window
Mefftk = -2*Meffwidth:2*Meffwidth ; %*10 mSec overlap
Meffkernel = exp(-(Mefftk/Meffwidth).^2/2)/(Meffwidth*sqrt(2*pi));
MhalfWidth=numel(Mefftk)/2;

Feffwidth=Meffwidth; %female gaussian width is double that of the male in order to compensate for IPI
Fefftk = -2*Feffwidth:2*Feffwidth ;
Feffkernel = exp(-(Fefftk/Feffwidth).^2/2)/(Feffwidth*sqrt(2*pi));
FhalfWidth=numel(Fefftk)/2;

%make spike rasters and draw the raster plot
%then convolve the spike rasters with the gaussians
%produced above
% figure(1)
% clf
dt=1/1000; %mSec

time=time-dt;
t = 0:dt:time;%time converted from seconds to mSec

count=1;


   spikeConvM(1,:) = conv(n_elementsM,Meffkernel);
   spikeConvF(1,:) = conv(n_elementsF,Feffkernel);
   %figure(2)
   %plot (t,spikeConv(halfWidth:end-halfWidth)+count)  %plots Smoothed PSTH or spike density function.
   %hold on
   %count=count+1;
   %spikesum = spikesum + spiketrainV;
   %SDFsum = SDFsum + spikeConv(halfWidth:end-halfWidth);



SDFM=spikeConvM(MhalfWidth:end-MhalfWidth);
SDFF=spikeConvF(FhalfWidth:end-FhalfWidth);
figure; hold on; plot(SDFM, 'b'); plot(SDFF, 'm');

%% STATS
% ind = SDFF~=0;
% SDFM2=SDFM(ind);
% SDFF2=SDFF(ind);
% figure(2); plot(SDFM2, SDFF2, '.'); xlabel('MALE'); ylabel('FEMALE');
% 
% l=polyfit(SDFM2, SDFF2,1);
% x=[0, max(SDFM2)];
% y=(x*l(1,1))+l(1,2);
% figure(2); hold on; plot(x,y,'r');
% [r,p]=corrcoef(SDFM2, SDFF2);
% STATS=struct('lreg', l, 'coeffr', r, 'coeffp', p);