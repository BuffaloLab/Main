% Code Comparse pre-post lesion stats for timmy and Stats of esther's vs normal
% SCM images for the other monkeys to determine if there is a change in
% behavior due to a lesion and/or the difference in complexity of scenes.
% Written by Seth Koenig January 2013. 
% 1. Comparison of salience at fixations and by fixation
% 2. Comparison of viewing behavior statistics
% 3. Salience IOR

%---[1] Salience at Fixation Location---%
scm_image_dir = 'C:\Users\GOD-OF-ChAOS\Documents\MATLAB\Buffalo Lab-Salience Model\SCM Image Sets\';
presets = {'Set006','Set007','Set008','Set009'};
postsets = {'SetE001','SetE002','SetE003','SetE004'};
image_sets = [presets postsets];
tags = {'MP','TT','JN','IW'};
minlen = 100;

for SET = 1:length(presets);
    data = NaN(36*length(presets)*4,3,2,minlen);
    SETNUM = image_sets{SET};
    cd([scm_image_dir SETNUM])
    matfiles = what;
    statfiles = [];
    for i = 1:length(matfiles.mat);
        str = strfind(matfiles.mat{i},'FixationStatistics');
        if ~isempty(str)
            statfiles = [statfiles i];
        end
    end
    for stat = statfiles;
        load(matfiles.mat{stat},'statistics')
        minlen = min(minlen,size(statistics.numbervalues,3));
    end
end

for ii = 1:length(tags);
    for SET = 1:length(postsets);
        data = NaN(36*length(postsets),3,2,minlen);
        SETNUM = postsets{SET};
        cd([scm_image_dir SETNUM])
        matfiles = what;
        statfiles = zeros(1,length(tags));
        for i = 1:length(matfiles.mat);
            if ~isempty(strfind(matfiles.mat{i},'FixationStatistics'));
                if ~isempty(strfind(matfiles.mat{i},tags{ii}))
                    load(matfiles.mat{i})
                    combineddata = shuffunshuffdata{2}{3};
                    data(36*(SET-1)+1:SET*36,:,:,:) = combineddata(:,:,:,1:minlen);
                end
            end
        end
    end
    alldata{1,ii} = data;
end

for ii = 1:length(tags);
    for SET = 1:length(postsets);
        SETNUM = postsets{SET};
        cd([scm_image_dir SETNUM])
        matfiles = what;
        statfiles = zeros(1,length(tags));
        for i = 1:length(matfiles.mat);
            if ~isempty(strfind(matfiles.mat{i},'FixationStatistics'));
                if ~isempty(strfind(matfiles.mat{i},tags{ii}))
                    load(matfiles.mat{i})
                    combineddata = shuffunshuffdata{2}{3};
                    data(36*(SET-1)+1:SET*36,:,:,:) = combineddata(:,:,:,1:minlen);
                end
            end
        end
    end
    alldata{2,ii} = data;
end

%kstest to compare distributions
allksp = cell(1,length(tags));
means = cell(1,length(tags));
allpres = cell(length(tags),size(alldata{1},2),size(alldata{1},3));
allposts =cell(length(tags),size(alldata{1},2),size(alldata{1},3));
for t = 1:length(tags)
    ksp = NaN(size(alldata{1},2),size(alldata{1},3),size(alldata{1},4));
    mn = NaN(size(alldata{1},2),size(alldata{1},3),size(alldata{1},4),2);
    for i = 1:size(alldata{1},2)
        for ii = 1:size(alldata{1},3)
            for iii = 1:size(alldata{1},4)
                pre = alldata{1,t}(:,i,ii,iii);
                pre(isnan(pre)) = []; pre = pre(1:end);
                post = alldata{2,t}(:,i,ii,iii);
                post(isnan(post)) = []; post = post(1:end);
                allpres{t,i,ii}= [allpres{t,i,ii};pre];
                allposts{t,i,ii} = [allposts{t,i,ii};post];
                [~,p] = kstest2(pre,post);
                ksp(i,ii,iii) = p;
                mn(i,ii,iii,:) = [mean(pre) mean(post)];
            end
        end
    end
    allksp{t} = ksp;
    means{t} = mn;
end

