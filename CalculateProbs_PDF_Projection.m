function [probs,crossPDFValues] = CalculateProbs_PDF_Projection(likelihoods,crossLikelihoodPDFs,priors)

    N = length(likelihoods(:,1));
    L = length(crossLikelihoodPDFs);

    %crossLikelihoodPDFs{i}{j} is the PDF of likelihood j given being drawn
    %from template i ( p(z_j | T_i) )
    
    crossPDFValues = zeros(N,L,L);
    for i=1:L
        for j=1:L
            crossPDFValues(:,i,j) = crossLikelihoodPDFs{i}{j}(likelihoods(:,j));
        end
    end
    
    if nargin < 4 || isempty(priors)
        priors = zeros(N,L) + (1/L);
    else
        s = size(priors);
        if s(2) < L
            temp = zeros(N,L);
            temp(:,3) = priors;
            temp(:,setdiff(1:L,3)) = repmat((1 - priors) / (L-1),1,L-1);
            priors = temp;
        end
    end
    
    beta = squeeze(sum(bsxfun(@times,crossPDFValues,priors),2));
    gamma = zeros(N,L);
    for i=1:L
        gamma(:,i) = bsxfun(@times,crossPDFValues(:,i,i),priors(:,i));
    end
    Z = sum(gamma ./ beta,2);
    
    
    probs = zeros(N,L);
    for i=1:L
        alpha = squeeze(crossPDFValues(:,i,i)).*priors(:,i);
        probs(:,i) = alpha ./ (Z.*beta(:,i));
    end
    
    