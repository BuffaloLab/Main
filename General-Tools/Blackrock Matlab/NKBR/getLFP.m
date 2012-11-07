function [LFP] = getLFP(dataset)
if strcmp('.nev',dataset(end-3:end)) || strcmp('.ns5',dataset(end-3:end))
    
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
    %     labels = cell(length(labtmp),1);
    lfpind = 1;
    
    for k = 1:length(labtmp)
        if strncmp(labtmp{k},'chan',4)
            LFP{1,lfpind} = ['AD' leadz(str2num(labtmp{k}(5:end)),2)];
            lfpind = lfpind + 1;
            % eye data labels:
            %         elseif strncmp(labtmp{k},'ainp14',6),  labels{k} = 'X';
            %         elseif strncmp(labtmp{k},'ainp15',6),  labels{k} = 'Y';
            %         elseif strncmp(labtmp{k},'ainp16',6),  labels{k} = 'P';
        end
    end
    
    %============================================
else % Plexon
    % get LFP channels
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
    % spkind = find(typarr == 0);
    analogind = find(typarr == 5);
    lfpindbzganalog = find(double(namarr(analogind,1)) == 65);
    lfpind = analogind(lfpindbzganalog);
    % sortindx=find(double(namarr(spkind,7)) ~= 105);
    % spkind=spkind(sortindx);
    % labarr=[namarr(spkind,:);namarr(lfpind,:)];
    % CHANNELS OF INTEREST:
    % SUA        = cellstr(namarr(spkind,:))';
    LFP        = cellstr(namarr(lfpind,:))';
    
    % CHNum = zeros(1,length(LFP));
    % for k = 1:length(LFP)
    %     CHNum(k) = str2num(LFP{1,k}(3:4));
    % end
end