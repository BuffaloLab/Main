% Preprocess spikes and LFP (PPSL) data with 10 second chunks
% Nathan Killian 100226 -note: must have trials sorted in ascending order!
% function [cfg1 data1] = PPSL(cfg1)
[dum I] = max(cfg1.trl(:,2));
if I ~=length(cfg1.trl(:,2))
    %     error('need to sort trials into chronological order to use this function')
    disp('sorting trials in chronological order')
    [dum sortind] = sort(cfg1.trl(:,1));
    cfg1.trl = cfg1.trl(sortind,:);
end
%spikes-----------------------------------
if cfg1.useSpikes
    cfg1.channel        = cfg1.SUA;
    cfg1.dftfilter      = 'no';
    cfg1.padding        = 0;
    cfg1.continuous     = 'yes';
    if dosorting
        disp('doing spike sorting')
        SS = spikesort(cfg1.datafile);
        disp('finished spike sorting')
        % if detrend_spikes
        if isempty(SS), cfg1.SUA = []; SUAdata = [];break;end
        dsfs = 1000;
        %         times = SS.time;
        desCH           = unique(SS.channel)';
        [units dum]     = unique(SS.unit);
        [unitCH dum]    = sort(SS.channel(dum));units = units(dum);
        count = 1;withspike = [];SUAlabel = [];
        for k = desCH
            withspike = ([withspike k]);
            for kk = 1:length(find(unitCH==k))
                SUAlabel{count,1} = ['sig' leadz(k,3) char(96+kk)];
                count = count + 1;
            end
        end
        if ~isempty(withspike)
            trl = cfg1.trl;
            numtrls = size(trl,1);
            datatmp.label = [SUAlabel];
            s0 = 1; sN = cfg1.trl(:,2)-cfg1.trl(:,1)+1;%accomodates variable length trials
            datatmp.trial = cell(1,numtrls);
            for kk = 1:numtrls
                datatmp.trial{1,kk} = zeros(length(withspike),sN(kk));
                datatmp.numspks{1,kk} = zeros(length(withspike),1);
            end
            for kk = 1:numtrls
                count = 1;
                for k = withspike
                    %     t0 = (kk-1)*trlchunk;tN = (kk)*trlchunk;S0 = dsfs*t0+1;
                    t0 = (trl(kk,1)-1)/dsfs;tN = (trl(kk,2)-1)/dsfs;S0 = round(dsfs*t0)+1;
                    times = SS.time(find((SS.time<tN & SS.time>=t0).*(SS.channel == k)));
                    datatmp.time{1,kk} = ([s0:sN(kk)]-1+trl(kk,3))/dsfs;
                    if ~isempty(times)
                        %         times(times == 0) = [];
                        samplenums = round(times*dsfs)-S0;
                        samplenums(samplenums ==  0) = 1;
                        samplenums(samplenums == -1) = [];
                        datatmp.numspks{1,kk}(count,1) = length(samplenums);
                        datatmp.trial{1,kk}(count,1:sN(kk)) = zeros(1,sN(kk));
                        datatmp.trial{1,kk}(count,samplenums) = 1;
                    end
                    count = count + 1;
                end
            end
            SUAdata = datatmp;
            cfg1.channel = SUAlabel';
        else
            SUAdata = [];
        end
    else
        if ~isfield(cfg1,'blackrock'),cfg1.blackrock = 0;end
        if cfg1.blackrock
            cfg1.dsfs = 1e3;
            SUAdata     = brload(cfg1);
        else
            SUAdata = ft_preprocessing(cfg1);
        end
    end
    if ~cfg1.useLFP
        data1 = SUAdata;
    end
