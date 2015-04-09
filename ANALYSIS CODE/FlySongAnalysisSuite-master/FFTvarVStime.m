run = 50;
% for i = 1:75
	length_song = numel(SINEFFTtimesall{i});
	last = length_song - run;
	runvar = zeros(last,1);
	for j = 1:last
		runvar(j) = var(SINEFFTfreqall{i}(j:j+run));
	end	
% end