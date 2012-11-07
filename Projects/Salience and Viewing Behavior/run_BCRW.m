function run_BCRW(ViewingBehaviorFile,imageNumber,imageX,imageY,d,novelty,plotoptions)


warning off all
if nargin < 3
    error(['Not enough inputs: function requires ViewingBehaviorFile,'...
        'imageX, imageY, d, and novelty.'])
end
if nargin < 5
    d = date;
end
if nargin < 6
    novelty = 'none';
end
if nargin < 7
    plotoptions.runs = 'all';
    plotoptions.probdens = 'none';
    plotoptions.type = 'image';
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
angprob = dat.probang;
distCDF = dat.distCDF;
persistence = sigmf(0:1:200, [0.5 10]);%dat.persistence;
clear dat

[RF,lr,lc,density] = receptivefield(rr,cc);

[exe] = getMaps(cnd,imageNumber*2-1,cndfil,test0start,...
    itmfil,resized_densitymap,RF,lr,lc,density,filenamestart);


[fxx fyy] = gradient(exe);
fxx = imfilter(fxx,fspecial('gauss',25,10),'replicate');
fyy = imfilter(fyy,fspecial('gauss',25,10),'replicate');
fxx = fxx/max(max(fxx));
fyy = -fyy/max(max(fyy));
fyy(:,1:10) = 0; fyy(:,end-9:end) = 0;
fxx(1:10,:) = 0; fxx(end-9:end,:) = 0;
fxx(:,1:10) = 1; fxx(:,end-9:end) = -1;
fyy(1:10,:) = -1; fyy(end-9:end,:) = +1;

angprob = 1/length(angprob)*ones(1,length(angprob));

dt = 0.005;
rr = 25;
totprob = cumsum(angprob);

fixations = zeros(600,800);
alltrials = zeros(600,800);

for n = 1:1000
    fx = fxx; fy = fyy;
    x = 400;
    y = 300;
    xxyy = [[x;y] zeros(2,9)];
    tmr = 0;
    t = 0;
    angold = [];
    if strcmpi(plotoptions.runs,'all')
        figure
        if strcmp(plotoptions.type,'image');
            imagesc(imread([num2str(imageNumber) '.bmp']))
        else
            imagesc(exe)
        end
        hold on
    end
    while t < 10
        if round(tmr*1/dt)+1 > size(distCDF,2);
            dh = randi(5);
            b = 1;
        else
            dhr = find(distCDF(:,round(tmr*1/dt)+1) > rand);
            dh = dhr(1);
        end
        if round(tmr*1/dt) < length(persistence);
            b = persistence(round(tmr*1/dt)+1);%correlation weight-1 is totally random, 0 is 100% correlated
        else
            b = 1;
        end
        if all(abs(xxyy(:,1) - mean( xxyy,2)) < [7;7]) && all((std( xxyy,0,2) < [7;7])) || tmr > 0.500
            xy = ceil(mean(xxyy,2));
            xb = [xy(1)-rr xy(1) + rr]; xb(xb < 1) = 1; xb(xb>800) = 800;
            yb = [xy(2)-rr xy(2) + rr]; yb(yb < 1) = 1; yb(yb>800) = 800;
            fx(yb(1):yb(2),xb(1):xb(2)) = 0;
            fy(yb(1):yb(2),xb(1):xb(2)) = 0;
            fixations(xy(2),xy(1)) =  fixations(xy(2),xy(1)) + 1;
            tmr = 0;
            xxyy = [[x;y] zeros(2,9)];
            angold = [];
        end
        if x > 790 || x < 10 || y > 590 || y < 10
            if (x > 790 && (y > 590 || y < 10)) || (x < 10 && (y > 590 || y < 10))
                dh(dh < 35) = 35;
            else
                dh(dh < 25) = 25;
            end
        end
        if tmr == 0;
            choice = find(totprob > rand);
            if isempty(choice)
                angh = length(totprob);
            else
                angh = choice(1);
            end
            ang = angh;
        else
            if abs(fy(y,x)) < 0.1 && abs(fx(y,x)) < 0.1
                ang = angold;
            else
                if  abs(fy(y,x)) > 0.1 && abs(fx(y,x)) > 0.1
                    angh = atand(fy(y,x)/fx(y,x));
                    if fx(y,x)+fy(y,x) < 0
                        angh = angh + 180;
                    end
                elseif abs(fy(y,x)) > 0.1
                    if fy(y,x) < 0;
                        angh = -90;
                    else
                        angh = 90;
                    end
                elseif abs(fx(y,x)) > 0.1
                    if fx(y,x) < 0;
                        angh = -180;
                    else
                        angh = 0;
                    end
                end
                if angold > 180
                    angold = angold - 360;
                end
                ang = angold*(1-b) + b*angh;
            end
        end
        xn = round(x + dh*cos(ang*pi/180));
        yn = round(y + dh*sin(ang*pi/180));
        angold = ang;
        if (xn > 800 || xn < 1 || yn < 1 || yn > 600)
            [xn yn angold] = boarder(x,xn,y,yn,ang,angold,dh);
        end
        if strcmpi(plotoptions.runs,'all')
            plot([x xn],[y yn],'b')
            plot(xn,yn,'.b','markersize',3)
        end
        
        
        alltrials(yn,xn) = alltrials(yn,xn) + 1;
        x = xn;
        y = yn;
        tmr = tmr + dt;
        t = t+dt;
        xxyy =  [[x;y]  xxyy(:,1:9)];
    end
    if strcmpi(plotoptions.runs,'all')
        pause(2)
        close
    end
