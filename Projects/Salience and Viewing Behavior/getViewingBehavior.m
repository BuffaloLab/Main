function getViewingBehavior(DATAFILE,SETNAME,SETNUM,CNDFILE,PLOTOPTIONS)
%Seth Koenig 06/06/2012

%function extracts eye tracking data from cortex files for free viewing of
%natural scence both novel and manipulated/moved. This part of the
%code is essentially get_Alldata.m. The 2nd part of the function extracts
%angles, distance, and time between fixations.

%Inputs:
%   DATAFILE: Data file from cortex e.g. MP120606.1
%   SETNAME:  Name of the task set name (item file) e.g. SET007.itm
%   SETNUM:   same as item file without .itm, e.g. SET007
%   CNDFILE:  condition file for the task type e.g. scm.cnd

%   PLOTOPTIONS: determines if function plots task images with eye tracking
%   layed over. Also determies if function will plot fit behavioral data.
%   If left blank no plots will appear.
%       PLOTOPTIONS.plot = 'none' or 'all'      Plot eye track data
%       PLOTOPTIONS.novel ='none' or 'all'      Plot all images or images or novel only
%       PLOTOPTIONS.behavior ='none' or 'all'   Plot fitted behavior statistics

%Outputs:
%   A file with the following name ['ViewingBehavior-'DATAFILE(1:end-2) '-' SETNUM]. 
%   File contains the necessary variables and data for succesive functions.
%   Saved variables are described by variable variablenames.

if nargin < 5
    PLOTOPTIONS.plot = 'none'
    PLOTOPTIONS.novel = 'none'
    PLOTOPTIONS.behavior ='none'
elseif nargin < 4
    error(['Not enough inputs: function requires DATAFILE, SETNAME,'...
        'SETNUM, and CNDFILE.']);
end

