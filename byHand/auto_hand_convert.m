function [ FPULSE, MPULSE, OVERLAP] = auto_hand_convert( file)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

load(file,'femaleBoutInfo','maleBoutInfo', 'run_data');
ch = str2double(file(strfind(file, 'ch')+2:strfind(file, '.mat')-1));
Fs=7812.5;
factor=Fs/1000;

FPULSE=[];
MPULSE=[];
OVERLAP=[];
% pulses=NaN(length(maleBoutInfo.wc),20);

FPULSE(:,2)=femaleBoutInfo.wMax/factor;
FPULSE(1:length(femaleBoutInfo.wMax),1)=ch;

% j=1;
for i=1:length(maleBoutInfo.wc);
% zz=find(run_data.pulseInfo.wc>maleBoutInfo.w0(i) & run_data.pulseInfo.wc<maleBoutInfo.w1(i));
% if isempty(zz)
%     continue
% else
%     pulses(j,1:length(zz))=run_data.pulseInfo.wc(zz);
%     j=j+1;
% end
% end
% pulses=pulses(:);
% keep=~isnan(pulses);
% keep=pulses(keep);
% MPULSE(1:length(keep),2)=sort(keep/10,'ascend');
% MPULSE(1:length(keep),1)=ch;

MPULSE(1:length(maleBoutInfo.wc),2)=maleBoutInfo.w0/factor;
MPULSE(1:length(maleBoutInfo.wc),3)=maleBoutInfo.w1/factor;
MPULSE(1:length(maleBoutInfo.wc),1)=ch;


end

