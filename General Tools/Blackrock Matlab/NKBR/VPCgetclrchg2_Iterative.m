function [x, y, CAL] = VPCgetclrchg2_Iterative(datfil,eog,mrk)
% function [x, y, CAL] = VPCgetclrchg2_Iterative(datfil)
%
% Color-Change Calibration Using
% Iterative Outlier Trial Removal
%
% 1. first remove mean value outlier trials
% 2. calibrate by removing 2 bad locations
% optional second round:
%   3. recalibrate by removing both mean outlier trials
%    and outliers in terms of radial distance from the calibration points
%   4. again remove 2 bad locations
%
% Nathan Killian 111218
dosecondround   = 1;% do the second iteration based on radial distance
pval1 = 0.025;pval2 = 0.05;% p-values for removing outliers
numbad1 = 2;numbad2 = 1;%how many of the nine points to consider as outliers

if nargin < 3,
    header = getnexheader(datfil);
    smpfrq = header.varheader(end-2).wfrequency;
    mrk    = getnexmrk(header,smpfrq);
elseif isempty(mrk)
    header = getnexheader(datfil);
    smpfrq = header.varheader(end-2).wfrequency;
    mrk    = getnexmrk(header,smpfrq);
else
   disp('VPCgetclrchg2_Iterative: using supplied mrk struct')
%    mrk
end

perdef = 'VPCpermrkclrchg2';
[per]  = feval(perdef,mrk);
numrpt = size(per,2);
for k = 1:numrpt
    lt(k)=per(k).endsmpind-per(k).begsmpind;
    cnd(k)=per(k).cnd;
end
if nargin < 2
    dat=proeyedat(header,per,smpfrq);
    global eyedat
    eyedat = dat;
else
%     per
    for k = 1:length(per)
        dat.trial{k} = eog(:,per(k).begsmpind:per(k).endsmpind);
    end
end
[cndsrt,indx]=sort(cnd,2,'ascend');%sort in order of the 9 clrchng cnds
trlsrt=dat.trial(indx);

%% DO A CALIBRATION WITH ALL OF THE DATA
usealldata      = 1;% IGNORE ALL TRIAL REMOVAL
clear meanx meany xcell ycell badind x y
for k=1:size(trlsrt,2) %1:num trials
    meanx(k)=mean(trlsrt{k}(1,:));
    meany(k)=mean(trlsrt{k}(2,:));
    %     varx(k)=var(trlsrt{k}(1,:));
    %     vary(k)=var(trlsrt{k}(2,:));
end

% REMOVE OUTLIERS BASED ON MEANS
% DO THIS FOR EACH POINT TYPE
badxind = [];badyind = [];
for i=1:9;
    cndind=find(cndsrt==1000+i);
    if usealldata
        xcell{i} = meanx(cndind);
        ycell{i} = meany(cndind);
    else
        [xcell{i} Dx] = rmoutlierspval(meanx(cndind),pval1,0);
        badx{i} = cndind(Dx.outliers);
        badxind = [badxind badx{i}];
        [ycell{i} Dy] = rmoutlierspval(meany(cndind),pval1,0);
        bady{i} = cndind(Dy.outliers);
        badyind = [badyind bady{i}];
    end
end
badind = unique([badxind badyind]);

% GET THE MEANS
for i=1:9;
    x(i)=mean(xcell{i});
    y(i)=mean(ycell{i});
