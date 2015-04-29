function [ normnel, normci ] = bootstrapplot(catgroup, bins)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
[nel,centers]=hist(catgroup,bins);
hh = @(x) hist(x,centers);
ci=bootci(1000,{hh,catgroup});
normnel=nel/max(nel);
normci=ci./max(nel);
figure(1); hold on; fill([centers fliplr(centers)], [normci(1,:) fliplr(normci(2,:))], 'b');
plot(centers,normnel);

end

