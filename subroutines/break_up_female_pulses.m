function female_pulses = break_up_female_pulses(female_pulses,amps,segmentParameters)
%Finds individual female pulses within female regions
%Inputs:
%   female_pulses -> cell array containing many collections of female pulse regions
%   amps -> wavelet amplitudes
%   segmentParameters -> struct containing run parameters
%
%Outputs:
%   female_pulses -> broken-up version of the input
%
% (C) Gordon J. Berman, Jan Clemens, Kelly M. LaRue, and Mala Murthy, 2015
%     Princeton University

    amps2 = gaussianfilterdata(amps,segmentParameters.smoothParameter_amplitudes);
    amps2(amps == 0) = 0;
    
    N = length(female_pulses(:,1));
    new_pulses = zeros(10*N,2);
    keep = true(N,1);
    
    count = 1;
    for i=1:N
        q = female_pulses(i,:);
        Lq = q(2) - q(1) + 1;
        idx = setdiff(find(imregionalmax(amps2(q(1):q(2)))),[1 Lq]);
        L = length(idx);
        if L > 1
            keep(i) = false;
            idx2 = find(imregionalmin(amps2(q(1):q(2))));
            w = zeros(L,2);
            for j=1:L
                w(j,:) = [idx2(j) idx2(j+1)-1];
            end
            w(end,2) = w(end,2) + 1;
            
            new_pulses(count:count+L-1,:) = w + q(1) - 1;
            count = count + L;
        end
    end
    
    new_pulses = new_pulses(1:count-1,:);
    
    female_pulses = [female_pulses(keep,:); new_pulses];
    female_pulses = sortrows(female_pulses);