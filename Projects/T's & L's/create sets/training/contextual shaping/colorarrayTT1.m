d=dir('S:\Contextual\');
clear filelist
i=1;
for k=1:length(d)
    if length(d(k).name)==5
        filelist(i,:)=d(k).name;
        i=i+1;
    end
end
if exist('filelist','var')
    numlistdum=filelist(:,3:5);
else
    numlistdum='0';
end
clear numlist
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
clear imgAll;
clear imgAllInd;
offset=128;

color=randsample(['r' 'g' 'c' 'b' 'm' 'y' 'w'],4);
i=1;
for l = 1:252 %change last number to change # of screens produced

    pos=[];
    xpos=[2.3 3.3 4.3 5.3 6.3 7.3 8.3 9.3];
    ypos=[2.7 3.7 4.7 5.7 6.7 7.7];
    for poslop=1:100
        dum=[randsample(xpos,1,true),randsample(ypos,1,true)];
        if ismember(dum,pos,'rows')==0
            pos=[pos;dum];
        end
        if size(pos,1)==12
            break
        end
    end

    clear Lx Ly
    Lcnt=[0 0 0 0];
    Lchoice=[1 2 3 4];
    for poslop=1:size(pos,1)-1
        r=pos(poslop,1);
        p=pos(poslop,2);
        Larrx=[r r (r+.6); (r+.6) (r+.6) r; (r+.6) r r; (r+.6) (r+.6) r];
        Larry=[p (p-.6) (p-.6); p (p-.6) (p-.6); p p (p-.6); (p-.6) p p];

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

        clrarr(k)=char(color(ind));
    end
    clrarr=char(clrarr);

    for k=1:length(color)
        numclr=length(find(clrarr==color(k)));
        if numclr==2
            Tclr=color(k);
        end
    end
    
    figure(i);
%     set(gcf,'InvertHardcopy','off');
%     axes('Parent',gcf,'Color',[0.5 0.5 0.5]);
    set(gca,'XTickMode','manual','YTickMode','manual');
%     set(gca,'XTick',[],'YTick',[],'ZColor',[0.5 0.5 0.5],'YColor',[0.5 0.5 0.5],'XColor',[0.5 0.5 0.5]);
    rectangle('Position',[0 0 12 9],'FaceColor',[0 0 0],'EdgeColor',[0 0 0])
%     for k=1:size(Lx,1)
%         hold on
%         plot(Lx(k,:),Ly(k,:),clrarr(k),'linewidth',10);
%         axis([0 8 0 6]);
%     end

    Tori=randsample([1 2],1);
    if Tori==1
        hold on
        axis off
        Tpos=pos(12,:);
        line([pos(12,1) pos(12,1)],[pos(12,2)-0.6 pos(12,2)],'color',Tclr,'linewidth',6);
        line([pos(12,1) pos(12,1)+.6],[pos(12,2)-0.3 pos(12,2)-0.3],'color',Tclr,'linewidth',6);
    else
        hold on
        axis off
        Tpos=pos(12,:);
        line([pos(12,1)+.6 pos(12,1)+.6],[pos(12,2) pos(12,2)-0.6],'color',Tclr,'linewidth',6);
        line([pos(12,1)+.6 pos(12,1)],[pos(12,2)-0.3 pos(12,2)-0.3],'color',Tclr,'linewidth',6);
    end
    Tloc(l,:) = [Tpos(1)+0.3 Tpos(2)-0.3];
    setpixelposition(gcf,[0 0 1000 800]);
    set(gcf,'Position',[35 -16 1000 705]);
    setpixelposition(gca,[100 100 800 599]);    
    h=getframe(gca);
    [imgInd]=rgb2ind(h.cdata,maptoapply,'nodither');
%     cmap{l}=h.cdata;
%     print(['-f' int2str(i)],'-dbmp',['S:\Contextual\TT' int2str(l) '.bmp']);

    if ~exist(strcat('S:\Contextual\',['TT' posnum]),'dir')
        mkdir('S:\Contextual\',['TT' posnum]);
    end
    newdir=strcat('S:\Contextual\',['TT' posnum]);
    imgout=strcat(newdir,'\TT',int2str(l));
    
    %Write ctx file, version that writes lookup table for first image
    im2cortbj(imgInd, maptoapply, imgout, offset,0);

    i=i+1;
end

% translate TLoc values to degree coordinates

for k=1:size(Tloc,1)
    Tloc(k,3)=(66*(Tloc(k,1)-6))/24;
    Tloc(k,4)=(66*(Tloc(k,2)-4.5))/24;
end

% xlswrite(['S:\TLoc\TLoc' posnum],TLoc)

%% make item file

itm=['ITEM TYPE FILLED CENTERX CENTERY BITPAN HEIGHT WIDTH ANGLE OUTER INNER -R- -G- -B- C A ------FILENAME------';
    '  -4    1      1    0.00    0.00      0   1.00  1.00  0.00              50  50  50 l                       ';
    '  -3   14      1    0.00    0.00      0   0.50  0.50  0.00             255 255 255 x                       ';
    '  -2    1      1    0.00    0.00      0   0.20  0.20  0.00  0.50       100 100 100 x                       ';
    '  -1    1      0    0.00    0.00      0   1.00  1.00  0.00             255 255 255 x                       ';
    '   0    1      1    0.00    0.00      0   0.15  0.15  0.00              37  63  49 x                       ';
    '   1    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT1.ctx    ';
    '   2    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT2.ctx    ';
    '   3    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT3.ctx    ';
    '   4    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT4.ctx    ';
    '   5    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT5.ctx    ';
    '   6    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT6.ctx    ';
    '   7    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT7.ctx    ';
    '   8    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT8.ctx    ';
    '   9    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT9.ctx    ';
    '  10    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT10.ctx   ';
    '  11    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT11.ctx   ';
    '  12    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT12.ctx   ';
    '  13    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT13.ctx   ';
    '  14    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT14.ctx   ';
    '  15    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT15.ctx   ';
    '  16    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT16.ctx   ';
    '  17    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT17.ctx   ';
    '  18    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT18.ctx   ';
    '  19    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT19.ctx   ';
    '  20    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT20.ctx   ';
    '  21    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT21.ctx   ';
    '  22    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT22.ctx   ';
    '  23    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT23.ctx   ';
    '  24    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT24.ctx   ';
    '  25    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT25.ctx   ';
    '  26    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT26.ctx   ';
    '  27    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT27.ctx   ';
    '  28    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT28.ctx   ';
    '  29    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT29.ctx   ';
    '  30    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT30.ctx   ';
    '  31    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT31.ctx   ';
    '  32    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT32.ctx   ';
    '  33    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT33.ctx   ';
    '  34    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT34.ctx   ';
    '  35    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT35.ctx   ';
    '  36    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT36.ctx   ';
    '  37    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT37.ctx   ';
    '  38    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT38.ctx   ';
    '  39    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT39.ctx   ';
    '  40    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT40.ctx   ';
    '  41    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT41.ctx   ';
    '  42    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT42.ctx   ';
    '  43    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT43.ctx   ';
    '  44    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT44.ctx   ';
    '  45    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT45.ctx   ';
    '  46    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT46.ctx   ';
    '  47    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT47.ctx   ';
    '  48    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT48.ctx   ';
    '  49    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT49.ctx   ';
    '  50    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT50.ctx   ';
    '  51    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT51.ctx   ';
    '  52    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT52.ctx   ';
    '  53    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT53.ctx   ';
    '  54    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT54.ctx   ';
    '  55    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT55.ctx   ';
    '  56    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT56.ctx   ';
    '  57    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT57.ctx   ';
    '  58    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT58.ctx   ';
    '  59    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT59.ctx   ';
    '  60    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT60.ctx   ';
    '  61    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT61.ctx   ';
    '  62    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT62.ctx   ';
    '  63    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT63.ctx   ';
    '  64    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT64.ctx   ';
    '  65    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT65.ctx   ';
    '  66    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT66.ctx   ';
    '  67    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT67.ctx   ';
    '  68    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT68.ctx   ';
    '  69    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT69.ctx   ';
    '  70    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT70.ctx   ';
    '  71    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT71.ctx   ';
    '  72    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT72.ctx   ';
    '  73    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT73.ctx   ';
    '  74    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT74.ctx   ';
    '  75    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT75.ctx   ';
    '  76    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT76.ctx   ';
    '  77    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT77.ctx   ';
    '  78    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT78.ctx   ';
    '  79    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT79.ctx   ';
    '  80    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT80.ctx   ';
    '  81    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT81.ctx   ';
    '  82    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT82.ctx   ';
    '  83    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT83.ctx   ';
    '  84    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT84.ctx   ';
    '  85    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT85.ctx   ';
    '  86    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT86.ctx   ';
    '  87    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT87.ctx   ';
    '  88    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT88.ctx   ';
    '  89    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT89.ctx   ';
    '  90    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT90.ctx   ';
    '  91    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT91.ctx   ';
    '  92    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT92.ctx   ';
    '  93    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT93.ctx   ';
    '  94    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT94.ctx   ';
    '  95    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT95.ctx   ';
    '  96    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT96.ctx   ';
    '  97    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT97.ctx   ';
    '  98    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT98.ctx   ';
    '  99    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT99.ctx   ';
    ' 100    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT100.ctx  ';
    ' 101    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT101.ctx  ';
    ' 102    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT102.ctx  ';
    ' 103    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT103.ctx  ';
    ' 104    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT104.ctx  ';
    ' 105    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT105.ctx  ';
    ' 106    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT106.ctx  ';
    ' 107    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT107.ctx  ';
    ' 108    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT108.ctx  ';
    ' 109    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT109.ctx  ';
    ' 110    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT110.ctx  ';
    ' 111    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT111.ctx  ';
    ' 112    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT112.ctx  ';
    ' 113    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT113.ctx  ';
    ' 114    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT114.ctx  ';
    ' 115    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT115.ctx  ';
    ' 116    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT116.ctx  ';
    ' 117    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT117.ctx  ';
    ' 118    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT118.ctx  ';
    ' 119    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT119.ctx  ';
    ' 120    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT120.ctx  ';
    ' 121    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT121.ctx  ';
    ' 122    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT122.ctx  ';
    ' 123    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT123.ctx  ';
    ' 124    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT124.ctx  ';
    ' 125    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT125.ctx  ';
    ' 126    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT126.ctx  ';
    ' 127    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT127.ctx  ';
    ' 128    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT128.ctx  ';
    ' 129    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT129.ctx  ';
    ' 130    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT130.ctx  ';
    ' 131    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT131.ctx  ';
    ' 132    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT132.ctx  ';
    ' 133    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT133.ctx  ';
    ' 134    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT134.ctx  ';
    ' 135    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT135.ctx  ';
    ' 136    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT136.ctx  ';
    ' 137    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT137.ctx  ';
    ' 138    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT138.ctx  ';
    ' 139    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT139.ctx  ';
    ' 140    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT140.ctx  ';
    ' 141    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT141.ctx  ';
    ' 142    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT142.ctx  ';
    ' 143    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT143.ctx  ';
    ' 144    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT144.ctx  ';
    ' 145    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT145.ctx  ';
    ' 146    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT146.ctx  ';
    ' 147    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT147.ctx  ';
    ' 148    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT148.ctx  ';
    ' 149    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT149.ctx  ';
    ' 150    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT150.ctx  ';
    ' 151    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT151.ctx  ';
    ' 152    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT152.ctx  ';
    ' 153    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT153.ctx  ';
    ' 154    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT154.ctx  ';
    ' 155    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT155.ctx  ';
    ' 156    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT156.ctx  ';
    ' 157    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT157.ctx  ';
    ' 158    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT158.ctx  ';
    ' 159    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT159.ctx  ';
    ' 160    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT160.ctx  ';
    ' 161    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT161.ctx  ';
    ' 162    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT162.ctx  ';
    ' 163    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT163.ctx  ';
    ' 164    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT164.ctx  ';
    ' 165    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT165.ctx  ';
    ' 166    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT166.ctx  ';
    ' 167    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT167.ctx  ';
    ' 168    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT168.ctx  ';
    ' 169    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT169.ctx  ';
    ' 170    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT170.ctx  ';
    ' 171    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT171.ctx  ';
    ' 172    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT172.ctx  ';
    ' 173    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT173.ctx  ';
    ' 174    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT174.ctx  ';
    ' 175    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT175.ctx  ';
    ' 176    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT176.ctx  ';
    ' 177    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT177.ctx  ';
    ' 178    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT178.ctx  ';
    ' 179    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT179.ctx  ';
    ' 180    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT180.ctx  ';
    ' 181    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT181.ctx  ';
    ' 182    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT182.ctx  ';
    ' 183    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT183.ctx  ';
    ' 184    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT184.ctx  ';
    ' 185    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT185.ctx  ';
    ' 186    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT186.ctx  ';
    ' 187    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT187.ctx  ';
    ' 188    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT188.ctx  ';
    ' 189    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT189.ctx  ';
    ' 190    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT190.ctx  ';
    ' 191    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT191.ctx  ';
    ' 192    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT192.ctx  ';
    ' 193    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT193.ctx  ';
    ' 194    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT194.ctx  ';
    ' 195    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT195.ctx  ';
    ' 196    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT196.ctx  ';
    ' 197    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT197.ctx  ';
    ' 198    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT198.ctx  ';
    ' 199    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT199.ctx  ';
    ' 200    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT200.ctx  ';
    ' 201    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT201.ctx  ';
    ' 202    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT202.ctx  ';
    ' 203    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT203.ctx  ';
    ' 204    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT204.ctx  ';
    ' 205    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT205.ctx  ';
    ' 206    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT206.ctx  ';
    ' 207    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT207.ctx  ';
    ' 208    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT208.ctx  ';
    ' 209    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT209.ctx  ';
    ' 210    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT210.ctx  ';
    ' 211    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT211.ctx  ';
    ' 212    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT212.ctx  ';
    ' 213    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT213.ctx  ';
    ' 214    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT214.ctx  ';
    ' 215    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT215.ctx  ';
    ' 216    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT216.ctx  ';
    ' 217    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT217.ctx  ';
    ' 218    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT218.ctx  ';
    ' 219    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT219.ctx  ';
    ' 220    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT220.ctx  ';
    ' 221    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT221.ctx  ';
    ' 222    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT222.ctx  ';
    ' 223    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT223.ctx  ';
    ' 224    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT224.ctx  ';
    ' 225    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT225.ctx  ';
    ' 226    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT226.ctx  ';
    ' 227    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT227.ctx  ';
    ' 228    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT228.ctx  ';
    ' 229    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT229.ctx  ';
    ' 230    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT230.ctx  ';
    ' 231    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT231.ctx  ';
    ' 232    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT232.ctx  ';
    ' 233    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT233.ctx  ';
    ' 234    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT234.ctx  ';
    ' 235    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT235.ctx  ';
    ' 236    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT236.ctx  ';
    ' 237    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT237.ctx  ';
    ' 238    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT238.ctx  ';
    ' 239    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT239.ctx  ';
    ' 240    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT240.ctx  ';
    ' 241    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT241.ctx  ';
    ' 242    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT242.ctx  ';
    ' 243    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT243.ctx  ';
    ' 244    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT244.ctx  ';
    ' 245    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT245.ctx  ';
    ' 246    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT246.ctx  ';
    ' 247    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT247.ctx  ';
    ' 248    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT248.ctx  ';
    ' 249    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT249.ctx  ';
    ' 250    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT250.ctx  ';
    ' 251    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT251.ctx  ';
    ' 252    8           0.00    0.00      0                                 75  75  75 x   C:\TT' posnum '\TT252.ctx  '];

for k=1:size(Tloc,1)
    nextitm=str2num(itm(end,double(2:4)));
    itm=[itm;
        ' ' num2str(nextitm+1) '    1      0' char(ones(1,(8-length(num2str(round(Tloc(k,3)*100)/100))))*' ') num2str(round(Tloc(k,3)*100)/100) ...
        char(ones(1,(8-length(num2str(round(Tloc(k,4)*100)/100))))*' ') num2str(round(Tloc(k,4)*100)/100) '      0'...
        '   0.01  0.01  0.00  0.00        75  75  75 x                       '];
end

if exist(strcat('S:\Cortex Programs\Contextual\',['TT' posnum '.itm']),'file')
    delete(strcat('S:\Cortex Programs\Contextual\',['TT' posnum '.itm']))
end
itmfil=strcat('S:\Cortex Programs\Contextual\',['TT' posnum '.itm']);
fid = fopen(itmfil, 'wt');
fprintf(fid,'%s',itm(1,:)');
for k=1:size(itm,1)-1
    fprintf(fid,'\n%s',itm(k+1,:)');
end
fclose(fid);

