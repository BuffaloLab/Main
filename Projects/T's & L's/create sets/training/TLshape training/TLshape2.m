close all
clear all
pack

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

%distractor color brightness
rgbval=[1 1 0; 
    1 0 1; 
    0 1 1; 
    1 0 0; 
    0 1 0;
    0 0 1; 
    1 1 1];
colorpick=randsample(7,4);
color=rgbval(colorpick,:);

i=1;
for l = 1:252 %change last number to change # of screens produced (should be 252 for 20 blks)

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

%         clrarr(k)=color(ind);
         clrarr(k,:)=(color(ind,:));
    end
%     clrarr=clrarr;

    for k=1:length(color)
        numclr=length(find(clrarr==color(k)));
        if numclr~=3
            Tclr=clrarr(k,:);
        end
    end

    for k=1:size(Tclr,2)
        if Tclr(k)<=0.1;
            Tclr(k)= 0;
        elseif Tclr(k)>=0.2
            Tclr(k)=1;
        end
    end
    figure(i)
%     set(gcf,'InvertHardcopy','off');
%     axes('Parent',gcf,'Color',[0.5 0.5 0.5]);
    set(gca,'XTickMode','manual','YTickMode','manual');
%     set(gca,'XTick',[],'YTick',[],'ZColor',[0.5 0.5 0.5],'YColor',[0.5 0.5 0.5],'XColor',[0.5 0.5 0.5]);
    rectangle('Position',[0 0 12 9],'FaceColor',[0 0 0],'EdgeColor',[0 0 0])
        for k=1:11
            hold on
            if Ly(k,1)==Ly(k,2)&& Ly(k,2)==Ly(k,3)
                rectangle('Position',[min(Lx(k,:)),min(Ly(k,:)),.3,.8],'EdgeColor',clrarr(k,:),'LineWidth',6,'Curvature',[1,1]);
            else
                rectangle('Position',[min(Lx(k,:)),min(Ly(k,:))+.3,.8,.3],'EdgeColor',clrarr(k,:),'LineWidth',6,'Curvature',[1,1]);
            end
            axis([0 12 0 9]);
        end
        hold on
        axis off
        Tpos=pos(12,:);
        rectangle('Position',[pos(12,1),pos(12,2)-.6,.65,.65],'EdgeColor',Tclr(1,:),'LineWidth',6,'Curvature',[1,1]);
        
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
    imgout=strcat(newdir,'\TL',int2str(l));
    
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
    '  20    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL20.ctx ';
    '  21    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL21.ctx ';
    '  22    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL22.ctx ';
    '  23    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL23.ctx ';
    '  24    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL24.ctx ';
    '  25    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL25.ctx ';
    '  26    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL26.ctx ';
    '  27    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL27.ctx ';
    '  28    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL28.ctx ';
    '  29    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL29.ctx ';
    '  30    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL30.ctx ';
    '  31    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL31.ctx ';
    '  32    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL32.ctx ';
    '  33    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL33.ctx ';
    '  34    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL34.ctx ';
    '  35    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL35.ctx ';
    '  36    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL36.ctx ';
    '  37    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL37.ctx ';
    '  38    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL38.ctx ';
    '  39    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL39.ctx ';
    '  40    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL40.ctx ';
    '  41    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL41.ctx ';
    '  42    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL42.ctx ';
    '  43    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL43.ctx ';
    '  44    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL44.ctx ';
    '  45    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL45.ctx ';
    '  46    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL46.ctx ';
    '  47    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL47.ctx ';
    '  48    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL48.ctx ';
    '  49    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL49.ctx ';
    '  50    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL50.ctx ';
    '  51    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL51.ctx ';
    '  52    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL52.ctx ';
    '  53    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL53.ctx ';
    '  54    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL54.ctx ';
    '  55    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL55.ctx ';
    '  56    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL56.ctx ';
    '  57    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL57.ctx ';
    '  58    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL58.ctx ';
    '  59    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL59.ctx ';
    '  60    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL60.ctx ';
    '  61    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL61.ctx ';
    '  62    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL62.ctx ';
    '  63    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL63.ctx ';
    '  64    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL64.ctx ';
    '  65    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL65.ctx ';
    '  66    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL66.ctx ';
    '  67    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL67.ctx ';
    '  68    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL68.ctx ';
    '  69    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL69.ctx ';
    '  70    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL70.ctx ';
    '  71    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL71.ctx ';
    '  72    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL72.ctx ';
    '  73    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL73.ctx ';
    '  74    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL74.ctx ';
    '  75    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL75.ctx ';
    '  76    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL76.ctx ';
    '  77    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL77.ctx ';
    '  78    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL78.ctx ';
    '  79    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL79.ctx ';
    '  80    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL80.ctx ';
    '  81    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL81.ctx ';
    '  82    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL82.ctx ';
    '  83    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL83.ctx ';
    '  84    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL84.ctx ';
    '  85    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL85.ctx ';
    '  86    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL86.ctx ';
    '  87    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL87.ctx ';
    '  88    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL88.ctx ';
    '  89    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL89.ctx ';
    '  90    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL90.ctx ';
    '  91    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL91.ctx ';
    '  92    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL92.ctx ';
    '  93    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL93.ctx ';
    '  94    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL94.ctx ';
    '  95    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL95.ctx ';
    '  96    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL96.ctx ';
    '  97    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL97.ctx ';
    '  98    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL98.ctx ';
    '  99    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL99.ctx ';
    ' 100    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL100.ctx';
    ' 101    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL101.ctx';
    ' 102    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL102.ctx';
    ' 103    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL103.ctx';
    ' 104    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL104.ctx';
    ' 105    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL105.ctx';
    ' 106    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL106.ctx';
    ' 107    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL107.ctx';
    ' 108    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL108.ctx';
    ' 109    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL109.ctx';
    ' 110    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL110.ctx';
    ' 111    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL111.ctx';
    ' 112    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL112.ctx';
    ' 113    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL113.ctx';
    ' 114    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL114.ctx';
    ' 115    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL115.ctx';
    ' 116    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL116.ctx';
    ' 117    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL117.ctx';
    ' 118    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL118.ctx';
    ' 119    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL119.ctx';
    ' 120    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL120.ctx';
    ' 121    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL121.ctx';
    ' 122    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL122.ctx';
    ' 123    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL123.ctx';
    ' 124    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL124.ctx';
    ' 125    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL125.ctx';
    ' 126    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL126.ctx';
    ' 127    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL127.ctx';
    ' 128    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL128.ctx';
    ' 129    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL129.ctx';
    ' 130    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL130.ctx';
    ' 131    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL131.ctx';
    ' 132    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL132.ctx';
    ' 133    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL133.ctx';
    ' 134    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL134.ctx';
    ' 135    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL135.ctx';
    ' 136    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL136.ctx';
    ' 137    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL137.ctx';
    ' 138    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL138.ctx';
    ' 139    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL139.ctx';
    ' 140    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL140.ctx';
    ' 141    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL141.ctx';
    ' 142    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL142.ctx';
    ' 143    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL143.ctx';
    ' 144    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL144.ctx';
    ' 145    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL145.ctx';
    ' 146    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL146.ctx';
    ' 147    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL147.ctx';
    ' 148    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL148.ctx';
    ' 149    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL149.ctx';
    ' 150    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL150.ctx';
    ' 151    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL151.ctx';
    ' 152    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL152.ctx';
    ' 153    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL153.ctx';
    ' 154    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL154.ctx';
    ' 155    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL155.ctx';
    ' 156    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL156.ctx';
    ' 157    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL157.ctx';
    ' 158    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL158.ctx';
    ' 159    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL159.ctx';
    ' 160    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL160.ctx';
    ' 161    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL161.ctx';
    ' 162    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL162.ctx';
    ' 163    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL163.ctx';
    ' 164    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL164.ctx';
    ' 165    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL165.ctx';
    ' 166    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL166.ctx';
    ' 167    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL167.ctx';
    ' 168    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL168.ctx';
    ' 169    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL169.ctx';
    ' 170    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL170.ctx';
    ' 171    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL171.ctx';
    ' 172    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL172.ctx';
    ' 173    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL173.ctx';
    ' 174    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL174.ctx';
    ' 175    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL175.ctx';
    ' 176    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL176.ctx';
    ' 177    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL177.ctx';
    ' 178    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL178.ctx';
    ' 179    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL179.ctx';
    ' 180    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL180.ctx';
    ' 181    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL181.ctx';
    ' 182    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL182.ctx';
    ' 183    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL183.ctx';
    ' 184    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL184.ctx';
    ' 185    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL185.ctx';
    ' 186    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL186.ctx';
    ' 187    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL187.ctx';
    ' 188    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL188.ctx';
    ' 189    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL189.ctx';
    ' 190    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL190.ctx';
    ' 191    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL191.ctx';
    ' 192    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL192.ctx';
    ' 193    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL193.ctx';
    ' 194    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL194.ctx';
    ' 195    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL195.ctx';
    ' 196    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL196.ctx';
    ' 197    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL197.ctx';
    ' 198    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL198.ctx';
    ' 199    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL199.ctx';
    ' 200    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL200.ctx';
    ' 201    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL201.ctx';
    ' 202    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL202.ctx';
    ' 203    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL203.ctx';
    ' 204    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL204.ctx';
    ' 205    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL205.ctx';
    ' 206    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL206.ctx';
    ' 207    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL207.ctx';
    ' 208    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL208.ctx';
    ' 209    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL209.ctx';
    ' 210    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL210.ctx';
    ' 211    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL211.ctx';
    ' 212    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL212.ctx';
    ' 213    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL213.ctx';
    ' 214    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL214.ctx';
    ' 215    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL215.ctx';
    ' 216    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL216.ctx';
    ' 217    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL217.ctx';
    ' 218    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL218.ctx';
    ' 219    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL219.ctx';
    ' 220    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL220.ctx';
    ' 221    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL221.ctx';
    ' 222    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL222.ctx';
    ' 223    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL223.ctx';
    ' 224    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL224.ctx';
    ' 225    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL225.ctx';
    ' 226    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL226.ctx';
    ' 227    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL227.ctx';
    ' 228    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL228.ctx';
    ' 229    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL229.ctx';
    ' 230    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL230.ctx';
    ' 231    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL231.ctx';
    ' 232    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL232.ctx';
    ' 233    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL233.ctx';
    ' 234    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL234.ctx';
    ' 235    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL235.ctx';
    ' 236    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL236.ctx';
    ' 237    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL237.ctx';
    ' 238    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL238.ctx';
    ' 239    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL239.ctx';
    ' 240    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL240.ctx';
    ' 241    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL241.ctx';
    ' 242    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL242.ctx';
    ' 243    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL243.ctx';
    ' 244    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL244.ctx';
    ' 245    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL245.ctx';
    ' 246    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL246.ctx';
    ' 247    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL247.ctx';
    ' 248    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL248.ctx';
    ' 249    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL249.ctx';
    ' 250    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL250.ctx';
    ' 251    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL251.ctx';
    ' 252    8           0.00    0.00      0                                 75  75  75 x   C:\TLsh' posnum '\TL252.ctx'];

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