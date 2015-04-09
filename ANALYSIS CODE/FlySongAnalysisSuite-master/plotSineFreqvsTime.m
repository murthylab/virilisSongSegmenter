
%toggle to use raw (1) or relative
raw = 1;


%get 2D arrays of time and Freq
numels = size(dTime,2) * size(dTime,3);
numbouts = size(dTime,1);
t = zeros(numbouts,numels);
f = t;

for i = 1:numbouts
    time = dTime(i,:,:);
    time = reshape(time,numels,1);
    t(i,:) = time';
    
    freq = dFreq(i,:,:);
    freq = reshape(freq,numels,1);
    f(i,:) = freq';
end
    
startTimes = t(:,1);
rmst = repmat(startTimes,1,size(t,2));
normT = t - rmst;

%range of times
start = 0;
% stop = max(max(normT));
%Too comp intensive to use all data, Use first 5 sec
stop = 5e4;

steps = 1 + floor(stop / 500);

bins = 50;

xx = linspace(100,200,bins);

Z = zeros(steps,bins);
M = zeros(steps,1);
S = M;
j = 0;

for i = start:500:stop
    j =j +1;
    D = f(normT==i);
    Z(j,:) = hist(D,xx);
    M(j) = mean(D);
    S(j) = std(D);
end



time_ax = start:500:stop;
pcolor(time_ax,xx,log(Z'));

colormap cool
shading flat
hold on
%plot mean
plot(time_ax,M,'k','LineWidth',2)
plot(time_ax,M+S,'k','LineWidth',1)
plot(time_ax,M-S,'k','LineWidth',1)
    
% xlim([1 200])
% ylim([60 200])

% plot(time_ax(1),M(1),'oc','MarkerFaceColor','c')
t = colorbar('peer',gca);
set(get(t,'ylabel'),'String','Log(N)');


set(gca,'XTick',0:1e4:stop);
set(gca,'XTickLabel',num2cell(0:5));
xlabel('Time from start of bout (sec)','fontsize',14);
ylabel('Sine frequency (Hz)','fontsize',14);
