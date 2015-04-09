function maxfreq = fftpm(pm,color)
%USAGE maxfreq = fftpm(pm,color)
%if specify color, then plots fft
%always spits out maxfreq

fs = 1e4;
L = length(pm);
NFFT = fs/2;%2^nextpow2(L);
Y = fft(pm,NFFT)/L;
f = fs/2*linspace(0,1,NFFT/2+1);
if nargin ==2
    plot(f,2*abs(Y(1:NFFT/2+1)),color)
end
[~,maxidx] = max(2*abs(Y(1:NFFT/2+1)));
maxfreq = f(maxidx);