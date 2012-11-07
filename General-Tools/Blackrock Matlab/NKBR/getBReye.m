function [eog pupil] = getBReye(dataset,dsfs)
if nargin < 2, dsfs = 1e3;end
if strcmp('.nev',dataset(end-3:end)) || strcmp('.ns5',dataset(end-3:end))
    disp('getBReye: loading blackrock eye data')
    %blackrock data ==================================
    nsfile  = [dataset(1:end-4) '.ns5'];
    nsdat   = openNSx(nsfile);
    % convert labels to Plexon convention
    labtmp = cell(length(nsdat.ElectrodesInfo),1);
    chans = nan(length(nsdat.ElectrodesInfo),1);
    for k = 1:length(nsdat.ElectrodesInfo)
        labtmp{k} = nsdat.ElectrodesInfo(k).Label;
        chans(k) = nsdat.ElectrodesInfo(k).ElectrodeID;
    end
    labels = cell(length(labtmp),1);
    ind = 1;
    for k = 1:length(labtmp)
        % eye data labels:
        if strncmp(labtmp{k},'ainp14',6),     labels{k} = 'X';            ind = ind + 1;
        elseif strncmp(labtmp{k},'ainp15',6), labels{k} = 'Y';            ind = ind + 1;
        elseif strncmp(labtmp{k},'ainp16',6), labels{k} = 'P';            ind = ind + 1;
        else
            labels{k} = 'analog';
        end
    end
    [~,keepind] = intersect(labels,{'X','Y','P'});
    
    newlab = labels(sort(keepind));
    [~,xyind] = intersect(newlab,{'X','Y'});
    [~,pupilind] = intersect(newlab,{'P'});
    
    chans = chans(sort(keepind));
    
    skipfactor = round(double(nsdat.MetaTags.SamplingFreq)/dsfs);
    
    dat = openNSx(nsfile,'read','precision','double','channels',chans,'skipfactor',skipfactor);
    dat
    
    eog = dat.Data(xyind,:); %will always put x then y because intersect() alphabetically sorts
    pupil = dat.Data(pupilind,:);
    whos eog
end