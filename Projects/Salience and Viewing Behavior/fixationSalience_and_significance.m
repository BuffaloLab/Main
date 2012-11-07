function fixationSalience_and_significance(ViewingBehaviorFile,imageX,imageY,d,novelty)
% created by Seth Koenig 6/21/2012

% function determines normalized salience, salience contrast values, and image
% intensity values at the location of fixation. The function also calculates
% if fixations occur at these values at a probability greater than expected
% by chance using both a z-test and a t-test. Values are plotted as a
% function of fixation number.

% Inputs:
%   ViewingBehaviorFile: Viewing behavior data from getViewingBehavior.m
%   imageX & imageY: X and Y dimensions of the set's images
%   d: date of creation of salience maps (does not adjust if created over several days)
%   novelty: calculates statistics for novel ('none') or all ('all') trials/conditions

%Outputs:
%   1).mat file named ['FixationStatistics-' datfil(1:end-2) '-' setnum]
%   containg fixations statistics. See variable statvariablenames for
%   detailed explanation of variables in .mat file.
%   2) Plot containing mean and standard deviations normalized salience,
%   salience contrast values, and image intensity values at the location of
%   fixation in comparison to their shuffled counterparts. Stastics are
%   calculated agains entire random distribution not against individual
%   fixation numbers (some shuffled data are randomly higher than others).

if nargin < 3
    error(['Not enough inputs: function requires ViewingBehaviorFile,'...
        'imageX, imageY, d, and novelty.'])
elseif nargin < 4
    d = date;
elseif nargin < 5
    novelty = 'none';
end

if strcmp(novelty,'all')
    step = 1;
else
    step = 2;
end

dat = load(ViewingBehaviorFile);
densitymap = dat.densitymap;
rr = imageY; cc = imageX;
resized_densitymap = imresize(densitymap,[rr,cc]);
resized_densitymap = 1+100*resized_densitymap;
cnd = dat.cnd;
setnum = dat.SETNUM;
datfil = dat.datfil;
fixation = dat.fixation;
cndfil = dat.cndfil;
test0start = dat.test0start;
itmfil = dat.itmfil;
filenamestart = dat.filenamestart;
clear dat

[RF,lr,lc,density] = receptivefield(rr,cc);

SMPcorr = cell(1,length(1:step:length(cnd)));
Execorr = cell(1,length(1:step:length(cnd)));
Icorr = cell(1,length(1:step:length(cnd)));
shuffunshuff = cell(1,2); %1 for shuffled 2 for unshuffled data

for s = 1:length(shuffunshuff)
    for cndlop=1:step:length(cnd)
        
        [saliencemap exe img] = getMaps(cnd,cndlop,cndfil,test0start,...
            itmfil,resized_densitymap,RF,lr,lc,density,filenamestart);
        
        L = length(fixation{cndlop});
        SMPcorr{cndlop} = zeros(1,L);
        Execorr{cndlop} = zeros(1,L);
        Icorr{cndlop} = zeros(1,L);
        
        for i = 1:L
            if s == 1; %shuffled points
                spot = [ceil(800*rand) ceil(600*rand)]; %x,y data
            else %unshuffled
                spot = ceil(fixation{cndlop}{i});
                spot(1) = spot(1)+400;spot(2) = -spot(2)+300;%x,y data
                spot(spot < 1) = 1;
            end
            
            SMPcorr{cndlop}(i) = saliencemap(spot(2),spot(1));
            Execorr{cndlop}(i)= exe(spot(2),spot(1));
            Icorr{cndlop}(i)= img(spot(2),spot(1));
        end
    end
    shuffunshuff{s} = {SMPcorr,Execorr,Icorr};
end

shuffunshuffdata = fixationValues(shuffunshuff,step,cnd);

statistics = fixationStatisticTests(shuffunshuffdata);

figure
hold on
plot(statistics(2).CI_Sal(1,2)*ones(1,length(shuffunshuffdata{2}{4})),'--r')
plot(statistics(2).CI_Exe(1,2)*ones(1,length(shuffunshuffdata{2}{4})),'--b')
plot(statistics(2).CI_I(1,2)*ones(1,length(shuffunshuffdata{2}{4})),'--k')
errorbar(shuffunshuffdata{2}{4},shuffunshuffdata{1}{5},'r')
errorbar(shuffunshuffdata{2}{6},shuffunshuffdata{1}{7},'b')
errorbar(shuffunshuffdata{2}{8},shuffunshuffdata{1}{9},'k')
hold off
xlabel('Fixation Number')
ylabel('Normalized Value')
legend({'Chance Salience','Chance Salience Contrast',...
    'Chance Image Intensity','Salience','Salience Contrast','Image Intensity'});
