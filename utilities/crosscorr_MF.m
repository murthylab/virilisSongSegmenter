function [Fvector, Mvector, mutualinfo,timelag] = crosscorr_MF(maletimeswith, femaletimeswith );
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

for i=1:length(maletimeswith);
  MTW=(maletimeswith{i}(:));
if ~isempty(MTW);
for b=1:length(MTW);
    if ~isnan(MTW(b,1));
        d=round(MTW(b,1));
        Mvector(i,d)=1;
    end
end
end  
end
    
    Fvector=zeros(length(maletimeswith),size(Mvector,2));
for i=1:length(maletimeswith);
for f=1:length(femaletimeswith{i});
    if ~isempty(femaletimeswith{i});
if ~isnan(femaletimeswith{i}(f,1));
a=round(femaletimeswith{i}(f,1));
Fvector(i,a)=1;
end
    end
end



[c,lags]=xcov(Mvector(i),Fvector(i),1000);

mutualinfo(i, 1:length(c))=c';
timelag(i,1:length(lags))=lags;
end


end

