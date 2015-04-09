function ipi = fit_ipi_model(pulseTimes,numComponents)
%ipi = fit_ipi_model(pulseInfo)
%provide pulses
%return info about ipis, time in second (not samples)

%p are pulses (=pulseInfo2.wc)
fprintf('fitting ipi model\n')
p = pulseTimes;

if nargin <2
    numComponents = 6;
end

p_shift_one = circshift(p,[0 -1]);
ipi_d=p_shift_one(1:end-1)-p(1:end-1);
%Test range of gmdistribution.fit parameters
AIC=zeros(1,numComponents);
obj=cell(1,numComponents);
options = statset('MaxIter',500);
for k=1:numComponents
    try
        obj{k}=gmdistribution.fit(ipi_d',k,'options',options);
        
    catch
        fprintf('problem\n')
        AIC(k) = NaN;
    end
%     if obj{k}.Converged == 1%keep AIC only for those that converged
%         AIC(k)=obj{k}.AIC;
%     else
%         
%     end

end
[~,numComponents]=min(AIC);%best fit model

% find(obj{1}.PComponents == max(obj{1}.PComponents));
ipi_index = find(obj{numComponents}.PComponents == max(obj{numComponents}.PComponents));%find the model in the mixture model with the highest mixture proportion
ipi_mean = obj{numComponents}.mu(ipi_index);
ipi_var = obj{numComponents}.Sigma(ipi_index);
ipi_SD = sqrt(ipi_var);

ipi_time = p(1:end-1);
ipi = struct('u',ipi_mean,'S',ipi_SD,'d',ipi_d,'t',ipi_time,'fit',obj{numComponents});%results in units of samples

%     fprintf('Could not fit mixture model with winnowed ipis.\n')
%     
%     ipi =struct('u',[],'S',[],'d',[],'t',[],'fit',{});
end

