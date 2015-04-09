%compare sine and pulse train lengths

[file_names, SineStart,SineStop,sinemaxFFTfreq,sinemaxFFTtime,SINEFFTfreqall, SINEFFTtimesall,BoutsStart,BoutsStop] = Collect_sineMaxFFTFreq('/Users/sternd/Documents/Projects/courtship_song_analysis.w.t.-forpaper/WT_species/mel-all-6Mar/')
load('/Users/sternd/Documents/Projects/courtship_song_analysis.w.t.-forpaper/WT_species/mel-all-6Mar/_summary info/ipiStatsAll.mat')

%calculate total sine duration for each individual

for i = 1:75
    durations{i} = sum(SineStop{i} - SineStart{i});
end
SineDuration = cell2mat(durations);
    

%calculate total pulse duration for each individual

PulseDuration = zeros(1,75);
for i = 1:75
    numbouts = length(ipiStatsAll.TrainsT{i});
    temp = zeros(numbouts,1);
    for ii = 1:numbouts
        bout = cell2mat(ipiStatsAll.TrainsT{i}(ii));
        durationbout = bout(end) - bout(1);
        temp(ii) = durationbout;
    end
    PulseDuration(i) = sum(temp);
end
