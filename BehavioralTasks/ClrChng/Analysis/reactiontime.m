% reaction time from onset of second stimulus

name=input('Datafile path and name in single quotes:  ');
[time_arr,event_arr,eog_arr,epp_arr,header,trialcount]  = get_ALLdata(name);
clear('corevt','cortim','perbegind','perendind','begtim','endtim','reacttim');

i=1;
for trlop = 1:trialcount
    if size(find(event_arr(19,trlop) == 200)) ~= 0
        corevt(:,i) = event_arr(:,trlop);
        cortim(:,i) = time_arr(:,trlop);
        perbegind = find(event_arr(:,trlop) == 25,1,'last');
        perendind = find(event_arr(:,trlop) == 4,1,'last');
        begtim(i) = time_arr(perbegind,trlop);
        endtim(i) = time_arr(perendind,trlop);
        reacttim(i) = endtim(i) - begtim(i);
        i=i+1;
    end
end

prcntcor = 100*length(corevt)/length(event_arr)
avereact = sum(reacttim)./length(reacttim)

figure;
subplot(2,1,1), hist(reacttim,30), title(name), xlabel('2nd Stim. Reaction Time (ms)'), ylabel('# of Correct Trials');
subplot(2,1,2), plot(reacttim), xlabel('Correct Trial #'), ylabel('Reaction Time (ms)');