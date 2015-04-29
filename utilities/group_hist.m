function [catgroup,f,x,curve,y]=group_hist( group );
% histogram for group data organized in a cell array
%   whole group
catgroup=cell2mat(group);
catgroup=catgroup(:);
a=~isnan(catgroup);
catgroup=catgroup(a);

%catgroup=log10(catgroup);
%figure; hist(catgroup,100000)
[f,x]=ksdensity(catgroup);
f=f./max(f);
%figure(1);plot(x,f);
%figure(2); semilogy(x,f);

%individual data sets plotted together
for n=1:length(group);
    if isempty(group{n});
        continue
    else
        data=group{n}(:);
        if isnan(data);
            continue
        else
        [d,y]=ksdensity(data);
        %d=d./max(d);
        curve(n,:)=d;
        
    end
    end


end
%figure(2); hold on; line(y,curve);
mean=nanmean(curve);
std=nanstd(curve);
%figure(3); fill([y (fliplr(y))], [mean+std fliplr(mean-std)], 'b');
%figure(3); hold on; plot(y,mean,'r');
end

