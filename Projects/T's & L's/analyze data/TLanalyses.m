% close all
clear all
pack

list=[ ...
% %OLD SETS    
%     'MP090327set300'; 'MP090330set301'; 'MP090402set311'; 'MP090403set312'; 'MP090407set314';
%     'MP090416set318'; 'MP090529set340'; 'MP090622set349';
%   
%     'TD090605set300'; 'TD090818set315'; 'TD090819set371'; 'TD090824set374'; 'TD090826set376';
%     'TD090827set377'; 'TD090903set380'; 'TD090821set373';
%
%     'IW090702set094'; 'IW090706set095'; 'IW090707set096'; 'IW090710set101'; 'IW090713set102';
%     'IW090714set103'; 'IW090717set108'; 'IW090721set113';
%
%     'TT090710set102'; 'TT090713set103'; 'TT090714set104'; 'TT090715set105'; 'TT090716set109';
%     'TT090717set110'; 'TT090720set112'; 'TT090722set079';
% 'TD090629set095'; % showed difference b/t old and new on first 2 blocks
% 'IW090619set085'; 'IW090630set093';
% MP090408set315 % hadn't seen before but still showed early memory effect
% MP090420set320 % had seen a week or two earlier but didn't show early memory effect
% MP090424set323 % had seen a few days earlier but didn't show early memory effect

%     'TD090605set300'; 'TD090608set078'; 'TD090609set079'; 'TD090624set092'; 
%     'TD090630set094'; %Theodore's old sets


% %TIMMY
 % % TIMMYpre-lesion (15)
%  'TT090817set131'; 'TT090819set132'; 'TT090824set134'; 'TT090826set135'; 'TT090831set136';
%  'TT090902set137'; 'TT090923set143'; 'TT090928set145'; 'TT090930set146'; 'TT091005set147';
%  'TT091007set148'; 'TT091012set149'; 'TT091014set150'; 'TT091019set151'; 'TT091021set152';
 % % TIMMY post-lesion (16)
% 'TT110601set401'; 'TT110602set402'; 'TT110603set403'; 'TT110606set404'; 'TT110607set405';
% 'TT110609set407'; 'TT110610set408'; 'TT110614set409'; 'TT110615set410'; 'TT110616set411';
% 'TT110617set412'; 'TT110620set413'; 'TT110621set414'; 'TT110622set415'; 'TT110623set416'; 'TT110624set417'; 
% %TIMMY bw sets
%   'TT111013set21bw412';'TT111011set21bw411';'TT111004set21bw410';'TT110726set21bw409';'TT110718set21bw408';'TT110712set21bw407';
%   'TT110711set21bw406';'TT110708set21bw405';'TT110706set21bw404';'TT110705set21bw403';'TT110630set21bw402';
% %TIMMY ro sets
% 'TT110714set21ro400';
% 'TT110729set21ro406';'TT110908set21ro407';'TT110915set21ro408';'TT110922set21ro409';'TT110929set21ro410';'TT111006set21ro411';
% 'TT110715set21ro401';'TT110719set21ro402';'TT110721set21ro403';'TT110725set21ro404';'TT110727set21ro405';
% %TIMMY sh sets
%     'TT120320setsh400';
%     'TT120326setsh402';'TT120321setsh401';
% 'TT120405setsh500';'TT120409setsh501';'TT120410setsh502';'TT120412setsh503';'TT120418setsh504';

% %PEEPERS
%    'MP110526set400';'MP110531set401';'MP110601set402';'MP110603set404';'MP110606set405';'MP110607set406';'MP110608set407';'MP110609set408';
%    'MP110610set409';'MP110616set412';'MP110620set413';'MP110621set414';'MP110624set415';'MP110623set416';% 'MP120813set484';
% %24HR repeated sets
% 'MP120925set494';'MP120921set493';'MP120821set485';'MP120911set489';'MP120814set484';'MP120807set483';'MP120803set482';
% 'MP120731set481';'MP120727set480';'MP120720set478';'MP120717set477';'MP120713set476';'MP120709set475';'MP120703set473';
% 'MP120628set472';'MP120626set471';'MP120622set470';'MP120619set469';'MP120615set468';
% %PEEPERS bw sets
%        'MP120418set21bw411';'MP111020set21bw410';'MP111006set21bw409';'MP110929set21bw408';'MP110722set21bw406';
%        'MP110720set21bw405';'MP110711set21bw404';'MP110705set21bw403';'MP110629set21bw402';    
% %PEEPERS ro sets
% %      'MP110714set21ro400';
% %      'MP110718set21ro303';'MP110721set21ro304';'MP110725set21ro305';'MP110727set21ro306';'MP110729set21ro307';'MP110908set21ro308';'MP110915set21ro309';'MP110922set21ro310';
%      'MP110927set21ro402';'MP111004set21ro403';'MP111012set21ro404';'MP111018set21ro405';'MP111212set21ro406';
%      'MP111219set21ro408';'MP120111set21ro409';'MP120117set21ro410';'MP120125set21ro411';
    % %PEEPERS sh sets
%     'MP120314setsh303';
%      'MP120425setsh501';'MP120427setsh502';'MP120430setsh503';'MP120510setsh504';

% %GUISEPPE
%  'JN110727set419';'JN110721set418';'JN110718set417';'JN110712set416';'JN110711set415';'JN110708set413';'JN110707set412';'JN110706set411';'JN110705set410';
%  'JN110701set409';'JN110630set408';'JN110629set407';'JN110628set406';'JN110627set405';'JN110624set404';'JN110623set403';'JN110622set402';'JN110621set401';
  % %Guiseppe bw sets
%   'JN110715set21bw400';
%   'JN110720set21bw401';'JN110726set21bw402'; 'JN110729set21bw403';'JN110923set21bw404';'JN110927set21bw405';
%   'JN111007set21bw406';'JN111013set21bw407';'JN111028set21bw408';'JN111102set21bw409';
% %Guiseppe ro sets
%   'JN110719set21ro400';
%     'JN110722set21ro401';'JN110725set21ro402';'JN110728set21ro403';'JN111004set21ro406';'JN110912set21ro407';
%     'JN110915set21ro408';'JN110922set21ro409';'JN111017set21ro410';'JN120418set21ro411';
% %Guiseppe sh sets
%     'JN120206setsh100';'JN120207setsh101';'JN120210setsh200';'JN120213setsh201';'JN120214setsh202';
%     'JN120215setsh300';'JN120216setsh301';'JN120223setsh302';
%     'JN120229setsh400';'JN120302setsh401';'JN120305setsh402';'JN120307setsh403';'JN120313setsh404';
%   'JN120425setsh501';'JN120427setsh502';'JN120430setsh503';'JN120502setsh504';

% %IRWIN
%  'IW110721set411';'IW110719set410';'IW110714set409';'IW110713set408';'IW110712set407';
%  'IW110711set406';'IW110708set405';'IW110707set404';'IW110706set402';'IW110705set401';'IW110701set400';
    % %IRWIN bw sets
%   'IW110715set21bw400';'IW110718set21bw401';'IW110720set21bw402';'IW110722set21bw403';
    % % IRWIN sh sets
%     'IW120409setsh501';'IW120411setsh502';'IW120413setsh503';'IW120419setsh504'(37 blks); 
  
    ];

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
    for k=1:numblks
        
        % % removes outliers
