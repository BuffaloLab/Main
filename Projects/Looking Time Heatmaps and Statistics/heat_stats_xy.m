function [values maps options] = heat_stats_xy(xy1,xy2,options)
% Matrix Difference Quantifications
% e.g. the difference in novel vs repeat looking time maps
% All output values quantify Differences/Distances/Dissimilarities
%
% Inputs:
%----------------------------------------
% xy1: x,y-values (degrees) for first condition, can be time x position or position x time
% xy2: x,y-values (degrees) for second condition, can be time x position or position x time
% options: (optional) parameters for creating heatmaps
%
% Outputs:
%----------------------------------------
% values.sum_product_norm: 1 minus the sum of the product of the two maps normalized to the maximum value
% values.local_novelty_preference: the name says it
% values.diff: 1-Normalized Mutual Information
% values.kld: Kullback-Leibler Divergence
%
% maps.t1 is heat map for condition 1
% maps.t2 is heat map for condition 2
% maps.xb are the x bin values for the heat maps
% maps.yb are the y bin values for the heat maps
% important note on binning: as long as using option 'specrange' for binning type, the bins are the same
% the data is binned using +/- 'sqr' units and 'nbins' is not used,
% instead 'degperbin' determines the number of bins
%
% options is the heat map options structure that was used
%
% Nathan Killian, njkillian@gmail.com
% Last Updated: 120525

if nargin<3,
    options = setdefaults([],'timth',1,'tth',25,'nbins',69,'binningtype','specrange',...
        'degperbin',0.5,'smtht',1,'gsize',[13 13],'gsigma',3,'sqr',17);
end
if nargin<2,heatmaponly = 1;elseif isempty(xy2),heatmaponly = 1;else heatmaponly = 0;end

% todo: this could be sped up by removing the weight vector
% the first input is the weight vector:
if heatmaponly
    if size(xy1,2)>size(xy1,1),xy1 = xy1';end
    R1 = ratemap_lookingtime(zeros(length(xy1),1),xy1(:,1),xy1(:,2),options);
    t1 = R1.t2;
    xb = R1.xb;yb = R1.yb;
    maps = var2field([],t1,xb,yb);
    values = [];
    return;
else
    if size(xy1,2)>size(xy1,1),xy1 = xy1';end
    if size(xy2,2)>size(xy2,1),xy2 = xy2';end
end
R1 = ratemap_lookingtime(zeros(length(xy1),1),xy1(:,1),xy1(:,2),options);
R2 = ratemap_lookingtime(zeros(length(xy2),1),xy2(:,1),xy2(:,2),options);
t1 = R1.t2;t2 = R2.t2;
xb = R1.xb;yb = R1.yb;
maps = var2field([],t1,t2,xb,yb);

%==============================
% Overlap and Normalized Overlap
% And Local Novelty Preference (time spent in different regions)
%==============================
totalnovtim = nansum(t1(:));totalrpttim = nansum(t2(:));
novelind = find(~isnan(t1));
product = t1.*t2;
maxoverlappts = length(novelind);
lookperpt1 = totalnovtim/maxoverlappts; lookperpt2 = totalrpttim/maxoverlappts;
maxuniformproduct = nansum(nansum(t1.*t1,2),1);
sum_product = nansum(product(:));
sum_product_norm = 1 - sum_product / maxuniformproduct;
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

% output variables
values = var2field([],sum_product_norm,local_novelty_preference,diff,kld,0);


%///////////////////////////////////////////////////////////
function d = setdefaults(varargin)
%d = var2field([],variable name, variable value, repeat...)
% Set Defaults
%way to put existing variables into structure fields
%first argument must be the structure variable (empty or otherwise)
%Nathan Killian 110215

lastvar = nargin-1;
d = varargin{1};
for k = 2:2:lastvar
    try
        if ~isfield(d,varargin{k})
            d = setfield(d,varargin{k},varargin{k+1});
        end
    catch
        %         %         names = fieldnames(varargin{k});
        %         inputname(k);
        %         period = strfind(inputname(k),'.');
        %         %         d = setfield(d,inputname(k)(period+1:end),varargin{k});
    end
end
return;

%///////////////////////////////////////////////////////////
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


%///////////////////////////////////////////////////////////
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

%///////////////////////////////////////////////////////////
function [normmi mi hx hy] = nmi(x,y,nbinsx,nbinsy,type)
% function [normmi mi hx hy] = nmi(x,y,nbinsx,nbinsy,type)
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

%///////////////////////////////////////////////////////////
function [h xb yb ] = hist2(x, y, nbinsx, nbinsy, type)
% function [h xb yb ] = hist2(x, y, nbinsx, nbinsy, type)
% Compute the joint histogram of two signals.
%
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