[status,result] = system('hostname');
if strcmp('GOD-OF-ChAOS-PC',result(1:15))
    setfile = SETNAME;
    datfil = DATAFILE;
    cndfile = ['C:\Users\GOD-OF-ChAOS\Documents\MATLAB\' CNDFILE];
    filedir = pwd;
else
    ini=datfil(1:2);
    if strcmp(ini,'IW')==1 || strcmp(ini,'iw')==1
        datfil=['S:\Cortex Data\Irwin\' DATAFILE];
    elseif strcmp(ini,'MP')==1 || strcmp(ini,'mp')==1
        datfil=['S:\Cortex Data\Peepers\' DATAFILE];
    elseif strcmp(ini,'WR')==1 || strcmp(ini,'wr')==1
        datfil=['S:\Cortex Data\Wilbur\' DATAFILE];
    elseif strcmp(ini,'TT')==1 || strcmp(ini,'tt')==1
        datfil=['S:\Cortex Data\Timmy\' DATAFILE];
        
    elseif strcmp(ini,'JN')==1 || strcmp(ini,'jn')==1
        datfil=['S:\Cortex Data\Guiseppe\' DATAFILE];
    elseif strcmp(ini,'TD')==1 || strcmp(ini,'td')==1
        datfil=['S:\Cortex Data\Theodore\' DATAFILE];
    end
    
    setfile = ['S:\Cortex Programs\Scene Manipulation\' SETNAME];
    cndfile = ['S:\Cortex Programs\Scene Manipulation\' CNDFILE];
    filedir = ['S:\Cortex Programs\Scene Manipulation\Scenes Renamed\' SETNUM]
end

[time_arr,event_arr,eog_arr,epp_arr,header,trialcount]  = get_ALLdata(datfil);

itmfil=[];
[fid,message]=fopen(setfile,'r');
if fid<0
    disp(message);
else
    while 1
        tline = fgetl(fid);
        if ~isempty(itmfil)
            if length(tline)>size(itmfil,2)
                tline=tline(1:size(itmfil,2));
            end
        end
        tline = [tline ones(1,(size(itmfil,2)-length(tline)))*char(32)];
        if ischar(tline)
            itmfil=[itmfil; tline];
        else
            break
        end
    end
end

fclose(fid);

cndfil=[];
[fid,message]=fopen(cndfile, 'r');
if fid<0
    disp(message);
else
    while 1
        tline = fgetl(fid);
        if ~isempty(cndfil)
            if length(tline)>size(cndfil,2)
                tline=tline(1:size(cndfil,2));
            end
        end
        tline = [tline ones(1,(size(cndfil,2)-length(tline)))*char(32)];
        if ischar(tline)
            cndfil=[cndfil; tline];
        else
            break
        end
    end
end
fclose(fid);

numrpt = size(event_arr,2);
valrptcnt = 0;
clear per clrchgind
for rptlop = 1:numrpt
    if size(find(event_arr((find(event_arr(:,rptlop)>1000,1,'last')),rptlop) < 1010)) ~=0
        if size(find(event_arr(:,rptlop) == 200)) ~=0
            perbegind = find(event_arr(:,rptlop) == 24);%was originally 23, changed this and begtimdum line below to optimize
            perendind = find(event_arr(:,rptlop) == 24);
            cndnumind = find(event_arr(:,rptlop) >= 1000 & event_arr(:,rptlop) <=2000);
            blknumind = find(event_arr(:,rptlop) >=500 & event_arr(:,rptlop) <=999);
            begtimdum = time_arr(perbegind,rptlop)-100;
            endtimdum = time_arr(perendind,rptlop);
            if endtimdum > begtimdum
                valrptcnt = valrptcnt + 1;
                clrchgind(valrptcnt)=rptlop;
                per(valrptcnt).begsmpind = begtimdum;
                per(valrptcnt).endsmpind = endtimdum;
                per(valrptcnt).begpos = 1;
                per(valrptcnt).cnd = event_arr(cndnumind,rptlop);
                per(valrptcnt).blk = event_arr(blknumind,rptlop);
                per(valrptcnt).allval = event_arr(:,rptlop);
                per(valrptcnt).alltim = time_arr(:,rptlop);
            end
        end
    end
end

samprate=5;

clear cnd
numrpt = size(per,2);
for rptlop = 1:numrpt
    cnd(rptlop)=per(rptlop).cnd;
end

evnnmb=2:2:size(eog_arr,1);
oddnmb=1:2:size(eog_arr,1);

clear x y
cndlst=unique(cnd);
for k=1:length(cndlst)
    cndind=find(cnd==cndlst(k));
    allind=clrchgind(cndind);
    for l=1:length(allind)
        x{k}(l)=mean(eog_arr(intersect(floor(((per(cndind(l)).begsmpind-1000)/samprate)*2):(floor((per(cndind(l)).endsmpind-1000)/samprate))*2,oddnmb),allind(l)));
        y{k}(l)=mean(eog_arr(intersect(floor(((per(cndind(l)).begsmpind-1000)/samprate)*2):(floor((per(cndind(l)).endsmpind-1000)/samprate))*2,evnnmb),allind(l)));
    end
end

%remove outlying points when calculating average eye position @ each location
for k=1:length(x)
    x{k}=x{k}(find(x{k}<mean(x{k}+std(x{k})) & x{k}>mean(x{k}-std(x{k}))));
    y{k}=y{k}(find(x{k}<mean(x{k}+std(x{k})) & x{k}>mean(x{k}-std(x{k}))));
    x{k}=x{k}(find(y{k}<mean(y{k}+std(y{k})) & y{k}>mean(y{k}-std(y{k}))));
    y{k}=y{k}(find(y{k}<mean(y{k}+std(y{k})) & y{k}>mean(y{k}-std(y{k}))));
end

clear meanx meany
for k=1:length(x)
    meanx(k)=mean(x{k});
end
for k=1:length(y)
    meany(k)=mean(y{k});
end

clear x y
x=meanx; y=meany;

meanxorigin = mean([x(6) x(2) x(1) x(5) x(9) ],2);
xscale = mean([6/(x(8)-meanxorigin) 3/(x(4)-meanxorigin) 3/(abs(x(3)-meanxorigin)) 6/(abs(x(7)-meanxorigin))],2);
meanyorigin = mean([y(7) y(3) y(1) y(4) y(8) ],2);
yscale = mean([6/(y(6)-meanyorigin) 3/(y(2)-meanyorigin) 3/(abs(y(5)-meanyorigin)) 6/(abs(y(9)-meanyorigin))],2);

%optional: to verify calibration
%figure;scatter((x-meanxorigin).*xscale,(y-meanyorigin).*yscale)

numrpt = size(event_arr,2);
valrptcnt = 0;
clear per vpcind
new_eog_arr=[];
for rptlop = 1:numrpt
    if size(find(event_arr((find(event_arr(:,rptlop)>1000,1,'last')),rptlop) >= 1010)) ~=0
        if size(find(event_arr(:,rptlop) == 200)) ~=0
            perbegind = find(event_arr(:,rptlop) == 23,1,'first');
            perendind = find(event_arr(:,rptlop) == 24,1,'first');
            cndnumind = find(event_arr(:,rptlop) >= 1000 & event_arr(:,rptlop) <=2000);
            blknumind = find(event_arr(:,rptlop) >=500 & event_arr(:,rptlop) <=999);
            begtimdum = time_arr(perbegind,rptlop);
            endtimdum = time_arr(perendind,rptlop);
            if endtimdum > begtimdum
                valrptcnt = valrptcnt + 1;
                vpcind(valrptcnt)=rptlop;
                per(valrptcnt).begsmpind = begtimdum;
                per(valrptcnt).endsmpind = endtimdum;
                per(valrptcnt).begpos = 1;
                per(valrptcnt).cnd = event_arr(cndnumind,rptlop);
                per(valrptcnt).blk = event_arr(blknumind,rptlop);
                per(valrptcnt).allval = event_arr(:,rptlop);
                per(valrptcnt).alltim = time_arr(:,rptlop);
                new_eog_arr=cat(2,new_eog_arr,eog_arr(:,rptlop));
            end
        end
    end
end

eyedat = [];
for trlop=1:size(per,2)
    trleog=new_eog_arr(~isnan(new_eog_arr(:,trlop)),trlop); % eog for this trial
    horeog=trleog(1:2:size(trleog,1)); % horizontal eye dat
    vrteog=trleog(2:2:size(trleog,1)); % vertical eye dat
    picstart=per(trlop).alltim(find(per(trlop).allval==23,1,'first'))-per(trlop).alltim(find(per(trlop).allval==100)); % picture start time relative to eye scan start
    picend=per(trlop).alltim(find(per(trlop).allval==24,1,'first'))-per(trlop).alltim(find(per(trlop).allval==100)); % picture end time relative to eye scan start
    
    eyedat{trlop}(1,:) = (horeog(round(picstart/5):round(picend/5))) .* xscale;
    eyedat{trlop}(2,:) = (vrteog(round(picstart/5):round(picend/5))) .* yscale;
end

%---remove bad values of from eyedat---%
for i = 1:size(eyedat,2);
    x = eyedat{i}(1,40:end)*24+400;
    y = eyedat{i}(2,40:end)*24+300;
    badx = find(x < 1 | x > 800);
    x(badx) = []; y(badx) = [];
    bady = find(y < 1 | y > 600);
    x(bady) = []; y(bady) = [];
    x = (x-400)/24; y = (y-300)/24;
    eyedat{i} = [x;y];
end

clear lt cnd
numrpt = size(per,2);
for rptlop = 1:numrpt
    %     lt(rptlop)=per(rptlop).endsmpind-per(rptlop).begsmpind-500;
    cnd(rptlop)=per(rptlop).cnd;
end

test0start=strfind(cndfil(1,:),'TEST0');
filenamestart=strfind(itmfil(1,:),'------FILENAME------');

if strcmpi(PLOTOPTIONS.plot,'all');
    if strcmpi(PLOTOPTIONS.novel,'all');
        step = 1;
    else
        step = 2;
    end
    for cndlop=1:step:length(cnd)
        rowtouse=strmatch([ones(1,(5-length(num2str(cnd(cndlop)-1000))))*char(32) num2str(cnd(cndlop)-1000) ' '],cndfil(:,1:6));
        itm0=str2double(cndfil(rowtouse,(test0start:test0start+2)));
        
        file_match=itmfil(strmatch([ones(1,(4-length(num2str(itm0))))*char(32) num2str(itm0)],itmfil(:,1:4)),filenamestart:end-1);
        
        [match_mtx,map] = imread([filedir '\' file_match(find(file_match=='\',1,'last')+1:end)]);
        figure
        image(-399:400,fliplr(-299:300),match_mtx);
        axis xy
        h2=axes('Position',get(gca,'Position'),'Layer','top');
        h=scatter(eyedat{cndlop}(1,:)*24,eyedat{cndlop}(2,:)*24,3,'ob','MarkerFaceColor','b');
        hh=line(eyedat{cndlop}(1,:)*24,eyedat{cndlop}(2,:)*24,'Color','b');
        xlim([-399 400]);
        ylim([-299 300]);
        axis off;
        title(['Condition ' num2str(cnd(cndlop)-1000)]);
    end
end

%-----Calculate Fixation Statistics-----%
% analyze fixations-frm scm_getdata.m

% construct filter for eye velocity measure
fltord = 60;
lowpasfrq = 25;
nyqfrq = 1000 ./ 2;
flt = fir2(fltord,[0,lowpasfrq./nyqfrq,lowpasfrq./nyqfrq,1],[1,1,0,0]);

% preallocate variables
% number of fixations in CR
novFixin = zeros(1,length(cnd(1:2:end)))+nan;
novFixTotal = zeros(1,length(cnd(1:2:end)))+nan;

% time spent in CR
novTimeIn=zeros(1,length(cnd(1:2:end)))+nan;
novTimeTotal=zeros(1,length(cnd(1:2:end)))+nan;

lop2=1;
lop3=1;
lop4=1;

fixation = cell(1,length(cnd(1:end)));
timefix = cell(1,length(cnd(1:end)));
for trllop=1:length(cnd)
    
    % differentiate and multiply with sampling rate to get velocity as deg/sec
    resampxnov=resample(eyedat{trllop}(1,40:end-40),5,1);
    resampynov=resample(eyedat{trllop}(2,40:end-40),5,1);
    
    % calculate velocity
    x_vnov= diff(filtfilt(flt,1, resampxnov)) .* 1000;
    y_vnov= diff(filtfilt(flt,1, resampynov)) .* 1000;
    
    % combine x- and y-velocity to get overall eye velocity
    velnov = abs(complex(x_vnov,y_vnov));
    % lim = threshold for detecting saccade
    lim = 50;
    sacbegnov = find(diff(velnov > lim) > 0);
    sacendnov = find(diff(velnov > lim) < 0);
    
    if velnov(end)>=lim
        if velnov(1)<lim
            tempbegnov=[1 sacendnov];
            tempendnov=sacbegnov;
        else
            tempbegnov=sacendnov;
            tempendnov=sacbegnov;
        end
    else
        if velnov(1)<lim
            tempbegnov=[1 sacendnov];
            tempendnov=[sacbegnov length(velnov)];
        else
            tempbegnov=sacendnov;
            tempendnov=[sacbegnov length(velnov)];
        end
    end
    
    % calculate fixations in CR & transitions into/out of CR for novel presentation
    fixInNov=0; % # of fixations inside area of interest for novel trial
    fixTotalNov=0; % # of total fixations for novel trial
    fixTransInNov=0; % # of transitions into area of interest for novel trial
    fixTransOutNov=0; % # of transitions out of area of interest for novel trial
    rmv = [];
    fixations = [];
    for fixlop=1:length(tempbegnov)
        fixhor=mean(resampxnov(tempbegnov(fixlop):tempendnov(fixlop)))*24; % fixation position, horizontal
        fixvrt=mean(resampynov(tempbegnov(fixlop):tempendnov(fixlop)))*24; % fixation position, vertical
        if fixlop~=1
            fixhor_lasttrl=mean(resampxnov(tempbegnov(fixlop-1):tempendnov(fixlop-1)))*24; % previous fixation position, horizontal
            fixvrt_lasttrl=mean(resampynov(tempbegnov(fixlop-1):tempendnov(fixlop-1)))*24; % previous fixation position, horizontal
        end
        fixout=1;
        if fixhor>-400 && fixhor<400
            if fixvrt>-300 && fixvrt<300
                fixTotalNov=fixTotalNov+1;
                fixations = [fixations {[fixhor,fixvrt]}];
            else
                rmv = [rmv fixlop];
            end
        else
            rmv = [rmv fixlop];
        end
    end
    fixation{trllop} = fixations;
    tempendnov(rmv) = [];
    timefix{trllop} = tempendnov/1000;
end

%-----Distance and time betwneen fixations as a function of fixation#----%
sacdist = [];
time = [];
for i = 1:2:length(fixation); %only uses novel viewing since images changes could alter natural behavior
    xy =[];
    for ii = 1:length(fixation{i})
        xy = [xy [fixation{i}{ii}(1);fixation{i}{ii}(2)]];
    end
    dist = sqrt(sum(diff(xy,1,2).^2,1));
    sacdist = [sacdist dist];
    time = [time diff(timefix{i})];
end

dists = zeros(length(fixation(1:2:end)),75);
times = zeros(length(fixation(1:2:end)),75);
rnd = 0;
for i = 1:2:length(fixation);
    rnd = rnd + 1;
    xy = [];
    for ii = 1:length(fixation{i})
        xy = [xy [fixation{i}{ii}(1);fixation{i}{ii}(2)]];
    end
    dist = sqrt(sum(diff(xy,1,2).^2,1));
    dists(rnd,:) = [dist  zeros(1,size(dists,2)-length(dist))];
    tme = diff(timefix{i});
    times(rnd,:) = [tme  zeros(1,size(times,2)-length(tme))];
end
stdd = zeros(1,50);
meand = zeros(1,50);
meant= zeros(1,50);
stdt = zeros(1,50);
nt = zeros(1,50);
nd = zeros(1,50);
for i = 1:size(dists,2)
    fill = dists(:,i);
    fill = fill(fill ~= 0);
    nd(i) = length(fill);
    meand(i) = mean(fill);
    stdd(i) = std(fill);
    fill = times(:,i);
    fill = fill(fill~= 0);
    nt(i) = length(fill);
    meant(i) = mean(fill);
    stdt(i) = std(fill);
end

%----Fixation Probability Density Map----%
dt = 12; %1/2 a degree
xrange = -400:dt:400+dt;
yrange = -300:dt:300+dt;
densitymap = zeros(length(yrange)-1,length(xrange)-1);
for i = 1:2:length(fixation) %only uses novel viewing since images changes could alter natural behavior
    for ii = 1:size(densitymap,1)
        for iii = 1:size(densitymap,2)
            xx = []; yy = [];
            for iv = 1:length(fixation{i})
                xx = [xx fixation{i}{iv}(1)];
                yy = [yy fixation{i}{iv}(2)];
            end
            t = find((yrange(ii) <= yy & yy < yrange(ii+1))...
                & (xrange(iii) <= xx & xx < xrange(iii+1)));
            densitymap(ii,iii) = densitymap(ii,iii)+ length(t);
        end
    end
end
f = fspecial('gaussian',[5,5],14);
densitymap = imfilter(densitymap,f);
densitymap = imfilter(densitymap,f);
densitymap = densitymap/sum(sum(densitymap));

%----Probability Distribution of Angles Between Fixations-----%
angles = cell(1,length(fixation));
for i = 1:2:length(fixation) %only uses novel viewing since images changes could alter natural behavior
    if ~isempty(fixation{i})
        angl = zeros(1,length(fixation{i}));
        for ii = 1:length(fixation{i});
            if ii == 1
                x = fixation{i}{ii}(2)-0;
                y = fixation{i}{ii}(1)-0;
                angl(ii) = atan2(y,x);
            else
                x = fixation{i}{ii}(2)-fixation{i}{ii-1}(2);
                y = fixation{i}{ii}(1)-fixation{i}{ii-1}(1) ;
                angl(ii) = atan2(y,x);
            end
        end
        angles{i} = 180/pi*angl;
    end
end
angls = [];
for i = 1:length(angles)
    angls = [angls angles{i}];
end
[probang] = hist(angls,360);
probang = [probang(1:10) probang probang(10:-1:1)];
n = (0:360)*pi/180;
probang = filter(1/12*ones(1,12),1,probang);
probang = [probang(11:end-10)]; probang = probang/sum(probang);
probang = [probang probang(1)];

%----2D Cumulative Distribution of Eye Movement Distance and Angles during a Saccade----%
distances = cell(1,length(1:2:length(timefix)));
saccangles = cell(1,length(1:2:length(timefix)));
maxl = 0;
for i = 1:2:length(timefix); %only uses novel viewing since images changes could alter natural behavior
    for ii = 1:length(timefix{i})-1
        timeindex1 = round(timefix{i}(ii)*1000/5);
        timeindex2 = round(timefix{i}(ii+1)*1000/5);
        
        xy = 24*eyedat{i}(:,timeindex1:timeindex2);
        dxy = diff(xy,1,2);
        opoveradj = dxy(2,:)./dxy(1,:);
        opoveradj(isnan(opoveradj)) = 0;
        sacange = atand(opoveradj);
        sacange(dxy(1,:) < 0) = sacange(dxy(1,:) < 0) + 180;
        saccangles{i}{ii} = sacange;
        distances{i}{ii} = sqrt(dxy(1,:).^2 + dxy(2,:).^2);
        maxl = max(maxl,size(dxy,2));        
    end    
end
anglevec = NaN*ones(sum(cellfun(@numel,distances)),maxl);
distvec = NaN*ones(sum(cellfun(@numel,distances)),maxl);
cnt = 1;
for i = 1:length(distances);
    for ii = 1:length(distances{i})
        distvec(cnt,1:length(distances{i}{ii})) = distances{i}{ii};
        anglevec(cnt,1:length(saccangles{i}{ii})) = saccangles{i}{ii};
       cnt = cnt + 1;
    end
end
mndist = nanmean(distvec,1);
[mx mxi] = nanmax(mndist);
stop = find(mndist < 0.01*mx); %need to define some stopping point
stop(stop < mxi) = [];
start = find(mndist > 0.5*mx); %thresh for start of saccade (fixations concrete markers)
start(start < 5) = [];
start = start(1);
if isempty(stop)
    stop = 125+start;
elseif stop(1)-start > 125
    stop = start+125;
else
    stop = stop(1);
end
smndist = filter(1/4*ones(1,4),1,mndist);
smndist = smndist(start:stop)*sum(mndist(start:stop))/sum(smndist(start:stop));
distvec = round(distvec(:,start:stop));
cutoff = mean(sacdist)+std(sacdist);
distvec(distvec > cutoff) = cutoff;
probdst = histc(distvec,1:max(max(distvec)),1);
distCDF = cumsum(probdst,1);
sCDF = sum(probdst,1);
distCDF = bsxfun(@rdivide,distCDF,sCDF);
anglevec = anglevec(:,start:stop)-90;
diffangles = diff(anglevec,1);
persistence = abs(nanmean(diffangles,1));
persistence(isnan(persistence)) = [];
persistence = filter(1/50*ones(1,50),1,persistence);
persistence = persistence/max(persistence);
[mxp mxi] = max(persistence); persistence(mxi:end) = 1;


if strcmpi(PLOTOPTIONS.behavior,'all')
    
    figure
    [x,y] = meshgrid(xrange(1:end-1),yrange(1:end-1));
    surf(x,y,densitymap,'EdgeColor','none')
    xlim([xrange(1) xrange(end-1)])
    ylim([yrange(1) yrange(end-1)])
    title('Fixation Probability Density Viewing')
    xlabel('Horizontal Position (Pixel)')
    ylabel('Vertical Position (Pixel)')
    
    figure
    polar(n,probang)
    title('Probability Distribution of Angles Between Fixation')
    
    figure
    hist(sacdist,100)
    title('Saccadic Distance')
    xlabel('Pixels')
    
    figure
    hist(time,100)
    title('Fixation Times Length')
    
    figure
    plot(time,sacdist,'*','markersize',3)
    ylabel('Pixels')
    xlabel('Time (s)')
    
    figure
    plot(0:5:5*(length(smndist)-1),smndist) 
    ylabel('Eye Movement Distance (Pixels)')
    xlabel('Time (ms)')
    
    figure
    subplot(3,1,1)
    plot(nt);
    xlabel('Fixation Number (minus last one)')
    ylabel('Number of Trials')
    title('Number of Trials vs Number of Fixations')
    subplot(3,1,2)
    errorbar(meant,stdt./sqrt(nd))
    xlabel('Fixation Number (minus last one)')
    ylabel('Time between Fixations (secs)')
    title('Time between Fixations vs Number of Fixations')
    subplot(3,1,3)
    errorbar(meand,stdd./sqrt(nd))
    xlabel('Fixation Number (minus last one)')
    ylabel('Distance between Fixations (Pixels)')
    title('Distance between Fixations vs Number of Fixations')
end

variablenames={
    'eyedat: contains x & y positions of eye tracking data';
    'fixation: x & y position in pixels of fixations';
    'timefix: time of fixations';
    'probang: distribution of angles between fixations';
    'n: angles for probang';
    'densitymap: 2D probability distribution of fixation';
    'sacdist: vector of all distances between fixations';
    'time: vector of all times between fixations';
    'dists: distance between fixations as a function of fixation #';
    'meand,stdd,nd: mean, STD, & # points for distance between fixations as function of fixation #';
    'times: time between fixations as a function of fixation #';
    'meant,stdt,nt: mean, STD, & # of points for time between fixations as a function fixation #';
    'smndist: smoothed mean eye movement distance';
    'distCDF: cumulative distribution function for eye movement distances';
    'diffangles: difference in angles between eye tracking data';
    'persistence: measure over time of persistence of eye movements in the same direction';
    };

save(['ViewingBehavior-' DATAFILE(1:end-2) '-' SETNUM],'eyedat','fixation',...
    'timefix','densitymap','probang','sacdist','time','dists','times','nd',...
    'meand','stdd','nt','meant','stdt','n','smndist','distCDF','diffangles',...
    'persistence','variablenames','cndfil','cnd','itmfil','datfil','SETNUM',...
    'filenamestart','test0start')