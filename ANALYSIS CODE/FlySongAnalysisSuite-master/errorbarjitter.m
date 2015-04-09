function errorbarjitter(d, offset, mean_or_med,...
    sort_or_nosort, colheaders, factor,left_or_right,...
    barends,Xsep,std,colors)
%Plots mean (or median)±SD plus jitter plot of raw data
%Columns are categories, rows are individual samples.
%USAGE errorbarjitter(D) plots with default values and no x-axis labels.
%
%OPTIONS
%
%OFFSET: plots with user defined offset of mean±SD and jittered raw data
%
%MEAN_OR_MEDIAN: plot with either mean ('mean') or median ('median')
%
%SORT_OR_NOSORT: plot with either sorted data ('sort') or user entered 
%order ('nosort'). Default is nosort.
%
%COLHEADERS: plot with user defined column headers. 
%It is a bad idea to sort without providing colheaders,
%since it may not be easy to track the source of the data. 
%
%FACTOR: plot with user defined factor for scaling the jitter
%
%LEFT_OR_RIGHT: when LEFT_OR_RIGHT = 'left', plot with mean±SD line 
%on left, when = 'right', plot with bar on right (default)
%
%BARENDS: when barends = 'yes', plot with capped ends of SD
%bars, when = 'no' (default), plot without barends
%
%XSEP: Distance between groups of plotted data
%
%STD: Provide a separate array containing the standard deviations
%(or any other estimates of distribution) for each datum in d, and an error
%bar equal to ± these deviations will be plotted on each datum
%
%COLORS: Plot data with user defined colors, using standard Matlab nomenclature, 
%specified as cell array equal in length to the number of data columns.
%
%ACKNOWLEDGEMENT: This function depends on jitter.m, written by Richie
%Cotton.
%
%
% $	Author: David Stern	$   $   Date :2011/11/02   $
%
% Bug Fixes and Improvements
% 2012/09/27    Added ability to plot one column of data.
% 2012/10/16    Fixed bug that caused crash when tried to sort multiple 
%               samples with the same mean
%               Adda ability to plot error bars on each sample
%               Added ability to plot different groups with different
%               colors



% Check number of inputs
if nargin < 1
    error('plot_u_sd_jitterraw:notEnoughInputs', 'This function requires at least one input.');
end
    
% Set defaults where required
if nargin < 2 || isempty(offset)
    offset = 0.2;
end

if nargin < 3 || isempty(mean_or_med)
    mean_or_med = 'mean';
end

if nargin < 4 || isempty(sort_or_nosort)
    sort_or_nosort = 'nosort';
end

if nargin <5 && strcmp(sort_or_nosort,'sort') ==1
    skip_colheaders = 1;
    fprintf('It is a bad idea to sort without providing colheaders.\n')
    fprintf('Good luck keeping track of your data!\n')
elseif strcmp(sort_or_nosort,'sort') ==1 && isempty(colheaders)
    skip_colheaders = 1;
    fprintf('It is a bad idea to sort without providing colheaders.\n')
    fprintf('Good luck keeping track of your data!\n')
    
end

if nargin<5 || isempty(colheaders) 
    skip_colheaders = 1;
else
    skip_colheaders = 0;
end

if nargin < 6 || isempty(factor)
    factor = 1;
end

if nargin < 7 || isempty(left_or_right)
    left_or_right = 'right';
elseif strcmp(left_or_right,'left') == 1
    offset = -offset;
end


if nargin < 8 || isempty(barends)
    barends = 'no';
end

if nargin < 9 || isempty(Xsep)
    Xsep = 1;
end

if nargin < 10 || isempty(std)
    std = [];
end

if nargin < 11 || isempty(colors)
    colors = 'black';
end

figure(1)
clf
hold on

n_categories = size(d,2);
n_data = size(d,1);
    

if strcmp(mean_or_med,'mean') == 1
    mean_d = nanmean(d);
elseif strcmp(mean_or_med,'median') == 1
    mean_d = nanmedian(d);
end