%         rcttim1dum=trltyp1(trltyp1(:,5)==blkarr(k),2)-trltyp1(trltyp1(:,5)==blkarr(k),1);
%         rcttim1dum=rcttim1dum(rcttim1dum<8000);
%         mu3=mean(rcttim1dum);
%         sigma3=std(rcttim1dum);
%         outliers=(rcttim1dum-mu3)>2*sigma3;
%         rcttim1=rcttim1dum;
%         rcttim1(outliers)=NaN;
%         avgrt1(k)=nanmean(rcttim1);
%         stert1(k)=nanstd(rcttim1)/sqrt(length(find(~isnan(rcttim1))));
%         clear mu3 sigma3 outliers
%         
%         rcttim2dum=trltyp2(trltyp2(:,5)==blkarr(k),2)-trltyp2(trltyp2(:,5)==blkarr(k),1);
%         rcttim2dum=rcttim2dum(rcttim2dum<8000);
%         mu3=mean(rcttim2dum);
%         sigma3=std(rcttim2dum);
%         outliers=(rcttim2dum-mu3)>2*sigma3;
%         rcttim2=rcttim2dum;
%         rcttim2(outliers)=NaN;
%         figure(l)
%         hist(rcttim2)
%         avgrt2(k)=nanmean(rcttim2);
%         stert2(k)=nanstd(rcttim2)/sqrt(length(find(~isnan(rcttim2))));
% 
%         clear mu3 sigma3 outliers

          % % includes all rt values
          rcttim1=trltyp1(trltyp1(:,5)==blkarr(k),2)-trltyp1(trltyp1(:,5)==blkarr(k),1);
          rcttim1=rcttim1(rcttim1<8000);
          avgrt1(k)=mean(rcttim1);
          stert1(k)=std(rcttim1)/sqrt(length(rcttim1));
          
          rcttim2=trltyp2(trltyp2(:,5)==blkarr(k),2)-trltyp2(trltyp2(:,5)==blkarr(k),1);
          rcttim2=rcttim2(rcttim2<8000);
          avgrt2(k)=mean(rcttim2);
          stert2(k)=std(rcttim2)/sqrt(length(rcttim2));
        
%     if strmatch('TD090821set373',list(l,:))
%         allavgrt1(l,1:length(avgrt1)-1)=avgrt1(1:end-1);
%         allavgrt2(l,1:length(avgrt2)-1)=avgrt2(1:end-1);
%     else
        allavgrt1(l,1:length(avgrt1))=avgrt1;
        allavgrt2(l,1:length(avgrt2))=avgrt2;
%     end

    clear avgsac1 avgsac2 stesac1 stesac2
    blkarr=unique(trltyp1(:,5));
    numblks=length(blkarr);
    for k=1:numblks
        sac1=trltyp1(trltyp1(:,5)==blkarr(k),7);
        rcttim1=trltyp1(trltyp1(:,5)==blkarr(k),2)-trltyp1(trltyp1(:,5)==blkarr(k),1);
        sac1=sac1(rcttim1<8000);
        avgsac1(k)=mean(sac1);
        stesac1(k)=std(sac1)/sqrt(length(sac1));

        sac2=trltyp2(trltyp2(:,5)==blkarr(k),7);
        rcttim2=trltyp2(trltyp2(:,5)==blkarr(k),2)-trltyp2(trltyp2(:,5)==blkarr(k),1);
        sac2=sac2(rcttim2<8000);
        avgsac2(k)=mean(sac2);
        stesac2(k)=std(sac2)/sqrt(length(sac2));
    end

%     if strmatch('TD090821set373',list(l,:))
%         allavgsac1(l,1:length(avgsac1)-1)=avgsac1(1:end-1);
%         allavgsac2(l,1:length(avgsac2)-1)=avgsac2(1:end-1);
%     else
        allavgsac1(l,1:length(avgsac1))=avgsac1;
        allavgsac2(l,1:length(avgsac2))=avgsac2;
%     end

    clear avgsacfrq1 avgsacfrq2 stesacfrq1 stesacfrq2
    blkarr=unique(trltyp1(:,5));
    numblks=length(blkarr);
    for k=1:numblks
        sacfrq1=trltyp1(trltyp1(:,5)==blkarr(k),8);
        rcttim1=trltyp1(trltyp1(:,5)==blkarr(k),2)-trltyp1(trltyp1(:,5)==blkarr(k),1);
        sacfrq1=sacfrq1(rcttim1<8000);
        avgsacfrq1(k)=mean(sacfrq1);
        stesacfrq1(k)=std(sacfrq1)/sqrt(length(sacfrq1));

        sacfrq2=trltyp2(trltyp2(:,5)==blkarr(k),8);
        rcttim2=trltyp2(trltyp2(:,5)==blkarr(k),2)-trltyp2(trltyp2(:,5)==blkarr(k),1);
        sacfrq2=sacfrq2(rcttim2<8000);
        avgsacfrq2(k)=mean(sacfrq2);
        stesacfrq2(k)=std(sacfrq2)/sqrt(length(sacfrq2));
    end

%     if strmatch('TD090821set373',list(l,:))
%         allavgsacfrq1(l,1:length(avgsacfrq1)-1)=avgsacfrq1(1:end-1);
%         allavgsacfrq2(l,1:length(avgsacfrq2)-1)=avgsacfrq2(1:end-1);
%     else
        allavgsacfrq1(l,1:length(avgsacfrq1))=avgsacfrq1;
        allavgsacfrq2(l,1:length(avgsacfrq2))=avgsacfrq2;
    end
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

%% SINGLE SET REACTION TIMES
for k=1:numblks
    rcttim1=trltyp1(trltyp1(:,5)==blkarr(k),2)-trltyp1(trltyp1(:,5)==blkarr(k),1);
    rcttim1=rcttim1(rcttim1<8000);
    avgrt1(k)=mean(rcttim1);
    stert1(k)=std(rcttim1)/sqrt(length(rcttim1));
    
    rcttim2=trltyp2(trltyp2(:,5)==blkarr(k),2)-trltyp2(trltyp2(:,5)==blkarr(k),1);
    rcttim2=rcttim2(rcttim2<8000);
    avgrt2(k)=mean(rcttim2);
    stert2(k)=std(rcttim2)/sqrt(length(rcttim2));