title([datfil(1:2) '-' setnum])

    function [RF,lr,lc,density] = receptivefield(rr,cc)
        rfsize = 30; %diameter ~2.5 degrees
        density = rfsize/2;
        lr = 1+density:density:rr-density;
        lc = 1+density:density:cc-density;
        sig1 = 5;
        sig2 = 10; %sigma changes not a huge effect on results, RF bigger change
        [x,y] = meshgrid(-rfsize:rfsize);
        gabor1 = exp(-(x.^2 + y.^2)/(2*sig1^2));
        gabor2 = exp(-(x.^2 + y.^2)/(2*sig2^2));
        gabor1 = gabor1/sum(sum(gabor1));
        gabor2 = gabor2/sum(sum(gabor2));
        RF = gabor1-gabor2;
    end

    function [saliencemap exe img] = getMaps(cnd,cndlop,cndfil,test0start,...
            itmfil,resized_densitymap,RF,lr,lc,density,filenamestart)
        rowtouse=strmatch([ones(1,(5-length(num2str(cnd(cndlop)-1000))))*char(32) num2str(cnd(cndlop)-1000) ' '],cndfil(:,1:6));
        itm0=str2double(cndfil(rowtouse,(test0start:test0start+2)));
        
        file_match=itmfil(strmatch([ones(1,(4-length(num2str(itm0))))*char(32) num2str(itm0)],itmfil(:,1:4)),filenamestart:end-1);
        fileper = find(file_match  == '.');
        fileslash = find(file_match == '\');
        img = imread(file_match(fileslash(end)+1:end));
        img = double(rgb2gray(img));
        img= img/max(max(img));
        
        %%-----Salience Map & Salience Contrast map (exe)------%%
        load([file_match(fileslash(end)+1:fileper-1) '-saliencemap-' d '.mat'],'fullmap');
        fullmap = fullmap.*resized_densitymap;
        saliencemap = fullmap/(max(max(fullmap)));
        sal = saliencemap;
        row1=saliencemap(randi(numel(saliencemap),size(saliencemap,1),100));
        row2=saliencemap(randi(numel(saliencemap),size(saliencemap,1),100));
        sal = [row1 sal row2];
        col1=saliencemap(randi(numel(saliencemap),100,size(sal,2)));
        col2=saliencemap(randi(numel(saliencemap),100,size(sal,2)));
        sal = [col1;sal;col2];
        
        RFmap = conv2(sal,RF,'same');
        RFmap(1:100,:) = [];RFmap(end:-1:end-99,:) = []; RFmap(:,1:100) = [];RFmap(:,end:-1:end-99) = [];
        exc = zeros(length(lr),length(lc));
        for i = 1:length(lr);
            for ii = 1:length(lc);
                exc(i,ii) = sum(sum(RFmap(lr(i):lr(i)+density,...
                    lc(ii)-density:lc(ii)+density)));
            end
        end
        exc = exc - min(min(exc));
        exe = imresize(exc,[size(fullmap,1) size(fullmap,2)]);
        exe = exe/max(max(exe));
    end

    function [shuffunshuffdata] = fixationValues(shuffunshuff,step,cnd)
        for s = 1:length(shuffunshuff)
            fixSal = -1*ones(length(1:step:length(cnd)),50);
            fixExe = -1*ones(length(1:step:length(cnd)),50);
            fixI = -1*ones(length(1:step:length(cnd)),50);
            switch step
                case 2
                    for i = 1:2:length(cnd)
                        fixSal((i+1)/2,1:length(shuffunshuff{s}{1}{i})) = shuffunshuff{s}{1}{i};
                        fixExe((i+1)/2,1:length(shuffunshuff{s}{2}{i})) = shuffunshuff{s}{2}{i};
                        fixI((i+1)/2,1:length(shuffunshuff{s}{3}{i})) = shuffunshuff{s}{3}{i};
                    end
                case 1
                    for i = 1:length(cnd)
                        fixSal(i,1:length(shuffunshuff{s}{1}{i})) = shuffunshuff{s}{1}{i};
                        fixExe(i,1:length(shuffunshuff{s}{2}{i})) =shuffunshuff{s}{2}{i};
                        fixI(i,1:length(shuffunshuff{s}{3}{i})) = shuffunshuff{s}{3}{i};
                    end
            end
            
            meanfixSal = -1*ones(1,size(fixSal,2));
            stdfixSal = -1*ones(1,size(fixSal,2));
            meanfixExe = -1*ones(1,size(fixSal,2));
            stdfixExe = -1*ones(1,size(fixSal,2));
            meanfixI = -1*ones(1,size(fixSal,2));
            stdfixI = -1*ones(1,size(fixSal,2));
            for i = 1:size(fixSal,2)
                nonzeros = find(fixSal(:,i) > 0);
                if length(nonzeros) > 3
                    meanfixSal(i) = mean(fixSal(nonzeros,i));
                    stdfixSal(i) = std(fixSal(nonzeros,i))/length(nonzeros);
                    meanfixExe(i) = mean(fixExe(nonzeros,i));
                    stdfixExe(i) = std(fixExe(nonzeros,i))/length(nonzeros);
                    meanfixI(i) = mean(fixI(nonzeros,i));
                    stdfixI(i) = std(fixI(nonzeros,i))/length(nonzeros);
                end
            end
            zz = find(meanfixSal < 0);
            meanfixSal(zz) = [];
            stdfixSal(zz) = [];
            meanfixExe(zz) = [];
            stdfixExe(zz) = [];
            meanfixI(zz) = [];
            stdfixI(zz) = [];
            shuffunshuffdata{s} = {fixSal fixExe fixI meanfixSal stdfixSal ...
                meanfixExe stdfixExe meanfixI stdfixI};
        end
    end

    function statistics = fixationStatisticTests(shuffunshuffdata)
        % p < 0.05 is significant
        fixSal = shuffunshuffdata{2}{1}; fixSal = fixSal(1:end); fixSal(fixSal <= 0) = [];
        sfixSal = shuffunshuffdata{1}{1}; sfixSal = sfixSal(1:end); sfixSal(sfixSal <= 0) = [];
        
        fixExe = shuffunshuffdata{2}{2}; fixExe = fixExe(1:end); fixExe(fixExe <= 0) = [];
        sfixExe = shuffunshuffdata{1}{2}; sfixExe = sfixExe(1:end); sfixExe(sfixExe <= 0) = [];
        
        fixI = shuffunshuffdata{2}{3}; fixI = fixI(1:end); fixI(fixI <= 0) = [];
        sfixI = shuffunshuffdata{1}{3}; sfixI = sfixI(1:end); sfixI(sfixI <= 0) = [];
        
        
        % T-test of shuffled (random fixations) vs unshuffled fixation data
        [hSal,pSal,tciSal] = ttest2(fixSal,sfixSal,0.05,'right');
        [hExe,pExe,tciExe] = ttest2(fixExe,sfixExe,0.05,'right');
        [hI,pI,tciI] = ttest2(fixI,sfixI,0.05,'right'); % p < 0.05 is significant
        
        % z-test of means agains random distributions assuming mean is larger
        zpSal = zeros(1,length(shuffunshuffdata{2}{4}));
        zpExe = zeros(1,length(shuffunshuffdata{2}{6}));
        zpI = zeros(1,length(shuffunshuffdata{2}{8}));
        ciSal = zeros(length(shuffunshuffdata{2}{4}),2);
        ciExe = zeros(length(shuffunshuffdata{2}{6}),2);
        ciI = zeros(length(shuffunshuffdata{2}{8}),2);
        sfixSal = shuffunshuffdata{1}{1}; sfixSal = sfixSal(1:end); sfixSal(sfixSal <= 0) = [];
        sfixExe = shuffunshuffdata{1}{2}; sfixExe = sfixExe(1:end); sfixExe(sfixExe <= 0) = [];
        sfixI = shuffunshuffdata{1}{3}; sfixI = sfixI(1:end); sfixI(sfixI <= 0) = [];
        for i = 1:length(shuffunshuffdata{2}{4});
            [h p ci] = ztest(sfixSal,shuffunshuffdata{2}{4}(i),std(sfixSal)...
                ,0.05,'left');
            zpSal(i) = p;
            ciSal(i,:) = ci;
            [h p ci] = ztest(sfixExe,shuffunshuffdata{2}{6}(i),std(sfixExe),...
                0.05,'left');
            zpExe(i) = p;
            ciExe(i,:) = ci;
            [h p ci] = ztest(sfixI,shuffunshuffdata{2}{8}(i),std(sfixI),...
                0.05,'left');
            zpI(i) = p;
            ciI(i,:) = ci;
        end
        statistics = struct('test',{'t-test','z-test'},'Mean_Sal_Salience',mean(fixSal),...
            'Mean_Salience_Contrast_Exe',mean(fixExe),'Mean_Image_Intensity',mean(fixI),...
            'Sal_p_values',[pSal {zpSal}],'Exe_p_values',[pExe {zpExe}],'I_p_values',...
            [pI {zpI}],'CI_Sal',[{tciSal} {ciSal}],'CI_Exe',[{tciExe} {ciExe}],...
            'CI_I',[{tciI} {ciI}]);
    end

statvariablenames = {
    'linearshuffunsuff: cell arrray containing shuffled and unshuffled values';
    'of the salience, salience contrast, and image intensity at fixations, respectively.';
    'Each cell has values fixSal fixExe fixI meanfixSal stdfixSal meanfixExe...';
    'stdfixExe meanfixI stdfixI]';
    ' ';
    'fixSal,meanfixSal,stdfixSal: salience values at fixation points as function of fixation#';
    'fixExe,meanExe,stdExe: salience contrast values at fixation points as function of fixation #';
    'fixI, meanI,stdI: image intensity values at fixation points as function of fixation #';
    ' ';
    'statistics: structure with results from t-test and z-test to determine if fixations';
    'occur at salience, salience contrasts, and image intesntisy valeus at rates higher than chance';
    };

save(['FixationStatistics-' datfil(1:end-2) '-' setnum],...
    'shuffunshuffdata','statistics','statvariablenames')
end