%add option to sort data by mean
%there must be an easier way to rearrange an array by a property of columns
if strcmp(sort_or_nosort,'sort') == 1
    
    [sorted_means,sort_idx] = sort(mean_d);    
    
    %now put original array in new order
    %if data in colheaders, sort that one too
    %there must be an easy way to do this
    sorted_d = d(:,sort_idx);
    d = sorted_d;
    if ~isempty(colors)
        sorted_colors = colors(sort_idx);
        colors = sorted_colors;
    end
    if ~isempty(std)
        sorted_std = std(:,sort_idx);
        std = sorted_std;
    end

    
    if skip_colheaders ~= 1
        sorted_colheaders = colheaders(sort_idx);
        colheaders = sorted_colheaders;
    end
    %recalculate mean for newly sorted data
    if strcmp(mean_or_med,'mean') == 1
        mean_d = nanmean(d);
    elseif strcmp(mean_or_med,'median') == 1
        mean_d = nanmedian(d);
    end
    
    std_d = nanstd(d);
end




%for column in data
%plot (mean ±SD)
e = nanstd(d,1);
%define X axis positions
x = 1:1:n_categories;
x = x*Xsep;

%put column indices in each column
    
%x = indices + offset
if strcmp(barends,'no') == 1
    scatter(x+offset,mean_d,[],'k','filled')
else
    errorbar(mean_d,e,'ok','MarkerFaceColor','k','XData',x+offset)
end
%plot error lines
for i = 1:n_categories
    line([x(i)+offset x(i)+offset],[mean_d(i)-e(i) mean_d(i)+e(i)],'Color','k','LineWidth',.5)
end
%plot raw data with jitter in x axis to left of each
if n_categories >1
    x = repmat(x,n_data,1);
    x = jitter(x,factor);
else %if have one column, need to add false second column to allow jitter to work properly, and then delete
    x=repmat(x,n_data,1);
    x(:,2) = 2;
    x = jitter(x,factor);
    x(:,2) = [];
end
x(isnan(d)) = NaN;

%make new matrix of X positions
%Y = jitter(vector of indices - offset)
for i = 1:n_categories
    scatter(x(:,i)-offset,d(:,i),'MarkerEdgeColor',colors{i})
end

if ~isempty(std)
    for i = 1:n_categories
        for j = 1:n_data
            line([x(j,i)-offset x(j,i)-offset],[d(j,i)-std(j,i) d(j,i)+std(j,i)],'Color',colors{i},'LineWidth',.5)
        end
    end
end

if skip_colheaders == 0
    %add x axis labels
    set(gca,'XTick',[1:1:n_categories])
    set(gca,'XTickLabel',colheaders)
end
hold off

