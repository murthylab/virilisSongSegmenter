%make great pulse model from each individual

%1 - Starting with pulseInfo2 models, put bad songs in separate folder
%2 - build culled model from each of remaining

culled_pulseInfo = cull_pulses(pulseInfo2,Lik_pulse.LLR_best,[0 200]);
[culled_pulse_model,culled_Lik_pulse] = fit_pulse_model(culled_pulseInfo.x);

%compare culled_pulse_model among individuals and strains
%Options
%PCA
%Cluster method - pdist, then UPGMA


%??? Is this necessary
%build new community pulse model with sample of data from each individual that forms
%a cluster


%Or just do following on good individuals
%algorithm to make pulse model calculate ipis from each individual

culled_pulseInfo = cull_pulses(pulseInfo2,Lik_pulse.LLR_best,[0 200]);
[culled_pulse_model,culled_Lik_pulse] = fit_pulse_model(culled_pulseInfo.x);
[~,Lik_pulse_all] = Z_2_pulse_model(culled_pulse_model,pulseInfo.x);
final_pulseInfo = cull_pulses(pulseInfo,Lik_pulse_all.LLR_best,[0 200]);
ipi = fit_ipi_model(final_pulseInfo,1e4);
culled_ipi = cullByCDF(ipi, [ ],.005);
gmixPlot(culled_ipi.d',5,100,1e5,[],1);%gives nice plot of mixture model
