% Code combines parameter profiles (distance, velocity, acceleration, and
% rotation) across multiple image sets and monkes. Second section/cell is
% for combining fixations and saccades of a specific duration, typically
% shorter ones. 
scm_image_dir = 'C:\Users\GOD-OF-ChAOS\Documents\MATLAB\Buffalo Lab-Salience Model\SCM Image Sets\';
image_sets = {'Set006','Set007','Set008','Set009',...
    'SetE001','SetE002','SetE003','SetE004'};
tags = {'MP','TT','JN','IW'};
medianfix = NaN(length(image_sets),length(tags));
mediansac = NaN(length(image_sets),length(tags));
for SET = 1:length(image_sets);
    SETNUM = image_sets{SET};
    cd([scm_image_dir SETNUM])
    matfiles = what;
    statfiles = [];
    for i = 1:length(matfiles.mat);
        str = strfind(matfiles.mat{i},'ViewingBehavior');
        if ~isempty(str)
            for ii = 1:length(tags);
                strt = strfind(matfiles.mat{i},tags{ii});
                if ~isempty(strt)
                    load(matfiles.mat{i},'avgfixprofile','avgsacprofile');
                    medianfix(SET,ii) = size(avgfixprofile,2);
                    mediansac(SET,ii) = size(avgsacprofile,2);
                end
            end
        end
    end
end
fixlen = round(median(nanmedian(medianfix)));
saclen = round(median(nanmedian(mediansac)));

allsaccades = NaN(45000,saclen,4);
allfixations = NaN(45000,fixlen,4);
persistence.sac = NaN(45000,saclen);
persistence.fix = NaN(45000,fixlen);
fixcount = 1;
fixcount2 = 1;
saccount = 1;
transitionthreshold = 45;

for SET = 1:length(image_sets);
    SETNUM = image_sets{SET};
    cd([scm_image_dir SETNUM])
    matfiles = what;
    eyedatafiles = zeros(1,length(tags));
    for i = 1:length(matfiles.mat);
        if ~isempty(strfind(matfiles.mat{i},'fixation'))
            for ii = 1:length(tags);
                if ~isempty(strfind(matfiles.mat{i},tags{ii}))
                    eyedatafiles(ii) = i;
                end
            end
        end
    end
    for eyefile = eyedatafiles;
        load(matfiles.mat{eyefile})
        
        for cndlop = 1:2:length(fixationstats); %only uses novel viewing since memory could alter natural behavior
            fixationtimes = fixationstats{cndlop}.fixationtimes;
            saccadetimes =  fixationstats{cndlop}.saccadetimes;
            xy =fixationstats{cndlop}.XY;
            if fixationtimes(1,1)<saccadetimes(1,1)
                fixcount2 = fixcount+1;
            else
                fixcount2 = fixcount;
            end
            for i = 1:size(saccadetimes,2);
                x = xy(1,saccadetimes(1,i)-5:saccadetimes(2,i)+7);
                y = xy(2,saccadetimes(1,i)-5:saccadetimes(2,i)+7);
                velx = diff(x);
                vely = diff(y);
                vel = sqrt(velx.^2+vely.^2);
                accel = abs(diff(vel));
                angle = 180*atan2(vely,velx)/pi;
                transitions = abs(diff(angle)) > transitionthreshold;
                vel = vel(1:end-1);
                rot = zeros(1,length(x)-2);
                dist = zeros(1,length(x)-2);
                for a = 1:length(x)-2;
                    rot(a) = abs(angle(a)-angle(a+1));
                    dist(a) = sqrt((x(a)-x(a+2)).^2 + (y(a)-y(a+2)).^2);
                end
                rot(rot > 180) = rot(rot > 180)-180;
                if  saclen == length(dist);
                    timewarp = 1:length(dist);
                else
                    timewarp = round(linspace(1,length(dist),saclen));
                end
                if i == size(saccadetimes,2)
                    if fixationtimes(1,end) >= saccadetimes(2,end)
                        persistence.sac(fixcount2,:) = transitions(timewarp);
                    end
                else
                    persistence.sac(fixcount2,:) = transitions(timewarp);
                end
                allsaccades(saccount,:,1) = dist(timewarp);
                allsaccades(saccount,:,2) = vel(timewarp);
                allsaccades(saccount,:,3) = accel(timewarp);
                allsaccades(saccount,:,4) = rot(timewarp);
                saccount = saccount+1;
                fixcount2 = fixcount2+1;
            end
            for i = 1:size(fixationtimes,2);
                x = xy(1,fixationtimes(1,i)-5:fixationtimes(2,i)+7);
                y = xy(2,fixationtimes(1,i)-5:fixationtimes(2,i)+7);
                velx = diff(x);
                vely = diff(y);
                vel = sqrt(velx.^2+vely.^2);
                accel = abs(diff(vel));
                angle = 180*atan2(vely,velx)/pi;
                transitions = abs(diff(angle)) > transitionthreshold;
                vel = vel(1:end-1);
                rot = zeros(1,length(x)-2);
                dist = zeros(1,length(x)-2);
                for a = 1:length(x)-2;
                    rot(a) = abs(angle(a)-angle(a+1));
                    dist(a) = sqrt((x(a)-x(a+2)).^2 + (y(a)-y(a+2)).^2);
                end
                rot(rot > 180) = rot(rot > 180)-180;
                if  fixlen == length(dist);
                    timewarp = 1:length(dist);
                else
                    timewarp = round(linspace(1,length(dist),fixlen));
                end
                if i == 1
                    if fixationtimes(1,1) >= saccadetimes(2,1)
                        persistence.fix(fixcount,:) = transitions(timewarp);
                    end
                else
                    persistence.fix(fixcount,:) = transitions(timewarp);
                end
                allfixations(fixcount,:,1) = dist(timewarp);
                allfixations(fixcount,:,2) = vel(timewarp);
                allfixations(fixcount,:,3) = accel(timewarp);
                allfixations(fixcount,:,4) = rot(timewarp);
                fixcount = fixcount+1;
            end
        end
    end
