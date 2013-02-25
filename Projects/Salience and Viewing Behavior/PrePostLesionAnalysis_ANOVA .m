%% Uses data from PrePostLesionAnalysis.m
% 4-way ANOVA for Salience at a fixation
% Because some ANOVAs can't be run well as 4-way ANOVAs e.g. when just
% looking at TT for effect of lesion, may have to change ANOVA code some.
% Also, when comparing viewing behavior stats (2nd cell of code) some
% statistics are of different sizes so they can't be compared at the same
% time. Sorry But code is not automated as is. Seth Koenig January 2013.
names = {};
sets = {};
salvals = [];
group = [];
fixationnumber = [];
for t = 1:length(tags)
    for SET = 1:length(presets);
        data = alldata{1,t}(36*(SET-1)+1:SET*36,1,1,:);
        data = reshape(data,[size(data,1),size(data,4)]);
        for ii = 1:size(data,1);
            data2 = data(ii,:);
            data2(isnan(data2)) = [];
            if  ~isempty(data2)
                nms = repmat(tags{t},[length(data2),1]);
                nms = cellstr(nms);
                names = [names;nms];
                sts = repmat(presets{SET},[length(data2),1]);
                sts = cellstr(sts);
                sets = [sets;sts];
                salvals = [salvals;data2'];
                group = [group;ones(length(data2),1)];
                fixationnumber = [fixationnumber; [1:length(data2)]'];
            end
        end
    end
    for SET = 1:length(postsets);
        data = alldata{2,t}(36*(SET-1)+1:SET*36,1,1,:);
        data = reshape(data,[size(data,1),size(data,4)]);
        for ii = 1:size(data,1);
            data2 = data(ii,:);
            data2(isnan(data2)) = [];
            if  ~isempty(data2)
                nms = repmat(tags{t},[length(data2),1]);
                nms = cellstr(nms);
                names = [names;nms];
                sts = repmat(postsets{SET},[length(data2),1]);
                sts = cellstr(sts);
                sets = [sets;sts];
                salvals = [salvals;data2'];
                group =[group;2*ones(length(data2),1)];
                fixationnumber = [fixationnumber; [1:length(data2)]'];
            end
        end
    end
end
psal = anovan(salvals,{names,sets,group,fixationnumber});

% 4-way ANOVA for mean Salience during a fixation
names = {};
sets = {};
salvals = [];
group = [];
fixationnumber = [];
for t = 1:length(tags)
    for SET = 1:length(presets);
        data = alldata{1,t}(36*(SET-1)+1:SET*36,1,2,:);
        data = reshape(data,[size(data,1),size(data,4)]);
        for ii = 1:size(data,1);
            data2 = data(ii,:);
            data2(isnan(data2)) = [];
            if  ~isempty(data2)
                nms = repmat(tags{t},[length(data2),1]);
                nms = cellstr(nms);
                names = [names;nms];
                sts = repmat(presets{SET},[length(data2),1]);
                sts = cellstr(sts);
                sets = [sets;sts];
                salvals = [salvals;data2'];
                group = [group;ones(length(data2),1)];
                fixationnumber = [fixationnumber; [1:length(data2)]'];
            end
        end
    end
    for SET = 1:length(postsets);
        data = alldata{2,t}(36*(SET-1)+1:SET*36,2,1,:);
        data = reshape(data,[size(data,1),size(data,4)]);
        for ii = 1:size(data,1);
            data2 = data(ii,:);
            data2(isnan(data2)) = [];
            if  ~isempty(data2)
                nms = repmat(tags{t},[length(data2),1]);
                nms = cellstr(nms);
                names = [names;nms];
                sts = repmat(postsets{SET},[length(data2),1]);
                sts = cellstr(sts);
                sets = [sets;sts];
                salvals = [salvals;data2'];
                group =[group;2*ones(length(data2),1)];
                fixationnumber = [fixationnumber; [1:length(data2)]'];
            end
        end
    end
end
psal2 = anovan(salvals,{names,sets,group,fixationnumber});

% 4-way ANOVA for Salience Contrast at a fixation
names = {};
sets = {};
salvals = [];
group = [];
fixationnumber = [];
for t = 1:length(tags)
    for SET = 1:length(presets);
        data = alldata{1,t}(36*(SET-1)+1:SET*36,2,1,:);
        data = reshape(data,[size(data,1),size(data,4)]);
        for ii = 1:size(data,1);
            data2 = data(ii,:);
            data2(isnan(data2)) = [];
            if  ~isempty(data2)
                nms = repmat(tags{t},[length(data2),1]);
                nms = cellstr(nms);
                names = [names;nms];
                sts = repmat(presets{SET},[length(data2),1]);
                sts = cellstr(sts);
                sets = [sets;sts];
                salvals = [salvals;data2'];
                group = [group;ones(length(data2),1)];
                fixationnumber = [fixationnumber; [1:length(data2)]'];
            end
        end
    end
    for SET = 1:length(postsets);
        data = alldata{2,t}(36*(SET-1)+1:SET*36,2,1,:);
        data = reshape(data,[size(data,1),size(data,4)]);
        for ii = 1:size(data,1);
            data2 = data(ii,:);
            data2(isnan(data2)) = [];
            if  ~isempty(data2)
                nms = repmat(tags{t},[length(data2),1]);
                nms = cellstr(nms);
                names = [names;nms];
                sts = repmat(postsets{SET},[length(data2),1]);
                sts = cellstr(sts);
                sets = [sets;sts];
                salvals = [salvals;data2'];
                group =[group;2*ones(length(data2),1)];
                fixationnumber = [fixationnumber; [1:length(data2)]'];
            end
        end
    end
end
psalc = anovan(salvals,{names,sets,group,fixationnumber});

% 4-way ANOVA for mean salience contrast during a fixation
names = {};
sets = {};
salvals = [];
group = [];
fixationnumber = [];
for t = 1:length(tags)
    for SET = 1:length(presets);
        data = alldata{1,t}(36*(SET-1)+1:SET*36,2,2,:);
        data = reshape(data,[size(data,1),size(data,4)]);
        for ii = 1:size(data,1);
            data2 = data(ii,:);
            data2(isnan(data2)) = [];
            if  ~isempty(data2)
                nms = repmat(tags{t},[length(data2),1]);
                nms = cellstr(nms);
                names = [names;nms];
                sts = repmat(presets{SET},[length(data2),1]);
                sts = cellstr(sts);
                sets = [sets;sts];
                salvals = [salvals;data2'];
                group = [group;ones(length(data2),1)];
                fixationnumber = [fixationnumber; [1:length(data2)]'];
            end
        end
    end
    for SET = 1:length(postsets);
        data = alldata{2,t}(36*(SET-1)+1:SET*36,2,2,:);
        data = reshape(data,[size(data,1),size(data,4)]);
        for ii = 1:size(data,1);
            data2 = data(ii,:);
            data2(isnan(data2)) = [];
            if  ~isempty(data2)
                nms = repmat(tags{t},[length(data2),1]);
                nms = cellstr(nms);
                names = [names;nms];
                sts = repmat(postsets{SET},[length(data2),1]);
                sts = cellstr(sts);
                sets = [sets;sts];
                salvals = [salvals;data2'];
                group =[group;2*ones(length(data2),1)];
                fixationnumber = [fixationnumber; [1:length(data2)]'];
            end
        end
    end
end
psalc2 = anovan(salvals,{names,sets,group,fixationnumber});

% 4-way ANOVA for image intensity at a fixation
names = {};
sets = {};
salvals = [];
group = [];
fixationnumber = [];
for t = 1:length(tags)
    for SET = 1:length(presets);
        data = alldata{1,t}(36*(SET-1)+1:SET*36,3,1,:);
        data = reshape(data,[size(data,1),size(data,4)]);
        for ii = 1:size(data,1);
            data2 = data(ii,:);
            data2(isnan(data2)) = [];
            if  ~isempty(data2)
                nms = repmat(tags{t},[length(data2),1]);
                nms = cellstr(nms);
                names = [names;nms];
                sts = repmat(presets{SET},[length(data2),1]);
                sts = cellstr(sts);
                sets = [sets;sts];
                salvals = [salvals;data2'];
                group = [group;ones(length(data2),1)];
                fixationnumber = [fixationnumber; [1:length(data2)]'];
            end
        end
    end
    for SET = 1:length(postsets);
        data = alldata{2,t}(36*(SET-1)+1:SET*36,3,1,:);
        data = reshape(data,[size(data,1),size(data,4)]);
        for ii = 1:size(data,1);
            data2 = data(ii,:);
            data2(isnan(data2)) = [];
            if  ~isempty(data2)
                nms = repmat(tags{t},[length(data2),1]);
                nms = cellstr(nms);
                names = [names;nms];
                sts = repmat(postsets{SET},[length(data2),1]);
                sts = cellstr(sts);
                sets = [sets;sts];
                salvals = [salvals;data2'];
                group =[group;2*ones(length(data2),1)];
                fixationnumber = [fixationnumber; [1:length(data2)]'];
            end
        end
    end
end
pI2 = anovan(salvals,{names,sets,group,fixationnumber});

% 4-way ANOVA for mean image intensity during a fixation
names = {};
sets = {};
salvals = [];
group = [];
fixationnumber = [];
for t = 1:length(tags)
    for SET = 1:length(presets);
        data = alldata{1,t}(36*(SET-1)+1:SET*36,3,2,:);
        data = reshape(data,[size(data,1),size(data,4)]);
        for ii = 1:size(data,1);
            data2 = data(ii,:);
            data2(isnan(data2)) = [];
            if  ~isempty(data2)
                nms = repmat(tags{t},[length(data2),1]);
                nms = cellstr(nms);
                names = [names;nms];
                sts = repmat(presets{SET},[length(data2),1]);
                sts = cellstr(sts);
                sets = [sets;sts];
                salvals = [salvals;data2'];
                group = [group;ones(length(data2),1)];
                fixationnumber = [fixationnumber; [1:length(data2)]'];
            end
        end
    end
    for SET = 1:length(postsets);
        data = alldata{2,t}(36*(SET-1)+1:SET*36,3,2,:);
        data = reshape(data,[size(data,1),size(data,4)]);
        for ii = 1:size(data,1);
            data2 = data(ii,:);
            data2(isnan(data2)) = [];
            if  ~isempty(data2)
                nms = repmat(tags{t},[length(data2),1]);
                nms = cellstr(nms);
                names = [names;nms];
                sts = repmat(postsets{SET},[length(data2),1]);
                sts = cellstr(sts);
                sets = [sets;sts];
                salvals = [salvals;data2'];
                group =[group;2*ones(length(data2),1)];
                fixationnumber = [fixationnumber; [1:length(data2)]'];
            end
        end
    end
end
pI2 = anovan(salvals,{names,sets,group,fixationnumber});
%%  
%--- ANOVA on Viewing Behavior---%
scm_image_dir = 'C:\Users\GOD-OF-ChAOS\Documents\MATLAB\Buffalo Lab-Salience Model\SCM Image Sets\';
presets = {'Set006','Set007','Set008','Set009'};
postsets = {'SetE001','SetE002','SetE003','SetE004'};
image_sets = [presets postsets];
tags = {'MP','TT','JN','IW'};


names = {};
sets = {};
group = [];
fixationnumber = [];

fixangle = [];
sacangle2 = [];
distfix = [];
durfix = [];
sacangle1 = [];
distsac = [];
dursac = [];
fixrate = [];

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
                    load(matfiles.mat{i});
                    
                    for iii = 1:36;
                        ang = anglebtwfix(iii,:);
                        ang(isnan(ang)) = [];
                        fixangle = [fixangle;ang'];
                        
                        dist = distbtwnfix(iii,:);
                        dist(isnan(dist)) = [];
                        distfix = [distfix;dist'];
                        
                        
                        fixtime = 5/1000*timebtwfix(iii,:);
                        fixtime(isnan(fixtime)) = [];
                        fixrate = [fixrate;fixtime'];
                        
%                         fixdur = fixduration(iii,:);
%                         fixdur(isnan(fixdur)) = [];
%                         durfix = [durfix;fixdur'];
%                         
%                         dist = sacdist(iii,:);
%                         dist(isnan(dist)) = [];
%                         distsac = [distsac;dist'];
%                         
%                         sac = sacangle(iii,:);
%                         sac(isnan(sac)) = [];
%                         sacangle1 = [sacangle1;sac'];
%                         
%                         sac2 = sacangle_2fix(iii,:);
%                         sac2(isnan(sac2)) = [];
%                         sacangle2 = [sacangle2;sac2'];
%                         
%                         sacdur = sacduration(iii,:);
%                         sacdur(isnan(sacdur)) = [];
%                         dursac = [dursac;sacdur'];
%                         
                        fixationnumber = [fixationnumber;[1:length(ang)]'];
                        nms = repmat(tags{ii},[length(ang),1]);
                        nms = cellstr(nms);
                        names = [names;nms];
                        sts = repmat(image_sets{SET},[length(ang),1]);
                        sts = cellstr(sts);
                        sets = [sets;sts];
                        if SET > 4
                            group = [group;2*ones(length(ang),1)];
                        else
                            group = [group;ones(length(ang),1)];
                        end
                    end
                end
            end
        end
    end
end
%%
pfixangle = anovan(fixangle,{names,group,fixationnumber})
pfixangle = anovan(fixangle,{sets,group})
pfixdist = anovan(distfix,{names,group,fixationnumber})
pfixdist = anovan(distfix,{sets,group})
pfixrate = anovan(fixrate,{names,group,fixationnumber})
pfixrate = anovan(fixrate,{sets,group})
%%
pfixdur = anovan(durfix,{names,group,fixationnumber})
pfixdur = anovan(durfix,{sets,group})
%%
psacdist = anovan(distsac,{names,group,fixationnumber})
psacdist = anovan(distsac,{sets,group})
psac1 = anovan(sacangle1,{names,group,fixationnumber})
psac1 = anovan(sacangle1,{sets,group})
psac2 = anovan(sacangle2,{names,group,fixationnumber})
psac2 = anovan(sacangle2,{sets,group})
psacdur = anovan(dursac,{names,group,fixationnumber})
psacdur = anovan(dursac,{sets,group})