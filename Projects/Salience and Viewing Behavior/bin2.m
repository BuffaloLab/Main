function [binnedmatrix] = bin2(matrix,xstep,ystep,upperlower,type)
% Function creates 2D binned matrices by essentially scaling the down the
% dimensions by xstep and ystep.

% INPUTS:
%   1) matrix: matrix you want to bin
%   2) xstep: the number of bins is approximately the horizontal size of
%   the matrix divided by xstep. See upper lower
%   3) ystep: the number of bins is approximately the vertical size of
%   the matrix divided by ystep. See upper lower
%   4) upperlower: if 'upper' include any extra elements in an incomplete 
%   extra bin (i.e. rounds up); if 'lower' exclude incomplete bin completely
%   ignoring values (i.e. rounds down). 
%   5) Type:
%       a) 'sum': calculate the sum of the values for each bin
%       b) 'mode': calculates the mode of the values for each bin
%       c) 'mean': calculates the mean of the values for each bin

% OUTPUT
%   1) Binned matrix!

if nargin < 5
    type = 'sum';
end
if nargin < 4
    upperlower = 'upper';
end
if nargin < 3
    xstep = 24;
    ystep = 24;
end
if nargin == 0;
    error('Not enough inputs')
end

[r c] = size(matrix);
if rem(r,ystep) ~= 0;
    if strcmpi(upperlower,'upper');
        ybin = [0:ystep:r-ystep r];
    else
        ybin = [0:ystep:r];
    end
else
    ybin = [0:ystep:r];
end

if rem(c,xstep) ~= 0;
    if strcmpi(upperlower,'upper');
        xbin = [0:xstep:c-xstep c];
    else
        xbin = [0:xstep:c];
    end
else
    xbin = [0:xstep:c];
end

binnedmatrix = zeros(length(ybin)-1,length(xbin)-1);
if strcmpi(type,'sum')
    for i = 1:length(ybin)-1
        for ii = 1:length(xbin)-1
            if i == 1 && ii == 1
                binnedmatrix(i,ii) = sum(sum(matrix(ybin(1)+1:ybin(2),xbin(1)+1:xbin(2))));
            elseif i == 1
                binnedmatrix(i,ii) = sum(sum(matrix(ybin(1)+1:ybin(2),xbin(ii)+1:xbin(ii+1))));
            elseif ii == 1
                binnedmatrix(i,ii) = sum(sum(matrix(ybin(i)+1:ybin(i+1),xbin(1)+1:xbin(2))));
            else
                binnedmatrix(i,ii) = sum(sum(matrix(ybin(i)+1:ybin(i+1),xbin(ii)+1:xbin(ii+1))));
            end
        end
    end
elseif strcmpi(type,'mode')
    for i = 1:length(ybin)-1
        for ii = 1:length(xbin)-1
            if i == 1 && ii == 1
                binnedmatrix(i,ii) = mean2(matrix(ybin(1)+1:ybin(2),xbin(1)+1:xbin(2)));
            elseif i == 1
                binnedmatrix(i,ii) = mean2(matrix(ybin(1)+1:ybin(2),xbin(ii)+1:xbin(ii+1)));
            elseif ii == 1
                binnedmatrix(i,ii) = mean2(matrix(ybin(i)+1:ybin(i+1),xbin(1)+1:xbin(2)));
            else
                binnedmatrix(i,ii) = mean2(matrix(ybin(i)+1:ybin(i+1),xbin(ii)+1:xbin(ii+1)));
            end
        end
    end
elseif strcmpi(type,'mean')
    for i = 1:length(ybin)-1
        for ii = 1:length(xbin)-1
            if i == 1 && ii == 1
                binnedmatrix(i,ii) = mean2(matrix(ybin(1)+1:ybin(2),xbin(1)+1:xbin(2)));
            elseif i == 1
                binnedmatrix(i,ii) = mean2(matrix(ybin(1)+1:ybin(2),xbin(ii)+1:xbin(ii+1)));
            elseif ii == 1
                binnedmatrix(i,ii) = mean2(matrix(ybin(i)+1:ybin(i+1),xbin(1)+1:xbin(2)));
            else
                binnedmatrix(i,ii) = mean2(matrix(ybin(i)+1:ybin(i+1),xbin(ii)+1:xbin(ii+1)));
            end
        end
    end
else
    error('Unknown type of binning')
end