end
Nans = find(isnan(allfixations(:,1,1)));
allfixations(Nans,:,:) = [];
Nans = find(isnan(allsaccades(:,1,1)));
allsaccades(Nans,:,:) = [];

avgfixation= mean(allfixations,1);
avgfixprofile = zeros(size(avgfixation));
for ii = 1:size(avgfixation,3);
    %     avgfixprofile(:,:,ii) = filtfilt(1/3*ones(1,3),1,avgfixation(:,:,ii));
    avgfixprofile(:,:,ii) = avgfixation(:,:,ii);
    avgfixprofile(:,:,ii) = avgfixprofile(:,:,ii) - min(avgfixprofile(:,:,ii));
    avgfixprofile(:,:,ii) = avgfixprofile(:,:,ii)/max(avgfixprofile(:,:,ii));
end
avgsaccade= mean(allsaccades,1);
avgsacprofile = zeros(size(avgsaccade));
for ii = 1:size(avgsaccade,3);
    %     avgsacprofile(:,:,ii) = filtfilt(1/3*ones(1,3),1,avgsaccade(:,:,ii));
    avgsacprofile(:,:,ii) = avgsaccade(:,:,ii);
    avgsacprofile(:,:,ii) =  avgsacprofile(:,:,ii) - min(avgsacprofile(:,:,ii));
    avgsacprofile(:,:,ii) = avgsacprofile(:,:,ii)/max(avgsacprofile(:,:,ii));
end

variables = {'Dist','vel','accel','rot'};
figure
title('Average Fixation Profile by Parameter')
hold all
h = area(5:fixlen-5,ones(1,fixlen-9));
set(h,'FaceColor',[.75 .75 .75])
set(h,'EdgeColor','none')
for ii =  1:size(avgfixprofile,3);
    plot(avgfixprofile(:,:,ii),'linewidth',2)
end
hold off
xlim([1 fixlen])
set(gca,'XTick',[])
set(gca,'YTick',[0 1],'YTickLabel',{'0','1'})
ylabel('Normalized Value')
legend([{'fixation'} variables],'Location','NorthEastOutside');
xlabel('Warped Time')
figure
title('Averag Saccade Profile by Parameter')
hold all
h1 = area(1:5,ones(1,5));
set(h1,'FaceColor',[.75 .75 .75])
set(h1,'EdgeColor','none')
h2 = area(saclen-4:saclen,ones(1,5));
set(h2,'FaceColor',[.75 .75 .75])
set(h2,'EdgeColor','none')
for ii = 1:size(avgsacprofile,3)
    p(ii) = plot(avgsacprofile(:,:,ii),'linewidth',2);