meanspre = NaN(length(tags),size(alldata{1},2),size(alldata{1},3));
meanspost = NaN(length(tags),size(alldata{1},2),size(alldata{1},3));
combinedkps = NaN(length(tags),size(alldata{1},2),size(alldata{1},3));
for t = 1:length(tags)
    for i = 1:size(alldata{1},2)
        for ii = 1:size(alldata{1},3)
            [~,p] = kstest2(allpres{t,i,ii},allposts{t,i,ii});
            combinedkps(t,i,ii) = p;
            meanspre(t,i,ii) = mean(allpres{t,i,ii});
            meanspost(t,i,ii) = mean(allposts{t,i,ii});
        end
    end
end

clr = ['rgbk'];
for t = 1:length(tags)
    for i = 1:size(means{1},1)
        pre = means{t}(i,1,:,1);
        pre = filtfilt(1/5*ones(1,5),1,reshape(pre,[1,size(pre,3)]));
        post = means{t}(i,1,:,2);
        post = filtfilt(1/5*ones(1,5),1,reshape(post,[1,size(post,3)]));
        figure(i)
        hold on
        plot(pre,[':' clr(t)])
        plot(post,['-' clr(t)])
        hold off
    end
end
labels = [];
titles = {'Salience','Salience Contrast','imgage Intensity',};
for t = 1:length(tags);
    labels = [labels {[tags{t} '-pre'],[tags{t} '-post']}];
end
for i = 1:size(means{1},1);
    figure(i)
    legend(labels,'location','NorthEastOutside');
    title(['Smoothed ' titles{i}])
end
salience.pvalues = combinedkps;
salience.mean_pre_values = meanspre;
salience.mean_post_values = meanspost;
%%
%---[2] Viewing Behavior ---%
scm_image_dir = 'C:\Users\GOD-OF-ChAOS\Documents\MATLAB\Buffalo Lab-Salience Model\SCM Image Sets\';
presets = {'Set006','Set007','Set008','Set009'};
postsets = {'SetE001','SetE002','SetE003','SetE004'};
image_sets = [presets postsets];
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
medianfix = round(nanmedian(medianfix));
mediansac = round(nanmedian(mediansac));

preview = cell(1,length(tags));
for i = 1:length(tags)
    preview{i}.densitymap = zeros(600,800);
    preview{i}.allfixations = [];
    preview{i}.allsaccades = [];
    preview{i}.persistence =[];
    preview{i}.anglebtwfix = [];
    preview{i}.sacangle_2fix = [];
    preview{i}.distanceprofile = [];
    preview{i}.distbtwnfix = [];
    preview{i}.fixduration = [];
    preview{i}.sacangle = [];
    preview{i}.sacdist = [];
    preview{i}.sacduration = [];
    preview{i}.timebtwfix = [];
end

postview = cell(1,length(tags));
for i = 1:length(tags)
    postview{i}.densitymap = zeros(600,800);
    postview{i}.allfixations = [];
    postview{i}.allsaccades = [];
    postview{i}.persistence =[];
    postview{i}.anglebtwfix = [];
    postview{i}.sacangle_2fix = [];
    postview{i}.distanceprofile = [];
    postview{i}.distbtwnfix = [];
    postview{i}.fixduration = [];
    postview{i}.sacangle = [];
    postview{i}.sacdist = [];
    postview{i}.sacduration = [];
    postview{i}.timebtwfix = [];
end

