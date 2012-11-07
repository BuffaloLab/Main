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

%  0.5 is grey-- so >0.5 goes toward 1, <0.5 goes toward 0 for full bright
sampcolorarr=[0.9 0.9 0; 0.9 0 0.9; 0 0.9 0.9; 0.9 0 0; 0 0.9 0;...
    0 0 0.9; 0.9 0.9 0.9];
colorpick=randsample(7,4);
color=sampcolorarr(colorpick,:);
%color=randsample(['r' 'g' 'c' 'b' 'k' 'm' 'y' 'w'],4);
i=1;
for l = 1:20 %change last number to change # of screens produced

    pos=[];
    xpos=[2.3 3.3 4.3 5.3 6.3 7.3 8.3 9.3];
    ypos=[2.7 3.7 4.7 5.7 6.7 7.7];
    for poslop=1:100
        dum=[randsample(xpos,1,true),randsample(ypos,1,true)];
        if ismember(dum,pos,'rows')==0
            pos=[pos;dum];
        end
        if size(pos,1)==10 % # of L's and T's on screen (max 12)
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

        clrarr(k,:)=(color(ind,:));
    end
    
    for k=1:size(color,1)
        numclr=length(find(ismember(clrarr,color(k,:),'rows')));
        if numclr~=3
            Tclr=color(k,:);
        end
    end

  
    % make T color bright