%///////////////////////////////////////////////////////////
function [R] = ratemap_lookingtime(S,X,Y,o)
% function [R] = ratemap_lookingtime(S,X,Y,o)
%compute ratemap and autocorr and find peaks
%input spike train, position values, and options
%N Killian 110905
% S is a legacy variable, but needed in hist3gc
if ~isfield(o,'sqr')&isfield(o,'squarerange'),o.sqr=o.squarerange;end

[h t r xb yb lb rb x0 y0 z0 origind] = hist3gc(X,Y,S,o.nbins,o.nbins,o.binningtype,o.sqr,o.degperbin);
t0 = t;%used for saving original data

if o.timth
    t0(t0<o.tth) = nan;
end
if ~o.smtht
    t2=t+eps;
end

%  DO FILTERING:

H = fspecial('gaussian',o.gsize,o.gsigma);

% t2 = imfilter(t,H);
t2 = nanfilt(t,H);%useful even if no nans, normalizes by the filter samples that overlap with the image
%but this in turn produces more variance at the edges because the value is taken using less data.

%             t2 = imfilter(t,H)+eps;
%             t2 = imfilter(t,H,0,'conv');
%             t2 = conv2(t,H,'same');
if o.timth
    shortind = t2<o.tth;
    CC = bwconncomp(shortind,6);
    stats = regionprops(CC,'Area','PixelIdxList');
    for k = 1:length(stats)
        if stats(k).Area<= 1 % FIXME: MAKE GENERIC USING DEGPERBIN
            shortind(stats(k).PixelIdxList) = 0;
        end
    end
    t2(shortind) = nan;
end

a = t2;

R = var2field([],t0,x0,y0,z0,origind,a,xb,yb,t2,0);
return;

%///////////////////////////////////////////////////////////
function [h t r xb yb lb rb x y z origind] = hist3gc(x, y, z, nbinsx, nbinsy,type,rangespec,valsperbin,savorig)
% function [h t r xb yb lb rb x y z origind] = hist3gc(x, y, z, nbinsx, nbinsy,type,rangespec,valsperbin,savorig)
%
% Compute the joint histogram of two signals.
% optimized for grid cells

% xb and yb are the bin CENTERS
% out of range values are NOT included

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

% if nargin < 8, smth = 0;end
if nargin < 9, savorig = 0;end
if nargin < 8, valsperbin = [];end
if nargin < 7,    rangespec = 1;end
if nargin < 6,    type = 'normal';end
minx = min(x);maxx = max(x);
miny = min(y);maxy = max(y);
% minz = min(z);maxz = max(z);
if savorig
    origind = 1:length(x);