end

figure;
plot(avgrt1,'Color','k','Marker','o','MarkerEdgeColor','k');
hold on
plot(avgrt2,'Color','r','Marker','o','MarkerEdgeColor','r');
hold on
errorbar((1:k),avgrt1(1:k),stert1(1:k),stert1(1:k),'k','LineStyle','none','Marker','none')
hold on
errorbar((1:k),avgrt2(1:k),stert2(1:k),stert2(1:k),'r','LineStyle','none','Marker','none')
leg1='Repeated';leg2='Novel';
xlim([0 40])
h=ylim;
n=min(min(avgrt1),min(avgrt2));
m=max(max(stert1),max(stert2));
ylim([0 h(2)+100]);
box off
ylabel('Search Time (ms)');
legend(leg1,leg2)
title(datfil(find(datfil=='\',1,'last')+1:end))

clear avgsac1 avgsac2 stesac1 stesac2
blkarr=unique(trltyp1(:,5));
numblks=length(blkarr);

%% PLOT
% %bar graph reaction time
% figure;
% bar(1:size(allavgrt1(:,1:20),2),[nanmean(allavgrt1(:,1:20),1)' nanmean(allavgrt2(:,1:20),1)'],'Grouped','BarWidth',1.5);
% hold on
% errorbar((1:size(allavgrt1(:,1:20),2))-0.142,nanmean(allavgrt1(:,1:20),1),allstert1(:,1:20),allstert1(:,1:20),'k','LineStyle','none','Marker','none')
% hold on
% errorbar((1:size(allavgrt2(:,1:20),2))+0.142,nanmean(allavgrt2(:,1:20),1),allstert2(:,1:20),allstert2(:,1:20),'k','LineStyle','none','Marker','none')
% leg1='Repeated';leg2='Novel';
% xlim([0 size(allavgrt1(:,1:20),2)+1])
% box off
% xlabel('Block Number'), ylabel('Search Time (ms)');
% legend(leg1,leg2)
% title('Average reaction time across sessions')

%scatter plot reaction time
figure;
plot(1:size(allavgrt1(:,1:40),2),nanmean(allavgrt1(:,1:40),1),'Color','k','Marker','o','MarkerEdgeColor','k');
hold on
plot(1:size(allavgrt2(:,1:40),2),nanmean(allavgrt2(:,1:40),1),'Color','r','Marker','o','MarkerEdgeColor','r');
hold on
errorbar((1:size(allavgrt1(:,1:40),2)),nanmean(allavgrt1(:,1:40),1),allstert1(:,1:40),allstert1(:,1:40),'k','LineStyle','none','Marker','none')
hold on
errorbar((1:size(allavgrt2(:,1:40),2)),nanmean(allavgrt2(:,1:40),1),allstert2(:,1:40),allstert2(:,1:40),'r','LineStyle','none','Marker','none')
leg1='Repeated';leg2='Novel';
xlim([0 size(allavgrt1(:,1:40),2)+1])
% ylim([950 2750])
box off
xlabel('Block Number'), ylabel('Search Time (ms)');
legend(leg1,leg2)
title('Average reaction time across sessions')

% %bar graph # of saccades
% figure;
% bar(1:size(allavgsac1(:,1:20),2),[nanmean(allavgsac1(:,1:20),1)' nanmean(allavgsac2(:,1:20),1)'],'Grouped','BarWidth',1.5);
% hold on
% errorbar((1:size(allavgsac1(:,1:20),2))-0.142,nanmean(allavgsac1(:,1:20),1),allstesac1(:,1:20),allstesac1(:,1:20),'k','LineStyle','none','Marker','none')
% hold on
% errorbar((1:size(allavgsac1(:,1:20),2))+0.142,nanmean(allavgsac2(:,1:20),1),allstesac2(:,1:20),allstesac2(:,1:20),'k','LineStyle','none','Marker','none')
% leg1='Repeated';leg2='Novel';
% xlim([0 size(allavgsac1(:,1:20),2)+1])
% box off
% xlabel('Block Number'), ylabel('# of saccades');
% legend(leg1,leg2)
% title('Average saccade number across sessions')

%scatter plot # of saccades
figure;
plot(1:size(allavgsac1(:,1:45),2),nanmean(allavgsac1(:,1:45),1),'Color','b','Marker','o','MarkerEdgeColor','b');
hold on
plot(1:size(allavgsac2(:,1:45),2),nanmean(allavgsac2(:,1:45),1),'Color','r','Marker','o','MarkerEdgeColor','r');
hold on
errorbar((1:size(allavgsac1(:,1:45),2)),nanmean(allavgsac1(:,1:45),1),allstesac1(:,1:45),allstesac1(:,1:45),'b','LineStyle','none','Marker','none')
hold on
errorbar((1:size(allavgsac2(:,1:45),2)),nanmean(allavgsac2(:,1:45),1),allstesac2(:,1:45),allstesac2(:,1:45),'r','LineStyle','none','Marker','none')
leg1='Repeated';leg2='Novel';
xlim([0 size(allavgsac1(:,1:45),2)+1])
box off
xlabel('Block Number'), ylabel('# of saccades');
legend(leg1,leg2)
title('Average saccade number across sessions')

% %bar graph saccade frequency
% figure;
% bar(1:size(allavgsacfrq1(:,1:20),2),[nanmean(allavgsacfrq1(:,1:20),1)' nanmean(allavgsacfrq2(:,1:20),1)'],'Grouped','BarWidth',1.5);
% hold on
% errorbar((1:size(allavgsacfrq1(:,1:20),2))-0.142,nanmean(allavgsacfrq1(:,1:20),1),allstesacfrq1(:,1:20),allstesacfrq1(:,1:20),'k','LineStyle','none','Marker','none')
% hold on
% errorbar((1:size(allavgsacfrq1(:,1:20),2))+0.142,nanmean(allavgsacfrq2(:,1:20),1),allstesacfrq2(:,1:20),allstesacfrq2(:,1:20),'k','LineStyle','none','Marker','none')
% leg1='Repeated';leg2='Novel';
% xlim([0 size(allavgsacfrq1(:,1:20),2)+1])
% box off
% xlabel('Block Number'), ylabel('Frequency of saccades (Hz)');
% legend(leg1,leg2)
% title('Average saccade frequency across sessions')

%scatter plot saccade frequency
figure;
plot(1:size(allavgsacfrq1(:,1:50),2),nanmean(allavgsacfrq1(:,1:50),1),'Color','b','Marker','o','MarkerEdgeColor','b');
hold on
plot(1:size(allavgsacfrq2(:,1:50),2),nanmean(allavgsacfrq2(:,1:50),1),'Color','r','Marker','o','MarkerEdgeColor','r');
hold on
errorbar((1:size(allavgsacfrq1(:,1:50),2)),nanmean(allavgsacfrq1(:,1:50),1),allstesacfrq1(:,1:50),allstesacfrq1(:,1:50),'b','LineStyle','none','Marker','none')
hold on
errorbar((1:size(allavgsacfrq2(:,1:50),2)),nanmean(allavgsacfrq2(:,1:50),1),allstesacfrq2(:,1:50),allstesacfrq2(:,1:50),'r','LineStyle','none','Marker','none')
leg1='Repeated';leg2='Novel';
xlim([0 size(allavgsacfrq1(:,1:50),2)+1])
box off
xlabel('Block Number'), ylabel('Frequency of saccades (Hz)');
legend(leg1,leg2)
title('Average saccade frequency across sessions')

%% NORMALIZED
allavgrt1(allavgrt1==0)=nan;
allavgrt2(allavgrt2==0)=nan;
allavgsac1(allavgsac1==0)=nan;
allavgsac2(allavgsac2==0)=nan;
allavgsacfrq1(allavgsacfrq1==0)=nan;
allavgsacfrq2(allavgsacfrq2==0)=nan;

mnklst=unique(list(:,1:2),'rows');

avgmnkrt1=[];
avgmnkrt2=[];
for k=1:size(mnklst,1)
    rowtouse=strmatch(mnklst(k,:),list);
    avgmnkrt1(k,:)=nanmean(allavgrt1(rowtouse,:),1);
    avgmnkrt2(k,:)=nanmean(allavgrt2(rowtouse,:),1);
end

%normalize
avgmnkrt1norm=[];
avgmnkrt2norm=[];
for k=1:size(avgmnkrt1,1)
    for l=1:size(avgmnkrt1,2)
        avgmnkrt1norm(k,l)=avgmnkrt1(k,l)/mean([avgmnkrt1(k,1) avgmnkrt2(k,1)]);
    end
end
for k=1:size(avgmnkrt2,1)
    for l=1:size(avgmnkrt2,2)
        avgmnkrt2norm(k,l)=avgmnkrt2(k,l)/mean([avgmnkrt1(k,1) avgmnkrt2(k,1)]);
    end
end

avgmnksac1=[];
avgmnksac2=[];
for k=1:size(mnklst,1)
    rowtouse=strmatch(mnklst(k,:),list);
    avgmnksac1(k,:)=nanmean(allavgsac1(rowtouse,:),1);
    avgmnksac2(k,:)=nanmean(allavgsac2(rowtouse,:),1);
end

%normalize
avgmnksac1norm=[];
avgmnksac2norm=[];
for k=1:size(avgmnksac1,1)
    for l=1:size(avgmnksac1,2)
        avgmnksac1norm(k,l)=avgmnksac1(k,l)/mean([avgmnksac1(k,1) avgmnksac2(k,1)]);
    end
end
for k=1:size(avgmnksac2,1)
    for l=1:size(avgmnksac2,2)
        avgmnksac2norm(k,l)=avgmnksac2(k,l)/mean([avgmnksac1(k,1) avgmnksac2(k,1)]);
    end
end

avgmnksacfrq1=[];
avgmnksacfrq2=[];
for k=1:size(mnklst,1)
    rowtouse=strmatch(mnklst(k,:),list);
    avgmnksacfrq1(k,:)=nanmean(allavgsacfrq1(rowtouse,:),1);
    avgmnksacfrq2(k,:)=nanmean(allavgsacfrq2(rowtouse,:),1);
end

%normalize
avgmnksacfrq1norm=[];
avgmnksacfrq2norm=[];
for k=1:size(avgmnksacfrq1,1)
    for l=1:size(avgmnksacfrq1,2)
        avgmnksacfrq1norm(k,l)=avgmnksacfrq1(k,l)/mean([avgmnksacfrq1(k,1) avgmnksacfrq2(k,1)]);
    end
end
for k=1:size(avgmnksacfrq2,1)
    for l=1:size(avgmnksacfrq2,2)
        avgmnksacfrq2norm(k,l)=avgmnksacfrq2(k,l)/mean([avgmnksacfrq1(k,1) avgmnksacfrq2(k,1)]);
    end
end

meanavgmnkrt1=nanmean(avgmnkrt1norm,1);
meanavgmnkrt2=nanmean(avgmnkrt2norm,1);
meanavgmnksac1=nanmean(avgmnksac1norm,1);
meanavgmnksac2=nanmean(avgmnksac2norm,1);
meanavgmnksacfrq1=nanmean(avgmnksacfrq1norm,1);
meanavgmnksacfrq2=nanmean(avgmnksacfrq2norm,1);

clear steavgmnkrt1 steavgmnkrt2 steavgmnksac1 steavgmnksac2 steavgmnksacfrq1 steavgmnksacfrq2
for k=1:size(avgmnkrt1,2)
    steavgmnkrt1(k)=nanstd(avgmnkrt1norm(:,k),1)/sqrt(length(find(~isnan(avgmnkrt1norm(:,k)))));
    steavgmnkrt2(k)=nanstd(avgmnkrt2norm(:,k),1)/sqrt(length(find(~isnan(avgmnkrt2norm(:,k)))));
    steavgmnksac1(k)=nanstd(avgmnksac1norm(:,k),1)/sqrt(length(find(~isnan(avgmnksac1norm(:,k)))));
    steavgmnksac2(k)=nanstd(avgmnksac2norm(:,k),1)/sqrt(length(find(~isnan(avgmnksac2norm(:,k)))));
    steavgmnksacfrq1(k)=nanstd(avgmnksacfrq1norm(:,k),1)/sqrt(length(find(~isnan(avgmnksacfrq1norm(:,k)))));
    steavgmnksacfrq2(k)=nanstd(avgmnksacfrq2norm(:,k),1)/sqrt(length(find(~isnan(avgmnksacfrq2norm(:,k)))));
end

% figure;
% bar(1:20,[meanavgmnkrt1(1:20)' meanavgmnkrt2(1:20)'],'Grouped','BarWidth',1.5);
% hold on
% errorbar((1:20)-0.142,meanavgmnkrt1(1:20),steavgmnkrt1(1:20),steavgmnkrt1(1:20),'k','LineStyle','none','Marker','none')
% hold on
% errorbar((1:20)+0.142,meanavgmnkrt2(1:20),steavgmnkrt2(1:20),steavgmnkrt2(1:20),'k','LineStyle','none','Marker','none')
% leg1='Repeated';leg2='Novel';
% xlim([0 21])
% box off
% xlabel('Block Number'), ylabel('Search Time (ms)');
% legend(leg1,leg2)
% title('Average reaction time across sessions')

% figure;
plot(1:40,meanavgmnkrt1(1:40),'Color','k','Marker','o','MarkerEdgeColor','k','MarkerFaceColor','k');
hold on
plot(1:40,meanavgmnkrt2(1:40),'Color','k','Marker','o','MarkerEdgeColor','k');
hold on
errorbar((1:40),meanavgmnkrt1(1:40),steavgmnkrt1(1:40),steavgmnkrt1(1:40),'k','LineStyle','none','Marker','none')
hold on
errorbar((1:40),meanavgmnkrt2(1:40),steavgmnkrt2(1:40),steavgmnkrt2(1:40),'k','LineStyle','none','Marker','none')
leg1='Repeated';leg2='Novel';
xlim([0 41])
box off
xlabel('Block Number'), ylabel('Search Time (ms)');
legend(leg1,leg2,leg3,leg4)
title('Average reaction time across sessions')

% figure;
% bar(1:20,[meanavgmnksac1(1:20)' meanavgmnksac2(1:20)'],'Grouped','BarWidth',1.5);
% hold on
% errorbar((1:20)-0.142,meanavgmnksac1(1:20),steavgmnksac1(1:20),steavgmnksac1(1:20),'k','LineStyle','none','Marker','none')
% hold on
% errorbar((1:20)+0.142,meanavgmnksac2(1:20),steavgmnksac2(1:20),steavgmnksac2(1:20),'k','LineStyle','none','Marker','none')
% leg1='Repeated';leg2='Novel';
% xlim([0 21])
% box off
% xlabel('Block Number'), ylabel('# of saccades');
% legend(leg1,leg2)
% title('Average saccade number across sessions')

% figure;
plot(1:40,meanavgmnksac1(1:40),'Color','k','Marker','o','MarkerEdgeColor','k');
hold on
plot(1:40,meanavgmnksac2(1:40),'Color','r','Marker','o','MarkerEdgeColor','r');
hold on
errorbar((1:40),meanavgmnksac1(1:40),steavgmnksac1(1:40),steavgmnksac1(1:40),'k','LineStyle','none','Marker','none')
hold on
errorbar((1:40),meanavgmnksac2(1:40),steavgmnksac2(1:40),steavgmnksac2(1:40),'r','LineStyle','none','Marker','none')
leg1='Repeated';leg2='Novel';
xlim([0 41])
box off
xlabel('Block Number'), ylabel('# of saccades');
legend(leg1,leg2,leg3,leg4)
title('Average saccade number across sessions')

% figure;
% bar(1:20,[meanavgmnksacfrq1(1:20)' meanavgmnksacfrq2(1:20)'],'Grouped','BarWidth',1.5);
% hold on
% errorbar((1:20)-0.142,meanavgmnksacfrq1(1:20),steavgmnksacfrq1(1:20),steavgmnksacfrq1(1:20),'k','LineStyle','none','Marker','none')
% hold on
% errorbar((1:20)+0.142,meanavgmnksacfrq2(1:20),steavgmnksacfrq2(1:20),steavgmnksacfrq2(1:20),'k','LineStyle','none','Marker','none')
% leg1='Repeated';leg2='Novel';
% xlim([0 21])
% box off
% xlabel('Block Number'), ylabel('Frequency of saccades');
% legend(leg1,leg2)
% title('Average saccade frequency across sessions')

% figure;
plot(1:40,meanavgmnksacfrq1(1:40),'Color','k','Marker','o','MarkerEdgeColor','k');
hold on
plot(1:40,meanavgmnksacfrq2(1:40),'Color','r','Marker','o','MarkerEdgeColor','r');
hold on
errorbar((1:40),meanavgmnksacfrq1(1:40),steavgmnksacfrq1(1:40),steavgmnksacfrq1(1:40),'k','LineStyle','none','Marker','none')
hold on
errorbar((1:40),meanavgmnksacfrq2(1:40),steavgmnksacfrq2(1:40),steavgmnksacfrq2(1:40),'r','LineStyle','none','Marker','none')
leg1='Repeated';leg2='Novel';
xlim([0 41])
box off
xlabel('Block Number'), ylabel('Frequency of saccades');
legend(leg1,leg2, leg3,leg4)
title('Average saccade frequency across sessions')
%% NORMALIZED LESION(L) VS. CONTROL
% % COMMENT OUT WHEN RUNNING LESION DATA
allavgrt1(allavgrt1==0)=nan;
allavgrt2(allavgrt2==0)=nan;
allavgsac1(allavgsac1==0)=nan;
allavgsac2(allavgsac2==0)=nan;
allavgsacfrq1(allavgsacfrq1==0)=nan;
allavgsacfrq2(allavgsacfrq2==0)=nan;

mnklst=unique(list(:,1:2),'rows');

avgmnkrt1=[];
avgmnkrt2=[];
for k=1:size(mnklst,1)
    rowtouse=strmatch(mnklst(k,:),list);
    avgmnkrt1(k,:)=nanmean(allavgrt1(rowtouse,:),1);
    avgmnkrt2(k,:)=nanmean(allavgrt2(rowtouse,:),1);
end

%normalize
avgmnkrt1norm=[];
avgmnkrt2norm=[];
for k=1:size(avgmnkrt1,1)
    for l=1:size(avgmnkrt1,2)
        avgmnkrt1norm(k,l)=avgmnkrt1(k,l)/mean([avgmnkrt1(k,1) avgmnkrt2(k,1)]);
    end
end
for k=1:size(avgmnkrt2,1)
    for l=1:size(avgmnkrt2,2)
        avgmnkrt2norm(k,l)=avgmnkrt2(k,l)/mean([avgmnkrt1(k,1) avgmnkrt2(k,1)]);
    end
end

avgmnksac1=[];
avgmnksac2=[];
for k=1:size(mnklst,1)
    rowtouse=strmatch(mnklst(k,:),list);
    avgmnksac1(k,:)=nanmean(allavgsac1(rowtouse,:),1);
    avgmnksac2(k,:)=nanmean(allavgsac2(rowtouse,:),1);
end

%normalize
avgmnksac1norm=[];
avgmnksac2norm=[];
for k=1:size(avgmnksac1,1)
    for l=1:size(avgmnksac1,2)
        avgmnksac1norm(k,l)=avgmnksac1(k,l)/mean([avgmnksac1(k,1) avgmnksac2(k,1)]);
    end
end
for k=1:size(avgmnksac2,1)
    for l=1:size(avgmnksac2,2)
        avgmnksac2norm(k,l)=avgmnksac2(k,l)/mean([avgmnksac1(k,1) avgmnksac2(k,1)]);
    end
end

avgmnksacfrq1=[];
avgmnksacfrq2=[];
for k=1:size(mnklst,1)
    rowtouse=strmatch(mnklst(k,:),list);
    avgmnksacfrq1(k,:)=nanmean(allavgsacfrq1(rowtouse,:),1);
    avgmnksacfrq2(k,:)=nanmean(allavgsacfrq2(rowtouse,:),1);
end

%normalize
avgmnksacfrq1norm=[];
avgmnksacfrq2norm=[];
for k=1:size(avgmnksacfrq1,1)
    for l=1:size(avgmnksacfrq1,2)
        avgmnksacfrq1norm(k,l)=avgmnksacfrq1(k,l)/mean([avgmnksacfrq1(k,1) avgmnksacfrq2(k,1)]);
    end
end
for k=1:size(avgmnksacfrq2,1)
    for l=1:size(avgmnksacfrq2,2)
        avgmnksacfrq2norm(k,l)=avgmnksacfrq2(k,l)/mean([avgmnksacfrq1(k,1) avgmnksacfrq2(k,1)]);
    end
end
 
meanavgmnkrt1=nanmean(avgmnkrt1norm,1);
meanavgmnkrt2=nanmean(avgmnkrt2norm,1);
meanavgmnksac1=nanmean(avgmnksac1norm,1);
meanavgmnksac2=nanmean(avgmnksac2norm,1);
meanavgmnksacfrq1=nanmean(avgmnksacfrq1norm,1);
meanavgmnksacfrq2=nanmean(avgmnksacfrq2norm,1);

clear steavgmnkrt1 steavgmnkrt2 steavgmnksac1 steavgmnksac2 steavgmnksacfrq1 steavgmnksacfrq2
for k=1:size(avgmnkrt1,2)
    steavgmnkrt1(k)=nanstd(avgmnkrt1norm(:,k),1)/sqrt(length(find(~isnan(avgmnkrt1norm(:,k)))));
    steavgmnkrt2(k)=nanstd(avgmnkrt2norm(:,k),1)/sqrt(length(find(~isnan(avgmnkrt2norm(:,k)))));
    steavgmnksac1(k)=nanstd(avgmnksac1norm(:,k),1)/sqrt(length(find(~isnan(avgmnksac1norm(:,k)))));
    steavgmnksac2(k)=nanstd(avgmnksac2norm(:,k),1)/sqrt(length(find(~isnan(avgmnksac2norm(:,k)))));
    steavgmnksacfrq1(k)=nanstd(avgmnksacfrq1norm(:,k),1)/sqrt(length(find(~isnan(avgmnksacfrq1norm(:,k)))));
    steavgmnksacfrq2(k)=nanstd(avgmnksacfrq2norm(:,k),1)/sqrt(length(find(~isnan(avgmnksacfrq2norm(:,k)))));
end

figure;
plot(1:40,meanavgmnkrt1(1:40),'Color','k','Marker','o','MarkerEdgeColor','k');
hold on
plot(1:40,meanavgmnkrt2(1:40),'Color','r','Marker','o','MarkerEdgeColor','r');
hold on
errorbar((1:40),meanavgmnkrt1(1:40),steavgmnkrt1(1:40),steavgmnkrt1(1:40),'k','LineStyle','none','Marker','none')
hold on
errorbar((1:40),meanavgmnkrt2(1:40),steavgmnkrt2(1:40),steavgmnkrt2(1:40),'r','LineStyle','none','Marker','none')
leg1='Repeated Lesioned';leg2='Novel Lesioned';leg3='Novel';leg4='Repeated';
xlim([0 41])
box off
xlabel('Block Number'), ylabel('Search Time');
legend(leg1,leg2,leg3,leg4)
title('Average reaction time across sessions')

% % LESIONED NORMALIZED (COMMENT OUT WHEN RUNNING NORMAL DATA)
% Lmeanavgmnkrt1=nanmean(avgmnkrt1norm,1);
% Lmeanavgmnkrt2=nanmean(avgmnkrt2norm,1);
% Lmeanavgmnksac1=nanmean(avgmnksac1norm,1);
% Lmeanavgmnksac2=nanmean(avgmnksac2norm,1);
% Lmeanavgmnksacfrq1=nanmean(avgmnksacfrq1norm,1);
% Lmeanavgmnksacfrq2=nanmean(avgmnksacfrq2norm,1);
% 
% clear Lsteavgmnkrt1 Lsteavgmnkrt2 Lsteavgmnksac1 Lsteavgmnksac2 Lsteavgmnksacfrq1 Lsteavgmnksacfrq2
% for k=1:size(avgmnkrt1,2)
%     Lsteavgmnkrt1(k)=nanstd(avgmnkrt1norm(:,k),1)/sqrt(length(find(~isnan(avgmnkrt1norm(:,k)))));
%     Lsteavgmnkrt2(k)=nanstd(avgmnkrt2norm(:,k),1)/sqrt(length(find(~isnan(avgmnkrt2norm(:,k)))));
%     Lsteavgmnksac1(k)=nanstd(avgmnksac1norm(:,k),1)/sqrt(length(find(~isnan(avgmnksac1norm(:,k)))));
%     Lsteavgmnksac2(k)=nanstd(avgmnksac2norm(:,k),1)/sqrt(length(find(~isnan(avgmnksac2norm(:,k)))));
%     Lsteavgmnksacfrq1(k)=nanstd(avgmnksacfrq1norm(:,k),1)/sqrt(length(find(~isnan(avgmnksacfrq1norm(:,k)))));
%     Lsteavgmnksacfrq2(k)=nanstd(avgmnksacfrq2norm(:,k),1)/sqrt(length(find(~isnan(avgmnksacfrq2norm(:,k)))));
% end
 
% % save LESIONED NORMALIZED DATA
% resfil=['S:\Cortex Programs\contextual\LESIONED NORMALIZED 110601-110724'];
% % save LESIONED NORMALIZED BW DATA
% resfil=['S:\Cortex Programs\contextual\LESIONED NORMALIZED BW110630-110726'];
% % save LESIONED NORMALIZED RO DATA
% resfil=['S:\Cortex Programs\contextual\LESIONED NORMALIZED RO110715-110729'];
% 
% save(resfil,'Lsteavgmnksacfrq2', 'Lsteavgmnksacfrq1', 'Lsteavgmnksac2', 'Lsteavgmnksac1', 'Lsteavgmnkrt2', 'Lsteavgmnkrt1', 'Lmeanavgmnksacfrq2', 'Lmeanavgmnksacfrq1', 'Lmeanavgmnksac2', 'Lmeanavgmnksac1', 'Lmeanavgmnkrt2', 'Lmeanavgmnkrt1');
%     
% load(['S:\Cortex Programs\contextual\LESIONED NORMALIZED 110601-110724'])
% load(['S:\Cortex Programs\contextual\LESIONED NORMALIZED BW110630-110726'])
% load(['S:\Cortex Programs\contextual\LESIONED NORMALIZED RO110715-110729'])

% % ADD LESION DATA TO RT FIGURE
% plot(1:40,Lmeanavgmnkrt1(1:40),'Color','b','Marker','o','MarkerEdgeColor','b');
% hold on
% plot(1:40,Lmeanavgmnkrt2(1:40),'Color','m','Marker','o','MarkerEdgeColor','m');
% hold on
% errorbar((1:40),Lmeanavgmnkrt1(1:40),Lsteavgmnkrt1(1:40),Lsteavgmnkrt1(1:40),'b','LineStyle','none','Marker','none')
% hold on
% errorbar((1:40),Lmeanavgmnkrt2(1:40),Lsteavgmnkrt2(1:40),Lsteavgmnkrt2(1:40),'m','LineStyle','none','Marker','none')
% hold on

figure;
plot(1:40,meanavgmnksac1(1:40),'Color','k','Marker','o','MarkerEdgeColor','k');
hold on
plot(1:40,meanavgmnksac2(1:40),'Color','r','Marker','o','MarkerEdgeColor','r');
hold on
errorbar((1:40),meanavgmnksac1(1:40),steavgmnksac1(1:40),steavgmnksac1(1:40),'k','LineStyle','none','Marker','none')
hold on
errorbar((1:40),meanavgmnksac2(1:40),steavgmnksac2(1:40),steavgmnksac2(1:40),'r','LineStyle','none','Marker','none')
leg1='Repeated Lesioned';leg2='Novel Lesioned';leg3='Novel';leg4='Repeated';
xlim([0 41])
box off
xlabel('Block Number'), ylabel('# of saccades');
legend(leg1,leg2,leg3,leg4)
title('Average saccade number across sessions')
% % LESIONED DATA, ONLY RUN WHEN ABOVE IS COMMENTED
% plot(1:40,Lmeanavgmnksac1(1:40),'Color','b','Marker','o','MarkerEdgeColor','b');
% hold on
% plot(1:40,Lmeanavgmnksac2(1:40),'Color','m','Marker','o','MarkerEdgeColor','m');
% hold on
% errorbar((1:40),Lmeanavgmnksac1(1:40),Lsteavgmnksac1(1:40),Lsteavgmnksac1(1:40),'b','LineStyle','none','Marker','none')
% hold on
% errorbar((1:40),Lmeanavgmnksac2(1:40),Lsteavgmnksac2(1:40),Lsteavgmnksac2(1:40),'m','LineStyle','none','Marker','none')
% hold on

figure;
plot(1:40,meanavgmnksacfrq1(1:40),'Color','k','Marker','o','MarkerEdgeColor','k');
hold on
plot(1:40,meanavgmnksacfrq2(1:40),'Color','r','Marker','o','MarkerEdgeColor','r');
hold on
errorbar((1:40),meanavgmnksacfrq1(1:40),steavgmnksacfrq1(1:40),steavgmnksacfrq1(1:40),'k','LineStyle','none','Marker','none')
hold on
errorbar((1:40),meanavgmnksacfrq2(1:40),steavgmnksacfrq2(1:40),steavgmnksacfrq2(1:40),'r','LineStyle','none','Marker','none')
leg1='Repeated Lesioned';leg2='Novel Lesioned';leg3='Novel';leg4='Repeated';
xlim([0 41])
box off
xlabel('Block Number'), ylabel('Frequency of saccades');
legend(leg1,leg2, leg3,leg4)
title('Average saccade frequency across sessions')
% % LESIONED DATA, ONLY RUN WHEN ABOVE IS COMMENTED
% plot(1:40,Lmeanavgmnksacfrq1(1:40),'Color','b','Marker','o','MarkerEdgeColor','b');
% hold on
% plot(1:40,Lmeanavgmnksacfrq2(1:40),'Color','m','Marker','o','MarkerEdgeColor','m');
% hold on
% errorbar((1:40),Lmeanavgmnksacfrq1(1:40),Lsteavgmnksacfrq1(1:40),Lsteavgmnksacfrq1(1:40),'b','LineStyle','none','Marker','none')
% hold on
% errorbar((1:40),Lmeanavgmnksacfrq2(1:40),Lsteavgmnksacfrq2(1:40),Lsteavgmnksacfrq2(1:40),'m','LineStyle','none','Marker','none')
% hold on

%% INITIAL LEARNING
 for k=1:20
    x=allavgrt1(:,k);
    y=allavgrt2(:,k);
    
    [t]=ttest2(x,y,[],[],'unequal');
    
    if t==1
        disp('mean reaction times are NOT EQUAL at 5 percent significance')
    else
        disp('mean reaction times are EQUAL at 5 percent significance')
    end
 end

 %% POST-MODIFICATION ANALYSIS
 for k=20:40
    x=allavgrt1(:,k);
    y=allavgrt2(:,k);
    
    [t]=ttest2(x,y,[],[],'unequal');
    
    if t==1
        disp('mean reaction times are NOT EQUAL at 5 percent significance')
    else
        disp('mean reaction times are EQUAL at 5 percent significance')
    end
 end
%% stats for all monkeys, 2-way ANOVA
numblk=6;

mnknum= size(unique(list(:,1:2),'rows'),1);

RTforANOVA1=avgmnkrt1(:,1:numblk);
RTforANOVA2=avgmnkrt2(:,1:numblk);

[p, table, stats] = anova2([RTforANOVA1;RTforANOVA2],mnknum);

SACforANOVA1=avgmnksac1(:,1:numblk);
SACforANOVA2=avgmnksac2(:,1:numblk);

[p, table, stats] = anova2([SACforANOVA1;SACforANOVA2],mnknum);

SACFRQforANOVA1=avgmnksacfrq1(:,1:numblk);
SACFRQforANOVA2=avgmnksacfrq2(:,1:numblk);

[p, table, stats] = anova2([SACFRQforANOVA1;SACFRQforANOVA2],mnknum);

%% stats for all monkeys, repeated measures 2-way ANOVA
mnklst=unique(list(:,1:2),'rows');
numblk=3;

% reaction time
y=[];
s=[];
f1=[];
f2=[];
for k=1:size(mnklst,1)
    rowtouse=strmatch(mnklst(k,:),list);
    for l=1:length(rowtouse)
        % factor 1, level 1
        y=[y; allavgrt1(rowtouse(l),1:numblk)'];
        s=[s; ones(numblk,1)*k];
        f1=[f1; ones(numblk,1)];
        f2=[f2; [1:numblk]'];
        % factor 1, level 2
        y=[y; allavgrt2(rowtouse(l),1:numblk)'];
        s=[s; ones(numblk,1)*k];
        f1=[f1; ones(numblk,1)*2];
        f2=[f2; [1:numblk]'];
    end
end
factnames{1}='Condition';
factnames{2}='Block';
% stats = rm_anova2(y,s,f1,f2,factnames)
datForAnova=[y f1 f2 s];
rmaov2(datForAnova);

% saccade number
y=[];
s=[];
f1=[];
f2=[];
for k=1:size(mnklst,1)
    rowtouse=strmatch(mnklst(k,:),list);
    for l=1:length(rowtouse)
        % factor 1, level 1
        y=[y; allavgsac1(rowtouse(l),1:numblk)'];
        s=[s; ones(numblk,1)*k];
        f1=[f1; ones(numblk,1)];
        f2=[f2; [1:numblk]'];
        % factor 1, level 2
        y=[y; allavgsac2(rowtouse(l),1:numblk)'];
        s=[s; ones(numblk,1)*k];
        f1=[f1; ones(numblk,1)*2];
        f2=[f2; [1:numblk]'];
    end
end
factnames{1}='Condition';
factnames{2}='Block';
% stats = rm_anova2(y,s,f1,f2,factnames)
datForAnova=[y f1 f2 s];
rmaov2(datForAnova);

% saccade frequency
y=[];
s=[];
f1=[];
f2=[];
for k=1:size(mnklst,1)
    rowtouse=strmatch(mnklst(k,:),list);
    for l=1:length(rowtouse)
        % factor 1, level 1
        y=[y; allavgsacfrq1(rowtouse(l),1:numblk)'];
        s=[s; ones(numblk,1)*k];
        f1=[f1; ones(numblk,1)];
        f2=[f2; [1:numblk]'];
        % factor 1, level 2
        y=[y; allavgsacfrq2(rowtouse(l),1:numblk)'];
        s=[s; ones(numblk,1)*k];
        f1=[f1; ones(numblk,1)*2];
        f2=[f2; [1:numblk]'];
    end
end
factnames{1}='Condition';
factnames{2}='Block';
% stats = rm_anova2(y,s,f1,f2,factnames)
datForAnova=[y f1 f2 s];
rmaov2(datForAnova);


%% stats for all monkeys, repeated measures 2-way ANOVA, normalize data
mnklst=unique(list(:,1:2),'rows');
numblk=20;

% reaction time
y=[];
s=[];
f1=[];
f2=[];
for k=1:size(mnklst,1)
    rowtouse=strmatch(mnklst(k,:),list);
    blk1avg=mean([allavgrt1(rowtouse,1); allavgrt2(rowtouse,1)]);
    for l=1:length(rowtouse)
        % factor 1, level 1
        y=[y; allavgrt1(rowtouse(l),1:numblk)'/blk1avg];
        s=[s; ones(numblk,1)*k];
        f1=[f1; ones(numblk,1)];
        f2=[f2; [1:numblk]'];
        % factor 1, level 2
        y=[y; allavgrt2(rowtouse(l),1:numblk)'/blk1avg];
        s=[s; ones(numblk,1)*k];
        f1=[f1; ones(numblk,1)*2];
        f2=[f2; [1:numblk]'];
    end
end
factnames{1}='Condition';
factnames{2}='Block';
% stats = rm_anova2(y,s,f1,f2,factnames)
datForAnova=[y f1 f2 s];
rmaov2(datForAnova);

% saccade number
y=[];
s=[];
f1=[];
f2=[];
for k=1:size(mnklst,1)
    rowtouse=strmatch(mnklst(k,:),list);
    blk1avg=mean([allavgsac1(rowtouse,1); allavgsac2(rowtouse,1)]);
    for l=1:length(rowtouse)
        % factor 1, level 1
        y=[y; allavgsac1(rowtouse(l),1:numblk)'/blk1avg];
        s=[s; ones(numblk,1)*k];
        f1=[f1; ones(numblk,1)];
        f2=[f2; [1:numblk]'];
        % factor 1, level 2
        y=[y; allavgsac2(rowtouse(l),1:numblk)'/blk1avg];
        s=[s; ones(numblk,1)*k];
        f1=[f1; ones(numblk,1)*2];
        f2=[f2; [1:numblk]'];
    end
end
factnames{1}='Condition';
factnames{2}='Block';
% stats = rm_anova2(y,s,f1,f2,factnames)
datForAnova=[y f1 f2 s];
rmaov2(datForAnova);

% saccade frequency
y=[];
s=[];
f1=[];
f2=[];
for k=1:size(mnklst,1)
    rowtouse=strmatch(mnklst(k,:),list);
    blk1avg=mean([allavgsacfrq1(rowtouse,1); allavgsacfrq2(rowtouse,1)]);
    for l=1:length(rowtouse)
        % factor 1, level 1
        y=[y; allavgsacfrq1(rowtouse(l),1:numblk)'/blk1avg];
        s=[s; ones(numblk,1)*k];
        f1=[f1; ones(numblk,1)];
        f2=[f2; [1:numblk]'];
        % factor 1, level 2
        y=[y; allavgsacfrq2(rowtouse(l),1:numblk)'/blk1avg];
        s=[s; ones(numblk,1)*k];
        f1=[f1; ones(numblk,1)*2];
        f2=[f2; [1:numblk]'];
    end
end
factnames{1}='Condition';
factnames{2}='Block';
% stats = rm_anova2(y,s,f1,f2,factnames)
datForAnova=[y f1 f2 s];
rmaov2(datForAnova);

%% stats on one monkey
RTforANOVA1=allavgrt1(:,1:20);
RTforANOVA2=allavgrt2(:,1:20);

[p, table, stats] = anova2([RTforANOVA1;RTforANOVA2],8);

SACforANOVA1=allavgsac1(:,1:20);
SACforANOVA2=allavgsac2(:,1:20);

[p, table, stats] = anova2([SACforANOVA1;SACforANOVA2],8);

SACFRQforANOVA1=allavgsacfrq1(:,1:20);
SACFRQforANOVA2=allavgsacfrq2(:,1:20);

[p, table, stats] = anova2([SACFRQforANOVA1;SACFRQforANOVA2],8);

