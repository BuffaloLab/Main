function SalienceIOR(FIXATIONFILE,distthresh,imageX,imageY,pairings)
% created by Seth Koenig 11/21/2012

% function determines rate of return fixations, the time between return
% fixations, time within trial of return, and salience at returned
% location. Inhibition of return was considered for mean fixation postions
% occruing within 0.5 dva of each other non-consequitively

% Inputs:
%   FIXATIONFILE: Fixations extracted from cortex e.g. MP120606_1-fixation.mat
%   ImageX,ImageY: x and y dimensions of images
%   Pairings: take all pairing or only closest unique pairing between first
%   and second fixation


%Outputs:
%   A .mat file named [FIXATIONFILE(1:end-13) '-SalienceIOR']
%   containg saccade statistics. See variable statvariablenames for
%   detailed explanation of variables in .mat file.

if nargin < 2
    error(['Not enough inputs: function requires FixationFile,'...
        'distance threhsold,imageX, imageY, and pairings.'])
end
if nargin < 4
    imageX = 800;
    imageY = 600;
end
    
if nargin < 5
    pairings = 'all';
end

load(FIXATIONFILE);
matfiles = what;
saliencemapfiles = [NaN;NaN];
for i = 1:length(matfiles.mat);
    str = strfind(matfiles.mat{i},'saliencemap');
    if ~isempty(str)
        dash = strfind(matfiles.mat{i},'-');
        saliencemapfiles = [saliencemapfiles [i;str2num(matfiles.mat{i}(1:dash(1)-1))]];
    end
