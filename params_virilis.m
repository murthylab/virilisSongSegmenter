function segParams = params_virilis(fs)

if nargin < 1  || isempty(fs)
    fs = 10000;
end

%%%%%%%%%%%%%%ALL USER DEFINED PARAMETERS ARE SET HERE%%%%%%%%%%%%%%%%%%%%%


%frequencies to use (don't change unless you want to re-run the likelihood
%models)
fc = 100:20:900; 

%sampling frequency  
%fs = 1e4; 

%factor for computing window around pulse peak 
%(this determines how much of the signal before and after the peak 
%is included in the pulse, and sets the parameters w0 and w1.)
pulseWindow = round(fs/25); 

%factor times the mean of xempty - only pulses larger than 
%this amplitude are counted as true pulses
noiseFactor = 1; 

%male pulse carrier frequency
mpf = 350; 

%100Hz lowpass filter for male pulse detection
male = 100;

%40Hz lowpass filter for female pulse detection
female = 40; 

%20Hz lowpass filter for male song bout detection
bout = 20; 

%male bout detection based on IPI, in samples
male_IPI = 250;

%Smoothing parameter for data
filterWindow = 5;


%%%%%%%%%%%%%%%%%%%%%%%

%Threshold for P(both singing | data)
probThreshold = 1;

%Male probability threshold
maleThreshold = .2;
    
%minimum size of a female pulse in the midst of a male pulse (in data
%points)
minFemalePulseSize = 150;

%number of PCA modes to use in analysis (3 -> 41)
probModes = 20; %(DONT CHANGE THIS!!!!!!!!!!!!!!)

%Pnoise < noiseThreshold to count as signal 
noiseThreshold = .5;

%minimum percentage of time where p(male) > p(female) in order for the bout
%to be counted as male (***)
minMaleBoutFraction = 1/5;

%Number of time points over which to test male activity (i is called male if
%the number of initially called male frames is greater than
%minMaleBoutFraction*maleTestDuration points over
%(i-maleTestDuration):(i+maleTestDuration)
maleTestDuration = 500;

%minimum duration for a bout to be called a male bout (in time points) (***)
minMaleDuration = 1000;

%Smoothing parameter for male and combination song likelihoods (***)
smoothParameter_male = 25;

%Smoothing parameter for female and nosie song likelihoods (***)
smoothParameter_female = 50;

%Smoothing parameter for female and nosie song likelihoods
smoothParameter_amplitudes = 25;

%Threshold for amplitude
amplitudeThreshold = .1;

%Threshold for for noise likelihood  (***)
%(smaller = more stringent, do not make lower than -5490, must be changed if probModes is changed)
noiseLikelihoodThreshold = 0;

%Threshold for calling the posterior value noise (between 0 and 1).
%Closer to 1 implies a more stringent cut-off
ampPostThreshold = .95;

%Maximum noise data set from which to create noise models
maxNumNoise = 500000;

%Maximum number of peaks to create GMM noise distribution PDF
maxNumPeaks = 4;

%Maximum number of peaks to create GMM noise distribution PDF for the first
%mode
maxNumPeaks_firstMode = 6;

%Number of PDF modes used to find female bouts within male bouts 
num_male_both_modes = 5;

%definition of closeness for female peak elimination (in ms)
female_IPI_limit = 26;

%num of consecutive close female peaks needed for elimination (should be
%odd)
num_female_IPI_limit = 3;

%length of time (in seconds) 
stop_recording_time = 140;

%whether or not to refine probabilities using the PDF projection theorem
usePDFProjections = false;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





segParams.fc = fc; 
segParams.fs = fs; 
segParams.pulsewindow = pulseWindow;
segParams.noiseFactor = noiseFactor;
segParams.mpf = mpf; 
segParams.male = male;
segParams.female = female;
segParams.bout = bout;
segParams.male_IPI = male_IPI;
segParams.probThreshold = probThreshold;
segParams.minFemalePulseSize = minFemalePulseSize;
segParams.filterWindow = filterWindow;
segParams.probModes = probModes;
segParams.noiseThreshold = noiseThreshold;
segParams.minMaleBoutFraction = minMaleBoutFraction;
segParams.minMaleDuration = minMaleDuration;
segParams.smoothParameter_male = smoothParameter_male;
segParams.smoothParameter_female = smoothParameter_female;
segParams.smoothParameter_amplitudes = smoothParameter_amplitudes;
segParams.amplitudeThreshold = amplitudeThreshold;
segParams.noiseLikelihoodThreshold = noiseLikelihoodThreshold;
segParams.maleThreshold = maleThreshold;
segParams.ampPostThreshold = ampPostThreshold;
segParams.maxNumNoise = maxNumNoise;
segParams.maxNumPeaks = maxNumPeaks;
segParams.maxNumPeaks_firstMode = maxNumPeaks_firstMode;
segParams.num_male_both_modes = num_male_both_modes;
segParams.female_IPI_limit = female_IPI_limit;
segParams.num_female_IPI_limit = num_female_IPI_limit;
segParams.stop_recording_time = stop_recording_time;
segParams.usePDFProjections = usePDFProjections;
segParams.maleTestDuration = maleTestDuration;


