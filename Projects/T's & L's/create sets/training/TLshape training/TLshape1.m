rand('twister',sum(100*clock)); % initialize random number generator

d=dir('S:\Contextual\');
clear filelist
i=1;
for k=1:length(d)
    if length(d(k).name)==7
        if d(k).name(1:4)== strcat('TLsh');
            filelist(i,:)=d(k).name;
            i=i+1;
        end
    end
end
if exist('filelist','var')
    numlistdum=filelist(:,5:7);
else
    numlistdum='0';
end
clear numlist
for k=1:size(numlistdum,1)
    numlist(k)=str2double(numlistdum(k,:));
end
for k=1:size(numlistdum,1)
    numlist(k)=str2double(numlistdum(k,:));
end
posnumdum=num2str(max(numlist)+1);
if length(posnumdum)==1
    posnum=['00' posnumdum];
elseif length(posnumdum)==2
    posnum=['0' posnumdum];
else
    posnum=posnumdum;
end

load('S:\CortexMatFiles\bj-img-func\ctximg-mat\1mnalln-mat-lut.mat')
maptoapply=imgAllMap;
clear imgAll imgAllInd Tloc
offset=128;

rgbval=[0.611764705882353   0.580392156862745   0.580392156862745;
    0.870588235294118   0.450980392156863   0.062745098039216;
    0.419607843137255   0.647058823529412   0.388235294117647;
    0.905882352941176   0.388235294117647   0.290196078431373;
    0.031372549019608   0.709803921568627   0.094117647058824;
    0.807843137254902   0.419607843137255   0.741176470588235;
    0.321568627450980   0.580392156862745   0.870588235294118];
color=randsample(7,4);
i=1;
for l = 1:20 %change last number to change # of screens produced

    pos=[];
    xpos=[2.3 3.3 4.3 5.3 6.3 7.3 8.3 9.3];
    ypos=[2.7 3.7 4.7 5.7 6.7 7.7];
    % pick L positions
    for poslop=1:100
        dum=[randsample(xpos,1,true),randsample(ypos,1,true)];
        if ismember(dum,pos,'rows')==0
            pos=[pos;dum];
        end
        if size(pos,1)==11
            break
        end
    end

    % pick T position; not near fixation cross
    for poslop=1:100
        dum=[randsample(xpos,1,true),randsample(ypos,1,true)];
        if ismember(dum,pos,'rows')==0
            if ~isequal(dum,[6.3 4.7]) && ~isequal(dum,[5.3 4.7])
                pos=[pos;dum];
                break
            end
        end
    end

    clear Lx Ly
    Lcnt=[0 0 0 0];
    Lchoice=[1 2 3 4];
    for poslop=1:size(pos,1)-1
        r=pos(poslop,1);
        p=pos(poslop,2);
                
        Larrx=[r (r+.6) (r+.55) (r+.55) ; (r+.6) (r+.6) r (r+.6); r (r+.6) r r; r (r+.6) r r];
        Larry=[p p p (p-.6); (p-.6) p (p-.55) (p-.55); (p-.55) (p-.55) p (p-.6); (p-.05) (p-.05) p (p-.6)];
        
        if length(Lchoice)>1
            ind=randsample(Lchoice,1,1);
        else
            ind=Lchoice;
        end
        Lcnt(ind)=Lcnt(ind)+1;
        if Lcnt(ind)==3
            Lchoice=setdiff(Lchoice,ind);
        end

        Lx(poslop,:) = Larrx(ind,:);
        Ly(poslop,:) = Larry(ind,:);
    end

    clrarr=[];
    Lcnt=[0 0 0 0];
    Lchoice=[1 2 3 4];
    for k=1:size(Lx,1)
        if length(Lchoice)>1
            ind=randsample(Lchoice,1,1);
        else
            ind=Lchoice;
        end
        Lcnt(ind)=Lcnt(ind)+1;
        if Lcnt(ind)==3
            Lchoice=setdiff(Lchoice,ind);
        end

        clrarr(k)=color(ind);
    end
    clrarr=clrarr;

    for k=1:length(color)
        numclr=length(find(clrarr==color(k)));
        if numclr==2
            Tclr=color(k);
        end
    end
    
    figure(i)
%     set(gcf,'InvertHardcopy','off');
%     axes('Parent',gcf,'Color',[0.5 0.5 0.5]);
    set(gca,'XTickMode','manual','YTickMode','manual');
%     set(gca,'XTick',[],'YTick',[],'ZColor',[0.5 0.5 0.5],'YColor',[0.5 0.5 0.5],'XColor',[0.5 0.5 0.5]);
    rectangle('Position',[0 0 12 9],'FaceColor',[0 0 0],'EdgeColor',[0 0 0])
        Tpos=pos(12,:);
        rectangle('Position',[pos(12,1),pos(12,2)-.6,.65,.65],'EdgeColor',rgbval(Tclr,:),'LineWidth',6,'Curvature',[1,1]);
        
    Tloc(l,:) = [Tpos(1)+0.3 Tpos(2)-0.3];
    setpixelposition(gcf,[0 0 1000 800]);
    set(gcf,'Position',[35 -16 1000 705]);
    setpixelposition(gca,[100 100 800 599]);    
    h=getframe(gca);
    [imgInd]=rgb2ind(h.cdata,maptoapply,'nodither');

    clear h
    pack 

    if ~exist(strcat('S:\Contextual\',['TLsh' posnum]),'dir')
        mkdir('S:\Contextual\',['TLsh' posnum]);
    end
    newdir=strcat('S:\Contextual\',['TLsh' posnum]);
    imgout=strcat(newdir,'\TLsh',int2str(l));
    
    %Write ctx file, version that writes lookup table for first image
    im2cortbj(imgInd, maptoapply, imgout, offset,0);
    close
    
    clear imgInd
    pack
    
    i=i+1;
end

% translate Tloc values to degree coordinates

for k=1:size(Tloc,1)
    Tloc(k,3)=(66*(Tloc(k,1)-6))/24;
    Tloc(k,4)=(66*(Tloc(k,2)-4.5))/24;
end

xlswrite(['S:\Tloc\Tlocsh' posnum],Tloc)
disp(['Generated stimuli for TLsh' posnum])

%% find eccentricity of T location to center crosshairs
clear repa2 repb2 repc2 repc
for k=1:12;
    repa2(k)=Tloc(k,3);
    repb2(k)=Tloc(k,4);
    repc2(k)=repa2(k)^2 + repb2(k)^2;
    repc(k)=sqrt(repc2(k));
end

clear newa2 newb2 newc2 newc
for k=13:(size(Tloc,1));
    newa2(k-12)=Tloc(k,3);
    newb2(k-12)=Tloc(k,4);
    newc2(k-12)=newa2(k-12)^2 + newb2(k-12)^2;
    newc(k-12)=sqrt(newc2(k-12));
end

[h,p] = ttest2(repc,newc);
if h == 0;
    disp('OK to use this set')
else disp('DO NOT USE SET, DELETE FROM CONTEXTUAL FOLDER AND TLOC FOLDER AND MAKE NEW SET')
end
%% make item file

itm=['ITEM TYPE FILLED CENTERX CENTERY BITPAN HEIGHT WIDTH ANGLE OUTER INNER -R- -G- -B- C A ------FILENAME------';
    '  -4    1      1    0.00    0.00      0   1.00  1.00  0.00               0   0   0 l                       ';
    '  -3   14      1    0.00    0.00      0   0.50  0.50  0.00             255 255 255 x                       ';
    '  -2    1      1    0.00    0.00      0   0.20  0.20  0.00  0.50       100 100 100 x                       ';
    '  -1    1      0    0.00    0.00      0   1.00  1.00  0.00             255 255 255 x                       ';
    '   0    1      1    0.00    0.00      0   0.15  0.15  0.00              37  63  49 x                       ';
    '   1    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL1.ctx  ';
    '   2    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL2.ctx  ';
    '   3    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL3.ctx  ';
    '   4    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL4.ctx  ';
    '   5    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL5.ctx  ';
    '   6    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL6.ctx  ';
    '   7    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL7.ctx  ';
    '   8    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL8.ctx  ';
    '   9    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL9.ctx  ';
    '  10    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL10.ctx ';
    '  11    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL11.ctx ';
    '  12    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL12.ctx ';
    '  13    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL13.ctx ';
    '  14    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL14.ctx ';
    '  15    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL15.ctx ';
    '  16    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL16.ctx ';
    '  17    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL17.ctx ';
    '  18    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL18.ctx ';
    '  19    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL19.ctx ';
    '  20    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL20.ctx '];

for k=1:size(Tloc,1)
    nextitm=str2num(itm(end,double(1:4)));
    itm=[itm;
        ones(1,(4-length(num2str(nextitm+1))))*char(32) num2str(nextitm+1) '    1      0' char(ones(1,(8-length(num2str(round(Tloc(k,3)*100)/100))))*' ') num2str(round(Tloc(k,3)*100)/100) ...
        char(ones(1,(8-length(num2str(round(Tloc(k,4)*100)/100))))*' ') num2str(round(Tloc(k,4)*100)/100) '      0'...
        '   6.00  6.00  0.00  0.00        75  75  75 x                       '];
end

if exist(strcat('S:\Cortex Programs\Contextual\',['TLsh' posnum '.itm']),'file')
    delete(strcat('S:\Cortex Programs\Contextual\',['TLsh' posnum '.itm']))
end
itmfil=strcat('S:\Cortex Programs\Contextual\',['TLsh' posnum '.itm']);
fid = fopen(itmfil, 'wt');
fprintf(fid,'%s',itm(1,:)');
for k=1:size(itm,1)-1
    fprintf(fid,'\n%s',itm(k+1,:)');
end
fclose(fid);

disp(['Generated item file ' 'TLsh' posnum '.itm'])