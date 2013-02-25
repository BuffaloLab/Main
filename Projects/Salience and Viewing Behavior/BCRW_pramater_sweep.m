%% sweep through parameters to get best fit using kl divergence
% code as below is about 90,000 simulations so it will take approximately 1
% week to run on a standard computer. You want to create Directories for
% each set of parameters for each image set to speed up saving of files.
% Previously saved all the files and then moved them. Second part/cell does
% analysis

% Requires: function run_BCRWCF_param_sweep

tic
scm_image_dir = 'c:\users\god-of-chaos\documents\matlab\buffalo lab-salience model\scm image sets\';
bcrw_param_sweepdir = [scm_image_dir 'bcrw parameter sweeps\'];
image_sets = {'Set006','Set007','Set008','Set009',...
    'SetE001','SetE002','SetE003','SetE004'};
for set = 1:length(image_sets), mkdir(image_sets{set}),end
tags = {'MP','TT','JN','IW'};

combinedbehaviorfile = ['c:\users\god-of-chaos\documents\matlab\buffalo lab-salience model\scm image sets'...
    '\combinedviewingbehavior.mat'];
load(combinedbehaviorfile,'allview')
imagex = 800; imagey = 600;
plotoptions.runs = 'none';
plotoptions.probdens = 'none';
plotoptions.type = 'sal';

ior_areas = [0 1 2 5 10]*24; %1 dva to 24 pixels
ior_taus = [0 [40:-5:25 20:-2:12 10:-1:1].^-1];%[0 0.25 0.5 0.75 1];
border_buffers = [1 10 25 50 100];
border_sacdists = [10 25 50 100 200];

for ia = 3%1:length(ior_areas)
    for it = 15:length(ior_taus)
        for bb = 4%1:length(border_buffers)
            for bs = 4%1:length(border_sacdists)
                for set = 1:length(image_sets);
                    setnum = image_sets{set};
                    cd([scm_image_dir setnum])
                    
                    matfiles = what;
                    saliencemapfiles = [nan;nan];
                    for i = 1:length(matfiles.mat);
                        str = strfind(matfiles.mat{i},'saliencemap.mat');
                        if ~isempty(str)
                            dash = strfind(matfiles.mat{i},'-');
                            saliencemapfiles = [saliencemapfiles [i;str2num(matfiles.mat{i}(1:dash(1)-1))]];
                        end
                    end
                    saliencemapfiles(:,1) = [];
                    [~,si] = sort(saliencemapfiles(2,:));
                    saliencemapfiles = si;
                    
                    for i = 1:length(saliencemapfiles)
                        for t = 1:length(tags)
                            disp([tags{t} '-' num2str(i) '-ia_' num2str(ior_areas(ia)) '-it_' ...
                                num2str(100*ior_taus(it)) 'bb_' num2str(border_buffers(bb))...
                                '-bs_' num2str(border_sacdists(bs))])
                            run_BCRWCF_param_sweep(allview{t},matfiles.mat{saliencemapfiles(i)},...
                                tags{t},imagex,imagey,plotoptions,ior_areas(ia),ior_taus(it),...
                                border_buffers(bb),border_sacdists(bs),[bcrw_param_sweepdir image_sets{set}]);
                        end
                    end
                end
            end
        end
    end
end
%%
tic
dir = 'c:\users\god-of-chaos\documents\matlab\buffalo lab-salience model\scm image sets';
dir1 = [dir '\bcrw parameter sweeps\SetE004\'];
scm_image_dir = 'c:\users\god-of-chaos\documents\matlab\buffalo lab-salience model\scm image sets\';
image_sets = {'Set006','Set007','Set008','Set009',...
    'SetE001','SetE002','SetE003','SetE004'};
tags = {'MP','TT','JN','IW'};
binsize = 25;
f = fspecial('gaussian',[256,256],24);
imagex = 800; imagey = 600;

ior_areas = 48;%[0 1 2 5 10]*24; %1 dva to 24 pixels
ior_taus = [0 [40:-5:25 20:-2:12 10:-1:1].^-1];%[0 0.25 0.5 0.75 1];
border_buffers = 50;%[1 10 25 50 100];
border_sacdists = 100;%[10 25 50 100 200];

kl_distances = zeros(length(ior_areas),length(ior_taus),length(border_buffers),length(border_sacdists));
num_distance = zeros(length(ior_areas),length(ior_taus),length(border_buffers),length(border_sacdists));

for set = 1:length(image_sets);
    cd([scm_image_dir image_sets{set}])
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
    
    for i = 1:36
        disp(['salmap-' num2str(i)])
        for ia = 1:length(ior_areas)
            for it = 1:length(ior_taus)
                for bb = 1:length(border_buffers)
                    for bs = 1:length(border_sacdists)
                        allfixations = zeros(imagey,imagex);
                        allbcrw = zeros(imagey,imagex);
                        n = 0;
                        for t = 1:length(tags)
                            load(matfiles.mat{eyedatafiles(t)})
                            fixations = fixationstats{i*2-1}.fixations;
                            fixationtimes = fixationstats{i*2-1}.fixationtimes;
                            if fixations(1,1) > imagex/2-100 && fixations(1,1) < imagex/2+100 &&...
                                    fixations(2,1) < imagey/2+100 && fixations(2,1) > imagey/2-100
                                fixations(:,1) = [];
                                fixationtimes(:,1) = [];
                            end
                            fixations =round(fixations);
                            fixations(2,:) = imagey - fixations(2,:);
                            fixations(fixations < 1) = 1;
                            fixations(1,fixations(1,:) > imagex) = imagex;
                            fixations(2,fixations(2,:) > imagey) = imagey;
                            ind = sub2ind(size(allfixations),fixations(2,:),fixations(1,:));
                            allfixations(ind) = allfixations(ind)+1;
                            try
                                file = [dir1 tags{t} '-' num2str(i) '-bcrw'...
                                    '-ia_' num2str(ior_areas(ia)) '-it_' num2str(100*ior_taus(it))...
                                    'bb_' num2str(border_buffers(bb))...
                                    '-bs_' num2str(border_sacdists(bs)) '.mat'];
                                load(file,'fixations')
                                n = n+1;
                            catch
                                try
                                    file = [dir2 tags{t} '-' num2str(i) '-bcrw'...
                                        '-ia_' num2str(ior_areas(ia)) '-it_' num2str(100*ior_taus(it))...
                                        'bb_' num2str(border_buffers(bb))...
                                        '-bs_' num2str(border_sacdists(bs)) '.mat'];
                                    load(file,'fixations')
                                    n = n+1;
                                catch
                                    break
                                end
                            end
                            allbcrw = allbcrw + fixations;
                        end
                        if n == 4
                            allfixations = imfilter(allfixations,f);
                            binfixations = bin2(allfixations,binsize,binsize);
                            binfixations = binfixations/sum(sum(binfixations));
                            binfixations(binfixations == 0) = eps;
                            allbcrw = imfilter(allbcrw,f);
                            binbcrw = bin2(allbcrw,binsize,binsize);
                            binbcrw = binbcrw/sum(sum(binbcrw));
                            binbcrw(binbcrw == 0) = eps;
                            kld = sum(sum(log2(binfixations./binbcrw).*binfixations))...
                                +sum(sum(log2(binbcrw./binfixations).*binbcrw));
                            kl_distances(ia,it,bb,bs) = kl_distances(ia,it,bb,bs)+kld;
                            num_distance(ia,it,bb,bs) = num_distance(ia,it,bb,bs)+1;
                        end
                    end
                end
            end
        end
    end
end
avgkl = kl_distances./num_distance;
save(['c:\users\god-of-chaos\documents\matlab\buffalo lab-salience model\scm image sets\'...
    'bcrwparamsweepresults-ior_taus-only.mat'])
toc

figure
plot(ior_taus,avgkl)
xlabel('IOR_{tau} (recovery rate-inverse of number of fixations')
ylabel('KL Divergence (Bits)')
set(gca,'XTick',1:length(ior_taus))
set(gca,'XTickLabel',num2str(ior_taus'))