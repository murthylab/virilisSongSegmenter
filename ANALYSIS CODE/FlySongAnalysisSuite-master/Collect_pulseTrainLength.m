%for hist of pulse trains


%cycle though every file, collect j from each file

j = zeros(numel(d.t),1);
for i = 1:numel(d.t)
    j(i) = d.t{i}(end) + d.d{i}(end) - d.t{i}(1);
end


hist(j,100)