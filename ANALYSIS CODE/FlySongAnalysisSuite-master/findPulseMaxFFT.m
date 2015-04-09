function pMFFT = findPulseMaxFFT(pulseInfo)

Fs = 22050;
nfft = 100000;

numPulse = numel(pulseInfo.x);

freq = zeros(numPulse,1);
time = zeros(numPulse,1);
%do for each pulse
for i = 1:numPulse
    
    ym = pulseInfo.x{i};
    r = length(ym);
    sec = r/10000;
    wnd = round(22050*sec);
    z = resample(ym,22050,10000);
    [Sn,F] = spectrogram(z,wnd,[],nfft,Fs);
    freq(i)= F(abs(Sn) == max(abs(Sn)));
    time(i) = pulseInfo.wc(i);
end
pMFFT.timeAll =time;
pMFFT.freqAll =freq;
