function values = heat_stats(t1,t2)
% Use this if you already have the heat maps generated
% Matrix Differences
% e.g. the difference in novel vs repeat looking time heat maps
% All output values quantify Differences/Distances/Dissimilarities
% Note: The inputs need not be heat maps! Works equally well for both vectors and 2D matrices!
%
% Inputs:
% t1: binned looking times for first condition
% t2: binned looking times for second condition
%
% Outputs in values structure:
% sum_product: the sum of the product of the two maps
% sum_product_norm: 1 minus the sum of the product of the two maps normalized to the maximum value
% local_novelty_preference: the name says it
% diff: 1-Normalized Mutual Information
% kld: Kullback-Leibler Divergence
%
% Nathan Killian 120417


%==============================
% Overlap and Normalized Overlap 
% And Local Novelty Preference (time spent in different regions)
%==============================
totalnovtim = nansum(t1(:));
totalrpttim = nansum(t2(:));
novelind    = find(~isnan(t1));
product     = t1.*t2;
maxoverlappts = length(novelind);
lookperpt1 = totalnovtim/maxoverlappts; 
lookperpt2 = totalrpttim/maxoverlappts;  
maxuniformproduct = nansum(nansum(t1.*t1,2),1);
sum_product         = nansum(product(:));
sum_product_norm    = 1 - sum_product / maxuniformproduct;
rpttiminnov = nansum(t2(novelind));% repeat time in region looked at during novel presentation
local_novelty_preference = 1-rpttiminnov/totalrpttim;

%==============================
% Mutual Information
%==============================
% points of non-overlap have joint prob = 0 and are not included
% and log(0) = 0 for p(x) = 0
% but normalizing by the entropy, (which includes all valid points for each distro)
% allows for non-overlapping points to be taken into account
[simil mi hx hy] = nmi(t1(:),t2(:),100,100,'largest');
diff = 1-simil;
%  note that KLD seems to give about the same result as NMI, at least on the population scale

%==============================
% Kullback-Leibler Divergence
%==============================
t1(isnan(t1)) = 0;t2(isnan(t2)) = 0;
kld = kldiv2(t1,t2);

% put output variables in the values structure
values = var2field([],sum_product,sum_product_norm,local_novelty_preference,diff,kld,0);




%-----------------------------------------------------------------------------------------------
%-----------------------------------------------------------------------------------------------
function d = var2field(varargin)
%d = var2field([],variables...., remove_old_flag (0/1))
%best way to put existing variables into structure fields
%first argument must be the structure variable (empty or otherwise)
% the remove_old_flag sets removal of variables from the workspace
%Nathan Killian 110215

rmold = 0;
if numel(varargin{nargin})==1 & isnumeric(varargin{nargin}) & ismember(varargin{nargin},[0 1])
    if varargin{nargin} ==1,
        rmold = 1;lastvar = nargin-1;
    elseif varargin{nargin} ==0,
        rmold = 0;lastvar = nargin-1;
    end
else
    rmold = 0;lastvar = nargin;
end
d = varargin{1};
for k = 2:lastvar
    try
        d = setfield(d,inputname(k),varargin{k});
        if rmold
            evalin('base',sprintf('clear(''%s'');',inputname(k)));
        end
    catch %not fully fleshed out yet
        %         names = fieldnames(varargin{k});
        inputname(k);
        period = strfind(inputname(k),'.');
        %         d = setfield(d,inputname(k)(period+1:end),varargin{k});
    end
end
return;


function dist=kldiv2(P,Q)
% dist = KLDiv(P,Q) Kullback-Leibler divergence of two discrete
% 2-D probability distributions
% it is the div. from P to Q ~= div. from Q to P (i.e. it is not symmetric)
% P and Q  are automatically normalised to have the sum of one on rows
% assumes P and Q have been obtained as a histogram, e.g. through hist2()
% P =  nbinsx x nbinsy
% Q =  same size as P
% dist = 1 x 1
% modified from KLDiv on matlab file exchange
% Nathan Killian 120417
Q(Q==0) = eps;

if size(P,2)~=size(Q,2)
    error('the number of columns in P and Q should be the same');
end
if size(P,1)~=size(Q,1)
    error('the number of rows in P and Q should be the same');
end
if sum(~isfinite(P(:))) + sum(~isfinite(Q(:)))
    error('the inputs contain non-finite values!')
end

P = P./sum(P(:));
Q = Q./sum(Q(:));
temp = P.*log(P./Q);
% Q is supposed to be greater than 0 when P(i) > 0
% otherwise is it undefined!!
temp(isnan(temp))=0; % resolving the case when P(i)==0
% temp(isinf(temp))=0;
dist = sum(temp(:));

return;


%
% mutualinformation.m
%
% Returns an estimate of the mutual information between two signals in
% bits.  Also returns mutual information normalized with the geometric 
% mean of the entropy of the two signals so it varies 0 to 1, where
% zero represents independent signals.
%
% x, y - signals to calculate mutual information between
% nbinx, nbinsy - number of bins to use when computing joint histogram
% nmi - normalized mutual information metric
% mi - unnormalized mutual information
% hx - entropy of signal x
% hy - entropy of signal y
%
% pwatkins - 1/21/07
% Nathan Killian 110901

function [normmi mi hx hy] = nmi(x,y,nbinsx,nbinsy,type)
if nargin<5, type = [];end

% INPUTS CAN HAVE NANS, BUT CANNOT BOTH BE ALL ZEROS
x(isnan(x)) = 0;y(isnan(y)) = 0;
len = min([length(x) length(y)]);
[jhxy] = hist2(x,y,nbinsx,nbinsy,type);  % the joint histogram
pxy = jhxy / len;  % normalize so total area is 1
px = sum(pxy,2);  % the marginal probability distributions
py = sum(pxy,1);
ppxy = px*py;  % product of the marginal distributions

