% % TLgrayscale 110524 MT
% %
% % this version of the contextual task uses 24 contexts per block, 12 of which are
% % repeated without change every block ("Old") and 12 of which are novel
% % however, at block 13 (determined by review of when learning has
% % reliably occurred in previous sets of TL2), color is eliminated
% % and all contexts are grayscale.  The 'OLD' contexts have the same
% % context just excluding color, and the novel contexts continue to be novel
% % each block but are also grey

% %
% % there are 24 'OLD' contexts made (odd # contexts are in color, even #
% % are in grayscale with same layout as the preceeding odd number)
% % 60 total blocks
% % 144 novel contexts in color = 12 blocks * 12 novel color contexts
% % 576 novel contexts in grayscale = 48 remaining blocks *12 novel grey images
% %
% % 7 isoluminant colors, 4 chosen randomly for each set

% % CHANGE OFFSET HERE! (comment all out but one)
% % (must add up to .6, closer values = harder task)
% dist_offset=[.50 .10];
% dist_offset=[.45 .15];
% dist_offset=[.40 .20]; timmy/guiseppe
% dist_offset=[.35 .25]; peepers
close all
clear all
pack all
clc

dist_offset=[.35 .25];
% % CHANGE BLOCK NUMBER WHERE MANIPULATION BEGINS HERE!!!
manipblkdum=21;

manipblk=num2str(manipblkdum);

rand('twister',sum(100*clock)); % initialize random number generator

% choose the name of the folder & item file

