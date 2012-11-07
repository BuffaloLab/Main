%% 24 hour data, single monkey, multiple sets
close all
clear all
pack

X=8000; % max search time
day='1'; % 1 if first showing or 2 if second showing
% lesion='Post'; % Post or Pre or comment out if no lesion
monkey='Timmy';

list=[ ...

%% TIMMY 24 HOUR Day 1 (post-lesion)
%  'TT121001set413';'TT120927set412';'TT120924set411';'TT120906set410';

%% TIMMY 24 HOUR Day 2 (post-lesion)
%  'TT121002set413';'TT120928set412';'TT120925set411';'TT120907set410';
 
% day1

% 'MP120924set494';'MP120920set493';'MP120820set485';'MP120910set489';'MP120813set484';'MP120806set483';'MP120802set482';
% 'MP120730set481';'MP120726set480';'MP120719set478';'MP120716set477';'MP120712set476';'MP120710set475';'MP120702set473';
% 'MP120627set472';'MP120625set471';'MP120621set470';'MP120618set469';'MP120614set468';
%     
% 'JN120806set455';'JN120802set454';'JN120726set452';'JN120716set449';'JN120702set448';'JN120628set447';'JN120625set446';
% 'JN120618set444';'JN120614set443';

%  'TT120308set442';'TT120202set431';'TT110825set435';'TT120507set464';'TT120618set478';'TT120621set479';'TT120628set481';
%  'TT120709set484';'TT120712set485';'TT120716set486';'TT120719set487';'TT120723set488';'TT120726set489';'TT120807set493';
%  'TT120813set495';'TT120816set496';'TT120820set497';

% day 2

% 'MP120925set494';'MP120921set493';'MP120821set485';'MP120911set489';'MP120814set484';'MP120807set483';'MP120803set482';
% 'MP120731set481';'MP120727set480';'MP120720set478';'MP120717set477';'MP120713set476';'MP120709set475';'MP120703set473';
% 'MP120628set472';'MP120626set471';'MP120622set470';'MP120619set469';'MP120615set468';
%    
% 'JN120807set455';'JN120803set454';'JN120727set452';'JN120717set449';'JN120703set448';'JN120629set447';'JN120626set446';
% 'JN120619set444';'JN120615set443';

%  'TT120309set442';'TT120203set431';'TT110826set435';'TT120508set464';'TT120619set478';'TT120622set479';'TT120629set481';
%  'TT120710set484';'TT120713set485';'TT120717set486';'TT120720set487';'TT120724set488';'TT120727set489';'TT120808set493';
%  'TT120814set495';'TT120817set496';'TT120821set497';
 ];

