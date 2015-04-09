Sine_Freq_Bout = NaN(75,1000,200);
Sine_Freq_Times = NaN(75,1000,200);

for i=1:length(file_names); %75 experiments
    maxFFTfreq = SINEFFTfreq{i}; %take the data from the first experiment
    maxFFTtimes = SINEFFTtimes{i};
    bout_Start = BoutsStart{i};
    bout_Stop = BoutsStop{i};
    
    for n = length(bout_Start); %
        start = bout_Start(n);
        stop = bout_Stop(n);
        A = find(maxFFTtimes>start & maxFFTtimes<stop); %A are the indices of maxFFTtimes within this bout
        B = maxFFTfreq(A); %these are the corresponding sine song frequencies within that region
        C = maxFFTtimes(A); %these are the times for these frequencies
        if C>0;
        C = C - (C(1)-1);
        B = B./min(B);
        Sine_Freq_Bout(i,1:length(A),n) = B; %each column is a different bout and frequencies are down the rows
        Sine_Freq_Times(i,1:length(A),n) = C;
        figure(1); hold on; plot(C./10000,B,'.');
        %figure(2); hold on; plot(B,'.r');
        end
    end
end

n=1;
for i = 1:75;
SFB(1,n:n+200000-1) = reshape(Sine_Freq_Bout(i,:,:),1,200000); %reshape works column-wise, so goes down each column
SFT(1,n:n+200000-1) = reshape(Sine_Freq_Times(i,:,:),1,200000);
n=n+200000;
end

r=1;
for n=1:15000000;
    a = SFB(1,n);
    TF = isnan(a);
    if TF == 1;
        continue
    end
    SFB_A(1,r) = SFB(1,n);
    SFT_A(1,r) = SFT(1,n);
    r = r + 1;
end

x=[];
y=[];
x = SFT_A';
y = SFB_A';
[cfun,cfit,output] = fit(x, y,'exp1');

rsquare = cfit.adjrsquare;
const = cfun.b;
mult = cfun.a;
xf = linspace(1,5e4,5e4);
    %if cfit.adjrsquare>0.8; %if rsquare value is > 0.5
yf = exp(const*xf);

%figure(1); hold on; plot(xf,yf,'k');
%%
mean_sfb = NaN(75,1000);
for i=1:75;
    sfb = Sine_Freq_Bout(i,:,:); %the matrix for each experiment (columns are each bout and rows contain the frequencies)
    sfb = squeeze(sfb);
    mean_sfb(i,1:1000) = nanmean(sfb,2); %mean down the columns
end

mm_sfb = nanmean(mean_sfb,1);
mm_sfb_std = nanstd(mean_sfb,1);

figure; errorbar (mm_sfb, mm_sfb_std);