end

alltrials = [zeros(25,size(alltrials,2)); alltrials; zeros(25,size(alltrials,2))];
alltrials = [zeros(size(alltrials,1),25) alltrials zeros(size(alltrials,1),25)];
fixations = [zeros(25,size(fixations,2)); fixations; zeros(25,size(fixations,2))];
fixations = [zeros(size(fixations,1),25) fixations zeros(size(fixations,1),25)];

for i = 1:25
    alltrials = imfilter(alltrials,fspecial('gauss'),32,32);
    fixations = imfilter(fixations,fspecial('gauss'),32,32);
end
alltrials = alltrials(26:end-25,26:end-25);
fixations = fixations(26:end-25,26:end-25);
if strcmpi(plotoptions.probdens,'all')
    figure
    imagesc(alltrials)
    title('PDF: All Positions')
    figure
    imagesc(fixations)
    title('PDF: Fixations')
    figure,imagesc(exe)
end

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

    function [exe] = getMaps(cnd,cndlop,cndfil,test0start,...
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
        
        RFmap = imfilter(fullmap,RF,'replicate');
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

    function [xn yn angold] = boarder(x,xn,y,yn,ang,angold,dh)
        cnt = 0;
        xx = [x xn]; yy = [y yn]; angs = ang;
        while (xn > 800 || xn < 1 || yn < 1 || yn > 600)
            cnt = cnt +1;
            if dh > 25;
                dhn = sqrt((x-xn).^2+(y-yn).^2);
                p = polyfit([x xn],[y yn],1);
                if xn > 800
                    y = round(p(1)*800 + p(2));
                    x = 800;
                elseif xn < 1
                    y = round(1*p(1)+p(2));
                    x = 1;
                elseif yn < 0
                    if any(isinf(p));
                        x = x; %#ok
                        y = 1;
                    else
                        x = round((0-p(2))/p(1));
                        y = 1;
                    end
                elseif yn > 600
                    if  any(isinf(p));
                        x = x; %#ok
                        y = 600;
                    else
                        x = round((600-p(2))/p(1));
                        y = 600;
                    end
                else
                    x = xn; y = yn;
                end
                angn = ang+180;
            else
                angn = ang + 180;
                dhn = dh;
            end
            x(x < 1) = 1; y(y < 1) = 1;
            x(x>800) = 800; y(y> 600) = 600;
            xn = round(x + dhn*cos(angn*pi/180));
            yn = round(y + dhn*sin(angn*pi/180));
            xn(xn < 1) = 1; yn(yn < 1) = 1;
            xn(xn>800) = 800; yn(yn> 600) = 600;
            angold = angn;
            if cnt > 10
                disp('too much count')
            end
        end
    end

save(['BCRW-' datfil(1:end-2) '-' setnum '-' num2str(imageNumber) '.mat'],'alltrials','fixations')
end