%     for k=1:size(Tclr,2)
%         if Tclr(k)<=0.5;
%             Tclr(k)=0;
%         elseif Tclr(k)>0.5
%             Tclr(k)=1;
%         end
%     end
    
    for k=1:size(Tclr,2)
        if Tclr(k)<=0.1;
            Tclr(k)=0;
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
    for k=1:size(Lx,1)
        hold on
        plot(Lx(k,:),Ly(k,:),'color',clrarr(k,:),'linewidth',6);
        axis([0 12 0 9]);
    end

    Tori=randsample([1 2],1);
    if Tori==1
        hold on
        axis off
        Tpos=pos(end,:);
        line([pos(end,1) pos(end,1)],[pos(end,2)-0.6 pos(end,2)],'color',Tclr,'linewidth',6);
        line([pos(end,1) pos(end,1)+.6],[pos(end,2)-0.3 pos(end,2)-0.3],'color',Tclr,'linewidth',6);
    else
        hold on
        axis off
        Tpos=pos(end,:);
        line([pos(end,1)+.6 pos(end,1)+.6],[pos(end,2) pos(end,2)-0.6],'color',Tclr,'linewidth',6);
        line([pos(end,1)+.6 pos(end,1)],[pos(end,2)-0.3 pos(end,2)-0.3],'color',Tclr,'linewidth',6);
    end
    Tloc(l,:) = [Tpos(1)+0.3 Tpos(2)-0.3];
    setpixelposition(gcf,[0 0 1000 800]);
    set(gcf,'Position',[35 -16 1000 705]);
    setpixelposition(gca,[100 100 800 599]);    
    h=getframe(gca);
    [imgInd]=rgb2ind(h.cdata,maptoapply,'nodither');
    
    clear h
    pack

    if ~exist(strcat('S:\Contextual\',['TN' posnum]),'dir')
        mkdir('S:\Contextual\',['TN' posnum]);
    end
    newdir=strcat('S:\Contextual\',['TN' posnum]);
    imgout=strcat(newdir,'\TN',int2str(l));
    
    %Write ctx file, version that writes lookup table for first image
    im2cortbj(imgInd, maptoapply, imgout, offset,0);
    close
    
    clear imgInd
    pack

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
    '   1    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN1.ctx    ';
    '   2    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN2.ctx    ';
    '   3    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN3.ctx    ';
    '   4    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN4.ctx    ';
    '   5    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN5.ctx    ';
    '   6    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN6.ctx    ';
    '   7    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN7.ctx    ';
    '   8    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN8.ctx    ';
    '   9    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN9.ctx    ';
    '  10    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN10.ctx   ';
    '  11    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN11.ctx   ';
    '  12    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN12.ctx   ';
    '  13    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN13.ctx   ';
    '  14    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN14.ctx   ';
    '  15    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN15.ctx   ';
    '  16    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN16.ctx   ';
    '  17    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN17.ctx   ';
    '  18    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN18.ctx   ';
    '  19    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN19.ctx   ';
    '  20    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN20.ctx   ';
    '  21    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN21.ctx   ';
    '  22    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN22.ctx   ';
    '  23    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN23.ctx   ';
    '  24    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN24.ctx   ';
    '  25    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN25.ctx   ';
    '  26    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN26.ctx   ';
    '  27    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN27.ctx   ';
    '  28    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN28.ctx   ';
    '  29    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN29.ctx   ';
    '  30    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN30.ctx   ';
    '  31    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN31.ctx   ';
    '  32    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN32.ctx   ';
    '  33    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN33.ctx   ';
    '  34    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN34.ctx   ';
    '  35    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN35.ctx   ';
    '  36    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN36.ctx   ';
    '  37    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN37.ctx   ';
    '  38    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN38.ctx   ';
    '  39    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN39.ctx   ';
    '  40    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN40.ctx   ';
    '  41    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN41.ctx   ';
    '  42    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN42.ctx   ';
    '  43    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN43.ctx   ';
    '  44    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN44.ctx   ';
    '  45    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN45.ctx   ';
    '  46    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN46.ctx   ';
    '  47    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN47.ctx   ';
    '  48    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN48.ctx   ';
    '  49    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN49.ctx   ';
    '  50    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN50.ctx   ';
    '  51    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN51.ctx   ';
    '  52    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN52.ctx   ';
    '  53    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN53.ctx   ';
    '  54    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN54.ctx   ';
    '  55    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN55.ctx   ';
    '  56    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN56.ctx   ';
    '  57    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN57.ctx   ';
    '  58    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN58.ctx   ';
    '  59    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN59.ctx   ';
    '  60    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN60.ctx   ';
    '  61    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN61.ctx   ';
    '  62    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN62.ctx   ';
    '  63    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN63.ctx   ';
    '  64    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN64.ctx   ';
    '  65    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN65.ctx   ';
    '  66    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN66.ctx   ';
    '  67    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN67.ctx   ';
    '  68    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN68.ctx   ';
    '  69    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN69.ctx   ';
    '  70    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN70.ctx   ';
    '  71    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN71.ctx   ';
    '  72    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN72.ctx   ';
    '  73    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN73.ctx   ';
    '  74    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN74.ctx   ';
    '  75    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN75.ctx   ';
    '  76    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN76.ctx   ';
    '  77    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN77.ctx   ';
    '  78    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN78.ctx   ';
    '  79    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN79.ctx   ';
    '  80    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN80.ctx   ';
    '  81    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN81.ctx   ';
    '  82    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN82.ctx   ';
    '  83    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN83.ctx   ';
    '  84    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN84.ctx   ';
    '  85    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN85.ctx   ';
    '  86    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN86.ctx   ';
    '  87    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN87.ctx   ';
    '  88    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN88.ctx   ';
    '  89    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN89.ctx   ';
    '  90    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN90.ctx   ';
    '  91    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN91.ctx   ';
    '  92    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN92.ctx   ';
    '  93    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN93.ctx   ';
    '  94    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN94.ctx   ';
    '  95    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN95.ctx   ';
    '  96    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN96.ctx   ';
    '  97    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN97.ctx   ';
    '  98    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN98.ctx   ';
    '  99    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN99.ctx   ';
    ' 100    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN100.ctx  ';
    ' 101    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN101.ctx  ';
    ' 102    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN102.ctx  ';
    ' 103    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN103.ctx  ';
    ' 104    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN104.ctx  ';
    ' 105    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN105.ctx  ';
    ' 106    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN106.ctx  ';
    ' 107    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN107.ctx  ';
    ' 108    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN108.ctx  ';
    ' 109    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN109.ctx  ';
    ' 110    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN110.ctx  ';
    ' 111    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN111.ctx  ';
    ' 112    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN112.ctx  ';
    ' 113    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN113.ctx  ';
    ' 114    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN114.ctx  ';
    ' 115    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN115.ctx  ';
    ' 116    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN116.ctx  ';
    ' 117    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN117.ctx  ';
    ' 118    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN118.ctx  ';
    ' 119    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN119.ctx  ';
    ' 120    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN120.ctx  ';
    ' 121    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN121.ctx  ';
    ' 122    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN122.ctx  ';
    ' 123    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN123.ctx  ';
    ' 124    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN124.ctx  ';
    ' 125    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN125.ctx  ';
    ' 126    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN126.ctx  ';
    ' 127    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN127.ctx  ';
    ' 128    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN128.ctx  ';
    ' 129    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN129.ctx  ';
    ' 130    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN130.ctx  ';
    ' 131    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN131.ctx  ';
    ' 132    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN132.ctx  ';
    ' 133    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN133.ctx  ';
    ' 134    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN134.ctx  ';
    ' 135    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN135.ctx  ';
    ' 136    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN136.ctx  ';
    ' 137    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN137.ctx  ';
    ' 138    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN138.ctx  ';
    ' 139    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN139.ctx  ';
    ' 140    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN140.ctx  ';
    ' 141    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN141.ctx  ';
    ' 142    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN142.ctx  ';
    ' 143    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN143.ctx  ';
    ' 144    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN144.ctx  ';
    ' 145    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN145.ctx  ';
    ' 146    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN146.ctx  ';
    ' 147    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN147.ctx  ';
    ' 148    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN148.ctx  ';
    ' 149    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN149.ctx  ';
    ' 150    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN150.ctx  ';
    ' 151    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN151.ctx  ';
    ' 152    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN152.ctx  ';
    ' 153    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN153.ctx  ';
    ' 154    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN154.ctx  ';
    ' 155    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN155.ctx  ';
    ' 156    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN156.ctx  ';
    ' 157    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN157.ctx  ';
    ' 158    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN158.ctx  ';
    ' 159    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN159.ctx  ';
    ' 160    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN160.ctx  ';
    ' 161    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN161.ctx  ';
    ' 162    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN162.ctx  ';
    ' 163    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN163.ctx  ';
    ' 164    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN164.ctx  ';
    ' 165    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN165.ctx  ';
    ' 166    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN166.ctx  ';
    ' 167    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN167.ctx  ';
    ' 168    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN168.ctx  ';
    ' 169    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN169.ctx  ';
    ' 170    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN170.ctx  ';
    ' 171    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN171.ctx  ';
    ' 172    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN172.ctx  ';
    ' 173    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN173.ctx  ';
    ' 174    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN174.ctx  ';
    ' 175    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN175.ctx  ';
    ' 176    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN176.ctx  ';
    ' 177    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN177.ctx  ';
    ' 178    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN178.ctx  ';
    ' 179    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN179.ctx  ';
    ' 180    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN180.ctx  ';
    ' 181    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN181.ctx  ';
    ' 182    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN182.ctx  ';
    ' 183    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN183.ctx  ';
    ' 184    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN184.ctx  ';
    ' 185    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN185.ctx  ';
    ' 186    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN186.ctx  ';
    ' 187    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN187.ctx  ';
    ' 188    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN188.ctx  ';
    ' 189    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN189.ctx  ';
    ' 190    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN190.ctx  ';
    ' 191    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN191.ctx  ';
    ' 192    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN192.ctx  ';
    ' 193    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN193.ctx  ';
    ' 194    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN194.ctx  ';
    ' 195    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN195.ctx  ';
    ' 196    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN196.ctx  ';
    ' 197    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN197.ctx  ';
    ' 198    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN198.ctx  ';
    ' 199    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN199.ctx  ';
    ' 200    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN200.ctx  ';
    ' 201    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN201.ctx  ';
    ' 202    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN202.ctx  ';
    ' 203    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN203.ctx  ';
    ' 204    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN204.ctx  ';
    ' 205    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN205.ctx  ';
    ' 206    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN206.ctx  ';
    ' 207    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN207.ctx  ';
    ' 208    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN208.ctx  ';
    ' 209    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN209.ctx  ';
    ' 210    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN210.ctx  ';
    ' 211    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN211.ctx  ';
    ' 212    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN212.ctx  ';
    ' 213    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN213.ctx  ';
    ' 214    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN214.ctx  ';
    ' 215    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN215.ctx  ';
    ' 216    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN216.ctx  ';
    ' 217    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN217.ctx  ';
    ' 218    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN218.ctx  ';
    ' 219    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN219.ctx  ';
    ' 220    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN220.ctx  ';
    ' 221    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN221.ctx  ';
    ' 222    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN222.ctx  ';
    ' 223    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN223.ctx  ';
    ' 224    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN224.ctx  ';
    ' 225    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN225.ctx  ';
    ' 226    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN226.ctx  ';
    ' 227    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN227.ctx  ';
    ' 228    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN228.ctx  ';
    ' 229    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN229.ctx  ';
    ' 230    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN230.ctx  ';
    ' 231    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN231.ctx  ';
    ' 232    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN232.ctx  ';
    ' 233    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN233.ctx  ';
    ' 234    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN234.ctx  ';
    ' 235    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN235.ctx  ';
    ' 236    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN236.ctx  ';
    ' 237    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN237.ctx  ';
    ' 238    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN238.ctx  ';
    ' 239    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN239.ctx  ';
    ' 240    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN240.ctx  ';
    ' 241    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN241.ctx  ';
    ' 242    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN242.ctx  ';
    ' 243    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN243.ctx  ';
    ' 244    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN244.ctx  ';
    ' 245    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN245.ctx  ';
    ' 246    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN246.ctx  ';
    ' 247    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN247.ctx  ';
    ' 248    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN248.ctx  ';
    ' 249    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN249.ctx  ';
    ' 250    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN250.ctx  ';
    ' 251    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN251.ctx  ';
    ' 252    8           0.00    0.00      0                                 75  75  75 x   C:\TN' posnum '\TN252.ctx  '];

for k=1:size(Tloc,1)
    nextitm=str2num(itm(end,double(2:4)));
    itm=[itm;
        ' ' num2str(nextitm+1) '    1      0' char(ones(1,(8-length(num2str(round(Tloc(k,3)*100)/100))))*' ') num2str(round(Tloc(k,3)*100)/100) ...
        char(ones(1,(8-length(num2str(round(Tloc(k,4)*100)/100))))*' ') num2str(round(Tloc(k,4)*100)/100) '      0'...
        '   0.01  0.01  0.00  0.00        75  75  75 x                       '];
end

if exist(strcat('S:\Cortex Programs\Contextual\',['TN' posnum '.itm']),'file')
    delete(strcat('S:\Cortex Programs\Contextual\',['TN' posnum '.itm']))
end
itmfil=strcat('S:\Cortex Programs\Contextual\',['TN' posnum '.itm']);
fid = fopen(itmfil, 'wt');
fprintf(fid,'%s',itm(1,:)');
for k=1:size(itm,1)-1
    fprintf(fid,'\n%s',itm(k+1,:)');
end
fclose(fid);

