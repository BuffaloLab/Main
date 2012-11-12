function [SUA nvdat] = getSUA(dataset,unsorted)
if nargin<2,  unsorted = 0;    end
if strcmp('.nev',dataset(end-3:end)) || strcmp('.ns5',dataset(end-3:end))
    %blackrock data ==================================
    nvfile  = [dataset(1:end-4) '.nev'];
    nvdat   = openNEV(nvfile,'16bits','nomat','overwrite');
    issortedunit = nvdat.Data.Spikes.Unit<200&nvdat.Data.Spikes.Unit>(-unsorted);
    chans = unique(nvdat.Data.Spikes.Electrode(issortedunit));%chans with sorted units
    nvdat.Data.Spikes.Globalindex = nan(size(nvdat.Data.Spikes.Electrode));
    chans = double(chans);
    for k = 1:length(chans)
        unitlabels{k} = unique(nvdat.Data.Spikes.Unit(nvdat.Data.Spikes.Electrode==chans(k)&issortedunit));
        unitsperchan(k) = length(unitlabels{k});
    end
    numunits = sum(unitsperchan);
    SUA = cell(1,numunits);
    unitind = 1;
    for k = 1:length(chans)
        ulabs = unitlabels{k};
        for kk = 1:length(ulabs)
            nvdat.Data.Spikes.Globalindex(nvdat.Data.Spikes.Electrode==chans(k)&nvdat.Data.Spikes.Unit==ulabs(kk)) = unitind;
            if unsorted& ulabs(kk)==0, uind = 'i';else
                uind = char(ulabs(kk)-1+'a');end
            SUA{unitind} = ['sig' leadz(chans(k),3) uind];
            unitind = unitind + 1;
        end
    end
    
    %============================================
else % Plexon
    
    if ischar(dataset)%from the .nex file
        header=getnexheader(dataset);
        numvar = size(header.varheader,2);
        for varlop = 1:numvar
            typarr(varlop) = header.varheader(varlop).typ;
        end
        for varlop = 1:numvar
            namarr(varlop,1:64) = char(header.varheader(varlop).nam');
        end
    else %used nex2mat fcns
        %     numvar = size(dataset.nam,1);
        %     for varlop = 1:numvar
        %         typarr(varlop) = dataset.typ(varlop);
        %     end
        %     for varlop = 1:numvar
        %         namarr(varlop,1:64) = char(dataset.nam(varlop)');
        %     end
        namarr = dataset.nam;typarr = dataset.typ;
    end
    spkind = find(typarr == 0);
    % analogind = find(typarr == 5);
    % lfpindbzganalog = find(double(namarr(analogind,1)) == 65);
    % lfpind = analogind(lfpindbzganalog);
    if unsorted
        sortindx=find(double(namarr(spkind,7)) );
    else
        sortindx=find(double(namarr(spkind,7)) ~= 105);
    end
    spkind=spkind(sortindx);
    % labarr=[namarr(spkind,:);namarr(lfpind,:)];
    % CHANNELS OF INTEREST:
    SUA        = cellstr(namarr(spkind,:))';
    % LFP        = cellstr(namarr(lfpind,:))';
end