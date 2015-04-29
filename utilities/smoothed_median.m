function [ group_median ] = smoothed_median( group )
%smoothing of histogram to find median values of song parameters

for i=1:length(group);
    indiv=group{i};
    if ~isempty(indiv);
    [f,x]=ksdensity(indiv);
    [c,n]=max(f);
    group_median(i,1)=x(n);
    end
end

