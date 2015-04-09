function [FALSENEGF, FALSENEGM, FALSEPOSF, FALSEPOSM]=GROUND_TRUTHINGv3(RR,FPULSE, MPULSE);

%take hand segmented data (from 5-6min of songs: 9 different songs; 
%PULSE times and SINE starts and stops are in ms (relative to the start of the full song))
%compare to pulseInfo2 (following heuristic winnow), pulseInfo,
%culled_pulseInfo_1 (pulse model winnow on pulseInfo) and culled_pulseInfo (pulse model winnow on
%pulseInfo2)

%the comparison should transform the pulse times or sine times into a
%smoothed vector of ones and zeros - then use various metrics to look at relationships.  Some sort of smoothing is critical
%because the exact pulse and sine times won't be the same for hand
%segmentation versus automated....

%%

for RR=RR
    
    if RR==1; %each hand annotated workspace contains both the hand segmeneted data and the automated data (including following culling with the pulse model)
        load('PS_ch1.mat', 'femaleBoutInfo');
        load('PS_ch1.mat', 'run_data');
        load('PS_ch1.mat', 'maleBoutInfo');
    elseif RR==2;
        load('PS_ch2.mat', 'femaleBoutInfo');
        load('PS_ch2.mat', 'run_data');
        load('PS_ch2.mat', 'maleBoutInfo');
    elseif RR==3;
         load('PS_ch3.mat', 'femaleBoutInfo');
        load('PS_ch3.mat', 'run_data');
        load('PS_ch3.mat', 'maleBoutInfo');
    elseif RR==4;
         load('PS_ch4.mat', 'femaleBoutInfo');
        load('PS_ch4.mat', 'run_data');
        load('PS_ch4.mat', 'maleBoutInfo');
    elseif RR==5;
         load('PS_ch5.mat', 'femaleBoutInfo');
        load('PS_ch5.mat', 'run_data');
        load('PS_ch5.mat', 'maleBoutInfo');
    elseif RR==6;
         load('PS_ch6.mat', 'femaleBoutInfo');
        load('PS_ch6.mat', 'run_data');
        load('PS_ch6.mat', 'maleBoutInfo');
    elseif RR==7;
         load('PS_ch7.mat', 'femaleBoutInfo');
        load('PS_ch7.mat', 'run_data');
        load('PS_ch7.mat', 'maleBoutInfo');
    elseif RR==8;
         load('PS_ch8.mat', 'femaleBoutInfo');
        load('PS_ch8.mat', 'run_data');
        load('PS_ch8.mat', 'maleBoutInfo');
    elseif RR==9;
         load('PS_ch9.mat', 'femaleBoutInfo');
        load('PS_ch9.mat', 'run_data');
        load('PS_ch9.mat', 'maleBoutInfo');
    elseif RR==10;
         load('PS_ch10.mat', 'femaleBoutInfo');
        load('PS_ch10.mat', 'run_data');
        load('PS_ch10.mat', 'maleBoutInfo');
    elseif RR==13;
         load('PS_ch13.mat', 'femaleBoutInfo');
        load('PS_ch13.mat', 'run_data');
        load('PS_ch13.mat', 'maleBoutInfo');
    end
%%    manual female pulses

RR

Fs=10000;

Fch=FPULSE(:,1)==RR;
Fch=FPULSE(Fch,2);
Fch= round(Fch.*Fs/1000)'; %to get data back into points from ms 
FEMALE = sort(Fch, 'ascend');
if ~isempty(run_data.stoptime);
FEMALE=FEMALE(find(FEMALE<run_data.stoptime*10));
else
    FEMALE=FEMALE;
end
IPI_f = (diff(FEMALE)); %in points
index = find(IPI_f < 1000 & IPI_f > 0); 
meanIPIf = mean(IPI_f(index)); %mean IPI
medianIPIf = median(IPI_f(index)); %mode IPI
varIPIf = var(IPI_f(index)); %variance IPI
stdIPIf = std(IPI_f(index)); %standard deviation IPI
IPI_female=struct('IPI_f', IPI_f,'meanIPIf',meanIPIf,'medianIPIf',medianIPIf,'varIPIf',varIPIf,'stdIPIf',stdIPIf);
h=figure(1); hist(IPI_f(index),100); title('female IPI histogram manual');
name = ['female_IPI_hist_manual_' int2str(RR) '.fig'];
saveas(h,name); 


%% manual male pulses

Mch=MPULSE(:,1)==RR;
Mch=MPULSE(Mch,2);
Mch= round(Mch.*Fs/1000)'; %to get data back into points from ms 
MALE = sort(Mch, 'ascend');
if ~isempty(run_data.stoptime);
MALE=MALE(find(MALE<run_data.stoptime*10));
else
    MALE=MALE;