for SET = 1:length(presets);
    SETNUM = presets{SET};
    cd([scm_image_dir SETNUM])
    matfiles = what;
    statfiles = [];
    for i = 1:length(matfiles.mat);
        str = strfind(matfiles.mat{i},'ViewingBehavior');
        if ~isempty(str)
            for ii = 1:length(tags);
                strt = strfind(matfiles.mat{i},tags{ii});
                if ~isempty(strt)
                    load(matfiles.mat{i});
                    if size(allfixations,2) == medianfix(ii);
                        timewarp = 1:size(allfixations,2);
                    else
                        timewarp = round(linspace(1,size(allfixations,2),medianfix(ii)));
                    end
                    distanceprofile.fix = distanceprofile.fix(:,timewarp);
                    persistence.fix = persistence.fix(:,timewarp);
                    persistence.fix = persistence.fix(:,6:end-5);
                    distanceprofile.fix = distanceprofile.fix(:,6:end-5);
                    preview{ii}.allfixations = [preview{ii}.allfixations;...
                        allfixations(:,timewarp,:)];
                    if size(allsaccades,2) == mediansac(ii);
                        timewarp = 1:size(allsaccades,2);
                    else
                        timewarp = round(linspace(1,size(allsaccades,2),mediansac(ii)));
                    end
                    preview{ii}.allsaccades = [preview{ii}.allsaccades;...
                        allsaccades(:,timewarp,:)];
                    distanceprofile.sac = distanceprofile.sac(:,timewarp);
                    distanceprofile.sac = distanceprofile.sac(:,6:end-5);
                    persistence.sac = persistence.sac(:,timewarp);
                    persistence.sac = persistence.sac(:,6:end-5);
                    preview{ii}.persistence = [ preview{ii}.persistence;
                        [persistence.sac persistence.fix]];
                    preview{ii}.anglebtwfix = [preview{ii}.anglebtwfix;anglebtwfix];
                    preview{ii}.sacangle_2fix = [preview{ii}.sacangle_2fix;...
                        sacangle_2fix];
                    preview{ii}.densitymap = preview{ii}.densitymap+densitymap;
                    preview{ii}.distanceprofile = [preview{ii}.distanceprofile;
                        [distanceprofile.sac distanceprofile.fix]];
                    preview{ii}.distbtwnfix = [preview{ii}.distbtwnfix;distbtwnfix];
                    preview{ii}.fixduration = [preview{ii}.fixduration;...
                        fixduration];
                    preview{ii}.sacangle = [preview{ii}.sacangle;sacangle];
                    preview{ii}.sacdist = [preview{ii}.sacdist;sacdist];
                    preview{ii}.sacduration = [preview{ii}.sacduration;sacduration];
                    preview{ii}.timebtwfix = [preview{ii}.timebtwfix;...
                        timebtwfix];
                    preview{ii}.mediansac = mediansac(ii)-10;
                    preview{ii}.medianfix = medianfix(ii)-10;
                end
            end
        end
    end
end

for SET = 1:length(postsets);
    SETNUM = postsets{SET};
    cd([scm_image_dir SETNUM])
    matfiles = what;
    statfiles = [];
    for i = 1:length(matfiles.mat);
        str = strfind(matfiles.mat{i},'ViewingBehavior');
        if ~isempty(str)
            for ii = 1:length(tags);
                strt = strfind(matfiles.mat{i},tags{ii});
                if ~isempty(strt)
                    load(matfiles.mat{i});
                    if size(allfixations,2) == medianfix(ii);
                        timewarp = 1:size(allfixations,2);
                    else
                        timewarp = round(linspace(1,size(allfixations,2),medianfix(ii)));
                    end
                    distanceprofile.fix = distanceprofile.fix(:,timewarp);
                    persistence.fix = persistence.fix(:,timewarp);
                    persistence.fix = persistence.fix(:,6:end-5);
                    distanceprofile.fix = distanceprofile.fix(:,6:end-5);
                    postview{ii}.allfixations = [postview{ii}.allfixations;...
                        allfixations(:,timewarp,:)];
                    if size(allsaccades,2) == mediansac(ii);
                        timewarp = 1:size(allsaccades,2);
                    else
                        timewarp = round(linspace(1,size(allsaccades,2),mediansac(ii)));
                    end
                    postview{ii}.allsaccades = [postview{ii}.allsaccades;...
                        allsaccades(:,timewarp,:)];
                    distanceprofile.sac = distanceprofile.sac(:,timewarp);
                    distanceprofile.sac = distanceprofile.sac(:,6:end-5);
                    persistence.sac = persistence.sac(:,timewarp);
                    persistence.sac = persistence.sac(:,6:end-5);
                    postview{ii}.persistence = [ postview{ii}.persistence;
                        [persistence.sac persistence.fix]];
                    postview{ii}.anglebtwfix = [postview{ii}.anglebtwfix;anglebtwfix];
                    postview{ii}.sacangle_2fix = [postview{ii}.sacangle_2fix;...
                        sacangle_2fix];
                    postview{ii}.densitymap = postview{ii}.densitymap+densitymap;
                    postview{ii}.distanceprofile = [postview{ii}.distanceprofile;
                        [distanceprofile.sac distanceprofile.fix]];
                    postview{ii}.distbtwnfix = [postview{ii}.distbtwnfix;distbtwnfix];
                    postview{ii}.fixduration = [postview{ii}.fixduration;...
                        fixduration];
                    postview{ii}.sacangle = [postview{ii}.sacangle;sacangle];
                    postview{ii}.sacdist = [postview{ii}.sacdist;sacdist];
                    postview{ii}.sacduration = [postview{ii}.sacduration;sacduration];
                    postview{ii}.timebtwfix = [postview{ii}.timebtwfix;...
                        timebtwfix];
                    postview{ii}.mediansac = mediansac(ii)-10;
                    postview{ii}.medianfix = medianfix(ii)-10;
                end
            end
        end
    end