function y = jitter(x, factor, uniformOrGaussianFlag, smallOrRangeFlag, realOrImaginaryFlag)
% Adds a small amount of noise to an input vector, matrix or N-D array. The
% noise can be uniformly or normally distributed, and can have a magnitude
% based upon the range of values of X, or based upon the smallest
% difference between values of X (excluding 'fuzz').
% 
% NOTE: This function accepts complex values for the first input, X.  If
% any values of X have imaginary components (even zero-valued imaginary
% components), then by default the noise will be imaginary.  Otherwise, the
% default is for real noise.  You can choose between real and imaginary
% noise by setting the fifth input parameter (see below).
% 
% Y = JITTER(X) adds an amount of uniform noise to the input X, with a
% magnitude of one fifth of the smallest difference between X values
% (excluding 'fuzz'), i.e. the noise, n~U(-d/5, d/5), where d is the
% smallest difference between X values.
% 
% Y = JITTER(X, FACTOR) adds noise as above, but scaled by a factor
% of FACTOR, i.e. n~U(-FACTOR*d/5, FACTOR*d/5).
% 
% Y = JITTER(X, FACTOR, 1) adds noise as above, but normally distributed
% (white noise), i.e. n~N(0, FACTOR*d/5). JITTER(X, FACTOR, 0) works the
% same as JITTER(X, FACTOR). If the second parameter is left empty (for
% example JITTER(X, [], 1)), then a default scale factor of 1 is used.
% 
% Y = JITTER(X, FACTOR, [], 1) adds an amount of noise to X with a
% magnitude of one fiftieth of the range of X.  JITTER(X, FACTOR, [], 0)
% works the same as JITTER(X, FACTOR, []).  A value of 0 or 1 can be given as
% the third input to choose between uniform and normal noise (see above),
% i.e. n~U(-FACTOR*r/50, FACTOR*r/50) OR n~N(0, FACTOR*r/50), where r is
% the range of the values of X.  If the second parameter is left empty then
% a default scale factor of 1 is used.
% 
% Y = JITTER(X, FACTOR, [], [], 1) adds an amount of noise as above, but
% with imaginary noise.  The magnitude of the noise is the same as in the
% real case, but the phase angle is a uniform random variable, theta~U(0,
% 2*pi).  JITTER(X, FACTOR, [], [], 0) works the same as JITTER(X, FACTOR,
% [], []). A value of 0 or 1 can be given as the third input to choose
% between uniform and normal noise, and a value of 0 or 1 can be given as
% the fourth input to choose between using the smallest distance between
% values or the range for determining the magnitude of the noise.  If the
% second parameter is left empty then a default scale factor of 1 is used.
% 
% 
% EXAMPLE:  x = [1 -2 7; Inf 3.5 NaN; -Inf 0.001 3];
%           jitter(x)
% 
%           ans =
% 
%             0.9273   -2.0602    6.9569
%                Inf    3.4597       NaN
%               -Inf    0.0333    2.9130
% 
%           %Plot a noisy sine curve. 
%           x2 = sin(0:0.1:6);
%           plot(jitter(x2, [], 1, 1));  
% 
% 
% ACKNOWLEGEMENT: This function is based upon the R function of the same
% name, written by Werner Stahel and Martin Maechler, ETH Zurich.
% See http://stat.ethz.ch/R-manual/R-patched/library/base/html/jitter.html
% for details of the original.
% 
% 
%   Class support for input X:
%      float: double, single
% 
% 
%   See also RAND, RANDN.
% 
% 
% $ Author: Richie Cotton $     $ Date: 2006/03/21 $


% Check number of inputs
if nargin < 1
    error('jitter:notEnoughInputs', 'This function requires at least one input.');
end
    
% Set defaults where required
if nargin < 2 || isempty(factor)
    factor = 1;
end

if nargin < 3 || isempty(uniformOrGaussianFlag)
    uniformOrGaussianFlag = 0;
end

if nargin < 4 || isempty(smallOrRangeFlag)
    smallOrRangeFlag = 0;
end

if nargin < 5 || isempty(realOrImaginaryFlag)
    realOrImaginaryFlag = ~isreal(x);
end


% Find the range of X, ignoring infinite value and NaNs
xFinite = x(isfinite(x(:)));
xRange = max(xFinite) - min(xFinite);

if ~smallOrRangeFlag
    % Remove 'fuzz'
    dp = 3 - floor(log10(xRange));
    xFuzzRemoved = round(x * 10^dp) * 10^-dp;
    % Find smallest distance between values of X
    xUnique = unique(sort(xFuzzRemoved));
    xDifferences = diff(xUnique);
    if length(xDifferences)
        smallestDistance = min(xDifferences);
    elseif xUnique ~= 0 
        % In this case, all values are the same, so xUnique has length 1
        smallestDistance = 0.1 * xUnique;
    else
        % In this case, all values are 0
        smallestDistance = 0.1 * xRange;
    end
    scaleFactor = 0.2 * factor * smallestDistance;
else
    % Calc scale factor based upon range
    scaleFactor = 0.02 * factor * xRange;
end

% Add the noise
s = size(x);
if uniformOrGaussianFlag
    % Normal noise
    if realOrImaginaryFlag
        randomPhaseAngles = 2 * pi * rand(s);
        y = x + scaleFactor * randn(s) * exp(randomPhaseAngles * i);
    else
        y = x + scaleFactor * randn(s);
    end
else
    % Uniform noise
    if realOrImaginaryFlag
        randomPhaseAngles = 2 * pi * rand(s);
        y = x + scaleFactor * (2*rand(s)-1) * exp(randomPhaseAngles * i);
    else
        y = x + scaleFactor * (2*rand(s)-1);
    end
end