end
hold off
xlim([1 saclen])
set(gca,'XTick',[])
set(gca,'YTick',[0 1],'YTickLabel',{'0','1'})
ylabel('Normalized Value')
legend([h1 p],[{'fixation'} variables],'Location','NorthEastOutside');
xlabel('Warped Time')
ylim([0 1.05])
%% Combined vieing parameter profiles for short fixations and saccades only
scm_image_dir = 'C:\Users\GOD-OF-ChAOS\Documents\MATLAB\Buffalo Lab-Salience Model\SCM Image Sets\';
image_sets = {'Set006','Set007','Set008','Set009',...
    'SetE001','SetE002','SetE003','SetE004'};
tags = {'MP','TT','JN','IW'};

saclen = 14; % for saccades 20 ms in duration or less. Duration is #-10 samples
fixlen = 19; % for fixations 45 ms in duration or less. Duration is #-10 samples
allsaccades = NaN(10000,saclen,4);
allfixations = NaN(10000,fixlen,4);
fixcount = 1;
fixcount2 = 1;
saccount = 1;
transitionthreshold = 45;

for SET = 1:length(image_sets);
    SETNUM = image_sets{SET};
    cd([scm_image_dir SETNUM])
    matfiles = what;
    eyedatafiles = zeros(1,length(tags));
    for i = 1:length(matfiles.mat);
        if ~isempty(strfind(matfiles.mat{i},'fixation'))
            for ii = 1:length(tags);
                if ~isempty(strfind(matfiles.mat{i},tags{ii}))
                    eyedatafiles(ii) = i;
                end
            end
        end
    end
    
    for eyefile = eyedatafiles;
        load(matfiles.mat{eyefile})
        
        for cndlop = 1:2:length(fixationstats); %only uses novel viewing since memory could alter natural behavior
            fixationtimes = fixationstats{cndlop}.fixationtimes;
            saccadetimes =  fixationstats{cndlop}.saccadetimes;
            xy =fixationstats{cndlop}.XY;
            if fixationtimes(1,1)<saccadetimes(1,1)
                fixcount2 = fixcount+1;
            else
                fixcount2 = fixcount;
            end
            for i = 1:size(saccadetimes,2);
                if diff(saccadetimes(:,i)) < saclen-10+1
                    x = xy(1,saccadetimes(1,i)-5:saccadetimes(2,i)+7);
                    y = xy(2,saccadetimes(1,i)-5:saccadetimes(2,i)+7);
                    velx = diff(x);
                    vely = diff(y);
                    vel = sqrt(velx.^2+vely.^2);
                    accel = abs(diff(vel));
                    angle = 180*atan2(vely,velx)/pi;
                    transitions = abs(diff(angle)) > transitionthreshold;
                    vel = vel(1:end-1);
                    rot = zeros(1,length(x)-2);
                    dist = zeros(1,length(x)-2);
                    for a = 1:length(x)-2;
                        rot(a) = abs(angle(a)-angle(a+1));
                        dist(a) = sqrt((x(a)-x(a+2)).^2 + (y(a)-y(a+2)).^2);
                    end
                    rot(rot > 180) = rot(rot > 180)-180;
                    if  saclen == length(dist);
                        timewarp = 1:length(dist);
                    else
                        timewarp = round(linspace(1,length(dist),saclen));
                    end
                    allsaccades(saccount,:,1) = dist(timewarp);
                    allsaccades(saccount,:,2) = vel(timewarp);
                    allsaccades(saccount,:,3) = accel(timewarp);
                    allsaccades(saccount,:,4) = rot(timewarp);
                    saccount = saccount+1;
                    fixcount2 = fixcount2+1;
                end
            end
            for i = 1:size(fixationtimes,2);
                if diff(fixationtimes(:,i)) < fixlen-10+1
                    x = xy(1,fixationtimes(1,i)-5:fixationtimes(2,i)+7);
                    y = xy(2,fixationtimes(1,i)-5:fixationtimes(2,i)+7);
                    velx = diff(x);
                    vely = diff(y);
                    vel = sqrt(velx.^2+vely.^2);
                    accel = abs(diff(vel));
                    angle = 180*atan2(vely,velx)/pi;
                    vel = vel(1:end-1);
                    rot = zeros(1,length(x)-2);
                    dist = zeros(1,length(x)-2);
                    for a = 1:length(x)-2;
                        rot(a) = abs(angle(a)-angle(a+1));
                        dist(a) = sqrt((x(a)-x(a+2)).^2 + (y(a)-y(a+2)).^2);
                    end
                    rot(rot > 180) = rot(rot > 180)-180;
                    if  fixlen == length(dist);
                        timewarp = 1:length(dist);
                    else
                        timewarp = round(linspace(1,length(dist),fixlen));
                    end
                    allfixations(fixcount,:,1) = dist(timewarp);
                    allfixations(fixcount,:,2) = vel(timewarp);
                    allfixations(fixcount,:,3) = accel(timewarp);
                    allfixations(fixcount,:,4) = rot(timewarp);
                    fixcount = fixcount+1;
                end
            end
        end
    end
