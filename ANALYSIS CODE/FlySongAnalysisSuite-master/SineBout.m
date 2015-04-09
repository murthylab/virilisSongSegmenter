BoutTime = cell(numel(BoutsStart),1);
BoutDur = BoutTime;
SineDur = BoutTime;

BoutDurVSTime = zeros(numel(BoutsStart),1);
SineFracVSTime = BoutDurVSTime;

for i = 1:numel(BoutsStart)
    
    numBouts = numel(BoutsStart{i});
    sinedur = zeros(numBouts,1);
    boutdur = sinedur;
    bouttime = boutdur;
    for j = 1:numBouts
        sinestarts = SineStart{i}(SineStart{i} >= BoutsStart{i}(j) & SineStart{i} <= BoutsStop{i}(j));
        sinestops = SineStop{i}(SineStop{i} >= BoutsStart{i}(j) & SineStop{i} <= BoutsStop{i}(j));
        sinedur(j) = sum(sinestops -sinestarts);
        boutdur(j) = BoutsStop{i}(j) - BoutsStart{i}(j);
        bouttime(j) = BoutsStart{i}(j);
        
    end
    BoutTime{i} = bouttime;
    BoutDur{i} = boutdur;
    SineDur{i} = sinedur;
    BoutDurVSTime(i) = corr(boutdur,bouttime);
    SineFracVSTime(i) = corr(sinedur./boutdur,bouttime);

end
    
    
