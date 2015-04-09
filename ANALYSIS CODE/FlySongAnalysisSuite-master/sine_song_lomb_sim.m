% culled_ipi = ipiStatsLomb.culled_ipi;

%%%Now loop through all mat files in folder and collect lomb_sim_results in
%%%for individuals

% lsr.filename{ } = filename
% lsr.results{ } = lomb_sim_results;



function lomb_sim_results = sine_song_lomb_sim(data,winnowed_sine)
%ippi =  ipiStatsLomb.culled_ipi


fs = data.fs;
SNR  = .1:.1:2;
d = cell(numel(SNR),1);
P = d;
f = d;
alpha = d;
best_alpha = zeros(numel(SNR),1);
best_P = best_alpha;
for i=1:numel(SNR)
    [simData,Pow,freq,sign] = sine_song_sine_sim(data.d,winnowed_sine,fs,SNR(i));
    d{i} = simData;
    P{i} = Pow;
    f{i} = freq;
    alpha{i} = sign;
    best_alpha(i) = min(sign(freq > 0.18 & freq < 0.22));
    best_P(i) = max(Pow(freq > 0.18 & freq < 0.22));
end

lomb_sim_results.d = d;
lomb_sim_results.P = P;
lomb_sim_results.f = f;
lomb_sim_results.alpha = alpha;
lomb_sim_results.best_alpha = best_alpha;
lomb_sim_results.best_P = best_P;



function [simData,P,f,alpha] = sine_song_sine_sim(d,winnowed_sine,fs,SNR)
t = 1:size(d); %10 minutes
f = 1/(5*fs);%freq = 1/period
% fs = 1e4;
A = 0.002; %amplitude ~2mV
% A = 1;
x = A *sin(2*pi*f*t);

holding_cell = cell(1,length(winnowed_sine.start));
for i = 1:length(winnowed_sine.start)
    holding_cell{i} = winnowed_sine.start(i):100:winnowed_sine.stop(i);
end

winnowed_sine_times =cell2mat(holding_cell);
% plot(t,x)

% culled_ipi = ipi;
cx = x(winnowed_sine_times);
ct = winnowed_sine_times;
% plot(ct,cx,'.-')
%  
% lomb(cx,ct./fs,1);
 
%Now try adding variance to cx
% SNR = .4;
% rmsrnd = sqrt(mean(randn(size(x,2),1).^2));
% rmsx = sqrt(mean(x.^2));

stdx = std(cell2mat(winnowed_sine.events)./fs);
 
% noise = (1/.7088)*(rmsx/SNR) .* randn(size(cx,2),1);
noised = (1/.7088)*(stdx/SNR) .* randn(size(cx,2),1);

% cy = cx+noise';
cyd = cx+noised';

% plot(ct,cy,'.-')
% lomb(cy,ct./fs,1);

% plot(ct,cyd,'.-')
[P,f,alpha] = lomb(cyd,ct./fs);
%don't plot
% [P,f,alpha] = lomb(cyd,ct./fs,1);
%get peaks
peaks = regionalmax(P);
%get f,alpha,Peaks for peaks < desired alpha
fPeaks = f(peaks);
alphaPeaks = alpha(peaks);

alphaThresh = 0.05;

signF = fPeaks(alphaPeaks < alphaThresh);
signAlpha = alphaPeaks(alphaPeaks <alphaThresh);
signPeaks = P(alphaPeaks < alphaThresh);

P = signPeaks;
f = signF;
alpha = signAlpha;

simData.t = ct;
simData.x = cyd;

%%%%%%%%%%%%%%%%%%%
%check rmsq vs rmsrnd
% t = 1:size(data.d); %10 minutes
% f = 1/55e4;%freq = 1/period
% A = 1;
% x = A *sin(2*pi*f*t);
% rmsx = sqrt(mean(x.^2))
% rmsrnd = sqrt(mean(randn(size(x,2),1).^2))
