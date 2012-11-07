DataPath = 'S:\Aaron\analysis\data\';  % Specify the location of the data files!


% Specify the monkey info
monkeys(1).name = 'Peepers';
monkeys(1).initials = 'MP';
monkeys(1).startdate = 120620;  %('Type start date in format yymmdd:  ');
monkeys(1).enddate = 120725;  %('Type end date in format yymmdd:  ');
    
monkeys(2).name = 'Timmy';
monkeys(2).initials = 'TT';
monkeys(2).startdate = 120620;   %('Type start date in format yymmdd:  ');
monkeys(2).enddate = 120801;   %('Type end date in format yymmdd:  ');
    
monkeys(3).name = 'Guiseppe';
monkeys(3).initials = 'JN';
monkeys(3).startdate = 120621;   %('Type start date in format yymmdd:  ');
monkeys(3).enddate = 120801;   %('Type end date in format yymmdd:  ');

monkeys(4).name = 'Wilbur';
monkeys(4).initials = 'WR';
monkeys(4).startdate = 120621;    %('Type start date in format yymmdd:  ');
monkeys(4).enddate = 120726;      %('Type end date in format yymmdd:  ');


for i=1:length(monkeys)
monkey = monkeys(i).name;
monkeyini = monkeys(i).initials;

%Initialize all necessary matrices, etc.
monkeys(i).prcntacc0=[];
monkeys(i).prcntbrkfix0=[];
monkeys(i).prcntearly0=[];
monkeys(i).prcntlate0=[];
monkeys(i).dateindx=[];
monkeys(i).prcntacc1=[];
monkeys(i).prcntbrkfix1=[];
monkeys(i).prcntearly1=[];
monkeys(i).prcntlate1=[];
monkeys(i).prcntacc2=[];
monkeys(i).prcntbrkfix2=[];
monkeys(i).prcntearly2=[];
monkeys(i).prcntlate2=[];
monkeys(i).prcntacc3=[];
monkeys(i).prcntbrkfix3=[];
monkeys(i).prcntearly3=[];
monkeys(i).prcntlate3=[];
monkeys(i).prcntacc4=[];
monkeys(i).prcntbrkfix4=[];
monkeys(i).prcntearly4=[];
monkeys(i).prcntlate4=[];
monkeys(i).prcntacc5=[];
monkeys(i).prcntbrkfix5=[];
monkeys(i).prcntearly5=[];
monkeys(i).prcntlate5=[];
monkeys(i).prcntacc6=[];
monkeys(i).prcntbrkfix6=[];
monkeys(i).prcntearly6=[];
monkeys(i).prcntlate6=[];
monkeys(i).trindx=[];
monkeys(i).prcntaccreg3=[];
monkeys(i).prcntaccunique3=[];
monkeys(i).prcntaccreg2=[];
monkeys(i).prcntaccunique2=[];
monkeys(i).prcntaccreg1=[];
monkeys(i).prcntaccunique1=[];
monkeys(i).prcntaccreg4=[];
monkeys(i).prcntaccunique4=[];
monkeys(i).prcntaccreg5=[];
monkeys(i).prcntaccunique5=[];
monkeys(i).prcntaccunique13=[];
monkeys(i).prcntaccreg13=[];
monkeys(i).prcntaccreg14=[];
monkeys(i).prcntaccunique14=[];
monkeys(i).prcntaccreg0=[];
monkeys(i).prcntaccunique0=[];
monkeys(i).prcntaccreg=[];
monkeys(i).prcntaccunique=[];
monkeys(i).dateindxunique = [];
monkeys(i).dateindxreg = [];
monkeys(i).prcntacc = [];
monkeys(i).prcntbrkfix = [];
monkeys(i).prcntearly = [];
monkeys(i).prcntlate = [];

monkeys(i).TotalCorr0 = 0;
monkeys(i).TotalCorr1 = 0;
monkeys(i).TotalCorr2 = 0;
monkeys(i).TotalCorr3 = 0;
monkeys(i).TotalCorr4 = 0;
monkeys(i).TotalCorr5 = 0;
monkeys(i).TotalCorr6 = 0;
monkeys(i).TotalResp0 = 0;
monkeys(i).TotalResp1 = 0;
monkeys(i).TotalResp2 = 0;
monkeys(i).TotalResp3 = 0;
monkeys(i).TotalResp4 = 0;
monkeys(i).TotalResp5 = 0;
monkeys(i).TotalResp6 = 0;
monkeys(i).TotalCorrReg0 = 0;
monkeys(i).TotalCorrReg1 = 0;
monkeys(i).TotalCorrReg2 = 0;
monkeys(i).TotalCorrReg3 = 0;
monkeys(i).TotalCorrReg4 = 0;
monkeys(i).TotalCorrReg5 = 0;
monkeys(i).TotalCorrReg6 = 0;
monkeys(i).TotalRespReg0 = 0;
monkeys(i).TotalRespReg1 = 0;
monkeys(i).TotalRespReg2 = 0;
monkeys(i).TotalRespReg3 = 0;
monkeys(i).TotalRespReg4 = 0;
monkeys(i).TotalRespReg5 = 0;
monkeys(i).TotalRespReg6 = 0;
monkeys(i).TotalCorrUnique0 = 0;
monkeys(i).TotalCorrUnique1 = 0;
monkeys(i).TotalCorrUnique2 = 0;
monkeys(i).TotalCorrUnique3 = 0;
monkeys(i).TotalCorrUnique4 = 0;
monkeys(i).TotalCorrUnique5 = 0;
monkeys(i).TotalCorrUnique6 = 0;
monkeys(i).TotalRespUnique0 = 0;
monkeys(i).TotalRespUnique1 = 0;
monkeys(i).TotalRespUnique2 = 0;
monkeys(i).TotalRespUnique3 = 0;
monkeys(i).TotalRespUnique4 = 0;
monkeys(i).TotalRespUnique5 = 0;
monkeys(i).TotalRespUnique6 = 0;
    
