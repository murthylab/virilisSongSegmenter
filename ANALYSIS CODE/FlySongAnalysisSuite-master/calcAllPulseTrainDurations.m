trainTimes = [];

for i = 1:75
    numtrains = numel(ipiTrainsTime{i});
    for j = 1:numtrains
        trainDuration = ipiTrainsTime{i}{j}(end) - ipiTrainsTime{i}{j}(1);
        if trainDuration > 0
            trainTimes = [trainTimes trainDuration];
        end
    end
end
