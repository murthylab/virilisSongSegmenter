function welchanovawd(x,alpha)
%WELCHANOVAWD Welch ANOVA Test for Unequal Variances without data.
%The ANOVA F-test to compare the means of k normally distributed
%  populations is not applicable when the variances are unknown, and not
%  known to be equal. A spacial case, k=2, is the famous Behrens-Fisher 
%  problem (Behrens, 1929; Fisher, 1935). Welch (1951) test was proposed to
%  fill this void, a generalization to his 1947 previous paper (Welch, 
%  1947). 
%     
%  The Welch test for general k compares the statistic
%                  __
%                 \   
%                 /__ w_i*(m_i - M)^2/(k - 1)
%           FW = -----------------------------
%                      1 + 2/3*(k - 2)*L
%
%  to the F_[(k - 1),1/L] distribution. Where:
%                      __                 __             
%                     \                  \            
%  w_i = n_i/v_i; M = /__ w_i*m_i/W; W = /__ w_i; f_i = n_i - 1;
%          __
%         \
%      3* /__(1 - w_i/W)^2/f_i
%  L = ------------------------
%             (k^2 - 1)
%
%  [m_i = sample mean; v_i = sample variance; n_i = sample size]                                                     
%
%  This m-file works without all the data samples. But only with the size,
%  mean and variance samples.
% 
%  Syntax: function welchanovawd(x,alpha)
%
%  Inputs:
%       x - data matrix (Size of matrix must be n-by-3; sample sizes=column
%           1, means=column 2,variances=column3)
%   alpha - significance level (default=0.05)
%
%  Outputs:
%       - Decision on the null-hypothesis tested
%
%  Taking the numerical example given by Welch (1951, p.335), an experiment
%  in wich three treatments are being compared,
%
%  Data are:
%
%           -----------------------------------------------
%           Treatment    Sample size     Mean      Variance
%           -----------------------------------------------
%               1             20         27.8        60.1         
%               2             10         24.1         6.3
%               3             10         22.2        15.4
%           -----------------------------------------------
%
%  Input data:
%
%  X=[20 27.8 60.1;10 24.1 6.3;10 22.2 15.4];
%
%  Calling on Matlab the function: 
%               welchanovawd(x,0.05)
%
%  Answer is:
%
%  Welch's Analysis of Variance Table.
%  ----------------------------------------
%  SOV       df              F       P
%  ----------------------------------------
%  Treat.    2             3.351   0.0532
%
%  Error    22.5678
%  ----------------------------------------
%  The associated probability for the Welch's F test is equal or larger 
%  than 0.05. So, the assumption of sample means are equal was met.
%
%  Created by A. Trujillo-Ortiz and R. Hernandez-Walls
%            Facultad de Ciencias Marinas
%            Universidad Autonoma de Baja California
%            Apdo. Postal 453
%            Ensenada, Baja California
%            Mexico.
%            atrujo@uabc.edu.mx
%
%  Copyright (C) June 3, 2012. 
%
%  --We thank Abdullah Chisti, University of Saskatchewan, Bangladesh, for
%   encourage us to produce this m-file.--
%
%  To cite this file, this would be an appropriate format:
%  Trujillo-Ortiz, A. and R. Hernandez-Walls. (2012). welchanovawd: Welch 
%    ANOVA Test for Unequal Variances without data. [WWW document]. URL 
%    http://www.mathworks.com/matlabcentral/fileexchange/37123-welchanovawd
%
%  References:
%  Behrens, W. V. (1929), Ein beitrag zur Fehlerberechnung
%             bei wenigen Beobachtungen. (transl: A contribution to error
%             estimation with few observations). Landwirtschaftliche 
%             Jahrbücher, 68:807–37.
%  Fisher, R. A. (1935), The fiducial argument in statistical inference.
%             Annals of Eugenics, 8:391–398.
%  Welch, B. L. (1947), The generalization of Student's problem when 
%             several different population variances are involved. 
%             Biometrika, 34(1–2):28–35  
%  Welch, B. L. (1951), On the comparision of several mean values: an
%             alternative approach. Biometrika, 38:330-336.
%

if nargin < 2 || isempty(alpha)
    alpha = 0.05; %default
elseif numel(alpha) ~= 1 || alpha <= 0 || alpha >= 1
    error('welchanovawd:BadAlpha','ALPHA must be a scalar between 0 and 1.');
end

X = x;
c = size(X,2);
if c ~= 3
    error('stats:welchanovawd:BadData','X must have three colums.');
end

k = length(X);
f = X(:,1)-1;
W = X(:,1)./X(:,3);
N = W'*X(:,2);

M = N/sum(W);
A = ((1 - W./sum(W)).^2)./f;
B = W.*(X(:,2) - M).^2;

L = 3*sum(A)/(k^2 - 1);

FW = (sum(B)/(k - 1))/(1 + 2/3*(k - 2)*L);  %Welch's F-statistic

v1 = k-1;  %numerator degrees of freedom
v2 = 1/L;  %denominator degrees of freedom

P = 1-fcdf(FW,v1,v2);  %P-value

disp(' ')
disp('Welch''s Analysis of Variance Table.')
fprintf('----------------------------------------\n');
disp('SOV       df              F       P')
fprintf('----------------------------------------\n');
fprintf('Treat.  %3i%18.3f%9.4f\n\n',v1,FW,P);
fprintf('Error%11.4f\n\n',v2);
fprintf('----------------------------------------\n');

if P >= alpha;
    fprintf('The associated probability for the Welch''s F test is equal or larger than% 3.2f\n', alpha);
    fprintf('So, the assumption of sample means are equal was met.\n');
else
    fprintf('The associated probability for the Welch''s F test is smaller than% 3.2f\n', alpha);
    fprintf('So, the assumption of sample means are equal was not met.\n');
end

return,