%The Analysis
    for datenum = monkeys(i).startdate:1:monkeys(i).enddate
        for filenum=1:9
            datfil = strcat(DataPath,monkey,'\',monkeyini,num2str(datenum),'.',num2str(filenum));
            if exist(datfil,'file')~=0
                    datfil
                    [time_arr,event_arr,eog_arr,epp_arr,header,trialcount]  = get_data_NoEOG(datfil);

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
                        
                        corr=0;
                        late=0;
                        early=0;
                        bkfix=0;
                        resp=0;
                        
                        % Tally up all the responses for the data file.
                        for trlop = 1:100  % Which trials would you like to count?  Here we want first 100 trials of each data file.                          
                            if size(find(event_arr(:,trlop) == 200),1) ~= 0
                                if event_arr(8,trlop) == 301
                                    corr0=corr0+1;
                                    resp0=resp0+1;
                                end
                                if event_arr(8,trlop) == 302
                                    corr1=corr1+1;
                                    resp1=resp1+1;
                                end
                                if event_arr(8,trlop) == 303
                                    corr2=corr2+1;
                                    resp2=resp2+1;
                                end
                                if event_arr(8,trlop) == 304
                                    corr3=corr3+1;
                                    resp3=resp3+1;
                                end
                                if event_arr(8,trlop) == 305
                                    corr4=corr4+1;
                                    resp4=resp4+1;
                                end
                                if event_arr(8,trlop) == 306
                                    corr5=corr5+1;
                                    resp5=resp5+1;
                                end
                                if event_arr(8,trlop) == 307
                                    corr6=corr6+1;
                                    resp6=resp6+1;
                                end
                            end
                            
                            if size(find(event_arr(:,trlop) == 202),1) ~= 0
                                if event_arr(8,trlop) == 301
                                    late0=late0+1;
                                    resp0=resp0+1;
                                end
                                if event_arr(8,trlop) == 302
                                    late1=late1+1;
                                    resp1=resp1+1;
                                end
                                if event_arr(8,trlop) == 303
                                    late2=late2+1;
                                    resp2=resp2+1;
                                end
                                if event_arr(8,trlop) == 304
                                    late3=late3+1;
                                    resp3=resp3+1;
                                end
                                if event_arr(8,trlop) == 305
                                    late4=late4+1;
                                    resp4=resp4+1;
                                end
                                if event_arr(8,trlop) == 306
                                    late5=late5+1;
                                    resp5=resp5+1;
                                end
                                if event_arr(8,trlop) == 307
                                    late6=late6+1;
                                    resp6=resp6+1;
                                end
                            end
                            
                            if size(find(event_arr(:,trlop) == 205),1) ~= 0
                                if size(find(event_arr(:,trlop) == 23),1) + size(find(event_arr(:,trlop) == 25),1) + size(find(event_arr(:,trlop) == 27),1) + size(find(event_arr(:,trlop) == 29),1) + size(find(event_arr(:,trlop) == 31),1) + size(find(event_arr(:,trlop) == 33),1) == 1
                                    early0=early0+1;
                                    resp0=resp0+1;
                                end
                                if size(find(event_arr(:,trlop) == 23),1) + size(find(event_arr(:,trlop) == 25),1) + size(find(event_arr(:,trlop) == 27),1) + size(find(event_arr(:,trlop) == 29),1) + size(find(event_arr(:,trlop) == 31),1) + size(find(event_arr(:,trlop) == 33),1) == 2
                                    if size(find(event_arr(:,trlop) == 23),1) == 1
                                        early1=early1+1;
                                        resp1=resp1+1;
                                    else
                                        early0=early0+1;
                                        resp0=resp0+1;
                                    end 
                                end
                                if size(find(event_arr(:,trlop) == 23),1) + size(find(event_arr(:,trlop) == 25),1) + size(find(event_arr(:,trlop) == 27),1) + size(find(event_arr(:,trlop) == 29),1) + size(find(event_arr(:,trlop) == 31),1) + size(find(event_arr(:,trlop) == 33),1) == 3
                                    if size(find(event_arr(:,trlop) == 23),1) == 1
                                        early2=early2+1;
                                        resp2=resp2+1;
                                    else
                                        early1=early1+1;
                                        resp1=resp1+1;
                                    end
                                end
                                if size(find(event_arr(:,trlop) == 23),1) + size(find(event_arr(:,trlop) == 25),1) + size(find(event_arr(:,trlop) == 27),1) + size(find(event_arr(:,trlop) == 29),1) + size(find(event_arr(:,trlop) == 31),1) + size(find(event_arr(:,trlop) == 33),1) == 4
                                    if size(find(event_arr(:,trlop) == 23),1) == 1
                                        early3=early3+1;
                                        resp3=resp3+1;
                                    else
                                        early2=early2+1;
                                        resp2=resp2+1;
                                    end
                                end
                                if size(find(event_arr(:,trlop) == 23),1) + size(find(event_arr(:,trlop) == 25),1) + size(find(event_arr(:,trlop) == 27),1) + size(find(event_arr(:,trlop) == 29),1) + size(find(event_arr(:,trlop) == 31),1) + size(find(event_arr(:,trlop) == 33),1) == 5
                                    if size(find(event_arr(:,trlop) == 23),1) == 1
                                        early4=early4+1;
                                        resp4=resp4+1;
                                    else
                                        early3=early3+1;
                                        resp3=resp3+1;
                                    end
                                end
                                if size(find(event_arr(:,trlop) == 23),1) + size(find(event_arr(:,trlop) == 25),1) + size(find(event_arr(:,trlop) == 27),1) + size(find(event_arr(:,trlop) == 29),1) + size(find(event_arr(:,trlop) == 31),1) + size(find(event_arr(:,trlop) == 33),1) == 6
                                    if size(find(event_arr(:,trlop) == 23),1) == 1
                                        early5=early5+1;
                                        resp5=resp5+1;
                                    else
                                        early4=early4+1;
                                        resp4=resp4+1;
                                    end
                                end
                                if size(find(event_arr(:,trlop) == 23),1) + size(find(event_arr(:,trlop) == 25),1) + size(find(event_arr(:,trlop) == 27),1) + size(find(event_arr(:,trlop) == 29),1) + size(find(event_arr(:,trlop) == 31),1) + size(find(event_arr(:,trlop) == 33),1) == 7
                                    if size(find(event_arr(:,trlop) == 23),1) == 1
                                        early6=early6+1;
                                        resp6=resp6+1;
                                    else
                                        early5=early5+1;
                                        resp5=resp5+1;
                                    end
                                end
                            end
                            
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
                        
                        %Store the info from the responses tallied above.
                        monkeys(i).prcntacc = [monkeys(i).prcntacc 100*(corr/resp)];
                        monkeys(i).prcntbrkfix = [monkeys(i).prcntbrkfix 100*(bkfix/size(event_arr,2))];
                        monkeys(i).prcntearly = [monkeys(i).prcntearly 100*(early/resp)];
                        monkeys(i).prcntlate = [monkeys(i).prcntlate 100*(late/resp)];
                        
                        monkeys(i).prcntacc0(length(monkeys(i).prcntacc0) + 1) = 100*(corr0/resp0);
                        monkeys(i).prcntearly0(length(monkeys(i).prcntearly0) + 1) = 100*(early0/resp0);
                        monkeys(i).prcntacc1(length(monkeys(i).prcntacc1) + 1) = 100*(corr1/resp1);
                        monkeys(i).prcntearly1(length(monkeys(i).prcntearly1) + 1) = 100*(early1/resp1);
                        monkeys(i).prcntacc2(length(monkeys(i).prcntacc2) + 1) = 100*(corr2/resp2);
                        monkeys(i).prcntearly2(length(monkeys(i).prcntearly2) + 1) = 100*(early2/resp2);
                        monkeys(i).prcntacc3(length(monkeys(i).prcntacc3) + 1) = 100*(corr3/resp3);
                        monkeys(i).prcntearly3(length(monkeys(i).prcntearly3) + 1) = 100*(early3/resp3);
                        monkeys(i).prcntacc4(length(monkeys(i).prcntacc4) + 1) = 100*(corr4/resp4);
                        monkeys(i).prcntearly4(length(monkeys(i).prcntearly4) + 1) = 100*(early4/resp4);
                        monkeys(i).prcntacc5(length(monkeys(i).prcntacc5) + 1) = 100*(corr5/resp5);
                        monkeys(i).prcntearly5(length(monkeys(i).prcntearly5) + 1) = 100*(early5/resp5);
                        monkeys(i).prcntacc6(length(monkeys(i).prcntacc6) + 1) = 100*(corr6/resp6);
                        monkeys(i).prcntearly6(length(monkeys(i).prcntearly6) + 1) = 100*(early6/resp6);

                        monkeys(i).dateindx(length(monkeys(i).dateindx) + 1)=str2double(strcat(num2str(datenum-floor(datenum/10000)*10000),'.',num2str(filenum)));
                        monkeys(i).trindx(length(monkeys(i).trindx) + 1) = trlop;

                        if size(find(event_arr(:,:) == 1007),1) == 0
                            monkeys(i).prcntaccreg = [monkeys(i).prcntaccreg 100*(corr/resp)];
                            monkeys(i).meanreg = mean(monkeys(i).prcntaccreg);
                            monkeys(i).prcntaccreg0(length(monkeys(i).prcntaccreg0) + 1)=100*(corr0/resp0);
                            monkeys(i).prcntaccreg1(length(monkeys(i).prcntaccreg1) + 1)=100*(corr1/resp1);
                            monkeys(i).prcntaccreg2(length(monkeys(i).prcntaccreg2) + 1)=100*(corr2/resp2);
                            monkeys(i).prcntaccreg3(length(monkeys(i).prcntaccreg3) + 1)=100*(corr3/resp3);
                            monkeys(i).prcntaccreg13(length(monkeys(i).prcntaccreg13) + 1) = 100*((corr1+corr2+corr3)/(resp1+resp2+resp3));
                            monkeys(i).prcntaccreg14(length(monkeys(i).prcntaccreg14) + 1) = 100*((corr1+corr2+corr3+corr4)/(resp1+resp2+resp3+resp4));
                            monkeys(i).prcntaccreg4(length(monkeys(i).prcntaccreg4) + 1)=100*(corr4/resp4);
                            monkeys(i).prcntaccreg5(length(monkeys(i).prcntaccreg5) + 1)=100*(corr5/resp5);
                            monkeys(i).dateindxreg = [monkeys(i).dateindxreg monkeys(i).dateindx(end)];
                            
                            monkeys(i).TotalCorrReg0 = monkeys(i).TotalCorrReg0 + corr0;
                            monkeys(i).TotalCorrReg1 = monkeys(i).TotalCorrReg1 + corr1;
                            monkeys(i).TotalCorrReg2 = monkeys(i).TotalCorrReg2 + corr2;
                            monkeys(i).TotalCorrReg3 = monkeys(i).TotalCorrReg3 + corr3;
                            monkeys(i).TotalCorrReg4 = monkeys(i).TotalCorrReg4 + corr4;
                            monkeys(i).TotalCorrReg5 = monkeys(i).TotalCorrReg5 + corr5;
                            monkeys(i).TotalCorrReg6 = monkeys(i).TotalCorrReg6 + corr6;
                            monkeys(i).TotalRespReg0 = monkeys(i).TotalRespReg0 + resp0;
                            monkeys(i).TotalRespReg1 = monkeys(i).TotalRespReg1 + resp1;
                            monkeys(i).TotalRespReg2 = monkeys(i).TotalRespReg2 + resp2;
                            monkeys(i).TotalRespReg3 = monkeys(i).TotalRespReg3 + resp3;
                            monkeys(i).TotalRespReg4 = monkeys(i).TotalRespReg4 + resp4;
                            monkeys(i).TotalRespReg5 = monkeys(i).TotalRespReg5 + resp5;
                            monkeys(i).TotalRespReg6 = monkeys(i).TotalRespReg6 + resp6;
                        else 
                            monkeys(i).prcntaccunique = [monkeys(i).prcntaccunique 100*(corr/resp)];
                            monkeys(i).meanunique = mean(monkeys(i).prcntaccunique);
                            monkeys(i).prcntaccunique0(length(monkeys(i).prcntaccunique0) + 1) = 100*(corr0/resp0);                            
                            monkeys(i).prcntaccunique1(length(monkeys(i).prcntaccunique1) + 1) = 100*(corr1/resp1);
                            monkeys(i).prcntaccunique2(length(monkeys(i).prcntaccunique2) + 1) = 100*(corr2/resp2);
                            monkeys(i).prcntaccunique3(length(monkeys(i).prcntaccunique3) + 1) = 100*(corr3/resp3);
                            monkeys(i).prcntaccunique13(length(monkeys(i).prcntaccunique13) + 1) = 100*((corr1+corr2+corr3)/(resp1+resp2+resp3));
                            monkeys(i).prcntaccunique14(length(monkeys(i).prcntaccunique14) + 1) = 100*((corr1+corr2+corr3+corr4)/(resp1+resp2+resp3+resp4));
                            monkeys(i).prcntaccunique4(length(monkeys(i).prcntaccunique4) + 1) = 100*(corr4/resp4);
                            monkeys(i).prcntaccunique5(length(monkeys(i).prcntaccunique5) + 1) = 100*(corr5/resp5); 
                            monkeys(i).dateindxunique = [monkeys(i).dateindxunique monkeys(i).dateindx(end)];
                            
                            monkeys(i).TotalCorrUnique0 = monkeys(i).TotalCorrUnique0 + corr0;
                            monkeys(i).TotalCorrUnique1 = monkeys(i).TotalCorrUnique1 + corr1;
                            monkeys(i).TotalCorrUnique2 = monkeys(i).TotalCorrUnique2 + corr2;
                            monkeys(i).TotalCorrUnique3 = monkeys(i).TotalCorrUnique3 + corr3;
                            monkeys(i).TotalCorrUnique4 = monkeys(i).TotalCorrUnique4 + corr4;
                            monkeys(i).TotalCorrUnique5 = monkeys(i).TotalCorrUnique5 + corr5;
                            monkeys(i).TotalCorrUnique6 = monkeys(i).TotalCorrUnique6 + corr6;
                            monkeys(i).TotalRespUnique0 = monkeys(i).TotalRespUnique0 + resp0;
                            monkeys(i).TotalRespUnique1 = monkeys(i).TotalRespUnique1 + resp1;
                            monkeys(i).TotalRespUnique2 = monkeys(i).TotalRespUnique2 + resp2;
                            monkeys(i).TotalRespUnique3 = monkeys(i).TotalRespUnique3 + resp3;
                            monkeys(i).TotalRespUnique4 = monkeys(i).TotalRespUnique4 + resp4;
                            monkeys(i).TotalRespUnique5 = monkeys(i).TotalRespUnique5 + resp5;
                            monkeys(i).TotalRespUnique6 = monkeys(i).TotalRespUnique6 + resp6;
                        end 
                        
                        monkeys(i).TotalCorr0 = monkeys(i).TotalCorr0 + corr0;
                        monkeys(i).TotalCorr1 = monkeys(i).TotalCorr1 + corr1;
                        monkeys(i).TotalCorr2 = monkeys(i).TotalCorr2 + corr2;
                        monkeys(i).TotalCorr3 = monkeys(i).TotalCorr3 + corr3;
                        monkeys(i).TotalCorr4 = monkeys(i).TotalCorr4 + corr4;
                        monkeys(i).TotalCorr5 = monkeys(i).TotalCorr5 + corr5;
                        monkeys(i).TotalCorr6 = monkeys(i).TotalCorr6 + corr6;
                        monkeys(i).TotalResp0 = monkeys(i).TotalResp0 + resp0;
                        monkeys(i).TotalResp1 = monkeys(i).TotalResp1 + resp1;
                        monkeys(i).TotalResp2 = monkeys(i).TotalResp2 + resp2;
                        monkeys(i).TotalResp3 = monkeys(i).TotalResp3 + resp3;
                        monkeys(i).TotalResp4 = monkeys(i).TotalResp4 + resp4;
                        monkeys(i).TotalResp5 = monkeys(i).TotalResp5 + resp5;
                        monkeys(i).TotalResp6 = monkeys(i).TotalResp6 + resp6;
            end
        end
    end
    
% Plot the monkey's performance by distractor over time.
figure(1);
subplot(2, 4, (2*(i-1)+1));
plot(monkeys(i).prcntaccreg0);
hold all
plot(monkeys(i).prcntaccreg1);
ylim([20 105])
plot(monkeys(i).prcntaccreg2);
plot(monkeys(i).prcntaccreg3);
plot(monkeys(i).prcntaccreg4);
plot(monkeys(i).prcntaccreg5);
set(gca,'XTickLabel', monkeys(i).dateindxreg)
set(gca, 'XTick', find(monkeys(i).dateindxreg));
title([monkeys(i).name ' Regular Trials']);
xlabel('Days');
ylabel('Percent Accuracy')

subplot(2, 4, 2*i);
plot(monkeys(i).prcntaccunique0);
hold all
plot(monkeys(i).prcntaccunique1);
ylim([20 105])
plot(monkeys(i).prcntaccunique2);
plot(monkeys(i).prcntaccunique3);
plot(monkeys(i).prcntaccunique4);
plot(monkeys(i).prcntaccunique5);
set(gca,'XTickLabel', monkeys(i).dateindxunique)
set(gca, 'XTick', find(monkeys(i).dateindxunique));
title([monkeys(i).name ' Unique Trials']);
xlabel('Days');
ylabel('Percent Accuracy');

    if i == length(monkeys)
        subplot(2,4,1)
        legend('0 Distractors','1 Distractor', '2 Distractors', '3 Distractors', '4 Distractors', '5 Distractors', 'Location', 'SouthWest')
    end
    
%Make a figure of just this monkey's various DMS Performance info.
figure;
subplot(2,2,1);
    bar(monkeys(i).prcntacc,'g');set(gca,'XTickLabel',monkeys(i).dateindx);
    set(gca,'xtick',1:size(monkeys(i).prcntacc,2),'Box','off','YGrid','on');
    ylabel('Percent accuracy');
    xlim([0.5 size(monkeys(i).prcntacc,2)+0.5]);
    rotateticklabel(gca);
    ax2=axes('Position',get(gca,'Position'),'XAxisLocation','top','YAxisLocation','right','Box','off','Color','none','XTickMode','manual',...
        'Xlim',get(gca,'XLim'),'XTick',get(gca,'XTick'),'Layer','top','XTickLabel',monkeys(i).trindx,'XColor','k','YColor','k',...
        'XMinorTick','off','YTick',zeros(1,0));
    xlabel('# Trials');
subplot(2,2,2);
    bar(monkeys(i).prcntbrkfix,'r');set(gca,'XTickLabel',monkeys(i).dateindx);
    set(gca,'xtick',1:size(monkeys(i).prcntbrkfix,2),'Box','off','YGrid','on');
    ylabel('Percent break fixation');
    xlim([0.5 size(monkeys(i).prcntbrkfix,2)+0.5]);
    rotateticklabel(gca);
    ax2=axes('Position',get(gca,'Position'),'XAxisLocation','top','YAxisLocation','right','Box','off','Color','none','XTickMode','manual',...
        'Xlim',get(gca,'XLim'),'XTick',get(gca,'XTick'),'Layer','top','XTickLabel',monkeys(i).trindx,'XColor','k','YColor','k',...
        'XMinorTick','off','YTick',zeros(1,0));
    xlabel('# Trials');
subplot(2,2,3);
    bar(monkeys(i).prcntearly,'y');set(gca,'XTickLabel',monkeys(i).dateindx);
    set(gca,'xtick',1:size(monkeys(i).prcntearly,2),'Box','off','YGrid','on');
    ylabel('Percent early');
    xlim([0.5 size(monkeys(i).prcntearly,2)+0.5]);
    rotateticklabel(gca);
    ax2=axes('Position',get(gca,'Position'),'XAxisLocation','top','YAxisLocation','right','Box','off','Color','none','XTickMode','manual',...
        'Xlim',get(gca,'XLim'),'XTick',get(gca,'XTick'),'Layer','top','XTickLabel',monkeys(i).trindx,'XColor','k','YColor','k',...
        'XMinorTick','off','YTick',zeros(1,0));
    xlabel('# Trials');
subplot(2,2,4);
    bar(monkeys(i).prcntlate,'b');set(gca,'XTickLabel',monkeys(i).dateindx);
    set(gca,'xtick',1:size(monkeys(i).prcntlate,2),'Box','off','YGrid','on');
    ylabel('Percent late');
    xlim([0.5 size(monkeys(i).prcntlate,2)+0.5]);
    rotateticklabel(gca);
    ax2=axes('Position',get(gca,'Position'),'XAxisLocation','top','YAxisLocation','right','Box','off','Color','none','XTickMode','manual',...
        'Xlim',get(gca,'XLim'),'XTick',get(gca,'XTick'),'Layer','top','XTickLabel',monkeys(i).trindx,'XColor','k','YColor','k',...
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


% Another figure of just this monkey's various DMS Performance info, 
% broken down by number of distractors.
figure;
subplot(2,1,1);
    bar([monkeys(i).prcntacc0;monkeys(i).prcntacc1;monkeys(i).prcntacc2;monkeys(i).prcntacc3;monkeys(i).prcntacc4;monkeys(i).prcntacc5]','Group');set(gca,'XTickLabel',monkeys(i).dateindx);
    set(gca,'xtick',1:size(monkeys(i).prcntacc0,2),'Box','off','YGrid','on');
    ylabel('Percent accuracy');    
    legend('0 Distractors','1 Distractor', '2 Distractors', '3 Distractors', '4 Distractors', '5 Distractors', 'Location', 'SouthWest')
    xlim([0.5 size(monkeys(i).prcntacc0,2)+0.5]);
    rotateticklabel(gca);
    ax2=axes('Position',get(gca,'Position'),'XAxisLocation','top','YAxisLocation','right','Box','off','Color','none','XTickMode','manual',...
        'Xlim',get(gca,'XLim'),'XTick',get(gca,'XTick'),'Layer','top','XTickLabel',monkeys(i).trindx,'XColor','k','YColor','k',...
        'XMinorTick','off','YTick',zeros(1,0));
    xlabel('# Trials');
subplot(2,1,2);
    bar([monkeys(i).prcntearly0;monkeys(i).prcntearly1;monkeys(i).prcntearly2;monkeys(i).prcntearly3;monkeys(i).prcntearly4;monkeys(i).prcntearly5]','Group');set(gca,'XTickLabel',monkeys(i).dateindx);
    set(gca,'xtick',1:size(monkeys(i).prcntearly0,2),'Box','off','YGrid','on');
    ylabel('Percent early');
    xlim([0.5 size(monkeys(i).prcntearly0,2)+0.5]);
    rotateticklabel(gca);

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




%Plot the monkey's performance over time
figure(3);
subplot(2, 2, i);
plot(monkeys(i).prcntaccreg);
hold all
plot(monkeys(i).prcntaccunique);
title(monkey);
ylabel('Percent Accuracy');
xlabel('Days');
if i == 1
    legend('Regular DMS', 'Unique DMS', 'Location', 'SouthEast');
end

end




% Creates a figure that displays mean percent accuracy (unique and regular trials) for each monkey just for zero distractors.

b=[nanmean(monkeys(1).prcntaccunique0), nanmean(monkeys(1).prcntaccreg0)
   nanmean(monkeys(2).prcntaccunique0), nanmean(monkeys(2).prcntaccreg0)
   nanmean(monkeys(3).prcntaccunique0), nanmean(monkeys(3).prcntaccreg0)
   nanmean(monkeys(4).prcntaccunique0), nanmean(monkeys(4).prcntaccreg0)];
errdata=[nanstd(monkeys(1).prcntaccunique0)/sqrt(length(find(~isnan(monkeys(1).prcntaccunique0)))), nanstd(monkeys(1).prcntaccreg2)/sqrt(length(find(~isnan(monkeys(1).prcntaccreg0)))) 
         nanstd(monkeys(2).prcntaccunique0)/sqrt(length(find(~isnan(monkeys(2).prcntaccunique0)))), nanstd(monkeys(2).prcntaccreg2)/sqrt(length(find(~isnan(monkeys(2).prcntaccreg0)))) 
         nanstd(monkeys(3).prcntaccunique0)/sqrt(length(find(~isnan(monkeys(3).prcntaccunique0)))), nanstd(monkeys(3).prcntaccreg2)/sqrt(length(find(~isnan(monkeys(3).prcntaccreg0))))
         nanstd(monkeys(4).prcntaccunique0)/sqrt(length(find(~isnan(monkeys(4).prcntaccunique0)))), nanstd(monkeys(4).prcntaccreg2)/sqrt(length(find(~isnan(monkeys(4).prcntaccreg0))))];
numbars=size(b,1)*size(b,2);  
figure;
subplot(2,4,1);
h=bar(b);
hold on 
ylim([50 100])
set(gca,'XTickLabel', {'Peepers'; 'Timmy'; 'Guiseppe'; 'Wilbur'})
ylabel('Percent Accuracy')
title({'Unique and Regular Trials with Zero Distractors'});
legend('Unique DMS','Regular DMS','Location', 'SouthWest')
group{1} = get(get(h(1), 'children'), 'xdata');
group{2} = get(get(h(2), 'children'), 'xdata');

centerX=[];
for i=1:size(b,1)
    nextbar = [];
     for j=1:size(b,2)
         nextbar = [nextbar mean(group{j}([1 3],i))];
     end
     centerX = [centerX; nextbar];
end

errorbar(centerX, b, errdata, '.k','LineWidth',2);


% Creates a figure that displays the mean percent accuracy for unique and
% regular trials with 1, 2, or 3 distractors for each monkey.
b=[nanmean(monkeys(1).prcntaccunique13), nanmean(monkeys(1).prcntaccreg13)
   nanmean(monkeys(2).prcntaccunique13), nanmean(monkeys(2).prcntaccreg13)
   nanmean(monkeys(3).prcntaccunique13), nanmean(monkeys(3).prcntaccreg13) 
   nanmean(monkeys(4).prcntaccunique13), nanmean(monkeys(4).prcntaccreg13)];
errdata=[nanstd(monkeys(1).prcntaccunique13)/sqrt(length(find(~isnan(monkeys(1).prcntaccunique13)))), nanstd(monkeys(1).prcntaccreg13)/sqrt(length(find(~isnan(monkeys(1).prcntaccreg13)))) 
         nanstd(monkeys(2).prcntaccunique13)/sqrt(length(find(~isnan(monkeys(2).prcntaccunique13)))), nanstd(monkeys(2).prcntaccreg13)/sqrt(length(find(~isnan(monkeys(2).prcntaccreg13)))) 
         nanstd(monkeys(3).prcntaccunique13)/sqrt(length(find(~isnan(monkeys(3).prcntaccunique13)))), nanstd(monkeys(3).prcntaccreg13)/sqrt(length(find(~isnan(monkeys(3).prcntaccreg13))))
         nanstd(monkeys(4).prcntaccunique13)/sqrt(length(find(~isnan(monkeys(4).prcntaccunique13)))), nanstd(monkeys(4).prcntaccreg13)/sqrt(length(find(~isnan(monkeys(4).prcntaccreg13))))];
numbars=size(b,1)*size(b,2);  
subplot(2,4,6)
h=bar(b);
hold on 
ylim([50 100])
set(gca,'XTickLabel', {'Peepers'; 'Timmy'; 'Guiseppe'; 'Wilbur'})
ylabel('Percent Accuracy')
title({'Unique vs Regular Trials W/ 1, 2, or 3 Distractors'});
group{1} = get(get(h(1), 'children'), 'xdata');
group{2} = get(get(h(2), 'children'), 'xdata');

centerX=[];
for i=1:size(b,1)
    nextbar = [];
     for j=1:size(b,2)
         nextbar = [nextbar mean(group{j}([1 3],i))];
     end
     centerX = [centerX; nextbar];
end

errorbar(centerX, b, errdata, '.k','LineWidth',2);

% Creates a figure that displays mean percent accuracy (unique and regular trials) for each monkey just for the maximum distractors possible.

b=[mean(monkeys(1).prcntaccunique4(find(monkeys(1).prcntaccunique4 > 0))), mean(monkeys(1).prcntaccreg4(find(monkeys(1).prcntaccreg4 > 0)))
   mean(monkeys(2).prcntaccunique4(find(monkeys(2).prcntaccunique4 > 0))), mean(monkeys(2).prcntaccreg4(find(monkeys(2).prcntaccreg4 > 0)))
   mean(monkeys(3).prcntaccunique4(find(monkeys(3).prcntaccunique4 > 0))), mean(monkeys(3).prcntaccreg4(find(monkeys(3).prcntaccreg4 > 0)))
   mean(monkeys(4).prcntaccunique4(find(monkeys(4).prcntaccunique4 > 0))), mean(monkeys(4).prcntaccreg4(find(monkeys(4).prcntaccreg4 > 0)))];
errdata=[nanstd(monkeys(1).prcntaccunique4(find(monkeys(1).prcntaccunique4 > 0)))/sqrt(length(find(monkeys(1).prcntaccunique4 > 0))), nanstd(monkeys(1).prcntaccreg4(find(monkeys(1).prcntaccreg4 > 0)))/sqrt(length(find(monkeys(1).prcntaccreg4 > 0))) 
         nanstd(monkeys(2).prcntaccunique4(find(monkeys(2).prcntaccunique4 > 0)))/sqrt(length(find(monkeys(2).prcntaccunique4 > 0))), nanstd(monkeys(2).prcntaccreg4(find(monkeys(2).prcntaccreg4 > 0)))/sqrt(length(find(monkeys(2).prcntaccreg4 > 0)))
         nanstd(monkeys(3).prcntaccunique4(find(monkeys(3).prcntaccunique4 > 0)))/sqrt(length(find(monkeys(3).prcntaccunique4 > 0))), nanstd(monkeys(3).prcntaccreg4(find(monkeys(3).prcntaccreg4 > 0)))/sqrt(length(find(monkeys(3).prcntaccreg4 > 0)))
         nanstd(monkeys(4).prcntaccunique4(find(monkeys(4).prcntaccunique4 > 0)))/sqrt(length(find(monkeys(4).prcntaccunique4 > 0))), nanstd(monkeys(4).prcntaccreg4(find(monkeys(4).prcntaccreg4 > 0)))/sqrt(length(find(monkeys(4).prcntaccreg4 > 0)))];

numbars=size(b,1)*size(b,2);  
subplot(2,4,5);
h=bar(b);
hold on 
ylim([50 100])
set(gca,'XTickLabel', {'Peepers'; 'Timmy'; 'Guiseppe'; 'Wilbur'})
ylabel('Percent Accuracy')
title({'Unique and Regular Trials with Four Distractors'});
group{1} = get(get(h(1), 'children'), 'xdata');
group{2} = get(get(h(2), 'children'), 'xdata');

centerX=[];
for i=1:size(b,1)
    nextbar = [];
     for j=1:size(b,2)
         nextbar = [nextbar mean(group{j}([1 3],i))];
     end
     centerX = [centerX; nextbar];
end

errorbar(centerX, b, errdata, '.k','LineWidth',2);

% Creates a figure that displays mean percent accuracy (unique and regular trials) for each monkey just for three distractors.

b=[nanmean(monkeys(1).prcntaccunique3), nanmean(monkeys(1).prcntaccreg3)
   nanmean(monkeys(2).prcntaccunique3), nanmean(monkeys(2).prcntaccreg3)
   nanmean(monkeys(3).prcntaccunique3), nanmean(monkeys(3).prcntaccreg3)
   nanmean(monkeys(4).prcntaccunique3), nanmean(monkeys(4).prcntaccreg3)];
errdata=[nanstd(monkeys(1).prcntaccunique3)/sqrt(length(find(~isnan(monkeys(1).prcntaccunique3)))), nanstd(monkeys(1).prcntaccreg3)/sqrt(length(find(~isnan(monkeys(1).prcntaccreg3)))) 
         nanstd(monkeys(2).prcntaccunique3)/sqrt(length(find(~isnan(monkeys(2).prcntaccunique3)))), nanstd(monkeys(2).prcntaccreg3)/sqrt(length(find(~isnan(monkeys(2).prcntaccreg3)))) 
         nanstd(monkeys(3).prcntaccunique3)/sqrt(length(find(~isnan(monkeys(3).prcntaccunique3)))), nanstd(monkeys(3).prcntaccreg3)/sqrt(length(find(~isnan(monkeys(3).prcntaccreg3))))
         nanstd(monkeys(4).prcntaccunique3)/sqrt(length(find(~isnan(monkeys(4).prcntaccunique3)))), nanstd(monkeys(4).prcntaccreg3)/sqrt(length(find(~isnan(monkeys(4).prcntaccreg3))))];
numbars=size(b,1)*size(b,2);  
subplot(2,4,4);
h=bar(b);
hold on 
ylim([50 100])
set(gca,'XTickLabel', {'Peepers'; 'Timmy'; 'Guiseppe'; 'Wilbur'})
ylabel('Percent Accuracy')
title({'Unique and Regular Trials with Three Distractors'});
group{1} = get(get(h(1), 'children'), 'xdata');
group{2} = get(get(h(2), 'children'), 'xdata');

centerX=[];
for i=1:size(b,1)
    nextbar = [];
     for j=1:size(b,2)
         nextbar = [nextbar mean(group{j}([1 3],i))];
     end
     centerX = [centerX; nextbar];
end

errorbar(centerX, b, errdata, '.k','LineWidth',2);

% Creates a figure that displays mean percent accuracy (unique and regular trials) for each monkey just for two distractors.

b=[nanmean(monkeys(1).prcntaccunique2), nanmean(monkeys(1).prcntaccreg2)
   nanmean(monkeys(2).prcntaccunique2), nanmean(monkeys(2).prcntaccreg2)
   nanmean(monkeys(3).prcntaccunique2), nanmean(monkeys(3).prcntaccreg2)
   nanmean(monkeys(4).prcntaccunique2), nanmean(monkeys(4).prcntaccreg2)];
errdata=[nanstd(monkeys(1).prcntaccunique2)/sqrt(length(find(~isnan(monkeys(1).prcntaccunique2)))), nanstd(monkeys(1).prcntaccreg2)/sqrt(length(find(~isnan(monkeys(1).prcntaccreg2)))) 
         nanstd(monkeys(2).prcntaccunique2)/sqrt(length(find(~isnan(monkeys(2).prcntaccunique2)))), nanstd(monkeys(2).prcntaccreg2)/sqrt(length(find(~isnan(monkeys(2).prcntaccreg2)))) 
         nanstd(monkeys(3).prcntaccunique2)/sqrt(length(find(~isnan(monkeys(3).prcntaccunique2)))), nanstd(monkeys(3).prcntaccreg2)/sqrt(length(find(~isnan(monkeys(3).prcntaccreg2))))
         nanstd(monkeys(4).prcntaccunique2)/sqrt(length(find(~isnan(monkeys(4).prcntaccunique2)))), nanstd(monkeys(4).prcntaccreg2)/sqrt(length(find(~isnan(monkeys(4).prcntaccreg2))))];
numbars=size(b,1)*size(b,2);  
subplot(2,4,3);
h=bar(b);
hold on 
ylim([50 100])
set(gca,'XTickLabel', {'Peepers'; 'Timmy'; 'Guiseppe'; 'Wilbur'})
ylabel('Percent Accuracy')
title({'Unique and Regular Trials with Two Distractors'});
% legend('Unique DMS','Regular DMS',-1)
group{1} = get(get(h(1), 'children'), 'xdata');
group{2} = get(get(h(2), 'children'), 'xdata');

centerX=[];
for i=1:size(b,1)
    nextbar = [];
     for j=1:size(b,2)
         nextbar = [nextbar mean(group{j}([1 3],i))];
     end
     centerX = [centerX; nextbar];
end

errorbar(centerX, b, errdata, '.k','LineWidth',2);



% Creates a figure that displays mean percent accuracy (unique and regular trials) for each monkey just for one distractors.

b=[nanmean(monkeys(1).prcntaccunique1), nanmean(monkeys(1).prcntaccreg1)
   nanmean(monkeys(2).prcntaccunique1), nanmean(monkeys(2).prcntaccreg1)
   nanmean(monkeys(3).prcntaccunique1), nanmean(monkeys(3).prcntaccreg1)
   nanmean(monkeys(4).prcntaccunique1), nanmean(monkeys(4).prcntaccreg1)];
errdata=[nanstd(monkeys(1).prcntaccunique1)/sqrt(length(find(~isnan(monkeys(1).prcntaccunique1)))), nanstd(monkeys(1).prcntaccreg2)/sqrt(length(find(~isnan(monkeys(1).prcntaccreg1)))) 
         nanstd(monkeys(2).prcntaccunique1)/sqrt(length(find(~isnan(monkeys(2).prcntaccunique1)))), nanstd(monkeys(2).prcntaccreg2)/sqrt(length(find(~isnan(monkeys(2).prcntaccreg1)))) 
         nanstd(monkeys(3).prcntaccunique1)/sqrt(length(find(~isnan(monkeys(3).prcntaccunique1)))), nanstd(monkeys(3).prcntaccreg2)/sqrt(length(find(~isnan(monkeys(3).prcntaccreg1))))
         nanstd(monkeys(4).prcntaccunique1)/sqrt(length(find(~isnan(monkeys(4).prcntaccunique1)))), nanstd(monkeys(4).prcntaccreg2)/sqrt(length(find(~isnan(monkeys(4).prcntaccreg1))))];
numbars=size(b,1)*size(b,2);  
subplot(2,4,2);
h=bar(b);
hold on 
ylim([50 100])
set(gca,'XTickLabel', {'Peepers'; 'Timmy'; 'Guiseppe'; 'Wilbur'})
ylabel('Percent Accuracy')
title({'Unique and Regular Trials with One Distractor'});
group{1} = get(get(h(1), 'children'), 'xdata');
group{2} = get(get(h(2), 'children'), 'xdata');

centerX=[];
for i=1:size(b,1)
    nextbar = [];
     for j=1:size(b,2)
         nextbar = [nextbar mean(group{j}([1 3],i))];
     end
     centerX = [centerX; nextbar];
end

errorbar(centerX, b, errdata, '.k','LineWidth',2);


% Bar Graph of each monkey's performance on trials with Five Distractors.
b=[mean(monkeys(1).prcntaccunique5(find(monkeys(1).prcntaccunique5 > 0))), mean(monkeys(1).prcntaccreg5(find(monkeys(1).prcntaccreg5 > 0)))
   mean(monkeys(2).prcntaccunique5(find(monkeys(2).prcntaccunique5 > 0))), mean(monkeys(2).prcntaccreg5(find(monkeys(2).prcntaccreg5 > 0)))
   mean(monkeys(3).prcntaccunique5(find(monkeys(3).prcntaccunique5 > 0))), mean(monkeys(3).prcntaccreg5(find(monkeys(3).prcntaccreg5 > 0)))
   mean(monkeys(4).prcntaccunique5(find(monkeys(4).prcntaccunique5 > 0))), mean(monkeys(4).prcntaccreg5(find(monkeys(4).prcntaccreg5 > 0)))];
errdata=[nanstd(monkeys(1).prcntaccunique5(find(monkeys(1).prcntaccunique5 > 0)))/sqrt(length(find(monkeys(1).prcntaccunique5 > 0))), nanstd(monkeys(1).prcntaccreg5(find(monkeys(1).prcntaccreg5 > 0)))/sqrt(length(find(monkeys(1).prcntaccreg5 > 0))) 
         nanstd(monkeys(2).prcntaccunique5(find(monkeys(2).prcntaccunique5 > 0)))/sqrt(length(find(monkeys(2).prcntaccunique5 > 0))), nanstd(monkeys(2).prcntaccreg5(find(monkeys(2).prcntaccreg5 > 0)))/sqrt(length(find(monkeys(2).prcntaccreg5 > 0)))
         nanstd(monkeys(3).prcntaccunique5(find(monkeys(3).prcntaccunique5 > 0)))/sqrt(length(find(monkeys(3).prcntaccunique5 > 0))), nanstd(monkeys(3).prcntaccreg5(find(monkeys(3).prcntaccreg5 > 0)))/sqrt(length(find(monkeys(3).prcntaccreg5 > 0)))
         nanstd(monkeys(4).prcntaccunique5(find(monkeys(4).prcntaccunique5 > 0)))/sqrt(length(find(monkeys(4).prcntaccunique5 > 0))), nanstd(monkeys(4).prcntaccreg5(find(monkeys(4).prcntaccreg5 > 0)))/sqrt(length(find(monkeys(4).prcntaccreg5 > 0)))];
numbars=size(b,1)*size(b,2);  
subplot(2,4,8);
h=bar(b);
hold on
ylim([50 100])
set(gca,'XTickLabel', {'Peepers'; 'Timmy'; 'Guiseppe'; 'Wilbur'})
ylabel('Percent Accuracy')
title({'Unique and Regular Trials with Five Distractors'});

group{1} = get(get(h(1), 'children'), 'xdata');
group{2} = get(get(h(2), 'children'), 'xdata');

centerX=[];
for i=1:size(b,1)
    nextbar = [];
     for j=1:size(b,2)
         nextbar = [nextbar mean(group{j}([1 3],i))];
     end
     centerX = [centerX; nextbar];
end

errorbar(centerX, b, errdata, '.k','LineWidth',2);

% Bar graph of each monkey's performance on trials that had up to the
% number of distractors that the monkey was previously used to doing
% regularly as a max.
b=[nanmean(monkeys(1).prcntaccunique14), nanmean(monkeys(1).prcntaccreg14)
   nanmean(monkeys(2).prcntaccunique13), nanmean(monkeys(2).prcntaccreg13)
   nanmean(monkeys(3).prcntaccunique14), nanmean(monkeys(3).prcntaccreg14) 
   nanmean(monkeys(4).prcntaccunique13), nanmean(monkeys(4).prcntaccreg13)];
errdata=[nanstd(monkeys(1).prcntaccunique14)/sqrt(length(find(~isnan(monkeys(1).prcntaccunique14)))), nanstd(monkeys(1).prcntaccreg14)/sqrt(length(find(~isnan(monkeys(1).prcntaccreg14)))) 
         nanstd(monkeys(2).prcntaccunique13)/sqrt(length(find(~isnan(monkeys(2).prcntaccunique13)))), nanstd(monkeys(2).prcntaccreg13)/sqrt(length(find(~isnan(monkeys(2).prcntaccreg13)))) 
         nanstd(monkeys(3).prcntaccunique14)/sqrt(length(find(~isnan(monkeys(3).prcntaccunique14)))), nanstd(monkeys(3).prcntaccreg14)/sqrt(length(find(~isnan(monkeys(3).prcntaccreg14))))
         nanstd(monkeys(4).prcntaccunique13)/sqrt(length(find(~isnan(monkeys(4).prcntaccunique13)))), nanstd(monkeys(4).prcntaccreg13)/sqrt(length(find(~isnan(monkeys(4).prcntaccreg13))))];
numbars=size(b,1)*size(b,2);  
subplot(2,4,7)
h=bar(b);
hold on 
ylim([50 100])
set(gca,'XTickLabel', {'MP(<=4)'; 'TT(<=3)'; 'JN(<=4)'; 'WR(<=3)'})
ylabel('Percent Accuracy')
title({'Unique vs Regular Trials W/ Up to Each Monkeys Usual Max Distractors'});
group{1} = get(get(h(1), 'children'), 'xdata');
group{2} = get(get(h(2), 'children'), 'xdata');

centerX=[];
for i=1:size(b,1)
    nextbar = [];
     for j=1:size(b,2)
         nextbar = [nextbar mean(group{j}([1 3],i))];
     end
     centerX = [centerX; nextbar];
end

errorbar(centerX, b, errdata, '.k','LineWidth',2);

%Main bar graph summarizing the each monkey's performance in total.
b=[monkeys(1).meanunique monkeys(1).meanreg; 
    monkeys(2).meanunique monkeys(2).meanreg; 
    monkeys(3).meanunique monkeys(3).meanreg;
    monkeys(4).meanunique monkeys(4).meanreg];
errdata=[nanstd(monkeys(1).prcntaccunique)/sqrt(length(find(~isnan(monkeys(1).prcntaccunique)))), nanstd(monkeys(1).prcntaccreg)/sqrt(length(find(~isnan(monkeys(1).prcntaccreg)))) 
         nanstd(monkeys(2).prcntaccunique)/sqrt(length(find(~isnan(monkeys(2).prcntaccunique)))), nanstd(monkeys(2).prcntaccreg)/sqrt(length(find(~isnan(monkeys(2).prcntaccreg)))) 
         nanstd(monkeys(3).prcntaccunique)/sqrt(length(find(~isnan(monkeys(3).prcntaccunique)))), nanstd(monkeys(3).prcntaccreg)/sqrt(length(find(~isnan(monkeys(3).prcntaccreg))))
         nanstd(monkeys(4).prcntaccunique)/sqrt(length(find(~isnan(monkeys(4).prcntaccunique)))), nanstd(monkeys(4).prcntaccreg)/sqrt(length(find(~isnan(monkeys(4).prcntaccreg))))];
numbars=size(b,1)*size(b,2);    
     
figure;
h = bar(b);
hold on 
ylim([50 100])
set(gca,'XTickLabel', {'Peepers'; 'Timmy'; 'Guiseppe'; 'Wilbur'})
ylabel('Percent Accuracy')
title({'Unique and Regular Trials Between Monkeys'});
legend('Unique DMS','Regular DMS',-1)
group{1} = get(get(h(1), 'children'), 'xdata');
group{2} = get(get(h(2), 'children'), 'xdata');

centerX=[];
for i=1:size(b,1)
    nextbar = [];
     for j=1:size(b,2)
         nextbar = [nextbar mean(group{j}([1 3],i))];
     end
     centerX = [centerX; nextbar];
end

errorbar(centerX, b, errdata, '.k','LineWidth',2);

