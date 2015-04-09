function [data] = build_matrix(varargin)
%USAGE
%%build_matrix(vec1, vec2, vec3...) out of different length vectors
%%replacing empty spaces with NaN.

%%Creates a matrix with vectors of different dimensions

data = [];

for i = 1:nargin
    lngths(i) = length(varargin{i});
end

ncells = max(lngths)

for i = 1:nargin
    res = varargin{i};
    
    if length(res) < ncells
         res(length(res)+1:ncells) = NaN;
    end
    
    data = cat(2, data, res');
       
end




    