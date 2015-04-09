function [ femaletimes ] = BTA( file )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
load(file, 'femaleBoutInfo', 'femaleBoutInfo_no_overlap','maleBoutInfo', 'run_data');
 femaletimes=NaN(length(maleBoutInfo.wc),100);
 
 for i=1:length(maleBoutInfo.wc);
zz=find(run_data.pulseInfo.wc>maleBoutInfo.w0(i) & run_data.pulseInfo.wc<maleBoutInfo.w1(i));%trigger on whole male bout
%5,'first'); %trigger to first pulse of male bout
if isempty(zz)
    continue
else
 a=run_data.pulseInfo.wc(zz(1,1));
 aa=run_data.pulseInfo.wc(zz(1,end));
 x=find(femaleBoutInfo_no_overlap<(aa+20000)& femaleBoutInfo_no_overlap>aa);
 xx= find(femaleBoutInfo_no_overlap>(a-20000)& femaleBoutInfo_no_overlap<a);
 %xx=find(femaleBoutInfo.wMax<(z+10000)&femaleBoutInfo.wMax>(z-10000));
 if isempty(xx)
     continue
 else
     c=femaleBoutInfo_no_overlap(x)-aa;
     cc=femaleBoutInfo_no_overlap(xx)-a;
     final=horzcat(c,cc);
     %x=femaleBoutInfo.wMax(xx)-z;
     femaletimes(i,1:length(final))=final;
    
 end
end
 end
end