end
IPI_m = (diff(MALE)); %in points
index = find(IPI_m < 1000 & IPI_m > 0); 
meanIPIm = mean(IPI_m(index)); %mean IPI
medianIPIm = median(IPI_m(index)); %mode IPI
varIPIm = var(IPI_m(index)); %variance IPI
stdIPIm = std(IPI_m(index)); %standard deviation IPI
IPI_male=struct('IPI_m', IPI_m,'meanIPIm',meanIPIm,'medianIPIm',medianIPIm,'varIPIm',varIPIm,'stdIPIm',stdIPIm);
h=figure(2); hist(IPI_m(index),100); title('male IPI histogram manual');
name = ['male_IPI_hist_manual_' int2str(RR) '.fig'];
saveas(h,name); 

%% automated female pulses

AUTOFEMALE = femaleBoutInfo.wMax;
if ~isempty(run_data.stoptime);
AUTOFEMALE=AUTOFEMALE(find(AUTOFEMALE<run_data.stoptime*10));
else
    AUTOFEMALE=AUTOFEMALE;
end
IPI_autof = (diff(AUTOFEMALE)); %in points
index = find(IPI_autof < 1000); 
meanIPI_autof = mean(IPI_autof(index)); %mean IPI
medianIPI_autof = median(IPI_autof(index));
varIPI_autof = var(IPI_autof(index));
stdIPI_autof = std(IPI_autof(index)); %standard deviation
IPI_autofemale=struct('IPI_autof', IPI_autof, 'meanIPI_autof',meanIPI_autof,'medianIPI_autof',medianIPI_autof,'varIPI_autof',varIPI_autof,'stdIPI_autof',stdIPI_autof);
g=figure(3); hist(IPI_autof(index),100); title('female IPI histogram auto');
name = ['female_IPI_hist_auto_' int2str(RR) '.fig'];
saveas(g,name); 

%% automated male pulses
vector_mpulse= [];
for n=1:numel(maleBoutInfo.wc); %
A=maleBoutInfo.w0(n); 
AA=maleBoutInfo.w1(n); 
zz=find(run_data.pulseInfo.wc>A & run_data.pulseInfo.wc<AA);
pulsetime=run_data.pulseInfo.wc(zz);
vector_mpulse(pulsetime) = 1;
end
AUTOMALE=find(vector_mpulse);
if ~isempty(run_data.stoptime);
AUTOMALE=AUTOMALE(find(AUTOMALE<run_data.stoptime*10));
else
    AUTOMALE=AUTOMALE;
end
IPI_autom = (diff(AUTOMALE)); %in points
index = find(IPI_autom < 1000); 
meanIPI_autom = mean(IPI_autom(index)); %mean IPI
medianIPI_autom = median(IPI_autom(index));
varIPI_autom = var(IPI_autom(index));
stdIPI_autom = std(IPI_autom(index)); %standard deviation
IPI_automale=struct('IPI_autom',IPI_autom,'meanIPI_autom',meanIPI_autom,'medianIPI_autom',medianIPI_autom,'varIPI_autom',varIPI_autom,'stdIPI_autom',stdIPI_autom);
g=figure(4); hist(IPI_autom(index),100); title('male IPI histogram auto');
name = ['male_IPI_hist_auto_' int2str(RR) '.fig'];
saveas(g,name); 


%% female ground truthing

%false negative
interval = 200;
for z=1:length(FEMALE);
    a=FEMALE(z);
    b = AUTOFEMALE < a + interval & AUTOFEMALE > a - interval;
    c = find(b);
    if isempty(c);
        falsenegf(z) = 1;
    end
end
falsenegf=find(falsenegf);
FALSENEGF = length(falsenegf)/length(FEMALE);


%false positive
 for z=1:length(AUTOFEMALE);
     a=AUTOFEMALE(z);
    b = FEMALE < a + interval & FEMALE > a - interval;
    c = find(b);
    if isempty(c);
        falseposf(z) = 1;
    end
 end
 falseposf=find(falseposf);
FALSEPOSF = length(falseposf)/length(AUTOFEMALE);

%% male ground truthing

%false negative
for z=1:length(MALE);
    a=MALE(z);
    b = AUTOMALE < a + interval & AUTOMALE > a - interval;
    c = find(b);
    if isempty(c);
        falsenegm(z) = 1;
  
    end
end
falsenegm=find(falsenegm);
FALSENEGM = length(falsenegm)/length(MALE);


%false positive
 for z=1:length(AUTOMALE);
     a=AUTOMALE(z);
    b = MALE < a + interval & MALE > a - interval;
    c = find(b);
    if isempty(c);
        falseposm(z) = 1;
       
    end
 end
 falseposm=find(falseposm);
FALSEPOSM = length(falseposm)/length(AUTOMALE);




name = ['gt_workspace_' int2str(RR) '.mat'];
save(name, 'FALSENEGF', 'FALSENEGM', 'FALSEPOSF', 'FALSEPOSM', 'IPI_automale', 'IPI_autofemale', 'IPI_male', 'IPI_female');
clearvars -except FPULSE MPULSE

end


