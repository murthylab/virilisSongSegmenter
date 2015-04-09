function [fitFunction,X,Y] = estimateCDFfromData(data,N)

    [Y,X] = hist(data,N);
    Y = cumsum(Y) ./ sum(Y);

    Y = [0 Y 1];
    X = [-1e20 X 1e20];
    
    fitFunction = fit(X',Y','linearinterp');