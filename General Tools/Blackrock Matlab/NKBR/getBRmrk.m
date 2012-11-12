function [mrk eventtimes eventcodes] = getBRmrk(dataset,dsfs)
% output is in samples
% dsfs = downsampling frequency, defaults to 1000
% Nathan Killian njkillian@gmail.com 4/4/2012
if nargin < 2, dsfs = 1e3;end
dsfs = 1e3;
% note: if speed issues arise, could potentially speed this up by loading only the event data
nvdat = openNEV(dataset);
% get event data:
fs = double(nvdat.MetaTags.SampleRes);
eventtimes = round(double(nvdat.Data.SerialDigitalIO.TimeStamp)'/fs*dsfs);% apply new sampling rate (dsfs)
eventcodes = double(nvdat.Data.SerialDigitalIO.UnparsedData);
for k = 1:length(eventtimes)
    mrk.val(k) = eventcodes(k);
    mrk.tim(k) = eventtimes(k);
end