%for plotting, get length of longest sine bout
x = zeros(numel(PulseTrainStart,1));
for i = 1:numel(PulseTrainStop)
    for j = 1:numel(PulseTrainStart{i})
        z = sum(ismember(pulseFFTtimes{i},PulseTrainStart{i}(j):PulseTrainStop{i}(j)));
        x(i) = z;
    end
end
MaxPulseTrainLength= max(x);

%for plotting, get max # of sine bouts per song bout and also total num
%bouts

a = zeros(numel(PulseTrainStart),1);
BoutNum = zeros(numel(BoutsStart),1);
NumPulseBoutsPerSongBout = cell(numel(BoutsStart),1);
for i = 1:numel(PulseTrainStart);
    numBouts = numel(BoutsStart{i});
    BoutNum(i) = numBouts;
    x = zeros(numBouts,1);
    for j = 1:numBouts
        z = sum(ismember(PulseTrainStart{i},BoutsStart{i}(j):BoutsStop{i}(j)));
        x(j) = z; %Num sine bouts per bout
    end
    NumPulseBoutsPerSongBout{i} = x;
    a(i) = max(x);
end
MaxNumPulseBouts=max(a);
TotalNumBouts = sum(BoutNum);

%Make 3D array to hold results for plotting
dFreq = NaN(TotalNumBouts,MaxPulseTrainLength,MaxNumPulseBouts);
dTime = NaN(TotalNumBouts,MaxPulseTrainLength,MaxNumPulseBouts);

%Dump data from SINEFFTfreq into d

boutNum = 0;
for i = 1:numel(PulseTrainStart);%for each individual
    numBouts = numel(BoutsStart{i});
    numPulseBouts = NumPulseBoutsPerSongBout{i};
    pulseBout = 0;
    for j = 1:numBouts%for each bout
        boutNum = boutNum + 1;
        for k = 1:numPulseBouts(j)%for each bout of sine in a song bout
            pulseBout = pulseBout+1;
            
             tf = ismember(pulseFFTtimes{i},PulseTrainStart{i}(pulseBout):PulseTrainStop{i}(pulseBout));

             pulseLength = sum(tf);
             dTime(boutNum,1:pulseLength,k) = pulseFFTtimes{i}(tf);
             dFreq(boutNum,1:pulseLength,k) = pulseFFTfreq{i}(tf);
    
        end
    end
end

dFreq(dFreq == 0) = NaN;
dTime(dTime == 0) = NaN;



