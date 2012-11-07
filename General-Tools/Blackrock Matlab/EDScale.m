%Eye Data Scaling function -be sure to run this before detecting artifacts
%Nathan Killian 100227
%--------------------------------------------------------------
%cfg1 needs fields:
% eyedataset (dataset with the eye data)
%
function [cfg1 eog CAL] = EDScale(cfg1)
global supplyCAL MANCAL HES
if ~isfield(cfg1,'eyedataset')&isfield(cfg1,'dataset'),cfg1.eyedataset = cfg1.dataset;end
if ~isfield(cfg1,'checkcal'),cfg1.checkcal=0;end
if ~isfield(cfg1,'savecalplot'),cfg1.savecalplot = 0;end
if ~isfield(cfg1,'clrchgfcn'),clrchgfcn =  'VPCgetclrchg2_Iterative';
else clrchgfcn = cfg1.clrchgfcn;end
dataset = cfg1.eyedataset;

if ~isfield(cfg1,'blackrock')||~(strcmp('.nev',cfg1.dataset(end-3:end)) || strcmp('.ns5',cfg1.dataset(end-3:end)))
    cfg1.blackrock = 0;
else
    cfg1.blackrock = 1;
end
if ~cfg1.blackrock
    hdr = read_header(dataset);
    X_indx = find(strcmp(hdr.label, 'X'));
    Y_indx = find(strcmp(hdr.label, 'Y'));
    eog = read_data(dataset, 'chanindx', [X_indx Y_indx])/1000;
    mrk = [];
else
    dsfs = 1e3;
    eog = getBReye(dataset)/1000;
    mrk = getBRmrk(dataset,dsfs)
    maxtim = max(mrk.tim)/dsfs
end
eogold = eog;

% % remove line noise from the EOG, does nothing to the final data
% eog = rmline(eog,1e3);

minx = min(eog(1,:));miny = min(eog(2,:));
maxx = max(eog(1,:));maxy = max(eog(2,:));
disp(['min X: ' num2str(minx) ', max X: ' num2str(maxx)]);
disp(['min Y: ' num2str(minx) ', max Y: ' num2str(maxx)]);
cfg1.xrange = [minx maxx];
cfg1.yrange = [miny maxy];
if supplyCAL
    CAL = MANCAL;
    %     CAL = [CAL(1) CAL(2) 1/CAL(3) 1/CAL(4)];
    disp('using supplied eye calibration')
else
    
    if HES
        xcal = (max(eog(1,:))-min(eog(1,:)))/rdes;
        ycal = (max(eog(2,:))-min(eog(2,:)))/rdes;
        meanxorigin = nanmean(eog(1,:));
        meanyorigin = nanmean(eog(2,:));
    else
        disp('using clrchng eye calibration')
        [x, y, CAL] = feval(clrchgfcn,dataset,eog,mrk);
        if isempty(CAL)
            disp('fcn returned no calibration data')
            meanxorigin = mean([x(6) x(2) x(1) x(5) x(9) ],2);
            xcal = mean([(x(8)-meanxorigin)/6 (x(4)-meanxorigin)/3 (abs(x(3)-meanxorigin))/3 (abs(x(7)-meanxorigin))/6],2);
            meanyorigin = mean([y(7) y(3) y(1) y(4) y(8) ],2);
            ycal = mean([(y(6)-meanyorigin)/6 (y(2)-meanyorigin)/3 (abs(y(5)-meanyorigin))/3 (abs(y(9)-meanyorigin))/6],2);
            disp(['xcal: ' num2str(xcal) ' ycal: ' num2str(ycal)])
            disp(['xoffset: ' num2str(meanxorigin) ' yoffset: ' num2str(meanyorigin)])
            X_offset = meanxorigin;X_slope  = xcal;Y_offset = meanyorigin;Y_slope  = ycal;
            CAL = [X_offset Y_offset 1/X_slope 1/Y_slope];
        end
    end
    
end
eog(1,:) = (eogold(1,:) - CAL(1))*CAL(3);
eog(2,:) = (eogold(2,:) - CAL(2))*CAL(4);
cfg1.artfctdef.reject = 'partial';


if cfg1.checkcal || cfg1.savecalplot
    %             CAL = [-0.1666   -0.1760    6.7164    5.0549];
    CAL
    
    xdes = [0 0 -3 3 0 0 -6 6 0];
    ydes = [0 3 0 0 -3 6 0 0 -6];
    
    figure(100);clf(100);figure(100);
    plot(x,y,'ko')
    hold on
    plot(xdes,ydes,'r.')
    axis([-7 7 -7 7])
    grid on
    RMSE_check = sqrt(mean([(x-xdes).^2 (y-ydes).^2]))
    title([num2str(rsig(RMSE_check,3))])
    if cfg1.savecalplot
        figdir = 'D:\EyeCalPlots\';
        if ~exist(figdir), mkdir(figdir);end
        savnam = [figdir cfg1.fid(1:end-4) '.png'];
        saveas(gcf,savnam);
        disp(['saved calibration plot to: ' savnam])
    end
    if cfg1.checkcal
        disp('pausing to check calibration')
        pause;
    end
end

