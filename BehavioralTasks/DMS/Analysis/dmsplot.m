% 
% dmsplot loads data for all sessions between startdate and enddate that 
% correspond to any version of DMS, then plots accuracy and percent errors
% (early, late and break fixation) for each data file.

% v1 070226 MJJ

disp('Irwin: IW   Peepers: MP   Wilbur: WR   Timmy: TT   Giuseppe: JN   Car bomb: CB');
ini=input('Monkey initials?:  ', 's');
if strcmp(ini,'IW')==1 || strcmp(ini,'iw')==1
    monkey='Irwin';
    monkini='IW';
elseif strcmp(ini,'MP')==1 || strcmp(ini,'mp')==1
    monkey='Peepers';
    monkini='MP';
elseif strcmp(ini,'WR')==1 || strcmp(ini,'wr')==1
    monkey='Wilbur';
    monkini='WR';
elseif strcmp(ini,'TT')==1 || strcmp(ini,'tt')==1
    monkey='Timmy';
    monkini='TT';
elseif strcmp(ini,'JN')==1 || strcmp(ini,'jn')==1
    monkey='Guiseppe';
    monkini='JN';
elseif strcmp(ini,'TD')==1 || strcmp(ini,'td')==1
    monkey='Theodore';
    monkini='TD';    
% elseif strcmp(ini,'CB')==1 || strcmp(ini,'cb')==1
%     [X,MAP] = imread('S:\Mike\stuff\irishcarbomb','jpeg');
%     figure;
%     imshow(X,MAP)
%     break
end
startdate=input('Type start date in format yymmdd:  ');
enddate=input('Type end date in format yymmdd:  ');
j=1;
prcntacc=[];
prcntbrkfix=[];
prcntearly=[];
prcntlate=[];
dateindx=[];
trindx=[];
for datenum = startdate:1:enddate;
    for filenum=1:9
        datfil = strcat('S:\Cortex Data\',monkey,'\',monkini,num2str(datenum),'.',num2str(filenum));
        if exist(datfil,'file')~=0
            [time_arr,event_arr,eog_arr,epp_arr,header,trialcount]  = get_ALLdata(datfil);
            if size(find(event_arr(:,:) == 1006),1) ~= 0
                if size(find(event_arr(:,:) == 1007),1) == 0
                    corr=0;
                    late=0;
                    early=0;
                    bkfix=0;
                    resp=0;
                    for trlop = 1:trialcount
                        if size(find(event_arr(:,trlop) == 200),1) == 1 || size(find(event_arr(:,trlop) == 202),1) == 1 || size(find(event_arr(:,trlop) == 205),1) == 1
                            resp=resp+1;
                        end
                        if size(find(event_arr(:,trlop) == 200),1) ~= 0
                            corr=corr+1;
                        end
                        if size(find(event_arr(:,trlop) == 202),1) ~= 0
                            late=late+1;
                        end
                        if size(find(event_arr(:,trlop) == 205),1) ~= 0
                            early=early+1;
                        end
                        if size(find(event_arr(:,trlop) == 203),1) ~= 0
                            bkfix=bkfix+1;
                        end
                    end
                    prcntacc(1,j) = 100*(corr/resp);
                    prcntbrkfix(1,j) = 100*(bkfix/size(event_arr,2));
                    prcntearly(1,j) = 100*(early/resp);
                    prcntlate(1,j) = 100*(late/resp);
                    dateindx(1,j)=str2double(strcat(num2str(datenum-floor(datenum/10000)*10000),'.',num2str(filenum)));
                    trindx(1,j)=trialcount;
                    j=j+1;
                end
            end
        end
    end
end

figure;
subplot(2,2,1);
    bar(prcntacc,'g');set(gca,'XTickLabel',dateindx);
    set(gca,'xtick',1:size(prcntacc,2),'Box','off','YGrid','on');
    ylabel('Percent accuracy');
    xlim([0.5 size(prcntacc,2)+0.5]);
    rotateticklabel(gca);
    ax2=axes('Position',get(gca,'Position'),'XAxisLocation','top','YAxisLocation','right','Box','off','Color','none','XTickMode','manual',...
        'Xlim',get(gca,'XLim'),'XTick',get(gca,'XTick'),'Layer','top','XTickLabel',trindx,'XColor','k','YColor','k',...
        'XMinorTick','off','YTick',zeros(1,0));
    xlabel('# Trials');
subplot(2,2,2);
    bar(prcntbrkfix,'r');set(gca,'XTickLabel',dateindx);
    set(gca,'xtick',1:size(prcntbrkfix,2),'Box','off','YGrid','on');
    ylabel('Percent break fixation');
    xlim([0.5 size(prcntbrkfix,2)+0.5]);
    rotateticklabel(gca);
    ax2=axes('Position',get(gca,'Position'),'XAxisLocation','top','YAxisLocation','right','Box','off','Color','none','XTickMode','manual',...
        'Xlim',get(gca,'XLim'),'XTick',get(gca,'XTick'),'Layer','top','XTickLabel',trindx,'XColor','k','YColor','k',...
        'XMinorTick','off','YTick',zeros(1,0));
    xlabel('# Trials');
subplot(2,2,3);
    bar(prcntearly,'y');set(gca,'XTickLabel',dateindx);
    set(gca,'xtick',1:size(prcntearly,2),'Box','off','YGrid','on');
    ylabel('Percent early');
    xlim([0.5 size(prcntearly,2)+0.5]);
    rotateticklabel(gca);
    ax2=axes('Position',get(gca,'Position'),'XAxisLocation','top','YAxisLocation','right','Box','off','Color','none','XTickMode','manual',...
        'Xlim',get(gca,'XLim'),'XTick',get(gca,'XTick'),'Layer','top','XTickLabel',trindx,'XColor','k','YColor','k',...
        'XMinorTick','off','YTick',zeros(1,0));
    xlabel('# Trials');
subplot(2,2,4);
    bar(prcntlate,'b');set(gca,'XTickLabel',dateindx);
    set(gca,'xtick',1:size(prcntlate,2),'Box','off','YGrid','on');
    ylabel('Percent late');
    xlim([0.5 size(prcntlate,2)+0.5]);
    rotateticklabel(gca);
    ax2=axes('Position',get(gca,'Position'),'XAxisLocation','top','YAxisLocation','right','Box','off','Color','none','XTickMode','manual',...
        'Xlim',get(gca,'XLim'),'XTick',get(gca,'XTick'),'Layer','top','XTickLabel',trindx,'XColor','k','YColor','k',...
        'XMinorTick','off','YTick',zeros(1,0));
    xlabel('# Trials');
string=strcat(monkey,' DMS');
titlepos = [.5 .97]; % normalized units.
ax = gca;
set(ax,'units','normalized');
axpos = get(ax,'position');
offset = (titlepos - axpos(1:2))./axpos(3:4);
text(offset(1),offset(2),string,'units','normalized',...
     'horizontalalignment','center','verticalalignment','middle');
set(gcf, 'PaperOrientation', 'landscape');
set(gcf, 'PaperPosition', [0.25 0.25 10.50 8.00]);
