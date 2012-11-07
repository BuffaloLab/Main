function PredictionsDistanceMeasures(ViewingBehaviorFile,imageX,imageY,d,novelty,plotoptions)
load(ViewingBehaviorFile,'fixation','SETNUM','datfil','cnd','densitymap')

if strcmpi(novelty,'all')
    step = 1;
else
    step = 2;
end

conditions = cnd(1:step:end); %#ok<COLND>
numcnd = length(conditions);
Randompairings = cell(1,numcnd);
Randomdistances = cell(1,numcnd);
Salpairings = cell(1,numcnd);
Saldistances = cell(1,numcnd);
Exepairings = cell(1,numcnd);
Exedistances = cell(1,numcnd);
BCRWpairings = cell(1,numcnd);
BCRWdistances = cell(1,numcnd);

rr = imageY; cc = imageX;
[RF,lr,lc,density] = receptivefield(rr,cc);
resized_densitymap = imresize(densitymap,[rr,cc]);
resized_densitymap = 1+100*resized_densitymap;

for cndlop = 1:step:length(cnd)
    
    imagenumber = (cndlop+1)/2;
    fixes = fixation{cndlop};
    
    load([num2str(imagenumber) '-saliencemap-' d '.mat'],'fullmap')
    [pairs distances] = DistanceandPairCalcs(fullmap,fixes,imageX,imageY,2*density);
    Salpairings{cndlop} = pairs;
    Saldistances{cndlop} = distances;
    
    
    RFmap = imfilter(resized_densitymap.*fullmap,RF,'replicate');
    exc = zeros(length(lr),length(lc));
    for ri = 1:length(lr);
        for ii = 1:length(lc);
            exc(ri,ii) = sum(sum(RFmap(lr(ri):lr(ri)+density,...
                lc(ii)-density:lc(ii)+density)));
        end
    end
    exc = exc - min(min(exc));
    exe = imresize(exc,[size(fullmap,1) size(fullmap,2)]);
    exe = exe/max(max(exe));
    [pairs distances] = DistanceandPairCalcs(exe,fixes,imageX,imageY,2*density);
    Exepairings{cndlop} = pairs;
    Exedistances{cndlop} = distances;
    
    
    load(['BCRW-' datfil(1:end-2) '-' SETNUM '-' num2str(imagenumber) '.mat'],'fixations')
    [pairs distances] = DistanceandPairCalcs(fixations,fixes,imageX,imageY,2*density);
    BCRWpairings{cndlop} = pairs;
    BCRWdistances{cndlop} = distances;
    
    [pairs distances] = DistanceandPairCalcs('Random',fixes,imageX,imageY,2*density);
    Randompairings{cndlop} = pairs;
    Randomdistances{cndlop} = distances;
end

numL = sum(cellfun(@numel,Randomdistances));
RandomDistances = zeros(1,numL);
SalDistances = zeros(1,numL);
ExeDistances = zeros(1,numL);
BCRWDistances = zeros(1,numL);
index = 0;
for ind = 1:length(Randomdistances);
    L = length(Randomdistances{ind});
    RandomDistances(ind+1:ind+L) = Randomdistances{ind}';
    SalDistances(ind+1:ind+L) = Saldistances{ind}';
    ExeDistances(ind+1:ind+L) = Exedistances{ind}';
    BCRWDistances(ind+1:ind+L) = BCRWdistances{ind}';
    index = index + L;
end

statistics = stattests(SalDistances,ExeDistances,BCRWDistances,RandomDistances);

if strcmpi(plotoptions,'stats')
    figure
    hold on
    errorbar(1,mean(RandomDistances),std(RandomDistances),'xr','markersize',10,'linewidth',3)
    errorbar(2,mean(SalDistances),std(SalDistances),'og','markersize',10,'linewidth',3)
    errorbar(3,mean(ExeDistances),std(SalDistances),'db','markersize',10,'linewidth',3)
    errorbar(4,mean(BCRWDistances),std(SalDistances),'+k','markersize',10,'linewidth',3)
    plot(1,RandomDistances,'xr')
    plot(2,SalDistances,'og')
    plot(3,ExeDistances,'db')
    plot(4,BCRWDistances,'+k')
    legend({'Random','Salience','Salience Contrast','BCRW'})
    ylabel('Distances from Fixation and Predicted Fixations')
    yylim = ylim;
    ylim([0 yylim(2)]);
end


save(['FixationDistanceStatistics' datfil(1:end-2) '-' SETNUM '.mat'],'RandomDistances',...
    'ExeDistances','SalDistances','BCRWDistances','statistics')

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

    function [pairs distances] = DistanceandPairCalcs(map,fixes,imageX,imageY,downsizefactor)
        if strcmpi(map,'Random');
            positions = zeros(length(fixes),2); %[y x]
            yx = zeros(length(fixes),2); %[y x]
            for it = 1:length(fixes)
                positions(it,:) = [ceil(rand*imageY) ceil(rand*imageX)];
                spot = ceil(fixes{it});
                spot(1) = spot(1)+400;spot(2) = -spot(2)+300;
                yx(it,:) = [spot(2) spot(1)];
            end
        else
            resizedmap = imresize(map,[imageY/downsizefactor imageX/downsizefactor]);
            positions = zeros(length(fixes),2); %[y x]
            yx = zeros(length(fixes),2); %[y x]
            for it = 1:length(fixes)
                if sum(resizedmap) ~= 0
                    [i j] = find(resizedmap == max(max(resizedmap)));
                    positions(it,:) = [i*downsizefactor-downsizefactor/2 j*downsizefactor-downsizefactor/2];
                    spot = ceil(fixes{it});
                    spot(1) = spot(1)+400;spot(2) = -spot(2)+300;
                    yx(it,:) = [spot(2) spot(1)];
                end
            end
        end
        pairs = zeros(size(yx,1),4);
        distances = zeros(size(yx,1),1);
        cnt = 1;
        while ~isempty(yx) %finds the minimum distance between pairs
            %(relatively fast, but may not be optimum solution)
            N=size(yx,1);
            [x y]=meshgrid(1:N);
            i=find(ones(N));
            i=[x(i) y(i)];
            dist =sqrt( (yx(i(:,1),1) - positions(i(:,2),1)).^2 +...
                (yx(i(:,1),2) - positions(i(:,2),2)).^2 );
            [dmin imin]=min(dist);
            pairs(cnt,:) = [positions(i(imin,2),:) yx(i(imin,1),:)];
            distances(i) = dmin;
            positions(i(imin,2),:) = [];
            yx(i(imin,2),:)= [];
            cnt = cnt+1;
        end
    end

    function [statistics] = stattests(SalDistances,ExeDistances,BCRWDistances,RandomDistances)
        vars = {'SalDistances','ExeDistances','BCRWDistances','RandomDistances'};
        statistics.h = cell(4,4);
        statistics.ci = cell(4,4);
        statistics.p = cell(4,4);
        [x y] = meshgrid(1:4);
        tests = ones(4)-eye(4);
        i = find(tests);
        i = [x(i) y(i)];
        for ti = 1:size(i,1);
            [h p c] = ttest2(eval(vars{i(ti,1)}),eval(vars{i(ti,2)}),0.05);
            statistics.h{i(ti,1),i(ti,2)} = h;
            statistics.ci{i(ti,1),i(ti,2)}= c;
            statistics.p{i(ti,1),i(ti,2)}= p;
        end
    end
end