function [ sub_nel, sub_nel_ci ] = subsample( data , samples, perms, centers);
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
n=length(data);
m=samples;
%round(n*0.5);
for i=1:perms;
    nums=randperm(n);
    sub_data(i,1:m)= data(nums(1:m));

    sub_nel(i,:)=hist(sub_data(i,:),centers);
    h=@(x) hist(x,centers);
    sub_nel_ci((i*2)-1:i*2,:)=bootci(1000,{h, sub_data(i,:)});
    
    hold on; fill([centers fliplr(centers)], [sub_nel_ci((i*2)-1,:)./max(sub_nel(i,:)) fliplr(sub_nel_ci(i*2,:)/max(sub_nel(i,:)))], 'b');
plot(centers,sub_nel(i,:)/max(sub_nel(i,:)))
end

