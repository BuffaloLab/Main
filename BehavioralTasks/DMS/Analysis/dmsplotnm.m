% 
% dmsplotnm loads data for all sessions between startdate and enddate that 
% correspond to DMS (won't work for DMSTRAIN) then plots accuracy and
% percent early errors for each data file, separating trials by the number 
% of nonmatch stimuli.

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
prcntacc0=[];
prcntbrkfix0=[];
prcntearly0=[];
prcntlate0=[];
dateindx=[];
prcntacc1=[];
prcntbrkfix1=[];
prcntearly1=[];
prcntlate1=[];
prcntacc2=[];
prcntbrkfix2=[];
prcntearly2=[];
prcntlate2=[];
prcntacc3=[];
prcntbrkfix3=[];
prcntearly3=[];
prcntlate3=[];
prcntacc4=[];
prcntbrkfix4=[];
prcntearly4=[];
prcntlate4=[];
prcntacc5=[];
prcntbrkfix5=[];
prcntearly5=[];
prcntlate5=[];
prcntacc6=[];
prcntbrkfix6=[];
prcntearly6=[];
prcntlate6=[];
trindx=[];
for datenum = startdate:1:enddate
    for filenum=1:9
        datfil = strcat('S:\Cortex Data\',monkey,'\',monkini,num2str(datenum),'.',num2str(filenum));
        if exist(datfil,'file')~=0
            [time_arr,event_arr,eog_arr,epp_arr,header,trialcount]  = get_ALLdata(datfil);
            if size(find(event_arr(:,:) == 1006),1) ~= 0
                if size(find(event_arr(:,:) == 1007),1) == 0
                    corr0=0;
                    late0=0;
                    early0=0;
                    bkfix0=0;
                    resp0=0;
                    corr1=0;
                    late1=0;
                    early1=0;
                    bkfix1=0;
                    resp1=0;
                    corr2=0;
                    late2=0;
                    early2=0;
                    bkfix2=0;
                    resp2=0;
                    corr3=0;
                    late3=0;
                    early3=0;
                    bkfix3=0;
                    resp3=0;
                    corr4=0;
                    late4=0;
                    early4=0;
                    bkfix4=0;
                    resp4=0;
                    corr5=0;
                    late5=0;
                    early5=0;
                    bkfix5=0;
                    resp5=0;
                    corr6=0;
                    late6=0;
                    early6=0;
                    bkfix6=0;
                    resp6=0;
                    num0=0;
                    num1=0;
                    num2=0;
                    num3=0;
                    num4=0;
                    num5=0;
                    num6=0;
                    for trlop = 1:trialcount
%                         if size(find(event_arr(:,trlop) == 23),1) + size(find(event_arr(:,trlop) == 25),1) + size(find(event_arr(:,trlop) == 27),1) + size(find(event_arr(:,trlop) == 29),1) + size(find(event_arr(:,trlop) == 31),1) == 1 
%                             num0=num0+1;
%                         end
%                         if size(find(event_arr(:,trlop) == 23),1) + size(find(event_arr(:,trlop) == 25),1) + size(find(event_arr(:,trlop) == 27),1) + size(find(event_arr(:,trlop) == 29),1) + size(find(event_arr(:,trlop) == 31),1) == 2 
%                             num1=num1+1;
%                         end
%                         if size(find(event_arr(:,trlop) == 23),1) + size(find(event_arr(:,trlop) == 25),1) + size(find(event_arr(:,trlop) == 27),1) + size(find(event_arr(:,trlop) == 29),1) + size(find(event_arr(:,trlop) == 31),1) == 3 
%                             num2=num2+1;
%                         end
%                         if size(find(event_arr(:,trlop) == 23),1) + size(find(event_arr(:,trlop) == 25),1) + size(find(event_arr(:,trlop) == 27),1) + size(find(event_arr(:,trlop) == 29),1) + size(find(event_arr(:,trlop) == 31),1) == 4 
%                             num3=num3+1;
%                         end
%                         if size(find(event_arr(:,trlop) == 23),1) + size(find(event_arr(:,trlop) == 25),1) + size(find(event_arr(:,trlop) == 27),1) + size(find(event_arr(:,trlop) == 29),1) + size(find(event_arr(:,trlop) == 31),1) == 5 
%                             num4=num4+1;
%                         end
                        if size(find(event_arr(:,trlop) == 200),1) ~= 0
                            if size(find(event_arr(:,trlop) == 23),1) + size(find(event_arr(:,trlop) == 25),1) + size(find(event_arr(:,trlop) == 27),1) + size(find(event_arr(:,trlop) == 29),1) + size(find(event_arr(:,trlop) == 31),1) == 2
                                corr0=corr0+1;
                                resp0=resp0+1;
                            end
                            if size(find(event_arr(:,trlop) == 23),1) + size(find(event_arr(:,trlop) == 25),1) + size(find(event_arr(:,trlop) == 27),1) + size(find(event_arr(:,trlop) == 29),1) + size(find(event_arr(:,trlop) == 31),1) == 3
                                corr1=corr1+1;
                                resp1=resp1+1;
                            end
                            if size(find(event_arr(:,trlop) == 23),1) + size(find(event_arr(:,trlop) == 25),1) + size(find(event_arr(:,trlop) == 27),1) + size(find(event_arr(:,trlop) == 29),1) + size(find(event_arr(:,trlop) == 31),1) == 4
                                corr2=corr2+1;
                                resp2=resp2+1;
                            end
                            if size(find(event_arr(:,trlop) == 23),1) + size(find(event_arr(:,trlop) == 25),1) + size(find(event_arr(:,trlop) == 27),1) + size(find(event_arr(:,trlop) == 29),1) + size(find(event_arr(:,trlop) == 31),1) == 5
                                corr3=corr3+1;
                                resp3=resp3+1;
                            end
                            if size(find(event_arr(:,trlop) == 23),1) + size(find(event_arr(:,trlop) == 25),1) + size(find(event_arr(:,trlop) == 27),1) + size(find(event_arr(:,trlop) == 29),1) + size(find(event_arr(:,trlop) == 31),1) == 6
                                corr4=corr4+1;
                                resp4=resp4+1;
                            end
                            if size(find(event_arr(:,trlop) == 23),1) + size(find(event_arr(:,trlop) == 25),1) + size(find(event_arr(:,trlop) == 27),1) + size(find(event_arr(:,trlop) == 29),1) + size(find(event_arr(:,trlop) == 31),1) == 7
                                corr5=corr5+1;
                                resp5=resp5+1;
                            end
                            if size(find(event_arr(:,trlop) == 23),1) + size(find(event_arr(:,trlop) == 25),1) + size(find(event_arr(:,trlop) == 27),1) + size(find(event_arr(:,trlop) == 29),1) + size(find(event_arr(:,trlop) == 31),1) == 8
                                corr6=corr6+1;
                                resp6=resp6+1;
                            end
                        end
                        if size(find(event_arr(:,trlop) == 202),1) ~= 0
                            if size(find(event_arr(:,trlop) == 23),1) + size(find(event_arr(:,trlop) == 25),1) + size(find(event_arr(:,trlop) == 27),1) + size(find(event_arr(:,trlop) == 29),1) + size(find(event_arr(:,trlop) == 31),1) == 2
                                late0=late0+1;
                                resp0=resp0+1;
                            end
                            if size(find(event_arr(:,trlop) == 23),1) + size(find(event_arr(:,trlop) == 25),1) + size(find(event_arr(:,trlop) == 27),1) + size(find(event_arr(:,trlop) == 29),1) + size(find(event_arr(:,trlop) == 31),1) == 3
                                late1=late1+1;
                                resp1=resp1+1;
                            end
                            if size(find(event_arr(:,trlop) == 23),1) + size(find(event_arr(:,trlop) == 25),1) + size(find(event_arr(:,trlop) == 27),1) + size(find(event_arr(:,trlop) == 29),1) + size(find(event_arr(:,trlop) == 31),1) == 4
                                late2=late2+1;
                                resp2=resp2+1;
                            end
                            if size(find(event_arr(:,trlop) == 23),1) + size(find(event_arr(:,trlop) == 25),1) + size(find(event_arr(:,trlop) == 27),1) + size(find(event_arr(:,trlop) == 29),1) + size(find(event_arr(:,trlop) == 31),1) == 5
                                late3=late3+1;
                                resp3=resp3+1;
                            end
                            if size(find(event_arr(:,trlop) == 23),1) + size(find(event_arr(:,trlop) == 25),1) + size(find(event_arr(:,trlop) == 27),1) + size(find(event_arr(:,trlop) == 29),1) + size(find(event_arr(:,trlop) == 31),1) == 6
                                late4=late4+1;
                                resp4=resp4+1;
                            end
                            if size(find(event_arr(:,trlop) == 23),1) + size(find(event_arr(:,trlop) == 25),1) + size(find(event_arr(:,trlop) == 27),1) + size(find(event_arr(:,trlop) == 29),1) + size(find(event_arr(:,trlop) == 31),1) == 7
                                late5=late5+1;
                                resp5=resp5+1;
                            end
                            if size(find(event_arr(:,trlop) == 23),1) + size(find(event_arr(:,trlop) == 25),1) + size(find(event_arr(:,trlop) == 27),1) + size(find(event_arr(:,trlop) == 29),1) + size(find(event_arr(:,trlop) == 31),1) == 8
                                late6=late6+1;
                                resp6=resp6+1;
                            end
                        end
                        if size(find(event_arr(:,trlop) == 205),1) ~= 0
                            if size(find(event_arr(:,trlop) == 23),1) + size(find(event_arr(:,trlop) == 25),1) + size(find(event_arr(:,trlop) == 27),1) + size(find(event_arr(:,trlop) == 29),1) + size(find(event_arr(:,trlop) == 31),1) == 1
                                early0=early0+1;
                                resp0=resp0+1;
                            end
                            if size(find(event_arr(:,trlop) == 23),1) + size(find(event_arr(:,trlop) == 25),1) + size(find(event_arr(:,trlop) == 27),1) + size(find(event_arr(:,trlop) == 29),1) + size(find(event_arr(:,trlop) == 31),1) == 2
                                if size(find(event_arr(:,trlop) == 23),1) == 1
                                    early1=early1+1;
                                    resp1=resp1+1;
                                else
                                    early0=early0+1;
                                    resp0=resp0+1;
                                end 
                            end
                            if size(find(event_arr(:,trlop) == 23),1) + size(find(event_arr(:,trlop) == 25),1) + size(find(event_arr(:,trlop) == 27),1) + size(find(event_arr(:,trlop) == 29),1) + size(find(event_arr(:,trlop) == 31),1) == 3
                                if size(find(event_arr(:,trlop) == 23),1) == 1
                                    early2=early2+1;
                                    resp2=resp2+1;
                                else
                                    early1=early1+1;
                                    resp1=resp1+1;
                                end
                            end
                            if size(find(event_arr(:,trlop) == 23),1) + size(find(event_arr(:,trlop) == 25),1) + size(find(event_arr(:,trlop) == 27),1) + size(find(event_arr(:,trlop) == 29),1) + size(find(event_arr(:,trlop) == 31),1) == 4
                                if size(find(event_arr(:,trlop) == 23),1) == 1
                                    early3=early3+1;
                                    resp3=resp3+1;
                                else
                                    early2=early2+1;
                                    resp2=resp2+1;
                                end
                            end
                            if size(find(event_arr(:,trlop) == 23),1) + size(find(event_arr(:,trlop) == 25),1) + size(find(event_arr(:,trlop) == 27),1) + size(find(event_arr(:,trlop) == 29),1) + size(find(event_arr(:,trlop) == 31),1) == 5
                                if size(find(event_arr(:,trlop) == 23),1) == 1
                                    early4=early4+1;
                                    resp4=resp4+1;
                                else
                                    early3=early3+1;
                                    resp3=resp3+1;
                                end
                            end
                            if size(find(event_arr(:,trlop) == 23),1) + size(find(event_arr(:,trlop) == 25),1) + size(find(event_arr(:,trlop) == 27),1) + size(find(event_arr(:,trlop) == 29),1) + size(find(event_arr(:,trlop) == 31),1) == 6
                                if size(find(event_arr(:,trlop) == 23),1) == 1
                                    early5=early5+1;
                                    resp5=resp5+1;
                                else
                                    early4=early4+1;
                                    resp4=resp4+1;
                                end
                            end
                            if size(find(event_arr(:,trlop) == 23),1) + size(find(event_arr(:,trlop) == 25),1) + size(find(event_arr(:,trlop) == 27),1) + size(find(event_arr(:,trlop) == 29),1) + size(find(event_arr(:,trlop) == 31),1) == 7
                                if size(find(event_arr(:,trlop) == 23),1) == 1
                                    early6=early6+1;
                                    resp6=resp6+1;
                                else
                                    early5=early5+1;
                                    resp5=resp5+1;
                                end
                            end
                        end
%                         if size(find(event_arr(:,trlop) == 203),1) ~= 0
%                             if size(find(event_arr(:,trlop) == 23),1) + size(find(event_arr(:,trlop) == 25),1) + size(find(event_arr(:,trlop) == 27),1) + size(find(event_arr(:,trlop) == 29),1) + size(find(event_arr(:,trlop) == 31),1) == 1
%                                 bkfix0=bkfix0+1;
%                             end
%                             if size(find(event_arr(:,trlop) == 23),1) + size(find(event_arr(:,trlop) == 25),1) + size(find(event_arr(:,trlop) == 27),1) + size(find(event_arr(:,trlop) == 29),1) + size(find(event_arr(:,trlop) == 31),1) == 2
%                                 bkfix1=bkfix1+1;
%                             end
%                             if size(find(event_arr(:,trlop) == 23),1) + size(find(event_arr(:,trlop) == 25),1) + size(find(event_arr(:,trlop) == 27),1) + size(find(event_arr(:,trlop) == 29),1) + size(find(event_arr(:,trlop) == 31),1) == 3
%                                 bkfix2=bkfix2+1;
%                             end
%                             if size(find(event_arr(:,trlop) == 23),1) + size(find(event_arr(:,trlop) == 25),1) + size(find(event_arr(:,trlop) == 27),1) + size(find(event_arr(:,trlop) == 29),1) + size(find(event_arr(:,trlop) == 31),1) == 4
%                                 bkfix3=bkfix3+1;
%                             end
%                             if size(find(event_arr(:,trlop) == 23),1) + size(find(event_arr(:,trlop) == 25),1) + size(find(event_arr(:,trlop) == 27),1) + size(find(event_arr(:,trlop) == 29),1) + size(find(event_arr(:,trlop) == 31),1) == 5
%                                 bkfix4=bkfix4+1;
%                             end
%                             if size(find(event_arr(:,trlop) == 23),1) + size(find(event_arr(:,trlop) == 25),1) + size(find(event_arr(:,trlop) == 27),1) + size(find(event_arr(:,trlop) == 29),1) + size(find(event_arr(:,trlop) == 31),1) == 6
%                                 bkfix5=bkfix5+1;
%                             end
%                             if size(find(event_arr(:,trlop) == 23),1) + size(find(event_arr(:,trlop) == 25),1) + size(find(event_arr(:,trlop) == 27),1) + size(find(event_arr(:,trlop) == 29),1) + size(find(event_arr(:,trlop) == 31),1) == 7
%                                 bkfix6=bkfix6+1;
%                             end
%                         end
                    end
                    prcntacc0(1,j) = 100*(corr0/resp0);
%                     prcntbrkfix0(1,j) = 100*(bkfix0/num0);
                    prcntearly0(1,j) = 100*(early0/resp0);
%                     prcntlate0(1,j) = 100*(late0/resp0);
                    if resp1 ~= 0
                        prcntacc1(1,j) = 100*(corr1/resp1);
%                         prcntbrkfix1(1,j) = 100*(bkfix1/num1);
                        prcntearly1(1,j) = 100*(early1/resp1);
%                         prcntlate1(1,j) = 100*(late1/resp1);
                    end
                    if resp2 ~= 0
                        prcntacc2(1,j) = 100*(corr2/resp2);
%                         prcntbrkfix2(1,j) = 100*(bkfix2/num2);
                        prcntearly2(1,j) = 100*(early2/resp2);
%                         prcntlate2(1,j) = 100*(late2/resp2);
                    end
                    if resp3 ~= 0
                        prcntacc3(1,j) = 100*(corr3/resp3);
%                         prcntbrkfix3(1,j) = 100*(bkfix3/num3);
                        prcntearly3(1,j) = 100*(early3/resp3);
%                         prcntlate3(1,j) = 100*(late3/resp3);
                    end
                    if resp4 ~= 0
                        prcntacc4(1,j) = 100*(corr4/resp4);
%                         prcntbrkfix4(1,j) = 100*(bkfix4/num4);
                        prcntearly4(1,j) = 100*(early4/resp4);
%                         prcntlate4(1,j) = 100*(late4/resp4);
                    end
                    if resp5 ~= 0
                        prcntacc5(1,j) = 100*(corr5/resp5);
%                         prcntbrkfix5(1,j) = 100*(bkfix5/num5);
                        prcntearly5(1,j) = 100*(early5/resp5);
%                         prcntlate5(1,j) = 100*(late5/resp5);
                    end
                    if resp6 ~= 0
                        prcntacc6(1,j) = 100*(corr6/resp6);
%                         prcntbrkfix6(1,j) = 100*(bkfix6/num6);
                        prcntearly6(1,j) = 100*(early6/resp6);
%                         prcntlate6(1,j) = 100*(late6/resp6);
                    end
                    dateindx(1,j)=str2double(strcat(num2str(datenum-floor(datenum/10000)*10000),'.',num2str(filenum)));
                    trindx(1,j)=trialcount;
                    j=j+1;
                end
            end
        end
    end
end

figure;
subplot(2,1,1);
    bar([prcntacc0;prcntacc1;prcntacc2;prcntacc3;prcntacc4;prcntacc5]','Group');set(gca,'XTickLabel',dateindx);
    set(gca,'xtick',1:size(prcntacc0,2),'Box','off','YGrid','on');
    ylabel('Percent accuracy');
    xlim([0.5 size(prcntacc0,2)+0.5]);
    rotateticklabel(gca);
    ax2=axes('Position',get(gca,'Position'),'XAxisLocation','top','YAxisLocation','right','Box','off','Color','none','XTickMode','manual',...
        'Xlim',get(gca,'XLim'),'XTick',get(gca,'XTick'),'Layer','top','XTickLabel',trindx,'XColor','k','YColor','k',...
        'XMinorTick','off','YTick',zeros(1,0));
    xlabel('# Trials');
subplot(2,1,2);
    bar([prcntearly0;prcntearly1;prcntearly2;prcntearly3;prcntearly4;prcntearly5]','Group');set(gca,'XTickLabel',dateindx);
    set(gca,'xtick',1:size(prcntearly0,2),'Box','off','YGrid','on');
    ylabel('Percent early');
    xlim([0.5 size(prcntearly0,2)+0.5]);
    rotateticklabel(gca);
%     ax2=axes('Position',get(gca,'Position'),'XAxisLocation','top','YAxisLocation','right','Box','off','Color','none','XTickMode','manual',...
%         'Xlim',get(gca,'XLim'),'XTick',get(gca,'XTick'),'Layer','top','XTickLabel',trindx,'XColor','k','YColor','k',...
%         'XMinorTick','off','YTick',zeros(1,0));
%     xlabel('# Trials');
string=strcat(monkey,' DMS');
titlepos = [.5 .99]; % normalized units.
ax = gca;
set(ax,'units','normalized');
axpos = get(ax,'position');
offset = (titlepos - axpos(1:2))./axpos(3:4);
text(offset(1),offset(2),string,'units','normalized',...
     'horizontalalignment','center','verticalalignment','middle');
set(gcf, 'PaperOrientation', 'landscape');
set(gcf, 'PaperPosition', [0.25 0.25 10.50 8.00]);