else origind = [];
end
switch type
    case 'lpf'
        x = resample(x,50,44100);
        y = resample(y,50,44100);
        dx = (maxx - minx) / (nbinsx-1);
        dy = (maxy - miny) / (nbinsy-1);
        %which bin number it falls in, left bounded
        x = floor((x-minx+dx/2)/dx)+1;
        y = floor((y-miny+dy/2)/dy)+1;
    case 'usexrange'
        dx = (maxx - minx) / (nbinsx-1);
        dy = (maxx - minx) / (nbinsy-1);
        xb = minx:dx:maxx;
        yb = minx:dy:maxx;
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
    case 'normal' %not-necessarily square bins, unless spec the valsperbin
        if ~isempty(valsperbin)
            nbinsx = round([maxx-minx]/valsperbin);
            nbinsy = round([maxy-miny]/valsperbin);
        end
        dx = (maxx - minx) / (nbinsx-1);
        dy = (maxy - miny) / (nbinsy-1);
        xb = minx:dx:maxx;
        yb = miny:dy:maxy;
        %         dz = (maxz - minz) / (nbinsz-1);
        %which bin number it falls in, left bounded
        x = floor((x-minx+dx/2)/dx)+1;
        y = floor((y-miny+dy/2)/dy)+1;
        %         z = floor((z-minz+dz/2)/dz)+1;
    case 'normalpad' %not-necessarily square bins, unless spec the valsperbin
        pad = 2;
        maxx = maxx-pad;minx=minx+pad;
        maxy = maxy-pad;miny=miny+pad;
        if ~isempty(valsperbin)
            nbinsx = round([maxx-minx]/valsperbin);
            nbinsy = round([maxy-miny]/valsperbin);
        end
        dx = (maxx - minx) / (nbinsx-1);
        dy = (maxy - miny) / (nbinsy-1);
        xb = minx:dx:maxx;
        yb = miny:dy:maxy;
        %         dz = (maxz - minz) / (nbinsz-1);
        %which bin number it falls in, left bounded
        x = floor((x-minx+dx/2)/dx)+1;
        y = floor((y-miny+dy/2)/dy)+1;
        %         z = floor((z-minz+dz/2)/dz)+1;
        y(x<1) = [];z(x<1) = [];x(x<1)=[];
        x(y<1) = [];z(y<1) = [];y(y<1) = [];
        y(x>nbinsx) = [];z(x>nbinsx) = [];x(x>nbinsx) = [];
        x(y>nbinsy) = [];z(y>nbinsy) = [];y(y>nbinsy) = [];
    case 'largest' %not-necessarily square bins, unless spec the valsperbin
        %largest range:
        minval = min([minx miny]);
        maxval = max([maxx maxy]);
        if ~isempty(valsperbin)
            nbins = round([maxval-minval]/valsperbin);
            nbinsx = nbins;
            nbinsy = nbins;
        end
        dx = (maxval - minval) / (nbinsx-1);
        dy = (maxval - minval) / (nbinsy-1);
        xb = minval:dx:maxval;
        yb = minval:dy:maxval;
        %which bin number it falls in, left bounded
        x = floor((x-minval+dx/2)/dx)+1;
        y = floor((y-minval+dy/2)/dy)+1;
        
    case 'smallest' %smallest total range, %not-necessarily square bins, unless spec the valsperbin
        minval = max([minx miny]);
        maxval = min([maxx maxy]);
        
        if ~isempty(valsperbin)
            nbins = round([maxval-minval]/valsperbin);
            nbinsx = nbins;nbinsy = nbins;
        end
        
        dx = (maxval - minval) / (nbinsx-1);
        dy = (maxval - minval) / (nbinsy-1);
        xb = minval:dx:maxval;
        yb = minval:dy:maxval;
        %which bin number it falls in, left bounded
        x = floor((x-minval+dx/2)/dx)+1;
        y = floor((y-minval+dy/2)/dy)+1;
        
        % % %         %floor low and high to min and max bins
        % % %         x(x<1) = 1;y(y<1) = 1;
        % % %         x(x>nbinsx) = nbinsx;y(y>nbinsy) = nbinsy;
        %
        %ignore out of range values!
        y(x<1) = [];z(x<1) = [];x(x<1)=[];
        x(y<1) = [];z(y<1) = [];y(y<1) = [];
        y(x>nbinsx) = [];z(x>nbinsx) = [];x(x>nbinsx) = [];
        x(y>nbinsy) = [];z(y>nbinsy) = [];y(y>nbinsy) = [];
        
    case 'smallestsym' %smallest symmetric range, square bins
        %         minval = max([minx miny]);
        %         maxval = min([maxx maxy]);
        minval = -min(abs([minx miny maxx maxy]));
        maxval = -minval;
        if ~isempty(valsperbin)
            nbins = round([maxval-minval]/valsperbin);
            nbinsx = nbins;nbinsy = nbins;
        end
        dx = (maxval - minval) / (nbinsx-1);
        dy = (maxval - minval) / (nbinsy-1);
        xb = minval:dx:maxval;
        yb = minval:dy:maxval;
        %which bin number it falls in, left bounded
        x = floor((x-minval+dx/2)/dx)+1;
        y = floor((y-minval+dy/2)/dy)+1;
        
        % % %         %floor low and high to min and max bins
        % % %         x(x<1) = 1;y(y<1) = 1;
        % % %         x(x>nbinsx) = nbinsx;y(y>nbinsy) = nbinsy;
        %
        
        %ignore out of range values!
        %         badi = unique([find(x<1) find(y<1)
        %         x(x<1) = [];
        y(x<1) = [];z(x<1) = [];x(x<1)=[];
        x(y<1) = [];z(y<1) = [];y(y<1) = [];
        y(x>nbinsx) = [];z(x>nbinsx) = [];x(x>nbinsx) = [];
        x(y>nbinsy) = [];z(y>nbinsy) = [];y(y>nbinsy) = [];
    case 'specrange' %square bins
        minval = -rangespec;
        maxval = -minval;
        if ~isempty(valsperbin)
            nbins = round([maxval-minval]/valsperbin);
            nbinsx = nbins;nbinsy = nbins;
        end
        dx = (maxval - minval) / (nbinsx-1);
        dy = (maxval - minval) / (nbinsy-1);
        xb = minval:dx:maxval;
        yb = minval:dy:maxval;
        %which bin number it falls in, left bounded
        x = floor((x-minval+dx/2)/dx)+1;
        y = floor((y-minval+dy/2)/dy)+1;
        % %         if smth
        % % bini = 1;
        % %             for xi = 1:nbinsx
        % % l = gausseval(z,x
        % %
        
        % % %         %floor low and high to min and max bins
        % % %         x(x<1) = 1;y(y<1) = 1;
        % % %         x(x>nbinsx) = nbinsx;y(y>nbinsy) = nbinsy;
        
        %ignore out of range values!
        %         badi = unique([find(x<1) find(y<1)
        %         x(x<1) = [];
        y(x<1) = [];z(x<1) = [];
        if savorig, origind(x<1)=[];end
        x(x<1)=[];
        x(y<1) = [];z(y<1) = [];
        if savorig, origind(y<1)=[];end
        y(y<1) = [];
        y(x>nbinsx) = [];z(x>nbinsx) = [];
        if savorig,        origind(x>nbinsx)=[];end
        x(x>nbinsx) = [];
        x(y>nbinsy) = [];z(y>nbinsy) = [];
        if savorig,        origind(y>nbinsy)=[];end
        y(y>nbinsy) = [];
        
end
if ~isempty(strmatch(type,'specrange'))
    lb = [xb-dx/2;yb-dy/2];rb = [xb+dx/2;yb+dy/2];
else
    lb =[];rb=[];
end
h = zeros([nbinsy nbinsx]);
% h = nan([nbinsy nbinsx]);
t = h;
if savorig, indices = cell(size(t));end
len = min([length(x) length(y) length(z)]);%length of the data itself
for i = 1:len
    %     t(x(i),y(i)) = t(x(i),y(i)) + 1;%add 1 for each occurrence
    %     h(x(i),y(i)) = h(x(i),y(i)) + z(i);%add spks to the bins as they occur
    if savorig, indices{y(i),x(i)} = [indices{y(i),x(i)} origind(i)];end
    t(y(i),x(i)) = t(y(i),x(i)) + 1;%add 1 for each occurrence
    h(y(i),x(i)) = h(y(i),x(i)) + z(i);%add spks to the bins as they occur
end
if savorig, origind = indices;end
% origind = [];
r = h./(t+eps);
return;

%///////////////////////////////////////////////////////////
function [r] = nanfilt(a,b)
% function [r p] = nanfilt(a,b)
% im filtering with nans removed
% nth is the threshold for calculating the autocorr at a given lag
% in number of pixels
% N Killian 110907

siz = size(a);
bsiz = size(b);
midpt = ceil(bsiz(1)/2);
half = floor(bsiz(1)/2);
if size(b,1)~=size(b,2),error('filter must be square');end
if ~isodd(bsiz(2))|~isodd(bsiz(1)), error('check size of filter, should be odd');end
% r = zeros(siz(1)*2-1,siz(2)*2-1);p = r;
r = nan(siz);

xlags = 1:siz(2);
ylags = 1:siz(1);

% xlags = 1:siz(2)*2-1;
% ylags = 1:siz(1)*2-1;
x00 = 1:bsiz(2);y00 = 1:bsiz(1);
ind = 1;
for lagx = xlags
    for lagy = ylags
        
        x0 = x00-midpt+lagx;x0 = x00(x0>0&x0<=siz(2));
        y0 = y00-midpt+lagy;y0 = y00(y0>0&y0<=siz(1));
        
        x1 = lagx-half:lagx+half;x1 = x1(x1>0&x1<=siz(2));
        y1 = lagy-half:lagy+half;y1 = y1(y1>0&y1<=siz(1));
        
        
        % % %         n = length(xind)*length(yind);
        l1t = a(y1,x1);   l2t = b(y0,x0);
        % % %         l1sel = find(~isnan(l1t));
        % % %         l2sel = find(~isnan(l2t));
        % % %         jointsel = intersect(l1sel,l2sel);
        jointsel = ~isnan(l1t) & ~isnan(l2t);
        if ~any(jointsel)
            r(ind) = nan;
        else
            l1 = l1t(jointsel);  l2 = l2t(jointsel);
            % % %         tmp = l1.*l2;
            % % %         n = length(~isnan(tmp));
            % % %         n = numf(jointsel);
            %         n = length(l1);
            %         length(xind)
            %         length(yind)
            %         if n>nth;
            
            r(ind) = nansum(l1.*l2)./nansum(l2);%nansum of l2 should normally be 1 except at edges or when nans in the input
            %         end
        end
        ind = ind+1;
    end
end
% r(isnan(r)) = 0;p(isnan(p)) = 0;
return;


function retval = isodd(num)
retval =  ~(floor(num/2)*2 == num);
return;
