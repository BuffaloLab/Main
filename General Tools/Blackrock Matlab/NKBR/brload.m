function [data] = brload(cfg1)
% function data = brload(cfg1)
% load Blackrock data, FieldTrip style
% Nathan Killian njkillian@gatech.edu 4/4/2012

getunits = 0;getanalog = 0;
if any(strncmp('sig',cfg1.channel,3)), getunits = 1;end% get SUA
if any(strncmp('AD',cfg1.channel,2)), getanalog = 1;end% get continuous
if any(strncmp('X',cfg1.channel,1)|strncmp('Y',cfg1.channel,1)|strncmp('P',cfg1.channel,1)), getanalog = 1;end% get continuous

if ~isfield(cfg1,'dsfs'),cfg1.dsfs = 1e3;end% downsampling frequency
trl = cfg1.trl;% must be specified in terms of samples at desired sampling rate

%% GET THE SPIKING DATA
trllens = [trl(:,2)-trl(:,1)]+1;%number of samples
if getunits %if speed issues arise, can put openNEV() in a loop and load only desired time segments
    data1 = [];
    [SUA nvdat] = getSUA(cfg1.dataset,0);
    tstamps = double(nvdat.Data.Spikes.TimeStamp);
    fs = double(nvdat.MetaTags.SampleRes);
    data1.label = SUA';numspkchans = length(SUA);
    data1.fsample = cfg1.dsfs;
    data1.cfg.trl = trl;
    disp('formatting spike data')
    for k = 1:size(trl,1)
        validtimes  = trl(k,1:2)/cfg1.dsfs*fs;%convert to samples in origsample rate
        validstamps = find(tstamps>=validtimes(1) & tstamps<=validtimes(2) );
        data1.trial{k} = zeros(numspkchans,trllens(k));
        stamps  = tstamps(validstamps);
        indices = nvdat.Data.Spikes.Globalindex(validstamps);
        for kk = 1:length(SUA)
            spksamps = round(stamps(indices==kk)/fs*cfg1.dsfs) - trl(k,1) + 1;
            data1.trial{k}(kk,spksamps) = 1;
        end
        data1.time{k} = [0:trllens(k)-1]/cfg1.dsfs;
    end
end
% numspks = numf(data.trial{1}(:))

%% GET THE ANALOG DATA
if getanalog
    data2 = [];
    nsfile = [cfg1.dataset(1:end-4) '.ns5'];
    nsdat = openNSx(nsfile);
    fs = nsdat.MetaTags.SamplingFreq;
    skipfactor = fs/cfg1.dsfs;
    
    % convert labels to Plexon convention
    labtmp = cell(length(nsdat.ElectrodesInfo),1);
    chans = nan(length(nsdat.ElectrodesInfo),1);
    for k = 1:length(nsdat.ElectrodesInfo)
        labtmp{k} = nsdat.ElectrodesInfo(k).Label;
        chans(k) = nsdat.ElectrodesInfo(k).ElectrodeID;
    end
    labels = cell(length(labtmp),1);
    for k = 1:length(labtmp)
        if strncmp(labtmp{k},'chan',4)
            labels{k,1} = ['AD' leadz(str2num(labtmp{k}(5:end)),2)];
            % eye data labels:
        elseif strncmp(labtmp{k},'ainp14',6),  labels{k} = 'X';
        elseif strncmp(labtmp{k},'ainp15',6),  labels{k} = 'Y';
        elseif strncmp(labtmp{k},'ainp16',6),  labels{k} = 'P';
        end
    end
    % and load only desired channels:
    [~, keepind] = intersect(labels,cfg1.channel);
    keepind = sort(keepind);labels = labels(keepind);chans = chans(keepind);
    
    data2.label = labels;
    data2.fsample = cfg1.dsfs;
    data2.cfg.trl = trl;
    disp('loading analog data')
    
    %load the analog data:
    for k = 1:size(trl,1)
        % if skipping, will open the same given number of samps as without skipping
        % but always starts in the same place
        % so just change the LAST sample value
        
        samps = [trl(k,1)*skipfactor:trl(k,1)*skipfactor+(trl(k,2)-trl(k,1))];
        dat = openNSx(nsfile,'read','precision','double','channels',chans,'duration', samps, 'sample','skipfactor',skipfactor);
        
        data2.trial{k}   = dat.Data;
        data2.time{k}    = [0:size(dat.Data,2)-1]/cfg1.dsfs;
    end
end
if getunits && getanalog
    data = ft_appenddata(cfg1, data1, data2);
elseif getunits
    data = data1;
elseif getanalog
    data = data2;
end