end
if any(isnan(x)|isnan(y)),error('removed too many trials, can recode to avoid this');end
% DO INITIAL CALIBRATION
xaxind = [1 2 5 6 9];yaxind = [1 3 4 7 8];
meanxorigin = mean(x(xaxind));
meanyorigin = mean(y(yaxind));
xcal = mean([(x(8)-meanxorigin)/6 (x(4)-meanxorigin)/3 (abs(x(3)-meanxorigin))/3 (abs(x(7)-meanxorigin))/6],2);
ycal = mean([(y(6)-meanyorigin)/6 (y(2)-meanyorigin)/3 (abs(y(5)-meanyorigin))/3 (abs(y(9)-meanyorigin))/6],2);
X_offset = meanxorigin;X_slope  = xcal;Y_offset = meanyorigin;Y_slope  = ycal;
CAL = [X_offset Y_offset 1/X_slope 1/Y_slope];
xorig = x;yorig = y;
x = (x - CAL(1)).*CAL(3);
y = (y - CAL(2)).*CAL(4);
% NOW SOME POINTS WILL STILL BE OFF, FIND THESE AND RECALIBRATE WITHOUT
% THEM TO IMPROVE THE ESTIMATE, remove 2 of 9 (hard coded with the 'ends')
xdes = [0 0 -3 3  0 0 -6 6  0];
ydes = [0 3  0 0 -3 6  0 0 -6];
err  = sqrt([(x-xdes).^2+(y-ydes).^2]/2);
[dum ind] = sort(err);
if numbad2 & ~usealldata
    badpts = ind(end-numbad1+1:end);%the bad calibration points (1-9)
else
    badpts = [];
end
meanxorigin = mean(xorig(setdiff(xaxind,badpts)));
meanyorigin = mean(yorig(setdiff(yaxind,badpts)));
xnext = 1;ynext = 1;xcalvals = [];ycalvals = [];
badpts2 = unique([badpts 1]);
for k = 1:length(xdes)
    if ismember(k,badpts2),continue;end
    if ismember(k,yaxind)
        xcalvals(xnext) = (xorig(k)-meanxorigin)/xdes(k);
        xnext = xnext+1;
    elseif ismember(k,xaxind)
        ycalvals(ynext) = (yorig(k)-meanyorigin)/ydes(k);
        ynext = ynext+1;
    end
end
xcal = mean(xcalvals);
ycal = mean(ycalvals);
X_offset = meanxorigin;X_slope  = xcal;Y_offset = meanyorigin;Y_slope  = ycal;
CAL0 = [X_offset Y_offset 1/X_slope 1/Y_slope]
x0 = (xorig - CAL0(1)).*CAL0(3);
y0 = (yorig - CAL0(2)).*CAL0(4);

RMSE0 = sqrt(mean([(x0-xdes).^2 (y0-ydes).^2]))

%% DO A CALIBRATION WITH INITIAL TRIAL REMOVAL
usealldata = 0;
clear meanx meany xcell ycell badind x y
for k=1:size(trlsrt,2) %1:num trials
    meanx(k)=mean(trlsrt{k}(1,:));
    meany(k)=mean(trlsrt{k}(2,:));
    %     varx(k)=var(trlsrt{k}(1,:));
    %     vary(k)=var(trlsrt{k}(2,:));
end

% REMOVE OUTLIERS BASED ON MEANS
% DO THIS FOR EACH POINT TYPE
badxind = [];badyind = [];
for i=1:9;
    cndind=find(cndsrt==1000+i);
    if usealldata
        xcell{i} = meanx(cndind);
        ycell{i} = meany(cndind);
    else
        [xcell{i} Dx] = rmoutlierspval(meanx(cndind),pval1,0);
        badx{i} = cndind(Dx.outliers);
        badxind = [badxind badx{i}];
        [ycell{i} Dy] = rmoutlierspval(meany(cndind),pval1,0);
        bady{i} = cndind(Dy.outliers);
        badyind = [badyind bady{i}];
    end
end
badind = unique([badxind badyind]);

% GET THE MEANS
for i=1:9;
    x(i)=mean(xcell{i});
    y(i)=mean(ycell{i});
