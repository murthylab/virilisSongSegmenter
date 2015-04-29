function errorbarjitterlog(data)
cat=size(data,2);

x=1:cat;
jitter=rand(1,size(data,1))*0.25';
for i=1:cat;
xjit(1:size(data,1),i)=i+jitter;
end

semilogy(xjit,data,'.')

med=(nanmedian(data));
std=nanstd(data);
hold on;
plot(x+0.5,med,'o')
xx=horzcat(x'+0.5,x'+0.5);
for i=1:cat;
    start=med(1,i)-std(1,i);
    if start<0
        start=0.001;
    end
    stop=med(1,i)+std(1,i);
line([i+0.5 i+0.5],[start stop])
end