end
%LFP-----------------------------------------------------------------------
if cfg1.useLFP
    if chunk4preproc
        %         hdr = read_header(headerfile, 'headerformat', headerformat);
        %         [nex, chanhdr] = read_plexon_nex(filename, 'header', hdr.orig, 'channel', chanindx(i), 'tsonly', 1);
        %         offset     = round(double(nex.ts-hdr.FirstTimeStamp)./hdr.TimeStampPerSample);
        
        %define trials as 10 s chunks for 0.1 Hz resolution line noise removal
        chunk = 10000;% num. of samples
        t0 = cfg1.trl(1,1);
        tN = cfg1.trl(end,2);
        trlold = cfg1.trl;
        trltemp = zeros(ceil((tN-t0+1)/chunk),3);
        if ~onechunk
            count = 2;
            trltemp(1,:) = [t0 t0+999 0];t0 = t0+1000;%don't trust the first second of data
            for k = t0:chunk:tN
                endtime = k + chunk-1;
                if endtime > tN, endtime = tN;end
                trltemp(count,:) = [k endtime 0];
                count = count + 1;
            end
        else
            trltemp = [t0 tN 0];
        end
        cfg1.trl         = trltemp;
    else
        trlold = cfg1.trl;
    end
    
    if PPeye & ~rmLFP
        cfg1.channel     = [cfg1.LFP {'X'} {'Y'}];
    elseif ~PPeye & ~rmLFP
        cfg1.channel     = cfg1.LFP;
    elseif PPeye & rmLFP
        cfg1.channel = [{'X'} {'Y'}];
    end
    if dodft
        cfg1.dftfilter   = 'yes';
    else
        cfg1.dftfilter = 'no';
    end
    cfg1.dftfreq     = [59.8 59.9 60 60.1 60.2 119.8 119.9 120 120.1 120.2];
    cfg1.padding     = 0;
    cfg1.continuous  = 'yes';
    cfg1.detrend     = detrend;
    
    cfg1.bpfilter    = bpfilter;
    cfg1.bpfreq      = bpfreq;
    
    %preprocess with temp trial chunks then restore older trials, older
    %must be xmaller chunks
    if ~isfield(cfg1,'blackrock'),cfg1.blackrock = 0;end
    if cfg1.blackrock
        cfg1.dsfs = 1e3;
        LFPdatatemp     = brload(cfg1);
    else
        LFPdatatemp     = ft_preprocessing(cfg1);
    end
    fltord    = 20;  lpfreq    = 240;%Hz
    %low pass filter the eye position data
    nyqfrq = 1000 ./ 2;
    flt = fir2(fltord,[0,lpfreq./nyqfrq,lpfreq./nyqfrq,1],[1,1,0,0]);
    if PPeye
        xyinds = [find(strcmp(LFPdatatemp.label,'X')) find(strcmp(LFPdatatemp.label,'Y'))];
        %         [bl al] = butter(4,120/(1000/2),'low');
        for trlind = 1:length(LFPdatatemp.trial)
            LFPdatatemp.trial{trlind}(xyinds(1),isnan(LFPdatatemp.trial{trlind}(xyinds(1),:)))=0;
            LFPdatatemp.trial{trlind}(xyinds(2),isnan(LFPdatatemp.trial{trlind}(xyinds(2),:)))=0;
            %             pause
            if eyefilt
                LFPdatatemp.trial{trlind}(xyinds(1),:) = filtfilt(flt,1,(LFPdatatemp.trial{trlind}(xyinds(1),:)/1000 - CAL(1))*CAL(3));
                LFPdatatemp.trial{trlind}(xyinds(2),:) = filtfilt(flt,1,(LFPdatatemp.trial{trlind}(xyinds(2),:)/1000 - CAL(2))*CAL(4));
            else
                LFPdatatemp.trial{trlind}(xyinds(1),:) = (LFPdatatemp.trial{trlind}(xyinds(1),:)/1000 - CAL(1))*CAL(3);
                LFPdatatemp.trial{trlind}(xyinds(2),:) = (LFPdatatemp.trial{trlind}(xyinds(2),:)/1000 - CAL(2))*CAL(4);
            end
            %fixme
            % % %             if dodownsample
            % % %                 LFPdatatemp.trial{trlind}(xyinds(1),:) = decimate(LFPdatatemp.trial{trlind}(xyinds(1),:),dsfactor);
            % % %                 LFPdatatemp.trial{trlind}(xyinds(2),:) = decimate(LFPdatatemp.trial{trlind}(xyinds(2),:),dsfactor);
            % % %             end
        end
    end
    
    %     if cfg1.prewhiten
    %     %do prewhitening with temporal derivative
    %     for k = 1:size(LFPdatatemp.trial,2)
    %        datatmp = LFPdatatemp.trial{k};
    %        datapw  = diff(datatmp,1,2);
    %        LFPdatatemp.trial{k} = [datapw(:,1) datapw];
    %     end
    %     end
    
    if chunk4preproc
        cfg1.trl = trlold;
        
        cfg2 = [];cfg2.trl = trlold(:,1:3);
        % from redefinetrial comments: Alternatively you can specify a new trial definition, expressed in
        %   samples relative to the original recording
        %     cfg.trl       = Nx3 matrix with the trial definition, see DEFINETRIAL
        LFPdatatemp          = ft_redefinetrial(cfg2,LFPdatatemp);
    end
    
    if cfg1.useCSDasLFP
        data = LFPdatatemp;
        
        locstmp        = [500 650 800 950 1100 1250 1400 1550 1700 1850 2000 2150 0]/1000;%mm
        [Num Txt Raw] = xlsread('D:\Dropbox\DB\ArrayInfo.xls');
        
        bad = str2num(Raw{find(strcmp(cfg1.fid(3:8),Raw(:,1))),4});
        good = setdiff(1:12,[bad 13]);
        old = [good];
        labarr = cfg1.LFP;
        lfpind = strmatch('AD',labarr);
        
        switch CSDmethod
            case 'standard'
                %     14,15 will be the left (superf) edge, and 16,17 will be the
                %     right/deep edge
                LFP = {'AD01','AD02','AD03','AD04','AD05','AD06','AD07','AD08','AD09','AD10','AD11','AD12','AD13','f14','f15','f16','f17'};
                %     newchans = [old
                new = old;oldtmp = old;
                old = [15 14 old 16 17];
                
                montage = getCSDmontageFictive(old,oldtmp,new,LFP,2);
                cfg2= [];cfg2.montage    = montage;cfg2.old = old;cfg2.new = new;
                
                %         for trltype = 1:3
                %         data  = eval(sprintf('f%g.data1',trltype));%load the data that's chunked into trials
                
                data2 = data; %data2 can have scaling, etc done to it
                oldlabel = data2.label;
                data2.label = [data2.label;'f14';'f15';'f16';'f17'];
                curnumchans = size(data2.trial{1},1);
                for ii = 1:size(data2.trial,2)
                    data2.trial{1,ii}(curnumchans+1,:) = data.trial{1,ii}(find(strcmp(oldlabel,LFP(oldtmp(1)))),:);
                    data2.trial{1,ii}(curnumchans+2,:) = data.trial{1,ii}(find(strcmp(oldlabel,LFP(oldtmp(1)))),:);
                    data2.trial{1,ii}(curnumchans+3,:) = data.trial{1,ii}(find(strcmp(oldlabel,LFP(oldtmp(end)))),:);
                    data2.trial{1,ii}(curnumchans+4,:) = data.trial{1,ii}(find(strcmp(oldlabel,LFP(oldtmp(end)))),:);
                end
                
                %\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
                %apply the montage via preprocessing in FT
                dataCSD = ft_preprocessing(cfg2, data2);
                LFPdatatemp = dataCSD;
                %         dataCSDth = preprocessing(cfg2, data2th);
                %         dataCSDga = preprocessing(cfg2, data2ga);
                %         dataCSDhiga = preprocessing(cfg2, data2higa);
                LFPdatatemp.label = LFPdatatemp.label';
                
                %////////////////////////////////////////////////////////////////////////
            case 'iCSD_splines'
                %                 cond = 0.3;%S/m
                %                 cond_top = 0.3;
                %                 diam = 0.5*1e-3;%mm->m
                %                 gauss_sigma = 0.15*1e-3;%mm->m
                %                 filter_range = 5*gauss_sigma;
                
                cond = 0.3;%S/m
                cond_top = 0.3;
                diam = 0.75*1e-3;%mm->m
                gauss_sigma = 0.1*1e-3;%mm->m
                filter_range = 5*gauss_sigma;
                
                labels = LFPdatatemp.label;
                clear CL
                for kk = 1:size(labels,1)
                    fc1 = labels{kk,1}(1);
                    if fc1 == 'A';CL(kk,1) = str2num(labels{kk,1}(3:4))+100;%100 for AD
                    else CL(kk,1) = str2num(labels{kk,1}(4:6))+200;         %200 for spks
                    end
                end
                rows = [];chi = 1;
                for Cvs = good
                    ACv = Cvs+100;
                    row = find(CL(:,1) == ACv);
                    rows(chi) = row;
                    chi = chi+1;
                end
                
                el_pos = locstmp(good)*1e-3;%mm->m
                [el_pos si] = sort(el_pos);
                Fcs = F_cubic_spline(el_pos,diam,cond,cond_top);
                %                 progress('init', 'etf', 'computing CSD')
                disp('computing CSD')
                Nrpt = length(LFPdatatemp.trial);
                for trli = 1:Nrpt
                    %                     progress(trli/length(LFPdatatemp.trial));
                    dtmp = LFPdatatemp.trial{trli}(rows(si),:);
                    if strmatch(dttrl,'yes')
                        dtmp = dtmp - repmat(nanmean(dtmp,2),[1 size(dtmp,2)]);
                    end
                    % do the CSD calculation
                    [zs,CSD_cs] = make_cubic_splines(el_pos,dtmp,Fcs);
                    if gauss_sigma~=0 %filter iCSD
                        [zs,CSD_cs]=gaussian_filtering(zs,CSD_cs,gauss_sigma,filter_range);
                    end;
                    unit_scale = 1e-3; % A/m^3 -> muA/mm^3
                    CSD_cs = CSD_cs*unit_scale;
                    
                    if keepsplines
                        timetmp = LFPdatatemp.time{trli};
                        LFPdatatemp.trial{trli} = [];
                        LFPdatatemp.trial{trli} = CSD_cs;
                        LFPdatatemp = var2field(LFPdatatemp,el_pos,zs,gauss_sigma,filter_range,cond,cond_top,diam,0);
                        if trli == 1
                            labels2 = cell(length(zs),1);
                            for k = 1:length(zs)
                                labels2{k,1} = num2str(rsig(zs(k)*1e6,0));%microns
                            end
                            LFPdatatemp.label = labels2;
                        end
                    else
                        % choose nearest points
                        %                     if trli == 1
                        %                         newrows = zeros(size(el_pos))';
                        %                         for pi = 1:length(el_pos)
                        %                             newrows(pi) = nearest(zs,el_pos(pi));
                        %                         end
                        %                     end
                        %do interpolation -better than nearest
                        timetmp = LFPdatatemp.time{trli};
                        [X Y] = meshgrid(timetmp,zs);%current interpolated data points
                        [XI YI] =meshgrid(timetmp,el_pos);%points to extract
                        CSD_new = interp2(X,Y,CSD_cs,XI,YI);
                        LFPdatatemp.trial{trli} = [];
                        %     LFPdatatemp.trial{trli} = CSD_cs(newrows,:);%for nearest
                        LFPdatatemp.trial{trli} = CSD_new;
                        if trli == 1,LFPdatatemp.label = labels(rows(si));end
                    end
                    
                    
                    disp(['finished trial ' num2str(trli) ' of ' num2str(Nrpt)])
                    %                     figure(401);clf(401);figure(401);
                    %                     subplot 121
                    %                     imagesc(CSD_cs(newrows,:));colorbar
                    %                     subplot 122
                    %                     imagesc(CSD_new);colorbar
                end
                %                 progress('close');
                
        end
        
        %         Run this after running ft_preprocessing (can play around with cfg.timwin and
        % cfg.interptoi):
        %
        % % remove influence of spikes on LFP waveform
        % % (interpolate using cubic spline)
        % for k=1:length(data.label)
        %
        %    if strmatch('sig',data.label{k})
        %
        %        lfpchnlab=cell2mat(data.label(strmatch('AD',data.label)));
        %
        % lfpchn=str2num(lfpchnlab(:,end-1:end))==str2num(data.label{k}(end-2:end-1));
        %
        %        clear cfg
        %        cfg.spikechannel = data.label{k};
        %        cfg.channel      = {lfpchnlab(lfpchn,:)};
        %        cfg.feedback     = 'no';
        %        cfg.method       = 'spline';
        %        cfg.timwin       = [-0.005 0.015]; % [begin end], time around each
        % spike (default = [-0.001 0.002])
        %        cfg.interptoi    = 0.02; % value, time in seconds used for
        % interpolation, which
        %                                 % must be larger than timwin (default =
        % 0.01)
        %
        %        data = ft_spiketriggeredinterpolation(cfg, data);
        %
        %    end
        % end
        %
        %
    elseif strmatch(dttrl,'yes')
        Nrpt = length(LFPdatatemp.trial);
        for trli = 1:Nrpt
            dtmp = LFPdatatemp.trial{trli};
            dtmp = dtmp - repmat(nanmean(dtmp,2),[1 size(dtmp,2)]);
            LFPdatatemp.trial{trli} = dtmp;
        end
        
    end
    
    %     cfg2 = [];cfg2.trl = trlold(:,1:3);
    %     % from redefinetrial comments: Alternatively you can specify a new trial definition, expressed in
    %     %   samples relative to the original recording
    %     %     cfg.trl       = Nx3 matrix with the trial definition, see DEFINETRIAL
    %     LFPdata          = redefinetrial(cfg2,LFPdatatemp);
    
    LFPdata = LFPdatatemp;
    if ~cfg1.useSpikes
        data1 = LFPdata;
    end
    
end
%put SUA and LFP into the same matrix
if cfg1.useLFP & cfg1.useSpikes
    data1 = ft_appenddata(cfg1, SUAdata, LFPdata);
end
clear data SUAdata LFPdata LFPdatatemp CSD_cs dtmp CSD_new
% pause
% % % if vartrllngth & runTF
% % %     trialsizes = zeros(length(data1.trial),1);
% % %     for k = 1:length(data1.trial)
% % %         trialsizes(k) = size(data1.trial{k},2);
% % %     end
% % %     [maxlen ind] = max(trialsizes);
% % %     maxtime = data1.time{ind};
% % %     for k = 1:length(data1.trial)
% % %         data1.trial{k}  = zerpad(data1.trial{k},maxlen,2);
% % % %         data1.trial{k}  = nanpad(data1.trial{k},maxlen,2);
% % %         data1.time{k}   = maxtime;
% % %     end
% % % end
