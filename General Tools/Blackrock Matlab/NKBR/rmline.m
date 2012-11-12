function [dat] = rmline(dat, fs, opts)
% function [dat freq] = rmline(dat, fs)
% remove line noise
% remove specified constant frequencies from the data
% fits a constant sine/cosine template to each segment of data
% will chop up the 2nd dimension into 10 second chunks
% 
% input
% dat: (mxn) channels or trials x samples
% fs:  sampling rate (Hz)
% opts: optional binary options 
% opts.usenotch: use notch filter, not DFT estimate
% opts.do120: remove 120 Hz as well
% 
% output
% dat: (mxn) matrix with 60 Hz removed
% 
% 'rmdft' function was modified from FieldTrip
% notching modified from Matlab's iirnotch.m
% Nathan Killian 110422

if nargin < 3
    opts.usenotch    = 0;%   use an actual notch filter, not the dft estimate, removes more
    % at the cost of lower specificity (broader spectral peak)
    opts.do120       = 0;%   remove 120 Hz as well
end
if opts.usenotch
    % 60 Hz
    Wo = 60/(fs/2);  BW = Wo/20;
    Ab = abs(10*log10(.5)); % 3-dB width
    BW = BW*pi;Wo = Wo*pi;
    Gb   = 10^(-Ab/20);
    beta = (sqrt(1-Gb.^2)/Gb)*tan(BW/2);
    gain = 1/(1+beta);
    b = gain*[1 -2*cos(Wo) 1];
    a = [1 -2*gain*cos(Wo) (2*gain-1)];
    for k=1:size(dat,1)
        dat(k,:) = filtfilt(b,a,dat(k,:));
    end
    if opts.do120
        % 120 Hz
        Wo = 120/(fs/2);  BW = Wo/35;
        Ab = abs(10*log10(.5)); % 3-dB width
        BW = BW*pi;Wo = Wo*pi;
        Gb   = 10^(-Ab/20);
        beta = (sqrt(1-Gb.^2)/Gb)*tan(BW/2);
        gain = 1/(1+beta);
        b = gain*[1 -2*cos(Wo) 1];
        a = [1 -2*gain*cos(Wo) (2*gain-1)];
        for k=1:size(dat,1)
            dat(k,:) = filtfilt(b,a,dat(k,:));
        end
    end
else % remove via DFT estimate
    fres = 1;%freq. resolution in Hz
    disp('removing 60 & 120 Hz')
    if fres == 10;
        freq = [59.8 59.9 60 60.1 60.2 119.8 119.9 120 120.1 120.2];%need at least 10 seconds
        chunksec = 10;
    elseif fres == 1;
        freq = [59 60 61 119 120 121];
        chunksec = 1;
    end
    if size(dat,2)>fs*chunksec %more than 10 seconds of data
        %define trials as 10 s chunks for 0.1 Hz resolution line noise removal
        chunk = chunksec*fs;% num. of samples
        t0 = 1;tN = size(dat,2);
        trltemp = zeros(ceil((tN-t0+1)/chunk),3);
        count = 2;
        trltemp(1,:) = [t0 t0+fs-1 0];t0 = t0+fs;%chop off first second in case there is some weirdness there
        for k = t0:chunk:tN
            endtime = k + chunk-1;
            if endtime > tN, endtime = tN;end
            trltemp(count,:) = [k endtime 0];
            count = count + 1;
        end
    end
    for k = 1:size(trltemp,1)
        dat_tmp = dat(:,trltemp(k,1):trltemp(k,2));
        for kk=1:length(freq)
            dat_tmp = rmdft(dat_tmp, fs, freq(kk));
        end
        dat(:,trltemp(k,1):trltemp(k,2)) = dat_tmp;
    end
end
disp('finished removing line noise')

function filt = rmdft(dat, fs, Fl)
% determine the size of the data
Nsamples = size(dat,2);
% set the default filter frequency
if nargin<3 || isempty(Fl)
    Fl = 60;
end
% determine the largest integer number of line-noise cycles that fits in the data
sel  = 1:round(floor(Nsamples * Fl/fs) * fs/Fl);
% temporarily remove mean to avoid leakage
mdat = mean(dat(:,sel),2);
dat  = dat - mdat(:,ones(1,Nsamples));
% fit a sin and cos to the signal and subtract them
time = (0:Nsamples-1)/fs;
tmp  = exp(1i*2*pi*Fl*time);                   % complex sin and cos
ampl = 2*dat(:,sel)*tmp(sel)'/length(sel);     % estimated amplitude of complex sin and cos on integer number of cycles
est  = ampl*tmp;                               % estimated signal at this frequency
filt = dat - est + mdat(:,ones(1,Nsamples));   % subtract estimated signal and add back the mean
filt = real(filt);
return;