% compute mutual information with log(0) = 0
sel = ((pxy ~= 0) & (ppxy ~= 0));
logf = zeros(size(pxy));
logf(sel) = log2(pxy(sel)./ppxy(sel));
mi = sum(sum(pxy.*logf));

% compute entropy of x with log(0) = 0
sel = (px ~= 0);
logf = zeros(size(px));
logf(sel) = log2(px(sel));
hx = -sum(px.*logf);

% compute entropy of y with log(0) = 0
sel = (py ~= 0);
logf = zeros(size(py));
logf(sel) = log2(py(sel));
hy = -sum(py.*logf);

normmi = mi / sqrt(hx*hy);
return;

% hist2.m
%
% Compute the joint histogram of two signals.
%
% pwatkins 1/19/07
% nkillian 100707 -no rescaling, assumes already in the appropriate
% relative levels, previously distributed the bins uniformly across the
% min-max range of each input individually, but then you are matching bins
% so that scaling doesn't play a role, but occasionally scaling is
% important and you want to compare absolute values. In those cases, you
% want to take the largest range and scale both x and y to that range
% so NMI always has an issue of relative scaling vs absolute scaling
% whereas NCM is scale-independent

%use the x range (orignal scaled because it will be the same in both
%measurements)
%then floor high and low values to the edge bins

function [h xb yb ] = hist2(x, y, nbinsx, nbinsy, type)
if nargin< 5, type = 'normal';elseif isempty(type), type = 'normal';end
% filtertype = 'butter';
filtertype = 'resample envelope';

minx = min(x);maxx = max(x);
miny = min(y);maxy = max(y);

switch type
    case 'lpf'
        F_ENVELOPE  =   50;
        F_SIGNAL    =   44100;
        
        switch filtertype
            case 'resample envelope'
                analytic_x	    =	hilbert(x);
                X               =	abs(analytic_x);
                x               =   resample( X , F_ENVELOPE , F_SIGNAL );
                
                analytic_y	    =	hilbert(y);
                Y               =	abs(analytic_y);
                y               =   resample( Y , F_ENVELOPE , F_SIGNAL );
            case 'butter'
                [B,A] = BUTTER(4,F_ENVELOPE/(F_SIGNAL/2));
                x = filtfilt(B,A,x);
                y = filtfilt(B,A,y);
        end
        
        minx = min(x);maxx = max(x);
        miny = min(y);maxy = max(y);
        dx = (maxx - minx) / (nbinsx-1);
        dy = (maxy - miny) / (nbinsy-1);
        %which bin number it falls in, left bounded
        x = floor((x-minx+dx/2)/dx)+1;
        y = floor((y-miny+dy/2)/dy)+1;
    case 'usexrange'
        dx = (maxx - minx) / (nbinsx-1);
        dy = (maxx - minx) / (nbinsy-1);
        
        %which bin number it falls in, left bounded
        x = floor((x-minx+dx/2)/dx)+1;
        y = floor((y-minx+dy/2)/dy)+1;
        
        %floor low and high to min and max bins
        x(x<1) = 1;y(y<1) = 1;
        x(x>nbinsx) = nbinsx;y(y>nbinsy) = nbinsy;
        
        % %ignore out of range values
        % x(x<1) = [];y(x<1) = [];
        % x(y<1) = [];y(y<1) = [];
        % x(x>nbinsx) = [];y(x>nbinsx) = [];
        % x(y>nbinsy) = [];y(y>nbinsy) = [];
    case 'normal' %independent of scaling, but could be biased by changing the min or max values, even a single value
        dx = (maxx - minx) / (nbinsx-1);
        dy = (maxy - miny) / (nbinsy-1);
        xb = minx:dx:maxx;  yb = miny:dy:maxy;
        %which bin number it falls in, left bounded
        x = floor((x-minx+dx/2)/dx)+1;
        y = floor((y-miny+dy/2)/dy)+1;
    case 'largest'
%         disp('doing histogram with largest range')
        %largest range:
        minval = min([minx miny]);
        maxval = max([maxx maxy]);
        dx = (maxval - minval) / (nbinsx-1);
        dy = (maxval - minval) / (nbinsy-1);
        xb = minval:dx:maxval;  yb = minval:dy:maxval;
        
        %which bin number it falls in, left bounded
        x = floor((x-minval+dx/2)/dx)+1;
        y = floor((y-minval+dy/2)/dy)+1;
    case 'smallest'
        minval = max([minx miny]);
        maxval = min([maxx maxy]);
        dx = (maxval - minval) / (nbinsx-1);
        dy = (maxval - minval) / (nbinsy-1);
        xb = minval:dx:maxval;  yb = minval:dy:maxval;
        
        %which bin number it falls in, left bounded
        x = floor((x-minval+dx/2)/dx)+1;
        y = floor((y-minval+dy/2)/dy)+1;
        
        %floor low and high to min and max bins
        x(x<1) = 1;y(y<1) = 1;
        x(x>nbinsx) = nbinsx;y(y>nbinsy) = nbinsy;
        
        % %ignore out of range values
        % x(x<1) = [];y(x<1) = [];
        % x(y<1) = [];y(y<1) = [];
        % x(x>nbinsx) = [];y(x>nbinsx) = [];
        % x(y>nbinsy) = [];y(y>nbinsy) = [];
end

h = zeros([nbinsy nbinsx]);
len = min([length(y) length(x)]);
for i = 1:len
    h(y(i),x(i)) = h(y(i),x(i)) + 1;%add 1 to the joint bins
end
return;


