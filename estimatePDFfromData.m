function [fitFunction,X,Y] = estimatePDFfromData(data,N)

    [Y,X] = hist(data,N);
    
    Y = Y / (sum(Y) *(X(2)-X(1)));
    Y = [0 Y 0];
    X = [-1e20 X 1e20];
    
    fitFunction = fit(X',Y','linearinterp');