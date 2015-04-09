function Dmean = DKL(p, q)
% returns the Kullback-Leibler divergence between P and Q


p2=(p/nansum(p))+eps;
q=(q/nansum(q))+eps;
D1 = nansum(p2.*log2(p2./q));
D2 = nansum(q.*log2(q./p2));
Dmean=(D1+D2)/2;