end

viewing_means_values.type = {'pre','SCM';'post','SCME'};
f = fspecial('gaussian',[100,100],50);
for t = 1:length(tags);
    pre = preview{t}.anglebtwfix;
    post = postview{t}.anglebtwfix;
    pre(isnan(pre)) = [];
    post(isnan(post)) = [];
    [~,p] = ttest2(pre,post);
    viewing_pvalue.anglebtwfix(t) = p;
    viewing_mean_values.anglebtwfix(1,t) = mean(pre);
    viewing_mean_values.anglebtwfix(2,t) = mean(post);
    
    pre = preview{t}.sacangle_2fix;
    post = postview{t}.sacangle_2fix;
    pre(isnan(pre)) = [];
    post(isnan(post)) = [];
    [~,p] = ttest2(pre,post);
    viewing_pvalue.sacangle_2fix(t) = p;
    viewing_mean_values.sacangle_2fix(1,t) = mean(pre);
    viewing_mean_values.sacangle_2fix(2,t) = mean(post);
    
    pre = preview{t}.sacangle;
    post = postview{t}.sacangle;
    pre(isnan(pre)) = [];
    post(isnan(post)) = [];
    [~,p] = ttest2(pre,post);
    viewing_pvalue.sacangle(t) = p;
    viewing_mean_values.sacangle(1,t) = mean(pre);
    viewing_mean_values.sacangle(2,t) = mean(post);
    
    pre = preview{t}.distbtwnfix;
    post = postview{t}.distbtwnfix;
    pre(isnan(pre)) = [];
    post(isnan(post)) = [];
    [~,p] = ttest2(pre,post);
    viewing_pvalue.distbtwnfix(t) = p;
     viewing_mean_values.distbtwnfix(1,t) = mean(pre);
    viewing_mean_values.distbtwnfix(2,t) = mean(post);
    
    pre = preview{t}.fixduration;
    post = postview{t}.fixduration;
    pre(isnan(pre)) = [];
    post(isnan(post)) = [];
    [~,p] = ttest2(pre,post);
    viewing_pvalue.fixduration(t) = p;
         viewing_mean_values.fixduration(1,t) = mean(pre);
    viewing_mean_values.fixduration(2,t) = mean(post);
    
    pre = preview{t}.sacdist;
    post = postview{t}.sacdist;
    pre(isnan(pre)) = [];
    post(isnan(post)) = [];
    [~,p] = ttest2(pre,post);
    viewing_pvalue.sacdist(t) = p;
     viewing_mean_values.sacdist(1,t) = mean(pre);
    viewing_mean_values.sacdist(2,t) = mean(post);
    
    pre = preview{t}.sacduration;
    post = postview{t}.sacduration;
    pre(isnan(pre)) = [];
    post(isnan(post)) = [];
    [~,p] = ttest2(pre,post);
    viewing_pvalue.sacduration(t) = p;
     viewing_mean_values.sacduration(1,t) = mean(pre);
    viewing_mean_values.sacduration(2,t) = mean(post);
    
    pre = preview{t}.timebtwfix;
    post = postview{t}.timebtwfix;
    pre(isnan(pre)) = [];
    post(isnan(post)) = [];
    [~,p] = ttest2(pre,post);
    viewing_pvalue.timebtwfix(t) = p;
    viewing_mean_values.timebtwfix(1,t) = mean(pre);
    viewing_mean_values.timebtwfix(2,t) = mean(post);
    
    figure
    suptitle([tags{t} 'Fixation Density map'])
    subplot(2,1,1)
    title('pre')
    pre = preview{t}.densitymap;
    pre = imfilter(pre,f);
    pre = pre./sum(sum(pre));
    imagesc(pre)
    subplot(2,1,2)
    title('post')
    post = postview{t}.densitymap;
    post = imfilter(post,f);
    post = post./sum(sum(post));
    imagesc(post)
    
    figure
    suptitle([tags{t} '-Average-Smoothed Fixation and Saccade Profiles by Parameter'])
    avgfixation= mean(preview{t}.allfixations,1);
    fixlen = size(avgfixation,2);
    avgfixprofile = zeros(size(avgfixation));
    for ii = 1:size(avgfixation,3);
        avgfixprofile(:,:,ii) = filtfilt(1/3*ones(1,3),1,avgfixation(:,:,ii));
    end
    avgsaccade= mean(preview{t}.allsaccades,1);
    saclen = size(avgsaccade,2);
    avgsacprofile = zeros(size(avgsaccade));
    for ii = 1:size(avgsaccade,3);
        avgsacprofile(:,:,ii) = filtfilt(1/3*ones(1,3),1,avgsaccade(:,:,ii));
    end
    subplot(2,2,1)
    title('pre fixation profile')
    hold all
    h = area(5:fixlen-5,ones(1,fixlen-9));
    set(h,'FaceColor',[.75 .75 .75])
    set(h,'EdgeColor','none')
    for ii =  1:size(avgfixprofile,3);
        plot(avgfixprofile(:,:,ii),'linewidth',2)
    end
    hold off
    xlim([1 fixlen])
    xlabel('Warped Time')
    ylabel('Normalized Value')
    subplot(2,2,2)
    title('pre saccade profile')
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
    xlabel('Warped Time')
    ylabel('Normalized Value')
    avgfixation= mean(postview{t}.allfixations,1);
    fixlen = size(avgfixation,2);
    avgfixprofile = zeros(size(avgfixation));
    for ii = 1:size(avgfixation,3);
        avgfixprofile(:,:,ii) = filtfilt(1/3*ones(1,3),1,avgfixation(:,:,ii));
    end
    avgsaccade= mean(postview{t}.allsaccades,1);
    saclen = size(avgsaccade,2);
    avgsacprofile = zeros(size(avgsaccade));
    for ii = 1:size(avgsaccade,3);
        avgsacprofile(:,:,ii) = filtfilt(1/3*ones(1,3),1,avgsaccade(:,:,ii));
    end
    subplot(2,2,3)
    title('post fixation profile')
    hold all
    h = area(5:fixlen-5,ones(1,fixlen-9));
    set(h,'FaceColor',[.75 .75 .75])
    set(h,'EdgeColor','none')
    for ii =  1:size(avgfixprofile,3);
        plot(avgfixprofile(:,:,ii),'linewidth',2)
    end
    hold off
    xlim([1 fixlen])
    xlabel('Warped Time')
    ylabel('Normalized Value')
    subplot(2,2,4)
    title('post saccade profile')
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
    legend([h1 p],[{'fixation'} variables],'Location','NorthEastOutside');
    xlabel('Warped Time')
    ylabel('Normalized Value')
    
    figure
    suptitle([tags{t} '-Probability of Saccade Angle Changeing > 45 Degrees'])
    subplot(2,1,1)
    title('pre')
    hold on
    h  = area(preview{t}.mediansac+1:size(preview{t}.persistence,2),...
        ones(1,size(preview{t}.persistence,2)-preview{t}.mediansac));
    set(h,'FaceColor',[.75 .75 .75])
    set(h,'EdgeColor','none')
    p = plot(mean(preview{t}.persistence));
    hold off
    xlim([1 size(preview{t}.persistence,2)])
    legend([h p],{'fixation','persistence'},'Location','NorthEastOutside');
    xlabel('Warped Time')
    ylabel('Probability of Saccade Angle Changeing > 45 Degrees')
    subplot(2,1,2)
    title('post')
    hold on
    h  = area(postview{t}.mediansac+1:size(postview{t}.persistence,2),...
        ones(1,size(postview{t}.persistence,2)-postview{t}.mediansac));
    set(h,'FaceColor',[.75 .75 .75])
    set(h,'EdgeColor','none')
    p = plot(mean(postview{t}.persistence));
    hold off
    xlim([1 size(postview{t}.persistence,2)])
    legend([h p],{'fixation','persistence'},'Location','NorthEastOutside');
    xlabel('Warped Time')
    ylabel('Probability of Saccade Angle Changeing > 45 Degrees')
    
    figure
    suptitle([tags{t} '-Saccade & Fixation Distance'])
    subplot(2,1,1)
    plot(nanmean(preview{t}.distanceprofile))
    title('pre')
    xlabel('Warped Time')
    ylabel('Distance (pixels)')
    suptitle([tags{t} '-Saccade & Fixation Distance'])
    subplot(2,1,2)
    plot(nanmean(postview{t}.distanceprofile))
    title('post')
    xlabel('Warped Time')
    ylabel('Distance (pixels)')
end
save('PrePostStats-ViewingBehavior_and_FixationSalience.mat','tags','presets',...
    'postsets','viewing_pvalue','viewing_mean_values','salience')