ini=list(1:2);
allavgrt1=nan(size(list,1),60);
allavgrt2=nan(size(list,1),60);
allavgsac1=nan(size(list,1),60);
allavgsac2=nan(size(list,1),60);
allavgsacfrq1=nan(size(list,1),60);
allavgsacfrq2=nan(size(list,1),60);
for l=1:size(list,1)
    load(['S:\Matlab analyzed data\contextual-eyedat\' list(l,:) 'eyedat.mat'])

    trltyp1=cfg.trl((cfg.trl(:,6)==1),:);
    trltyp2=cfg.trl((cfg.trl(:,6)==2),:);

    clear avgrt1 avgrt2 stert1 stert2 
    blkarr=unique(trltyp1(:,5));
    numblks=length(blkarr);
    for k=1:numblks;

          % % excludes trials with search times longer than X
        rcttim1=trltyp1(trltyp1(:,5)==blkarr(k),2)-trltyp1(trltyp1(:,5)==blkarr(k),1);
        rcttim1=rcttim1(rcttim1<X);
        avgrt1(k)=mean(rcttim1);
        stert1(k)=std(rcttim1)/sqrt(length(rcttim1));
        
        rcttim2=trltyp2(trltyp2(:,5)==blkarr(k),2)-trltyp2(trltyp2(:,5)==blkarr(k),1);
        rcttim2=rcttim2(rcttim2<X);
%                 figure(l)
%                 hist(rcttim2)
        avgrt2(k)=mean(rcttim2);
        stert2(k)=std(rcttim2)/sqrt(length(rcttim2));

    end
    
        allavgrt1(l,1:length(avgrt1))=avgrt1;
        allavgrt2(l,1:length(avgrt2))=avgrt2;


    clear avgsac1 avgsac2 stesac1 stesac2
    blkarr=unique(trltyp1(:,5));
    numblks=length(blkarr);
    for k=1:numblks
        sac1=trltyp1(trltyp1(:,5)==blkarr(k),7);
        rcttim1=trltyp1(trltyp1(:,5)==blkarr(k),2)-trltyp1(trltyp1(:,5)==blkarr(k),1);
        sac1=sac1(rcttim1<X);
        avgsac1(k)=mean(sac1);
        stesac1(k)=std(sac1)/sqrt(length(sac1));

        sac2=trltyp2(trltyp2(:,5)==blkarr(k),7);
        rcttim2=trltyp2(trltyp2(:,5)==blkarr(k),2)-trltyp2(trltyp2(:,5)==blkarr(k),1);
        sac2=sac2(rcttim2<X);
        avgsac2(k)=mean(sac2);
        stesac2(k)=std(sac2)/sqrt(length(sac2));
    end

        allavgsac1(l,1:length(avgsac1))=avgsac1;
        allavgsac2(l,1:length(avgsac2))=avgsac2;


    clear avgsacfrq1 avgsacfrq2 stesacfrq1 stesacfrq2
    blkarr=unique(trltyp1(:,5));
    numblks=length(blkarr);
    for k=1:numblks
        sacfrq1=trltyp1(trltyp1(:,5)==blkarr(k),8);
        rcttim1=trltyp1(trltyp1(:,5)==blkarr(k),2)-trltyp1(trltyp1(:,5)==blkarr(k),1);
        sacfrq1=sacfrq1(rcttim1<X);
        avgsacfrq1(k)=mean(sacfrq1);
        stesacfrq1(k)=std(sacfrq1)/sqrt(length(sacfrq1));

        sacfrq2=trltyp2(trltyp2(:,5)==blkarr(k),8);
        rcttim2=trltyp2(trltyp2(:,5)==blkarr(k),2)-trltyp2(trltyp2(:,5)==blkarr(k),1);
        sacfrq2=sacfrq2(rcttim2<X);
        avgsacfrq2(k)=mean(sacfrq2);
        stesacfrq2(k)=std(sacfrq2)/sqrt(length(sacfrq2));
    end

        allavgsacfrq1(l,1:length(avgsacfrq1))=avgsacfrq1;
        allavgsacfrq2(l,1:length(avgsacfrq2))=avgsacfrq2;

clear cfg

end



allstert1=zeros(1,size(allavgrt1,2))+nan;
allstert2=zeros(1,size(allavgrt2,2))+nan;
for k=1:size(allavgrt1,2)
    allstert1(k)=nanstd(allavgrt1(:,k))/sqrt(length(find(~isnan(allavgrt1(:,k)))));
    allstert2(k)=nanstd(allavgrt2(:,k))/sqrt(length(find(~isnan(allavgrt2(:,k)))));
end

allstesac1=zeros(1,size(allavgsac1,2))+nan;
allstesac2=zeros(1,size(allavgsac2,2))+nan;
for k=1:size(allavgsac1,2)
    allstesac1(k)=nanstd(allavgsac1(:,k))/sqrt(length(find(~isnan(allavgsac1(:,k)))));
    allstesac2(k)=nanstd(allavgsac2(:,k))/sqrt(length(find(~isnan(allavgsac2(:,k)))));
end

allstesacfrq1=zeros(1,size(allavgsacfrq1,2))+nan;
allstesacfrq2=zeros(1,size(allavgsacfrq2,2))+nan;
for k=1:size(allavgsacfrq1,2)
    allstesacfrq1(k)=nanstd(allavgsacfrq1(:,k))/sqrt(length(find(~isnan(allavgsacfrq1(:,k)))));
    allstesacfrq2(k)=nanstd(allavgsacfrq2(:,k))/sqrt(length(find(~isnan(allavgsacfrq2(:,k)))));
end

%% figures
%scatter plot reaction time

figure;
plot(1:size(allavgrt1(:,1:20),2),nanmean(allavgrt1(:,1:20),1),'Color','k','Marker','o','MarkerEdgeColor','k','MarkerFaceColor','k');
hold on
plot(1:size(allavgrt2(:,1:20),2),nanmean(allavgrt2(:,1:20),1),'Color','k','Marker','o','MarkerEdgeColor','k');
hold on
errorbar((1:size(allavgrt1(:,1:20),2)),nanmean(allavgrt1(:,1:20),1),allstert1(:,1:20),allstert1(:,1:20),'k','LineStyle','none','Marker','none')
hold on
errorbar((1:size(allavgrt2(:,1:20),2)),nanmean(allavgrt2(:,1:20),1),allstert2(:,1:20),allstert2(:,1:20),'k','LineStyle','none','Marker','none')
leg1='Repeated';leg2='Novel';
xlim([0 size(allavgrt1(:,1:20),2)+1])
ylim([600 2000])
box off
xlabel('Block Number'), ylabel('Search Time (ms)');
legend(leg1,leg2)
title(strcat(ini,day,lesion))


%scatter plot # of saccades
figure;
plot(1:size(allavgsac1(:,1:20),2),nanmean(allavgsac1(:,1:20),1),'Color','b','Marker','o','MarkerEdgeColor','b','MarkerFaceColor','k');
hold on
plot(1:size(allavgsac2(:,1:20),2),nanmean(allavgsac2(:,1:20),1),'Color','k','Marker','o','MarkerEdgeColor','k');
hold on
errorbar((1:size(allavgsac1(:,1:20),2)),nanmean(allavgsac1(:,1:20),1),allstesac1(:,1:20),allstesac1(:,1:20),'b','LineStyle','none','Marker','none')
hold on
errorbar((1:size(allavgsac2(:,1:20),2)),nanmean(allavgsac2(:,1:20),1),allstesac2(:,1:20),allstesac2(:,1:20),'k','LineStyle','none','Marker','none')
leg1='Repeated';leg2='Novel';
xlim([0 size(allavgsac1(:,1:20),2)+1])
box off
xlabel('Block Number'), ylabel('# of saccades');
legend(leg1,leg2)
title(strcat(ini,day,lesion))



%scatter plot saccade frequency
figure;
plot(1:size(allavgsacfrq1(:,1:20),2),nanmean(allavgsacfrq1(:,1:20),1),'Color','b','Marker','o','MarkerEdgeColor','b');
hold on
plot(1:size(allavgsacfrq2(:,1:20),2),nanmean(allavgsacfrq2(:,1:20),1),'Color','r','Marker','o','MarkerEdgeColor','r');
hold on
errorbar((1:size(allavgsacfrq1(:,1:20),2)),nanmean(allavgsacfrq1(:,1:20),1),allstesacfrq1(:,1:20),allstesacfrq1(:,1:20),'b','LineStyle','none','Marker','none')
hold on
errorbar((1:size(allavgsacfrq2(:,1:20),2)),nanmean(allavgsacfrq2(:,1:20),1),allstesacfrq2(:,1:20),allstesacfrq2(:,1:20),'r','LineStyle','none','Marker','none')
leg1='Repeated';leg2='Novel';
xlim([0 size(allavgsacfrq1(:,1:20),2)+1])
box off
xlabel('Block Number'), ylabel('Frequency of saccades (Hz)');
legend(leg1,leg2)
title(strcat(ini,day,lesion))

%% rename data
TT2Postallavgrt1=allavgrt1;
TT2Postallavgrt2=allavgrt2;
TT2Postallavgsac1=allavgsac1;
TT2Postallavgsac2=allavgsac2;
TT2Postallavgsacfrq2=allavgsacfrq2;
TT2Postallavgsacfrq1=allavgsacfrq1;
TT2Postallstesacfrq1=allstesacfrq1;
TT2Postallstesacfrq2=allstesacfrq2;
TT2Postallstesac2=allstesac2;
TT2Postallstesac1=allstesac1;
TT2Postallstert1=allstert1;
TT2Postallstert2=allstert2;
TT2PostList=list;
TT2Posttrltyp1=trltyp1;
TT2Posttrltyp2=trltyp2;


save data
resfil=strcat('S:\Laura\24 hour\',monkey,'\',lesion,' Lesion\Day ',day');
save(resfil, 'TT2Postallavgrt1','TT2Postallavgrt2','TT2Postallavgsac1','TT2Postallavgsac2','TT2Postallavgsacfrq2',...
    'TT2Postallavgsacfrq1','TT2Postallstesacfrq1','TT2Postallstesacfrq2','TT2Postallstesac2','TT2Postallstesac1',...
    'TT2Postallstert1','TT2Postallstert2','TT2PostList','TT2Posttrltyp1','TT2Posttrltyp2');
disp(strcat('Saved:',resfil))

%%  compare day 1 old to day 2 old
load(strcat('S:\Laura\24 hour\',monkey,'\',lesion,' Lesion\Day 1'));
load(strcat('S:\Laura\24 hour\',monkey,'\',lesion,' Lesion\Day 2'));

%scatter plot reaction time
figure;
plot(1:size(TT1Postallavgrt1(:,1:20),2),nanmean(TT1Postallavgrt1(:,1:20),1),'Color','b','Marker','o','MarkerEdgeColor','b');
hold on
plot(1:size(TT2Postallavgrt1(:,1:20),2),nanmean(TT2Postallavgrt1(:,1:20),1),'Color','r','Marker','o','MarkerEdgeColor','r');
hold on
errorbar((1:size(TT1Postallavgrt1(:,1:20),2)),nanmean(TT1Postallavgrt1(:,1:20),1),TT1Postallstert1(:,1:20),TT1Postallstert1(:,1:20),'b','LineStyle','none','Marker','none')
hold on
errorbar((1:size(TT2Postallavgrt1(:,1:20),2)),nanmean(TT2Postallavgrt1(:,1:20),1),TT2Postallstert1(:,1:20),TT2Postallstert1(:,1:20),'r','LineStyle','none','Marker','none')
leg1='Day1';leg2='Day2';
xlim([0 size(TT1Postallavgrt1(:,1:20),2)+1])
box off
xlabel('Block Number'), ylabel('Reaction Time (ms)');
legend(leg1,leg2)
title(strcat(ini,' Repeat Day 1 vs Day 2'))


%scatter plot # of saccades
figure;
plot(1:size(TT1Postallavgsac1(:,1:20),2),nanmean(TT1Postallavgsac1(:,1:20),1),'Color','b','Marker','o','MarkerEdgeColor','b');
hold on
plot(1:size(TT2Postallavgsac1(:,1:20),2),nanmean(TT2Postallavgsac1(:,1:20),1),'Color','r','Marker','o','MarkerEdgeColor','r');
hold on
errorbar((1:size(TT1Postallavgsac1(:,1:20),2)),nanmean(TT1Postallavgsac1(:,1:20),1),TT1Postallstesac1(:,1:20),TT1Postallstesac1(:,1:20),'b','LineStyle','none','Marker','none')
hold on
errorbar((1:size(TT2Postallavgsac1(:,1:20),2)),nanmean(TT2Postallavgsac1(:,1:20),1),TT2Postallstesac1(:,1:20),TT2Postallstesac1(:,1:20),'r','LineStyle','none','Marker','none')
leg1='Day1';leg2='Day2';
xlim([0 size(TT1Postallavgsac1(:,1:20),2)+1])
box off
xlabel('Block Number'), ylabel('# of saccades');
legend(leg1,leg2)
title(strcat(ini,' Repeat Day 1 vs Day 2'))



%scatter plot saccade frequency
figure;
plot(1:size(TT1Postallavgsacfrq1(:,1:20),2),nanmean(TT1Postallavgsacfrq1(:,1:20),1),'Color','b','Marker','o','MarkerEdgeColor','b');
hold on
plot(1:size(TT2Postallavgsacfrq1(:,1:20),2),nanmean(TT2Postallavgsacfrq1(:,1:20),1),'Color','r','Marker','o','MarkerEdgeColor','r');
hold on
errorbar((1:size(TT1Postallavgsacfrq1(:,1:20),2)),nanmean(TT1Postallavgsacfrq1(:,1:20),1),TT1Postallstesacfrq1(:,1:20),TT1Postallstesacfrq1(:,1:20),'b','LineStyle','none','Marker','none')
hold on
errorbar((1:size(TT2Postallavgsacfrq1(:,1:20),2)),nanmean(TT2Postallavgsacfrq1(:,1:20),1),TT2Postallstesacfrq1(:,1:20),TT2Postallstesacfrq1(:,1:20),'r','LineStyle','none','Marker','none')
leg1='Day1';leg2='Day2';
xlim([0 size(TT1Postallavgsacfrq1(:,1:20),2)+1])
box off
xlabel('Block Number'), ylabel('Frequency of saccades (Hz)');
legend(leg1,leg2)
title(strcat(ini,' Repeat Day 1 vs Day 2'))