end
saliencemapfiles(:,1) = [];
[~, si] = sort(saliencemapfiles(2,:));
saliencemapfiles = si;
totaluniquereturns = 0;
totalfixs = 0;
returns = 0;
returnfixsal = NaN(2500,11); %fix1x fix1y fix1t fix1sal fix2x fix2y fix2t fix2sal fixdist
IORfixsal = NaN(1,2500);
fixdur = NaN(1,2500);
fixcount1 = 0;
fixcount2 = 0;
for cndlop=1:2:length(fixationstats)
    reindexed = (cndlop+1)/2;
    load(matfiles.mat{saliencemapfiles(reindexed)},'fullmap');
    saliencemap = fullmap;
    fixations = fixationstats{cndlop}.fixations;
    fixationtimes = fixationstats{cndlop}.fixationtimes;
    if fixations(1,1) > imageX/2-100 && fixations(1,1) < imageX/2+100 &&...
            fixations(2,1) < imageY/2+100 && fixations(2,1) > imageY/2-100
        fixations(:,1) = [];
        fixationtimes(:,1) = [];
    end
    totalfixs = totalfixs + size(fixations,2);
    N=size(fixations,2);
    [x y]=meshgrid(1:N);
    i=find(ones(N)-eye(N)); %forms pairs except for self-pairing
    i=[x(i) y(i)];
    i(i(:,1) > i(:,2),:) = []; %repeat pairs
    i(i(:,1)+1 == i(:,2),:) = []; %removes consecutive in time pairs
    dist =sqrt((fixations(1,i(:,1))-fixations(1,i(:,2))).^2 +...
        (fixations(2,i(:,1))-fixations(2,i(:,2))).^2);
    returns = find(dist >= distthresh(1) & dist <= distthresh(2));
    returnfixind = i(returns,1);
    if ~strcmpi(pairings,'all')
        tempind = [];
        for ii = 1:length(returnfixind);
            ind = returnfixind(ii);
            indr = find(returnfixind == ind);
            indr(indr == ii) = [];
            if ~isempty(indr)
                dists = [dist(returns(ii)) dist(returns(indr))];
                [~, mind] = min(dists);
                if mind == 1;
                    tempind = [tempind returns(ii)];
                else
                    tempind = [tempind returns(indr(mind-1))];
                end
            else
                tempind = [tempind returns(ii)];
            end
        end
        returns = unique(tempind);
        returnfixind = i(returns,2);
        tempind = [];
        temp = NaN(1,2);
        for ii = 1:length(returnfixind);
            ind = returnfixind(ii);
            indr = find(returnfixind == ind);
            indr(indr == ii) = [];
            if ~isempty(indr)
                dists = [dist(returns(ii)) dist(returns(indr))];
                [~, mind] = min(dists);
                if mind == 1;
                    tempind = [tempind returns(ii)];
                else
                    tempind = [tempind returns(indr(mind-1))];
                end
            else
                tempind = [tempind returns(ii)];
            end
        end
        temp(1,:) = [];
        temp = unique(temp,'rows');
        returns = unique(tempind);
        temp = [];
        for ii = 1:length(returns);
            initpos= fixations(:,i(returns(ii),1));
            for iii = 1:(i(returns(ii),2)-i(returns(ii),1))
                nextpos = fixations(:,i(ii,1)+iii);
                leftdist = sqrt(sum((nextpos-initpos).^2));
                if leftdist > 24*10
                    temp = [temp;returns(ii)];
                    break
                end
            end
        end
        returns = temp;
        returnfixind = i(returns,1);
    end
    totaluniquereturns = totaluniquereturns + length(unique(returnfixind));
    for ii = 1:N;
        if any(any(ii == i(returns,:)));
            ind = find(ii == i(returns,2));
            for iii = 1:length(ind)
                fixcount1 = fixcount1+1;
                pair = [i(returns(ind(iii)),1) i(returns(ind(iii)),2)];
                spot = [ceil(fixations(:,pair(1))) ceil(fixations(:,pair(2)))];
                spot(2,:) = imageY-spot(2,:);
                spott = [mean(fixationtimes(1,pair(1)):fixationtimes(1,pair(1)))...
                    mean(fixationtimes(1,pair(2)):fixationtimes(1,pair(2)))];
                spot(spot < 1) = 1;
                spot(1,spot(1,:) > imageX) = imageX;
                spot(2,spot(2,:) > imageY) = imageY;
                returnfixsal(fixcount1,:) = [...
                    spot(1,1) spot(2,1) spott(1) saliencemap(spot(2,1),spot(1,1))...
                    spot(1,2) spot(2,2) spott(2) saliencemap(spot(2,2),spot(1,2))...
                    dist(returns(ind(iii))) fixationtimes(2,pair(1))-fixationtimes(1,pair(1))...
                    fixationtimes(2,pair(2))-fixationtimes(1,pair(2))];
                %fix1x fix1y fix1t fix1sal fix2x fix2y fix2t fix2sal
                %fixdist fix1dur fix2dur
            end
        else
            fixcount2 = fixcount2 + 1;
            spot = ceil(fixations(:,ii));
            spot(2) = imageY-spot(2);
            spot(1,spot(1) > imageX) = imageX;
            spot(2,spot(2) > imageY) = imageY;
            spot(spot < 1) = 1;
            IORfixsal(fixcount2) = saliencemap(spot(2),spot(1));
            fixdur(fixcount2) = diff(fixationtimes(:,ii));
        end
    end
end
returnfixsal(fixcount1+1:end,:) = [];
IORfixsal(fixcount2+1:end) = [];
fixdur(fixcount2+1:end) = [];

IORvariablenames = {
    'totalfixs: total number of fixations for a behavioral file';
    'returnfixsal: [fix1x fix1y fix1t fix1sal fix2x fix2y fix2t fix2sal fixdist fix1dur fix2dur]';
    'allfixdur: duration of all non-return fixations';
    'where fix is fixation, 1 or 2 is the fixation number in the pair of fixations';
    'that are within 2 dva of each other, fix#t is the time of the fixation,';
    'and fixdist is the distance between the pair of fixations';
    'IORfixsal: salience at fixations without a return';
    'totaluniquereturns: total unique fixations that had returns'
    };

save([FIXATIONFILE(1:end-13) '-SalienceIOR'],'totalfixs','returnfixsal',...
    'IORfixsal','totaluniquereturns','IORvariablenames','fixdur')
end