close all
clear all
pack 
% %CHANGE TO FIT DATA
datfil='JN120418.2';
tlocfil='21ro411';
cndfil='TLmod21.cnd';


% load the Cortex data
tloc = xlsread(['S:\Tloc\Tloc' tlocfil '.xls']);
ini=datfil(1:2);
if strcmp(ini,'IW')==1 || strcmp(ini,'iw')==1
    datfil=['S:\Cortex Data\Irwin\' datfil];
elseif strcmp(ini,'MP')==1 || strcmp(ini,'mp')==1
    datfil=['S:\Cortex Data\Peepers\' datfil];
elseif strcmp(ini,'WR')==1 || strcmp(ini,'wr')==1
    datfil=['S:\Cortex Data\Wilbur\' datfil];
elseif strcmp(ini,'TT')==1 || strcmp(ini,'tt')==1
    datfil=['S:\Cortex Data\Timmy\' datfil];
elseif strcmp(ini,'JN')==1 || strcmp(ini,'jn')==1
    datfil=['S:\Cortex Data\Guiseppe\' datfil];
elseif strcmp(ini,'TD')==1 || strcmp(ini,'td')==1
    datfil=['S:\Cortex Data\Theodore\' datfil];
end
[time_arr,event_arr,eog_arr,epp_arr,header,trialcount]  = get_ALLdata(datfil);

fid=fopen(['S:\Cortex Programs\Contextual\' cndfil],'rt');
tline=fgets(fid);
cndmrk=regexp(tline,'COND#'):regexp(tline,'COND#')+4;
tst0mrk=regexp(tline,'TEST0'):regexp(tline,'TEST0')+4;
tst1mrk=regexp(tline,'TEST1'):regexp(tline,'TEST1')+4;

cndind=[];
itmind=[];
tlinenew=0;
while tlinenew~=-1
    tlinenew=fgets(fid);
    if tlinenew~=-1
        cndind=[cndind str2double(tlinenew(cndmrk))];
        itmind=[itmind str2double(tlinenew(tst0mrk))];
    end
end

% correct trial type for some files

i=0;
if strmatch('TL3.cnd',cndfil)
    for k=1:size(event_arr,2)
        typnumind = find(event_arr(:,k) == 1 | event_arr(:,k) == 2);
        cndnumind = find(event_arr(:,k) >= 1000 & event_arr(:,k) <=4999);
        typ       = event_arr(typnumind,k);
        cnd       = event_arr(cndnumind,k);
        itm       = itmind(cndind==cnd-1000);
        if itm<=24
            if typ==2
                event_arr(typnumind,k)=1;
                i=i+1;
            end
        elseif itm>24
            if typ==1
                event_arr(typnumind,k)=2;
                i=i+1;
            end
        end
    end
end

disp(['Fixed ' num2str(i) ' trials']);

% calibrate the eye data

numrpt = size(event_arr,2);
trl= [];
for rptlop = 1:numrpt
    if ~isempty(find(event_arr(:,rptlop) == 284,1))
        perbegind = find(event_arr(:,rptlop) == 8,1,'last');
        perendind = find(event_arr(:,rptlop) == 24);
        cndnumind = find(event_arr(:,rptlop) >= 1000 & event_arr(:,rptlop) <=4999);
        blknumind = find(event_arr(:,rptlop) >=500 & event_arr(:,rptlop) <=999);
        typnumind = find(event_arr(:,rptlop) == 1 | event_arr(:,rptlop) == 2);
        perbegeye = find(event_arr(:,rptlop) == 100);
        perendeye = find(event_arr(:,rptlop) == 101);
        begtim    = time_arr(perbegind,rptlop) + 300;
        endtim    = time_arr(perendind,rptlop);
        cnd       = event_arr(cndnumind,rptlop);
        blk       = event_arr(blknumind,rptlop);
        typ       = event_arr(typnumind,rptlop);
        begeye    = time_arr(perbegeye,rptlop);
        endeye    = time_arr(perendeye,rptlop);
        if endtim-begtim>=0
            trl = [trl; [begtim endtim 0 cnd blk typ begeye endeye rptlop]];
        end
    end
end

% put the eyedata into Plexon-->Fieldtrip format
clear caldata
caldata.label={'X';'Y'};
for k=1:size(trl,1)
    hordum=eog_arr(1:2:end,trl(k,end));
    vrtdum=eog_arr(2:2:end,trl(k,end));
    hordum=hordum(~isnan(hordum));
    vrtdum=vrtdum(~isnan(vrtdum));
    
    hordumint=interp(hordum,5);
    vrtdumint=interp(vrtdum,5);
    
    caldata.trial{k}(1,:)=hordumint((trl(k,1)-trl(k,7)):(trl(k,2)-trl(k,7)))';
    caldata.trial{k}(2,:)=vrtdumint((trl(k,1)-trl(k,7)):(trl(k,2)-trl(k,7)))';
end

calcfg.trl=trl;

xvolarr=zeros(1,length(caldata.trial))+nan;
yvolarr=zeros(1,length(caldata.trial))+nan;
xcalarr=zeros(1,length(caldata.trial))+nan;
ycalarr=zeros(1,length(caldata.trial))+nan;
for k=1:length(caldata.trial)
    cndnum=calcfg.trl(k,4)-1000;
    itmnum=itmind(find(cndind==cndnum));
    xvolarr(k)=mean(caldata.trial{k}(1,:));
    yvolarr(k)=mean(caldata.trial{k}(2,:));
    xdeg=tloc(itmnum,3);
    ydeg=tloc(itmnum,4);
    xcalarr(k)=xvolarr(k)/xdeg;
    ycalarr(k)=yvolarr(k)/ydeg;
end

xcal=mean(xcalarr);
ycal=mean(ycalarr);

% define the trials solely based on the marker events
numrpt = size(event_arr,2);
trl= [];
for rptlop = 1:numrpt
    if ~isempty(find(event_arr(:,rptlop) == 284,1))
        perbegind = find(event_arr(:,rptlop) == 23);
        perendind = find(event_arr(:,rptlop) == 8,1,'last');
        cndnumind = find(event_arr(:,rptlop) >= 1000 & event_arr(:,rptlop) <=4999);
        blknumind = find(event_arr(:,rptlop) >=500 & event_arr(:,rptlop) <=999);
        typnumind = find(event_arr(:,rptlop) == 1 | event_arr(:,rptlop) == 2);
        perbegeye = find(event_arr(:,rptlop) == 100);
        perendeye = find(event_arr(:,rptlop) == 101);
        begtim    = time_arr(perbegind,rptlop);
        endtim    = time_arr(perendind,rptlop);
        cnd       = event_arr(cndnumind,rptlop);
        blk       = event_arr(blknumind,rptlop);
        typ       = event_arr(typnumind,rptlop);
        begeye    = time_arr(perbegeye,rptlop);
        endeye    = time_arr(perendeye,rptlop);
        if endtim-begtim>=0
            trl = [trl; [begtim endtim 0 cnd blk typ begeye endeye rptlop]];
        end
    end
end

% get the eye data
cfg=[];
cfg.label={'X';'Y'};
for k=1:size(trl,1)
    hordum=eog_arr(1:2:end,trl(k,end));
    vrtdum=eog_arr(2:2:end,trl(k,end));
    hordum=hordum(~isnan(hordum));
    vrtdum=vrtdum(~isnan(vrtdum));
    
    hordumint=interp(hordum,5);
    vrtdumint=interp(vrtdum,5);
    
    cfg.trial{k}(1,:)=hordumint((trl(k,1)-trl(k,7)):(trl(k,2)-trl(k,7)))';
    cfg.trial{k}(2,:)=vrtdumint((trl(k,1)-trl(k,7)):(trl(k,2)-trl(k,7)))';
end

% find saccades
fltord = 20;
lowpasfrq = 40;
nyqfrq = 1000 ./ 2;
flt = fir2(fltord,[0,lowpasfrq./nyqfrq,lowpasfrq./nyqfrq,1],[1,1,0,0]);

cfg.trl=[];
fixdurarr=zeros(length(cfg.trial),100)+nan;
i=1;
for k=1:length(cfg.trial)
    if size(cfg.trial{k},2)>60
        %differentiate and multiply with sampling rate to get velocity as deg/sec
        x_v= diff(filtfilt(flt,1, cfg.trial{k}(1,:)./xcal)) .* 1000;
        y_v= diff(filtfilt(flt,1, cfg.trial{k}(2,:)./ycal)) .* 1000;

        %combine x- and y-velocity to get overall eye velocity
        vel = abs(complex(x_v,y_v));
        %threshold for detecting saccade
        lim = 50;
        sacbeg = find(diff(vel > lim) > 0);
        sacend = find(diff(vel > lim) < 0);

        if vel(end)>=lim
            if vel(1)<lim
                tempbeg=[0 sacend];
                tempend=sacbeg;
            else
                tempbeg=sacend;
                tempend=sacbeg;
            end
        else
            if vel(1)<lim
                tempbeg=[0 sacend];
                tempend=[sacbeg length(vel)];
            else
                tempbeg=sacend;
                tempend=[sacbeg length(vel)];
            end
        end
        fixdurdum=tempend-tempbeg;
        numsac=length(sacbeg);
        fixdurarr(i,1:length(fixdurdum))=fixdurdum;

        cfg.trl(i,:)=[trl(k,1:6) numsac 1000/mean(fixdurdum)];
        i=i+1;
    end
end

% analyze behavior
trltyp1=cfg.trl((cfg.trl(:,6)==1),:);
trltyp2=cfg.trl((cfg.trl(:,6)==2),:);

clear avgrt1 avgrt2 stert1 stert2
blkarr=unique(trltyp1(:,5));
numblks=length(blkarr);
for k=1:numblks
    rcttim1=trltyp1(trltyp1(:,5)==blkarr(k),2)-trltyp1(trltyp1(:,5)==blkarr(k),1);
    rcttim1=rcttim1(rcttim1<15000);
    avgrt1(k)=mean(rcttim1);
    stert1(k)=std(rcttim1)/sqrt(length(rcttim1));
    
    rcttim2=trltyp2(trltyp2(:,5)==blkarr(k),2)-trltyp2(trltyp2(:,5)==blkarr(k),1);
    rcttim2=rcttim2(rcttim2<15000);
    avgrt2(k)=mean(rcttim2);
    stert2(k)=std(rcttim2)/sqrt(length(rcttim2));
    
end

% save cfg
filnam=datfil(find(datfil=='\',1,'last')+1:(find(datfil=='.',1,'last'))-1);
resfil=['S:\Matlab analyzed data\contextual-eyedat\' filnam 'set' tlocfil 'eyedat.mat'];
cfg=rmfield(cfg,'trial');
save(resfil, 'cfg');
disp(strcat('Generated:',resfil))