end
if any(isnan(x)|isnan(y)),error('removed too many trials, can recode to avoid this');end
% DO INITIAL CALIBRATION
xaxind = [1 2 5 6 9];yaxind = [1 3 4 7 8];
meanxorigin = mean(x(xaxind));
meanyorigin = mean(y(yaxind));
xcal = mean([(x(8)-meanxorigin)/6 (x(4)-meanxorigin)/3 (abs(x(3)-meanxorigin))/3 (abs(x(7)-meanxorigin))/6],2);
ycal = mean([(y(6)-meanyorigin)/6 (y(2)-meanyorigin)/3 (abs(y(5)-meanyorigin))/3 (abs(y(9)-meanyorigin))/6],2);
X_offset = meanxorigin;X_slope  = xcal;Y_offset = meanyorigin;Y_slope  = ycal;
CAL = [X_offset Y_offset 1/X_slope 1/Y_slope];
xorig = x;yorig = y;
x = (x - CAL(1)).*CAL(3);
y = (y - CAL(2)).*CAL(4);
% NOW SOME POINTS WILL STILL BE OFF, FIND THESE AND RECALIBRATE WITHOUT
% THEM TO IMPROVE THE ESTIMATE, remove 2 of 9 (hard coded with the 'ends')
xdes = [0 0 -3 3  0 0 -6 6  0];
ydes = [0 3  0 0 -3 6  0 0 -6];
err  = sqrt([(x-xdes).^2+(y-ydes).^2]/2);
[dum ind] = sort(err);
if numbad2 & ~usealldata
    badpts = ind(end-numbad1+1:end);%the bad calibration points (1-9)
else
    badpts = [];
end
meanxorigin = mean(xorig(setdiff(xaxind,badpts)));
meanyorigin = mean(yorig(setdiff(yaxind,badpts)));
xnext = 1;ynext = 1;xcalvals = [];ycalvals = [];
badpts2 = unique([badpts 1]);
for k = 1:length(xdes)
    if ismember(k,badpts2),continue;end
    if ismember(k,yaxind)
        xcalvals(xnext) = (xorig(k)-meanxorigin)/xdes(k);
        xnext = xnext+1;
    elseif ismember(k,xaxind)
        ycalvals(ynext) = (yorig(k)-meanyorigin)/ydes(k);
        ynext = ynext+1;
    end
end
xcal = mean(xcalvals);
ycal = mean(ycalvals);
X_offset = meanxorigin;X_slope  = xcal;Y_offset = meanyorigin;Y_slope  = ycal;
CAL1 = [X_offset Y_offset 1/X_slope 1/Y_slope]
x1 = (xorig - CAL1(1)).*CAL1(3);
y1 = (yorig - CAL1(2)).*CAL1(4);

RMSE1 = sqrt(mean([(x1-xdes).^2 (y1-ydes).^2]))