d=dir('S:\Contextual\');
clear filelist
i=1;
for k=1:length(d)
    if length(d(k).name)==7
        if d(k).name(1:4)== strcat(manipblk,'bw');
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

% determine numbering based on offset
if dist_offset(1)==.50 && dist_offset(2)==.10
    numlist=(numlist(numlist>=100 & numlist<200));
    if ~isempty(numlist)
        posnumdum=num2str(max(numlist)+1);
    else
        posnumdum='100';
    end
elseif dist_offset(1)==.45 && dist_offset(2)==.15
    numlist=(numlist(numlist>=200 & numlist<300));
    if ~isempty(numlist)
        posnumdum=num2str(max(numlist)+1);
    else
        posnumdum='200';
    end
elseif dist_offset(1)==.40 && dist_offset(2)==.20
    numlist=(numlist(numlist>=300 & numlist<400));
    if ~isempty(numlist)
        posnumdum=num2str(max(numlist)+1);
    else
        posnumdum='300';
    end
elseif dist_offset(1)==.35 && dist_offset(2)==.25
    numlist=(numlist(numlist>=400 & numlist<500));
    if ~isempty(numlist)
        posnumdum=num2str(max(numlist)+1);
    else
        posnumdum='400';
    end
end

% turn posnumdum into 3-digit string
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

% color=randsample(['r' 'g' 'c' 'b' 'm' 'y' 'w'],4);
% color=randsample(['r' 'g' 'c' 'b' 'm' 'y'],4);
rgbval=[0.611764705882353   0.580392156862745   0.580392156862745;
    0.870588235294118   0.450980392156863   0.062745098039216;
    0.419607843137255   0.647058823529412   0.388235294117647;
    0.905882352941176   0.388235294117647   0.290196078431373;
    0.031372549019608   0.709803921568627   0.094117647058824;
    0.807843137254902   0.419607843137255   0.741176470588235;
    0.321568627450980   0.580392156862745   0.870588235294118];
color=randsample(7,4);

% make "old" contexts (odd numbers in color, even in grayscale)
i=1;
for l = 1:24 %makes 12 in color and cooresponding 12 same configuration but in grayscale
 if l==1||l==3||l==5||l==7||l==9||l==11||l==13||l==15||l==17||l==19||l==21||l==23; % find all repeated odd figures, these will be in color
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
        Larrx=[r (r+.6) (r+dist_offset(1)) (r+dist_offset(1)); ...
            (r+.6) (r+.6) r (r+.6); ...
            r (r+.6) r r; ...
            r (r+.6) r r];
        Larry=[p p p (p-.6); ...
            (p-.6) p (p-dist_offset(1)) (p-dist_offset(1)); ...
            (p-dist_offset(1))  (p-dist_offset(1)) p (p-.6); ...
            (p-dist_offset(2)) (p-dist_offset(2)) p (p-.6)];
        
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
    for k=1:size(Lx,1)
        hold on
        line([Lx(k,1) Lx(k,2)],[Ly(k,1) Ly(k,2)],'color',rgbval(clrarr(k),:),'linewidth',6);
        line([Lx(k,3) Lx(k,4)],[Ly(k,3) Ly(k,4)],'color',rgbval(clrarr(k),:),'linewidth',6);
        axis([0 12 0 9]);
    end

    Tori=randsample([1 2],1);
    if Tori==1
        hold on
        axis off
        Tpos=pos(12,:);
        line([pos(12,1) pos(12,1)],[pos(12,2)-0.6 pos(12,2)],'color',rgbval(Tclr,:),'linewidth',6);
        line([pos(12,1) pos(12,1)+.6],[pos(12,2)-0.3 pos(12,2)-0.3],'color',rgbval(Tclr,:),'linewidth',6);
    else
        hold on
        axis off
        Tpos=pos(12,:);
        line([pos(12,1)+.6 pos(12,1)+.6],[pos(12,2) pos(12,2)-0.6],'color',rgbval(Tclr,:),'linewidth',6);
        line([pos(12,1)+.6 pos(12,1)],[pos(12,2)-0.3 pos(12,2)-0.3],'color',rgbval(Tclr,:),'linewidth',6);
    end
    Tloc(l,:) = [Tpos(1)+0.3 Tpos(2)-0.3];
    setpixelposition(gcf,[0 0 1000 800]);
    set(gcf,'Position',[35 -16 1000 705]);
    setpixelposition(gca,[100 100 800 599]);    
    h=getframe(gca);
    [imgInd]=rgb2ind(h.cdata,maptoapply,'nodither');


    clear h
    pack 

    if ~exist(strcat('S:\Contextual\',[manipblk 'bw' posnum]),'dir')
        mkdir('S:\Contextual\',[manipblk 'bw' posnum]);
    end

    newdir=strcat('S:\Contextual\',[manipblk 'bw' posnum]);
    imgout=strcat(newdir,'\TL',int2str(l));
    
    
%     %Write ctx file, version that writes lookup table for first image
    im2cortbj(imgInd, maptoapply, imgout, offset,0);

    
   close
    i=i+1;
 else
     figure(i)
%     set(gcf,'InvertHardcopy','off');
%     axes('Parent',gcf,'Color',[0.5 0.5 0.5]);
    set(gca,'XTickMode','manual','YTickMode','manual');
%     set(gca,'XTick',[],'YTick',[],'ZColor',[0.5 0.5 0.5],'YColor',[0.5 0.5 0.5],'XColor',[0.5 0.5 0.5]);
    rectangle('Position',[0 0 12 9],'FaceColor',[0 0 0],'EdgeColor',[0 0 0])
    for k=1:size(Lx,1)
        hold on
        line([Lx(k,1) Lx(k,2)],[Ly(k,1) Ly(k,2)],'color',[.5 .5 .5],'linewidth',6); % items will be gray with 30% color saturation
        line([Lx(k,3) Lx(k,4)],[Ly(k,3) Ly(k,4)],'color',[.5 .5 .5],'linewidth',6);
        axis([0 12 0 9]);
    end

    %Tori=randsample([1 2],1);
    if Tori==1
        hold on
        axis off
        Tpos=pos(12,:);
        line([pos(12,1) pos(12,1)],[pos(12,2)-0.6 pos(12,2)],'color',[.5 .5 .5],'linewidth',6);
        line([pos(12,1) pos(12,1)+.6],[pos(12,2)-0.3 pos(12,2)-0.3],'color',[.5 .5 .5],'linewidth',6);
    else
        hold on
        axis off
        Tpos=pos(12,:);
        line([pos(12,1)+.6 pos(12,1)+.6],[pos(12,2) pos(12,2)-0.6],'color',[.5 .5 .5],'linewidth',6);
        line([pos(12,1)+.6 pos(12,1)],[pos(12,2)-0.3 pos(12,2)-0.3],'color',[.5 .5 .5],'linewidth',6);
    end
    Tloc(l,:) = [Tpos(1)+0.3 Tpos(2)-0.3];
    setpixelposition(gcf,[0 0 1000 800]);
    set(gcf,'Position',[35 -16 1000 705]);
    setpixelposition(gca,[100 100 800 599]);    
    h=getframe(gca);
    [imgInd]=rgb2ind(h.cdata,maptoapply,'nodither');


    clear h
    pack 

    imgout=strcat(newdir,'\TL',int2str(i));
    
    
    %Write ctx file, version that writes lookup table for first image
    im2cortbj(imgInd, maptoapply, imgout, offset,0);

   close    
    clear imgInd
    pack
    
    i=i+1;
 end
end

%  make novel images 
i=25;
for l = 25:744; 
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
        Larrx=[r (r+.6) (r+dist_offset(1)) (r+dist_offset(1)); ...
            (r+.6) (r+.6) r (r+.6); ...
            r (r+.6) r r; ...
            r (r+.6) r r];
        Larry=[p p p (p-.6); ...
            (p-.6) p (p-dist_offset(1)) (p-dist_offset(1)); ...
            (p-dist_offset(1))  (p-dist_offset(1)) p (p-.6); ...
            (p-dist_offset(2)) (p-dist_offset(2)) p (p-.6)];
        
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
    
    manipswitch = ((manipblkdum-1)*12 +25);
    if l < manipswitch;
    figure(i)
%     set(gcf,'InvertHardcopy','off');
%     axes('Parent',gcf,'Color',[0.5 0.5 0.5]);
    set(gca,'XTickMode','manual','YTickMode','manual');
%     set(gca,'XTick',[],'YTick',[],'ZColor',[0.5 0.5 0.5],'YColor',[0.5 0.5 0.5],'XColor',[0.5 0.5 0.5]);
    rectangle('Position',[0 0 12 9],'FaceColor',[0 0 0],'EdgeColor',[0 0 0])
    for k=1:size(Lx,1)
        hold on
        line([Lx(k,1) Lx(k,2)],[Ly(k,1) Ly(k,2)],'color',rgbval(clrarr(k),:),'linewidth',6);
        line([Lx(k,3) Lx(k,4)],[Ly(k,3) Ly(k,4)],'color',rgbval(clrarr(k),:),'linewidth',6);
        axis([0 12 0 9]);
    end

    Tori=randsample([1 2],1);
    if Tori==1
        hold on
        axis off
        Tpos=pos(12,:);
        line([pos(12,1) pos(12,1)],[pos(12,2)-0.6 pos(12,2)],'color',rgbval(Tclr,:),'linewidth',6);
        line([pos(12,1) pos(12,1)+.6],[pos(12,2)-0.3 pos(12,2)-0.3],'color',rgbval(Tclr,:),'linewidth',6);
    else
        hold on
        axis off
        Tpos=pos(12,:);
        line([pos(12,1)+.6 pos(12,1)+.6],[pos(12,2) pos(12,2)-0.6],'color',rgbval(Tclr,:),'linewidth',6);
        line([pos(12,1)+.6 pos(12,1)],[pos(12,2)-0.3 pos(12,2)-0.3],'color',rgbval(Tclr,:),'linewidth',6);
    end
    else
       figure(i)
%     set(gcf,'InvertHardcopy','off');
%     axes('Parent',gcf,'Color',[0.5 0.5 0.5]);
    set(gca,'XTickMode','manual','YTickMode','manual');
%     set(gca,'XTick',[],'YTick',[],'ZColor',[0.5 0.5 0.5],'YColor',[0.5 0.5 0.5],'XColor',[0.5 0.5 0.5]);
    rectangle('Position',[0 0 12 9],'FaceColor',[0 0 0],'EdgeColor',[0 0 0])
    for k=1:size(Lx,1)
        hold on
        line([Lx(k,1) Lx(k,2)],[Ly(k,1) Ly(k,2)],'color',[.5 .5 .5],'linewidth',6);
        line([Lx(k,3) Lx(k,4)],[Ly(k,3) Ly(k,4)],'color',[.5 .5 .5],'linewidth',6);
        axis([0 12 0 9]);
    end

    Tori=randsample([1 2],1);
    if Tori==1
        hold on
        axis off
        Tpos=pos(12,:);
        line([pos(12,1) pos(12,1)],[pos(12,2)-0.6 pos(12,2)],'color',[.5 .5 .5],'linewidth',6);
        line([pos(12,1) pos(12,1)+.6],[pos(12,2)-0.3 pos(12,2)-0.3],'color',[.5 .5 .5],'linewidth',6);
    else
        hold on
        axis off
        Tpos=pos(12,:);
        line([pos(12,1)+.6 pos(12,1)+.6],[pos(12,2) pos(12,2)-0.6],'color',[.5 .5 .5],'linewidth',6);
        line([pos(12,1)+.6 pos(12,1)],[pos(12,2)-0.3 pos(12,2)-0.3],'color',[.5 .5 .5],'linewidth',6);
    end 
    end
    Tloc(l,:) = [Tpos(1)+0.3 Tpos(2)-0.3];
    setpixelposition(gcf,[0 0 1000 800]);
    set(gcf,'Position',[35 -16 1000 705]);
    setpixelposition(gca,[100 100 800 599]);    
    h=getframe(gca);
    [imgInd]=rgb2ind(h.cdata,maptoapply,'nodither');


    clear h
    pack 

    imgout=strcat(newdir,'\TL',int2str(l));
       
%     %Write ctx file, version that writes lookup table for first image
    im2cortbj(imgInd, maptoapply, imgout, offset,0);

    
    close
    pack
    
    i=i+1;

end

% translate Tloc values to degree coordinates

for k=1:size(Tloc,1)
    Tloc(k,3)=(66*(Tloc(k,1)-6))/24;
    Tloc(k,4)=(66*(Tloc(k,2)-4.5))/24;
end

xlswrite(['S:\Tloc\Tloc' manipblk 'bw' posnum],Tloc)
disp(['Generated stimuli for ' manipblk 'bw' posnum])

%% find eccentricity of T location to center crosshairs
clear repa2 repb2 repc2 repc

for k=1:24;
    if k==1||k==3||k==5||k==7||k==9||k==11||k==13||k==15||k==17||k==19||k==21||k==23;
    repa2(k)=Tloc(k,3);
    repb2(k)=Tloc(k,4);
    repc2(k)=repa2(k)^2 + repb2(k)^2;
    repc(k)=sqrt(repc2(k));
    else
        repc(k)=NaN;
        k=k+1;
    end
end


clear newa2 newb2 newc2 newc
for k=25:(size(Tloc,1));
    newa2(k-12)=Tloc(k,3);
    newb2(k-12)=Tloc(k,4);
    newc2(k-12)=newa2(k-12)^2 + newb2(k-12)^2;
    newc(k-12)=sqrt(newc2(k-12));
end

[h,p] = ttest2(repc,newc);
if h == 0;
    disp('OK to use this set')
else
    disp('DO NOT USE SET, DELETE FROM CONTEXTUAL FOLDER AND TLOC FOLDER AND MAKE NEW SET')
    beep
end
%% make item file

itm=['ITEM TYPE FILLED CENTERX CENTERY BITPAN HEIGHT WIDTH ANGLE OUTER INNER -R- -G- -B- C A ------FILENAME------';
    '  -4    1      1    0.00    0.00      0   1.00  1.00  0.00               0   0   0 l                       ';
    '  -3   14      1    0.00    0.00      0   0.50  0.50  0.00             255 255 255 x                       ';
    '  -2    1      1    0.00    0.00      0   0.20  0.20  0.00  0.50       100 100 100 x                       ';
    '  -1    1      0    0.00    0.00      0   1.00  1.00  0.00             255 255 255 x                       ';
    '   0    1      1    0.00    0.00      0   0.15  0.15  0.00              37  63  49 x                       ';
    '   1    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL1.ctx  ';
    '   2    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL2.ctx  ';
    '   3    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL3.ctx  ';
    '   4    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL4.ctx  ';
    '   5    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL5.ctx  ';
    '   6    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL6.ctx  ';
    '   7    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL7.ctx  ';
    '   8    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL8.ctx  ';
    '   9    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL9.ctx  ';
    '  10    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL10.ctx ';
    '  11    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL11.ctx ';
    '  12    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL12.ctx ';
    '  13    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL13.ctx ';
    '  14    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL14.ctx ';
    '  15    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL15.ctx ';
    '  16    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL16.ctx ';
    '  17    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL17.ctx ';
    '  18    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL18.ctx ';
    '  19    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL19.ctx ';
    '  20    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL20.ctx ';
    '  21    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL21.ctx ';
    '  22    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL22.ctx ';
    '  23    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL23.ctx ';
    '  24    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL24.ctx ';
    '  25    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL25.ctx ';
    '  26    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL26.ctx ';
    '  27    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL27.ctx ';
    '  28    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL28.ctx ';
    '  29    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL29.ctx ';
    '  30    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL30.ctx ';
    '  31    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL31.ctx ';
    '  32    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL32.ctx ';
    '  33    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL33.ctx ';
    '  34    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL34.ctx ';
    '  35    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL35.ctx ';
    '  36    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL36.ctx ';
    '  37    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL37.ctx ';
    '  38    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL38.ctx ';
    '  39    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL39.ctx ';
    '  40    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL40.ctx ';
    '  41    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL41.ctx ';
    '  42    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL42.ctx ';
    '  43    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL43.ctx ';
    '  44    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL44.ctx ';
    '  45    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL45.ctx ';
    '  46    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL46.ctx ';
    '  47    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL47.ctx ';
    '  48    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL48.ctx ';
    '  49    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL49.ctx ';
    '  50    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL50.ctx ';
    '  51    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL51.ctx ';
    '  52    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL52.ctx ';
    '  53    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL53.ctx ';
    '  54    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL54.ctx ';
    '  55    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL55.ctx ';
    '  56    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL56.ctx ';
    '  57    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL57.ctx ';
    '  58    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL58.ctx ';
    '  59    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL59.ctx ';
    '  60    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL60.ctx ';
    '  61    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL61.ctx ';
    '  62    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL62.ctx ';
    '  63    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL63.ctx ';
    '  64    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL64.ctx ';
    '  65    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL65.ctx ';
    '  66    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL66.ctx ';
    '  67    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL67.ctx ';
    '  68    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL68.ctx ';
    '  69    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL69.ctx ';
    '  70    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL70.ctx ';
    '  71    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL71.ctx ';
    '  72    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL72.ctx ';
    '  73    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL73.ctx ';
    '  74    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL74.ctx ';
    '  75    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL75.ctx ';
    '  76    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL76.ctx ';
    '  77    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL77.ctx ';
    '  78    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL78.ctx ';
    '  79    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL79.ctx ';
    '  80    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL80.ctx ';
    '  81    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL81.ctx ';
    '  82    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL82.ctx ';
    '  83    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL83.ctx ';
    '  84    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL84.ctx ';
    '  85    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL85.ctx ';
    '  86    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL86.ctx ';
    '  87    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL87.ctx ';
    '  88    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL88.ctx ';
    '  89    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL89.ctx ';
    '  90    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL90.ctx ';
    '  91    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL91.ctx ';
    '  92    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL92.ctx ';
    '  93    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL93.ctx ';
    '  94    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL94.ctx ';
    '  95    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL95.ctx ';
    '  96    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL96.ctx ';
    '  97    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL97.ctx ';
    '  98    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL98.ctx ';
    '  99    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL99.ctx ';
    ' 100    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL100.ctx';
    ' 101    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL101.ctx';
    ' 102    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL102.ctx';
    ' 103    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL103.ctx';
    ' 104    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL104.ctx';
    ' 105    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL105.ctx';
    ' 106    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL106.ctx';
    ' 107    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL107.ctx';
    ' 108    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL108.ctx';
    ' 109    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL109.ctx';
    ' 110    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL110.ctx';
    ' 111    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL111.ctx';
    ' 112    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL112.ctx';
    ' 113    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL113.ctx';
    ' 114    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL114.ctx';
    ' 115    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL115.ctx';
    ' 116    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL116.ctx';
    ' 117    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL117.ctx';
    ' 118    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL118.ctx';
    ' 119    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL119.ctx';
    ' 120    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL120.ctx';
    ' 121    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL121.ctx';
    ' 122    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL122.ctx';
    ' 123    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL123.ctx';
    ' 124    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL124.ctx';
    ' 125    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL125.ctx';
    ' 126    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL126.ctx';
    ' 127    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL127.ctx';
    ' 128    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL128.ctx';
    ' 129    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL129.ctx';
    ' 130    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL130.ctx';
    ' 131    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL131.ctx';
    ' 132    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL132.ctx';
    ' 133    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL133.ctx';
    ' 134    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL134.ctx';
    ' 135    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL135.ctx';
    ' 136    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL136.ctx';
    ' 137    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL137.ctx';
    ' 138    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL138.ctx';
    ' 139    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL139.ctx';
    ' 140    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL140.ctx';
    ' 141    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL141.ctx';
    ' 142    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL142.ctx';
    ' 143    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL143.ctx';
    ' 144    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL144.ctx';
    ' 145    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL145.ctx';
    ' 146    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL146.ctx';
    ' 147    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL147.ctx';
    ' 148    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL148.ctx';
    ' 149    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL149.ctx';
    ' 150    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL150.ctx';
    ' 151    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL151.ctx';
    ' 152    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL152.ctx';
    ' 153    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL153.ctx';
    ' 154    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL154.ctx';
    ' 155    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL155.ctx';
    ' 156    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL156.ctx';
    ' 157    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL157.ctx';
    ' 158    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL158.ctx';
    ' 159    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL159.ctx';
    ' 160    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL160.ctx';
    ' 161    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL161.ctx';
    ' 162    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL162.ctx';
    ' 163    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL163.ctx';
    ' 164    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL164.ctx';
    ' 165    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL165.ctx';
    ' 166    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL166.ctx';
    ' 167    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL167.ctx';
    ' 168    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL168.ctx';
    ' 169    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL169.ctx';
    ' 170    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL170.ctx';
    ' 171    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL171.ctx';
    ' 172    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL172.ctx';
    ' 173    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL173.ctx';
    ' 174    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL174.ctx';
    ' 175    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL175.ctx';
    ' 176    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL176.ctx';
    ' 177    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL177.ctx';
    ' 178    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL178.ctx';
    ' 179    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL179.ctx';
    ' 180    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL180.ctx';
    ' 181    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL181.ctx';
    ' 182    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL182.ctx';
    ' 183    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL183.ctx';
    ' 184    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL184.ctx';
    ' 185    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL185.ctx';
    ' 186    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL186.ctx';
    ' 187    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL187.ctx';
    ' 188    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL188.ctx';
    ' 189    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL189.ctx';
    ' 190    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL190.ctx';
    ' 191    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL191.ctx';
    ' 192    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL192.ctx';
    ' 193    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL193.ctx';
    ' 194    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL194.ctx';
    ' 195    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL195.ctx';
    ' 196    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL196.ctx';
    ' 197    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL197.ctx';
    ' 198    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL198.ctx';
    ' 199    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL199.ctx';
    ' 200    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL200.ctx';
    ' 201    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL201.ctx';
    ' 202    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL202.ctx';
    ' 203    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL203.ctx';
    ' 204    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL204.ctx';
    ' 205    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL205.ctx';
    ' 206    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL206.ctx';
    ' 207    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL207.ctx';
    ' 208    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL208.ctx';
    ' 209    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL209.ctx';
    ' 210    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL210.ctx';
    ' 211    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL211.ctx';
    ' 212    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL212.ctx';
    ' 213    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL213.ctx';
    ' 214    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL214.ctx';
    ' 215    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL215.ctx';
    ' 216    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL216.ctx';
    ' 217    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL217.ctx';
    ' 218    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL218.ctx';
    ' 219    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL219.ctx';
    ' 220    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL220.ctx';
    ' 221    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL221.ctx';
    ' 222    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL222.ctx';
    ' 223    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL223.ctx';
    ' 224    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL224.ctx';
    ' 225    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL225.ctx';
    ' 226    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL226.ctx';
    ' 227    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL227.ctx';
    ' 228    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL228.ctx';
    ' 229    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL229.ctx';
    ' 230    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL230.ctx';
    ' 231    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL231.ctx';
    ' 232    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL232.ctx';
    ' 233    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL233.ctx';
    ' 234    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL234.ctx';
    ' 235    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL235.ctx';
    ' 236    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL236.ctx';
    ' 237    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL237.ctx';
    ' 238    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL238.ctx';
    ' 239    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL239.ctx';
    ' 240    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL240.ctx';
    ' 241    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL241.ctx';
    ' 242    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL242.ctx';
    ' 243    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL243.ctx';
    ' 244    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL244.ctx';
    ' 245    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL245.ctx';
    ' 246    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL246.ctx';
    ' 247    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL247.ctx';
    ' 248    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL248.ctx';
    ' 249    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL249.ctx';
    ' 250    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL250.ctx';
    ' 251    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL251.ctx';
    ' 252    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL252.ctx';
    ' 251    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL251.ctx';
    ' 252    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL252.ctx';
    ' 253    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL253.ctx';
    ' 254    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL254.ctx';
    ' 255    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL255.ctx';
    ' 256    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL256.ctx';
    ' 257    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL257.ctx';
    ' 258    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL258.ctx';
    ' 259    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL259.ctx';
    ' 260    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL260.ctx';
    ' 261    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL261.ctx';
    ' 262    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL262.ctx';
    ' 263    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL263.ctx';
    ' 264    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL264.ctx';
    ' 265    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL265.ctx';
    ' 266    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL266.ctx';
    ' 267    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL267.ctx';
    ' 268    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL268.ctx';
    ' 269    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL269.ctx';
    ' 270    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL270.ctx';
    ' 271    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL271.ctx';
    ' 272    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL272.ctx';
    ' 273    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL273.ctx';
    ' 274    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL274.ctx';
    ' 275    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL275.ctx';
    ' 276    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL276.ctx';
    ' 277    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL277.ctx';
    ' 278    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL278.ctx';
    ' 279    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL279.ctx';
    ' 280    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL280.ctx';
    ' 281    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL281.ctx';
    ' 282    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL282.ctx';
    ' 283    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL283.ctx';
    ' 284    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL284.ctx';
    ' 285    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL285.ctx';
    ' 286    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL286.ctx';
    ' 287    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL287.ctx';
    ' 288    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL288.ctx';
    ' 289    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL289.ctx';
    ' 290    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL290.ctx';
    ' 291    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL291.ctx';
    ' 292    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL292.ctx';
    ' 293    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL293.ctx';
    ' 294    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL294.ctx';
    ' 295    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL295.ctx';
    ' 296    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL296.ctx';
    ' 297    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL297.ctx';
    ' 298    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL298.ctx';
    ' 299    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL299.ctx';
    ' 300    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL300.ctx';
    ' 301    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL301.ctx';
    ' 302    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL302.ctx';
    ' 303    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL303.ctx';
    ' 304    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL304.ctx';
    ' 305    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL305.ctx';
    ' 306    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL306.ctx';
    ' 307    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL307.ctx';
    ' 308    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL308.ctx';
    ' 309    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL309.ctx';
    ' 310    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL310.ctx';
    ' 311    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL311.ctx';
    ' 312    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL312.ctx';
    ' 313    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL313.ctx';
    ' 314    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL314.ctx';
    ' 315    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL315.ctx';
    ' 316    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL316.ctx';
    ' 317    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL317.ctx';
    ' 318    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL318.ctx';
    ' 319    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL319.ctx';
    ' 320    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL320.ctx';
    ' 321    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL321.ctx';
    ' 322    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL322.ctx';
    ' 323    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL323.ctx';
    ' 324    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL324.ctx';
    ' 325    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL325.ctx';
    ' 326    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL326.ctx';
    ' 327    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL327.ctx';
    ' 328    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL328.ctx';
    ' 329    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL329.ctx';
    ' 330    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL330.ctx';
    ' 331    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL331.ctx';
    ' 332    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL332.ctx';
    ' 333    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL333.ctx';
    ' 334    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL334.ctx';
    ' 335    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL335.ctx';
    ' 336    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL336.ctx';
    ' 337    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL337.ctx';
    ' 338    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL338.ctx';
    ' 339    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL339.ctx';
    ' 340    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL340.ctx';
    ' 341    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL341.ctx';
    ' 342    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL342.ctx';
    ' 343    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL343.ctx';
    ' 344    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL344.ctx';
    ' 345    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL345.ctx';
    ' 346    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL346.ctx';
    ' 347    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL347.ctx';
    ' 348    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL348.ctx';
    ' 349    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL349.ctx';
    ' 350    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL350.ctx';
    ' 351    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL351.ctx';
    ' 352    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL352.ctx';
    ' 353    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL353.ctx';
    ' 354    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL354.ctx';
    ' 355    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL355.ctx';
    ' 356    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL356.ctx';
    ' 357    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL357.ctx';
    ' 358    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL358.ctx';
    ' 359    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL359.ctx';
    ' 360    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL360.ctx';
    ' 361    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL361.ctx';
    ' 362    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL362.ctx';
    ' 363    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL363.ctx';
    ' 364    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL364.ctx';
    ' 365    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL365.ctx';
    ' 366    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL366.ctx';
    ' 367    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL367.ctx';
    ' 368    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL368.ctx';
    ' 369    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL369.ctx';
    ' 370    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL370.ctx';
    ' 371    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL371.ctx';
    ' 372    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL372.ctx';
    ' 373    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL373.ctx';
    ' 374    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL374.ctx';
    ' 375    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL375.ctx';
    ' 376    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL376.ctx';
    ' 377    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL377.ctx';
    ' 378    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL378.ctx';
    ' 379    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL379.ctx';
    ' 380    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL380.ctx';
    ' 381    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL381.ctx';
    ' 382    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL382.ctx';
    ' 383    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL383.ctx';
    ' 384    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL384.ctx';
    ' 385    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL385.ctx';
    ' 386    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL386.ctx';
    ' 387    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL387.ctx';
    ' 388    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL388.ctx';
    ' 389    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL389.ctx';
    ' 390    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL390.ctx';
    ' 391    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL391.ctx';
    ' 392    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL392.ctx';
    ' 393    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL393.ctx';
    ' 394    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL394.ctx';
    ' 395    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL395.ctx';
    ' 396    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL396.ctx';
    ' 397    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL397.ctx';
    ' 398    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL398.ctx';
    ' 399    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL399.ctx';
    ' 400    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL400.ctx';
    ' 401    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL401.ctx';
    ' 402    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL402.ctx';
    ' 403    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL403.ctx';
    ' 404    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL404.ctx';
    ' 405    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL405.ctx';
    ' 406    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL406.ctx';
    ' 407    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL407.ctx';
    ' 408    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL408.ctx';
    ' 409    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL409.ctx';
    ' 410    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL410.ctx';
    ' 411    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL411.ctx';
    ' 412    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL412.ctx';
    ' 413    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL413.ctx';
    ' 414    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL414.ctx';
    ' 415    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL415.ctx';
    ' 416    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL416.ctx';
    ' 417    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL417.ctx';
    ' 418    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL418.ctx';
    ' 419    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL419.ctx';
    ' 420    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL420.ctx';
    ' 421    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL421.ctx';
    ' 422    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL422.ctx';
    ' 423    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL423.ctx';
    ' 424    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL424.ctx';
    ' 425    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL425.ctx';
    ' 426    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL426.ctx';
    ' 427    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL427.ctx';
    ' 428    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL428.ctx';
    ' 429    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL429.ctx';
    ' 430    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL430.ctx';
    ' 431    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL431.ctx';
    ' 432    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL432.ctx';
    ' 433    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL433.ctx';
    ' 434    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL434.ctx';
    ' 435    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL435.ctx';
    ' 436    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL436.ctx';
    ' 437    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL437.ctx';
    ' 438    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL438.ctx';
    ' 439    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL439.ctx';
    ' 440    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL440.ctx';
    ' 441    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL441.ctx';
    ' 442    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL442.ctx';
    ' 443    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL443.ctx';
    ' 444    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL444.ctx';
    ' 445    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL445.ctx';
    ' 446    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL446.ctx';
    ' 447    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL447.ctx';
    ' 448    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL448.ctx';
    ' 449    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL449.ctx';
    ' 450    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL450.ctx';
    ' 451    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL451.ctx';
    ' 452    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL452.ctx';
    ' 453    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL453.ctx';
    ' 454    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL454.ctx';
    ' 455    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL455.ctx';
    ' 456    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL456.ctx';
    ' 457    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL457.ctx';
    ' 458    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL458.ctx';
    ' 459    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL459.ctx';
    ' 460    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL460.ctx';
    ' 461    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL461.ctx';
    ' 462    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL462.ctx';
    ' 463    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL463.ctx';
    ' 464    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL464.ctx';
    ' 465    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL465.ctx';
    ' 466    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL466.ctx';
    ' 467    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL467.ctx';
    ' 468    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL468.ctx';
    ' 469    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL469.ctx';
    ' 470    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL470.ctx';
    ' 471    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL471.ctx';
    ' 472    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL472.ctx';
    ' 473    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL473.ctx';
    ' 474    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL474.ctx';
    ' 475    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL475.ctx';
    ' 476    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL476.ctx';
    ' 477    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL477.ctx';
    ' 478    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL478.ctx';
    ' 479    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL479.ctx';
    ' 480    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL480.ctx';
    ' 481    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL481.ctx';
    ' 482    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL482.ctx';
    ' 483    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL483.ctx';
    ' 484    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL484.ctx';
    ' 485    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL485.ctx';
    ' 486    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL486.ctx';
    ' 487    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL487.ctx';
    ' 488    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL488.ctx';
    ' 489    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL489.ctx';
    ' 490    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL490.ctx';
    ' 491    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL491.ctx';
    ' 492    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL492.ctx';
    ' 493    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL493.ctx';
    ' 494    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL494.ctx';
    ' 495    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL495.ctx';
    ' 496    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL496.ctx';
    ' 497    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL497.ctx';
    ' 498    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL498.ctx';
    ' 499    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL499.ctx';
    ' 500    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL500.ctx';
    ' 501    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL501.ctx';
    ' 502    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL502.ctx';
    ' 503    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL503.ctx';
    ' 504    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL504.ctx';
    ' 505    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL505.ctx';
    ' 506    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL506.ctx';
    ' 507    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL507.ctx';
    ' 508    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL508.ctx';
    ' 509    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL509.ctx';
    ' 510    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL510.ctx';
    ' 511    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL511.ctx';
    ' 512    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL512.ctx';
    ' 513    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL513.ctx';
    ' 514    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL514.ctx';
    ' 515    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL515.ctx';
    ' 516    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL516.ctx';
    ' 517    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL517.ctx';
    ' 518    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL518.ctx';
    ' 519    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL519.ctx';
    ' 520    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL520.ctx';
    ' 521    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL521.ctx';
    ' 522    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL522.ctx';
    ' 523    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL523.ctx';
    ' 524    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL524.ctx';
    ' 525    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL525.ctx';
    ' 526    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL526.ctx';
    ' 527    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL527.ctx';
    ' 528    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL528.ctx';
    ' 529    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL529.ctx';
    ' 530    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL530.ctx';
    ' 531    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL531.ctx';
    ' 532    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL532.ctx';
    ' 533    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL533.ctx';
    ' 534    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL534.ctx';
    ' 535    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL535.ctx';
    ' 536    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL536.ctx';
    ' 537    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL537.ctx';
    ' 538    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL538.ctx';
    ' 539    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL539.ctx';
    ' 540    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL540.ctx';
    ' 541    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL541.ctx';
    ' 542    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL542.ctx';
    ' 543    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL543.ctx';
    ' 544    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL544.ctx';
    ' 545    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL545.ctx';
    ' 546    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL546.ctx';
    ' 547    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL547.ctx';
    ' 548    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL548.ctx';
    ' 549    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL549.ctx';
    ' 550    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL550.ctx';
    ' 551    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL551.ctx';
    ' 552    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL552.ctx';
    ' 553    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL553.ctx';
    ' 554    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL554.ctx';
    ' 555    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL555.ctx';
    ' 556    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL556.ctx';
    ' 557    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL557.ctx';
    ' 558    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL558.ctx';
    ' 559    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL559.ctx';
    ' 560    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL560.ctx';
    ' 561    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL561.ctx';
    ' 562    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL562.ctx';
    ' 563    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL563.ctx';
    ' 564    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL564.ctx';
    ' 565    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL565.ctx';
    ' 566    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL566.ctx';
    ' 567    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL567.ctx';
    ' 568    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL568.ctx';
    ' 569    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL569.ctx';
    ' 570    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL570.ctx';
    ' 571    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL571.ctx';
    ' 572    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL572.ctx';
    ' 573    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL573.ctx';
    ' 574    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL574.ctx';
    ' 575    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL575.ctx';
    ' 576    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL576.ctx';
    ' 577    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL577.ctx';
    ' 578    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL578.ctx';
    ' 579    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL579.ctx';
    ' 580    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL580.ctx';
    ' 581    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL581.ctx';
    ' 582    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL582.ctx';
    ' 583    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL583.ctx';
    ' 584    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL584.ctx';
    ' 585    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL585.ctx';
    ' 586    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL586.ctx';
    ' 587    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL587.ctx';
    ' 588    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL588.ctx';
    ' 589    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL589.ctx';
    ' 590    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL590.ctx';
    ' 591    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL591.ctx';
    ' 592    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL592.ctx';
    ' 593    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL593.ctx';
    ' 594    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL594.ctx';
    ' 595    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL595.ctx';
    ' 596    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL596.ctx';
    ' 597    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL597.ctx';
    ' 598    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL598.ctx';
    ' 599    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL599.ctx';
    ' 600    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL600.ctx';
    ' 601    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL601.ctx';
    ' 602    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL602.ctx';
    ' 603    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL603.ctx';
    ' 604    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL604.ctx';
    ' 605    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL605.ctx';
    ' 606    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL606.ctx';
    ' 607    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL607.ctx';
    ' 608    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL608.ctx';
    ' 609    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL609.ctx';
    ' 610    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL610.ctx';
    ' 611    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL611.ctx';
    ' 612    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL612.ctx';
    ' 613    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL613.ctx';
    ' 614    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL614.ctx';
    ' 615    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL615.ctx';
    ' 616    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL616.ctx';
    ' 617    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL617.ctx';
    ' 618    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL618.ctx';
    ' 619    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL619.ctx';
    ' 620    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL620.ctx';
    ' 621    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL621.ctx';
    ' 622    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL622.ctx';
    ' 623    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL623.ctx';
    ' 624    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL624.ctx';
    ' 625    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL625.ctx';
    ' 626    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL626.ctx';
    ' 627    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL627.ctx';
    ' 628    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL628.ctx';
    ' 629    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL629.ctx';
    ' 630    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL630.ctx';
    ' 631    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL631.ctx';
    ' 632    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL632.ctx';
    ' 633    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL633.ctx';
    ' 634    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL634.ctx';
    ' 635    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL635.ctx';
    ' 636    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL636.ctx';
    ' 637    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL637.ctx';
    ' 638    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL638.ctx';
    ' 639    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL639.ctx';
    ' 640    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL640.ctx';
    ' 641    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL641.ctx';
    ' 642    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL642.ctx';
    ' 643    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL643.ctx';
    ' 644    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL644.ctx';
    ' 645    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL645.ctx';
    ' 646    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL646.ctx';
    ' 647    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL647.ctx';
    ' 648    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL648.ctx';
    ' 649    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL649.ctx';
    ' 650    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL650.ctx';
    ' 651    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL651.ctx';
    ' 652    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL652.ctx';
    ' 653    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL653.ctx';
    ' 654    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL654.ctx';
    ' 655    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL655.ctx';
    ' 656    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL656.ctx';
    ' 657    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL657.ctx';
    ' 658    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL658.ctx';
    ' 659    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL659.ctx';
    ' 660    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL660.ctx';
    ' 661    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL661.ctx';
    ' 662    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL662.ctx';
    ' 663    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL663.ctx';
    ' 664    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL664.ctx';
    ' 665    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL665.ctx';
    ' 666    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL666.ctx';
    ' 667    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL667.ctx';
    ' 668    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL668.ctx';
    ' 669    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL669.ctx';
    ' 670    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL670.ctx';
    ' 671    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL671.ctx';
    ' 672    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL672.ctx';
    ' 673    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL673.ctx';
    ' 674    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL674.ctx';
    ' 675    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL675.ctx';
    ' 676    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL676.ctx';
    ' 677    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL677.ctx';
    ' 678    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL678.ctx';
    ' 679    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL679.ctx';
    ' 680    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL680.ctx';
    ' 681    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL681.ctx';
    ' 682    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL682.ctx';
    ' 683    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL683.ctx';
    ' 684    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL684.ctx';
    ' 685    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL685.ctx';
    ' 686    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL686.ctx';
    ' 687    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL687.ctx';
    ' 688    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL688.ctx';
    ' 689    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL689.ctx';
    ' 690    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL690.ctx';
    ' 691    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL691.ctx';
    ' 692    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL692.ctx';
    ' 693    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL693.ctx';
    ' 694    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL694.ctx';
    ' 695    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL695.ctx';
    ' 696    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL696.ctx';
    ' 697    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL697.ctx';
    ' 698    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL698.ctx';
    ' 699    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL699.ctx';
    ' 700    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL700.ctx';
    ' 701    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL701.ctx';
    ' 702    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL702.ctx';
    ' 703    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL703.ctx';
    ' 704    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL704.ctx';
    ' 705    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL705.ctx';
    ' 706    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL706.ctx';
    ' 707    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL707.ctx';
    ' 708    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL708.ctx';
    ' 709    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL709.ctx';
    ' 710    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL710.ctx';
    ' 711    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL711.ctx';
    ' 712    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL712.ctx';
    ' 713    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL713.ctx';
    ' 714    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL714.ctx';
    ' 715    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL715.ctx';
    ' 716    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL716.ctx';
    ' 717    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL717.ctx';
    ' 718    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL718.ctx';
    ' 719    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL719.ctx';
    ' 720    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL720.ctx';
    ' 721    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL721.ctx';
    ' 722    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL722.ctx';
    ' 723    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL723.ctx';
    ' 724    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL724.ctx';
    ' 725    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL725.ctx';
    ' 726    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL726.ctx';
    ' 727    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL727.ctx';
    ' 728    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL728.ctx';
    ' 729    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL729.ctx';
    ' 730    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL730.ctx';
    ' 731    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL731.ctx';
    ' 732    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL732.ctx';
    ' 733    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL733.ctx';
    ' 734    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL734.ctx';
    ' 735    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL735.ctx';
    ' 736    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL736.ctx';
    ' 737    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL737.ctx';
    ' 738    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL738.ctx';
    ' 739    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL739.ctx';
    ' 740    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL740.ctx';
    ' 741    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL741.ctx';
    ' 742    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL742.ctx';
    ' 743    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL743.ctx';
    ' 744    8           0.00    0.00      0                                 75  75  75 x   C:\' manipblk 'bw' posnum '\TL744.ctx'];
    


for k=1:size(Tloc,1)
    nextitm=str2num(itm(end,double(1:4)));
    itm=[itm;
        ones(1,(4-length(num2str(nextitm+1))))*char(32) num2str(nextitm+1) '    1      0' char(ones(1,(8-length(num2str(round(Tloc(k,3)*100)/100))))*' ') num2str(round(Tloc(k,3)*100)/100) ...
        char(ones(1,(8-length(num2str(round(Tloc(k,4)*100)/100))))*' ') num2str(round(Tloc(k,4)*100)/100) '      0'...
        '   6.00  6.00  0.00  0.00        75  75  75 x                       '];
end


if ~exist(strcat('S:\Cortex Programs\Contextual\',['' manipblk 'bw' posnum '.itm']),'file')
%     delete(strcat('S:\Cortex Programs\Contextual\',['' manipblk 'bw' posnum '.itm']))

itmfil=strcat('S:\Cortex Programs\Contextual\',['' manipblk 'bw' posnum '.itm']);
fid = fopen(itmfil, 'wt');
fprintf(fid,'%s',itm(1,:)');
for k=1:size(itm,1)-1
    fprintf(fid,'\n%s',itm(k+1,:)');
end
fclose(fid);

disp(['Generated item file ' '' manipblk 'bw' posnum '.itm'])
else
    disp (['file ' '' manipblk 'bw' posnum '.itm already exists NO .ITM file created'])
end
