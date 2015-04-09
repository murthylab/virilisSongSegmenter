function [ variablecol ] = cell2column( variable );
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

for i=1:length(variable);
c(1,i)=length(variable{i});
d=max(c);
end

variablecol=NaN(d,length(variable));

for n=1:length(variable);
    variablecol(1:length(variable{n}),n)=cell2mat(variable(n));
end
end

