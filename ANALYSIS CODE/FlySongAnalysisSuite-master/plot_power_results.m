%plot power results

all_alpha = zeros(20,75);
for i = 1:75
    all_alpha(:,i) = lsr.results{i}.best_alpha;
end

power = zeros(20,1);
for i = 1:20
    power(i) = numel(find(all_alpha(i,:) < 0.05)) / 75;
end
plot(.1:.1:2,power)