end
Nans = find(isnan(allfixations(:,1,1)));
allfixations(Nans,:,:) = [];
Nans = find(isnan(allsaccades(:,1,1)));
allsaccades(Nans,:,:) = [];

load(['C:\Users\GOD-OF-ChAOS\Documents\MATLAB\Buffalo Lab-Salience Model\'...
    'SCM Image Sets\MinMaxFixandSacProfiles.mat']);
minn = min(minfix,minsac);
maxx = max(maxfix,maxsac);
avgfixation= mean(allfixations,1);
fixlen = size(avgfixation,2);
avgfixprofile = zeros(size(avgfixation));
for ii = 1:size(avgfixation,3);
    avgfixprofile(:,:,ii) = filtfilt(1/3*ones(1,3),1,avgfixation(:,:,ii));
    avgfixprofile(:,:,ii) =  avgfixprofile(:,:,ii) - minn(:,:,ii);
    avgfixprofile(:,:,ii) =  avgfixprofile(:,:,ii)/(maxx(:,:,ii)-minn(:,:,ii));
    %     avgfixprofile(:,:,ii) = avgfixprofile(:,:,ii) - min(avgfixprofile(:,:,ii));
    %     avgfixprofile(:,:,ii) = avgfixprofile(:,:,ii)/max(avgfixprofile(:,:,ii));
end
avgsaccade= mean(allsaccades,1);
saclen = size(avgsaccade,2);
avgsacprofile = zeros(size(avgsaccade));
for ii = 1:size(avgsaccade,3);
    avgsacprofile(:,:,ii) = filtfilt(1/3*ones(1,3),1,avgsaccade(:,:,ii));
    avgsacprofile(:,:,ii) = avgsaccade(:,:,ii);
    avgsacprofile(:,:,ii) =  avgsacprofile(:,:,ii) - minn(:,:,ii);
    avgsacprofile(:,:,ii) =  avgsacprofile(:,:,ii)/(maxx(:,:,ii)-minn(:,:,ii));
    %     avgsacprofile(:,:,ii) =  avgsacprofile(:,:,ii) - min(avgsacprofile(:,:,ii));
    %     avgsacprofile(:,:,ii) = avgsacprofile(:,:,ii)/max(avgsacprofile(:,:,ii));
end

variables = {'Dist','vel','accel','rot'};
figure
title('Average-Smoothed Fixation Profile by Parameter')
hold all
h = area(5:fixlen-5,ones(1,fixlen-9));
set(h,'FaceColor',[.75 .75 .75])
set(h,'EdgeColor','none')
for ii =  1:size(avgfixprofile,3);
    plot(avgfixprofile(:,:,ii),'linewidth',2)
end
hold off
xlim([1 fixlen])
set(gca,'XTick',[])
set(gca,'YTick',[0 1],'YTickLabel',{'0','1'})
ylabel('Normalized Value')
legend([{'fixation'} variables],'Location','NorthEastOutside');
xlabel('Warped Time')
figure
title('Average-Smoothed Saccade Profile by Parameter')
hold all
h1 = area(1:5,1.1*ones(1,5));
set(h1,'FaceColor',[.75 .75 .75])
set(h1,'EdgeColor','none')
h2 = area(saclen-4:saclen,1.1*ones(1,5));
set(h2,'FaceColor',[.75 .75 .75])
set(h2,'EdgeColor','none')
for ii = 1:size(avgsacprofile,3)
    p(ii) = plot(avgsacprofile(:,:,ii),'linewidth',2);
end
hold off
xlim([1 saclen])
set(gca,'XTick',[])
set(gca,'YTick',[0 1],'YTickLabel',{'0','1'})
ylabel('Normalized Value')
legend([h1 p],[{'fixation'} variables],'Location','NorthEastOutside');
xlabel('Warped Time')