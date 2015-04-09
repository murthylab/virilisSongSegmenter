
%toggle to use raw (1) or relative
raw = 0;

    
bins = 50;

if raw == 1
    %for raw data
    %for sine data
%     xx = linspace(100,200,50);
    %for pulse data
    xx = linspace(100,350,50);
    
else
    %for relative to start
    xx = linspace(-100,100,bins);
end

size_bout = 8;%size(dTime,3);
% time = size(dTime,2);
time = 30; %Look at only first 20 time points in each sine
hold on
colormap cool


for i = 1:size_bout
    
    Z = zeros(time,bins);
    M = zeros(time,1);
    S = zeros(time,1);
    for j = 1:time
        if raw == 1
%             to plot raw
            Z(j,:) = hist(dFreq(:,j,i),xx);
            M(j) = nanmean(dFreq(:,j,i));
            S(j) = nanstd(dFreq(:,j,i));
        else
%             to plot relative to starting freq
            Z(j,:) = hist(dFreq(:,j,i)-dFreq(:,1,1),xx);
            M(j) = nanmean(dFreq(:,j,i)-dFreq(:,1,1));
            S(j) = nanstd(dFreq(:,j,i)-dFreq(:,1,1));
        end
        if i == 1 && j == 1
            line([1 time*size_bout],[M(1) M(1)],'Color',[.5 .5 .5])
        end
    end
    Z(Z == 0) = NaN;

    time_ax = (1:time) + (time * (i -1));
    
    pcolor(time_ax,xx,log(Z'));
    shading interp;
    plot(time_ax,M,'k','LineWidth',2);
    plot(time_ax,M+S,'k','LineWidth',1);
    plot(time_ax,M-S,'k','LineWidth',1);
    plot(time_ax(1),M(1),'or','MarkerFaceColor','r');
end


set(gca,'XTick',time/2:time:time*size_bout-time/2)
set(gca,'XTickLabel',num2cell(1:size_bout))
% xlabel('Sine train number in a single song bout','fontsize',14)
xlabel('Sine train number in a single song bout','fontsize',14);
if raw == 1
%     ylabel('Sine frequency (Hz)','fontsize',14)
    ylabel('Sine frequency (Hz)','fontsize',14);
else
%     ylabel('Sine frequency relative to initial frequency (Hz)','fontsize',14)
        ylabel('Sine frequency relative to initial frequency (Hz)','fontsize',14);

end
t = colorbar('peer',gca);
set(get(t,'ylabel'),'String','Log(N)');
