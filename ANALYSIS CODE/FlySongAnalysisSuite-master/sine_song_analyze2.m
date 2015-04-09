function maxFFT = sine_song_analyze2(winnowed_sine)

Fs = 10000;
nfft = 100000;
NumSine = size(winnowed_sine.clips,1);
maxFFTFreq = cell(NumSine,1);
maxFFTFreqTime = cell(NumSine,1);
% [poolavail,isOpen] = check_open_pool;
for i = 1:NumSine 
    ym = winnowed_sine.clips{i};
    boutStart = winnowed_sine.start(i);
    r = length(ym);
    sec = r/10000;
    if r>1
        if sec < 0.1
            wnd = round(Fs*sec);
            z = resample(ym,Fs,10000);
            voltage=[];
            [Sn,F] = spectrogram(z,wnd,[],nfft,Fs);
            a = find(F>80 & F<250);
            freq2 = F(a);
            voltage = abs(Sn(a,:));
            
            [~,I] = max(voltage); %I = index of max of the signal between 80-250Hz
            maxFFTFreq{i} = freq2(I); %the frequency with this index
            maxFFTFreqTime{i} = boutStart;
            
        elseif sec > 0.1
            wnd = round(0.1*Fs);
            z = resample(ym,Fs,10000);
            voltage=[];
            [Sn,F] = spectrogram(z,wnd,[],nfft,Fs);
            a = find(F>80 & F<250);
            freq2 = F(a);
            voltage = abs(Sn(a,:));
            
            [~,I] = max(voltage); %I = index of max of the signal between 80-250Hz
            maxFFTFreq{i} = freq2(I); %the frequency with this index
            maxFFTFreqTime{i} = boutStart:500:boutStart+(500*length(I))-1;
        end
    end
end
maxFFTFreq = maxFFTFreq


maxFFT.freq = maxFFTFreq;
maxFFT.time = maxFFTFreqTime;
maxFFT.freqAll = cell2mat(maxFFTFreq);
maxFFT.timeAll = cell2mat(maxFFTFreqTime');


