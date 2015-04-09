function [variablemedian] = cellmedian(variable);
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
for i=1:length(variable);
    variablemedian(i,1)=median(variable{i});
end

end