% SECOND ROUND OF OUTLIER REMOVAL BASED ON EUCLIDEAN DISTANCE FROM ESTIMATED POINTS
% =======================================================================
if dosecondround & ~usealldata
    clear meanx meany xcell ycell x y
    trlsrt(badind) = [];cndsrt(badind) = [];%first time that badind is used
    trlsrt0 = trlsrt;%BAD REMOVED, BUT NOT CALIBRATED!
    %calibrate all eye data, using the 2nd calibration values
    for k = 1:length(trlsrt)
        trlsrt{k}(1,:) = (trlsrt{k}(1,:) - CAL1(1))*CAL1(3);
        trlsrt{k}(2,:) = (trlsrt{k}(2,:) - CAL1(2))*CAL1(4);
    end
    
    for k=1:size(trlsrt,2) %1:num trials
        cndtmp  = cndsrt(k)-1000;
        xytmp   = [xdes(cndtmp) ydes(cndtmp)];
        xtmp    = trlsrt{k}(1,:)';
        ytmp    = trlsrt{k}(2,:)';
        xtmp0    = trlsrt0{k}(1,:)';
        ytmp0    = trlsrt0{k}(2,:)';
        radtmp  = multinorm([xtmp ytmp]-repmat(xytmp,length(xtmp),1),2);%radius for all datapoints
        meanrad(k) = mean(radtmp);
        meanx(k) = mean(xtmp0);
        meany(k) = mean(ytmp0);
    end
    % REMOVE OUTLIERS BASED ON RADIAL DISTANCES
    % DO THIS FOR EACH POINT TYPE
    badrad = [];
    for i=1:9;
        cndind=find(cndsrt==1000+i);
        [radcell{i} Drad] = rmoutlierspval(meanrad(cndind),pval2,2);
        badtmp = cndind(Drad.outliers);
        xcell{i} = mean(meanx(setdiff(cndind,badtmp)));
        ycell{i} = mean(meany(setdiff(cndind,badtmp)));
        badrad = [badrad badtmp];
    end
    
    % get calibrated mean x and y locations
    x = [];y = [];
    for i=1:9;
        x(i)=mean(xcell{i});
        y(i)=mean(ycell{i});
    end
    if any(isnan(x)|isnan(y)),error('removed too many trials, can recode to avoid this');end
    % DO INITIAL CALIBRATION
    xaxind = [1 2 5 6 9];yaxind = [1 3 4 7 8];
    meanxorigin = mean(x(xaxind));
    meanyorigin = mean(y(yaxind));
    xcal = mean([(x(8)-meanxorigin)/6 (x(4)-meanxorigin)/3 (abs(x(3)-meanxorigin))/3 (abs(x(7)-meanxorigin))/6],2);
    ycal = mean([(y(6)-meanyorigin)/6 (y(2)-meanyorigin)/3 (abs(y(5)-meanyorigin))/3 (abs(y(9)-meanyorigin))/6],2);
    X_offset = meanxorigin;X_slope  = xcal;Y_offset = meanyorigin;Y_slope  = ycal;
    CAL21 = [X_offset Y_offset 1/X_slope 1/Y_slope];
    %     [(x(8)-meanxorigin)/6 (x(4)-meanxorigin)/3 (abs(x(3)-meanxorigin))/3 (abs(x(7)-meanxorigin))/6]
    
    xorig = x;yorig = y;
    x = (x - CAL21(1)).*CAL21(3);
    y = (y - CAL21(2)).*CAL21(4);
    RMSE21 = sqrt( mean([(x-xdes).^2 (y-ydes).^2]) );
    % sort([(x-xdes).^2 (y-ydes).^2])
    % NOW SOME POINTS WILL STILL BE OFF, FIND THESE AND RECALIBRATE WITHOUT
    % THEM TO IMPROVE THE ESTIMATE, remove 2 of 9 (hard coded with the 'ends')
    xdes = [0 0 -3 3  0 0 -6 6  0];
    ydes = [0 3  0 0 -3 6  0 0 -6];
    err  = sqrt([(x-xdes).^2+(y-ydes).^2]);
    [dum ind] = sort(err);
    if numbad2 & ~usealldata
        badpts = ind(end-numbad2+1:end);%the bad calibration points (1-9)
    else
        badpts = [];
    end
    meanxorigin = mean(xorig(setdiff(xaxind,badpts)));
    meanyorigin = mean(yorig(setdiff(yaxind,badpts)));
    xcalvals = [];ycalvals = [];
    xnext = 1;ynext = 1;
    badpts2 = unique([badpts 1]);
    for k = 1:length(xdes)
        if ismember(k,badpts2),continue;end
        if ismember(k,yaxind)
            %             k
            %             xdes(k)
            xcalvals(xnext) = (xorig(k)-meanxorigin)/xdes(k);
            xnext = xnext+1;
        elseif ismember(k,xaxind)
            
            ycalvals(ynext) = (yorig(k)-meanyorigin)/ydes(k);
            ynext = ynext+1;
        end
    end
    %     xcalvals
    %     ycalvals
    xcal = mean(xcalvals);
    ycal = mean(ycalvals);
    X_offset = meanxorigin;X_slope  = xcal;Y_offset = meanyorigin;Y_slope  = ycal;
    CAL2 = [X_offset Y_offset 1/X_slope 1/Y_slope]
    x2 = (xorig - CAL2(1)).*CAL2(3);
    y2 = (yorig - CAL2(2)).*CAL2(4);
    RMSE2 = sqrt( mean([(x2-xdes).^2 (y2-ydes).^2]) )
    %    sort([(x2-xdes).^2 (y2-ydes).^2])
    errors = [RMSE0 RMSE1 RMSE2];
    bestcal = minind(errors)-1;
    eval(sprintf('CAL = CAL%g;x = x%g;y = y%g;',bestcal,bestcal,bestcal));
    
else
    errors = [RMSE0 RMSE1];
    bestcal = minind(errors)-1;
    eval(sprintf('CAL = CAL%g;x = x%g;y = y%g;',bestcal,bestcal,bestcal));
    
end
