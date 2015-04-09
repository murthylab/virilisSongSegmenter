function [ data ] = binread( FileName)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
load(FileName);
skip=legnth(rDat.channels);
nchan=1;
fid=fopen(FileName,'r');
y=fread(fid,[nchan inf],'double');
fclose(fid);

figure(1); plot(y(1:2:end))
figure(2); plot(y(2:2:end))
end

