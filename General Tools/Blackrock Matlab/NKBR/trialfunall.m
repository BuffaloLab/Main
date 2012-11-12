function [trl] = trialfunall(cfg1)
global trl LT
offset = cfg1.offset

%==========================================================
% SUPPORT LOADING OF BLACKROCK OR PLEXON FILES
% SPECIFY cfg1.blackrock = 1; to load blackrock
% N Killian, njkillian@gmail.com 4/4/2012
if ~isfield(cfg1,'blackrock')||~(strcmp('.nev',cfg1.dataset(end-3:end)) || strcmp('.ns5',cfg1.dataset(end-3:end)))
    cfg1.blackrock = 0;
else
    cfg1.blackrock = 1;
end

if cfg1.blackrock
    dsfs = 1e3;
    % note: if speed issues arise, could potentially speed this up by loading only the event data
    nvdat = openNEV(cfg1.dataset);
    % get event data:
    fs = double(nvdat.MetaTags.SampleRes);
    eventtimes = round(double(nvdat.Data.SerialDigitalIO.TimeStamp)'/fs*dsfs);% apply new sampling rate (dsfs)
    eventcodes = double(nvdat.Data.SerialDigitalIO.UnparsedData);
    for k = 1:length(eventtimes)
        mrk.val(k) = eventcodes(k);
        mrk.tim(k) = eventtimes(k);
    end
else
    % read the header
    hdr = read_header(cfg1.dataset);
    % read the events
    event = read_event(cfg1.dataset);
    numevt = length(event);
    for k = 1:numevt
        mrk.val(k) = event(k).value;
        mrk.tim(k) = event(k).sample;
    end
end
%=============================================================


%fix 16th bit problem:
baddays = {'090710' '090713' '090714' '100422' '100423' '100426'};
if any(strcmp(cfg1.fid(3:8),baddays))
    mrk.val = 32767-mrk.val;
    disp('fixed bad event data')
end

rptdef.rptbeg   = 150;
rptdef.rptend   = 151;
rptmrk = prorptmrkFT(mrk,rptdef);
numrpt = size(rptmrk,2);

trl= [];
for rptlop=1:numrpt
    %     if isempty(cfg1.badblks)
    %     elseif (length(rptmrk(rptlop).val) == length(setdiff(rptmrk(rptlop).val,cfg1.badblks)))%CONDNUM of image presentations
    %         continue
    %     end
    if size(find(rptmrk(rptlop).val(find(rptmrk(rptlop).val>1000,1,'last')) >= 1010)) ~=0
        %look at encoding and recognition trials:
        if size(find(rptmrk(rptlop).val == 200)) ~=0 & size(find(rptmrk(rptlop).val == 23)) ~=0 & size(find(rptmrk(rptlop).val == 24)) ~=0
            perbegind = find(rptmrk(rptlop).val == 23);%image on
            perendind = find(rptmrk(rptlop).val == 24);%image off
            cndnumind = find(rptmrk(rptlop).val >= 1000 & rptmrk(rptlop).val <=2000);
            begtim = rptmrk(rptlop).tim(perbegind)-offset;
            endtim = rptmrk(rptlop).tim(perendind);
            cnd    = rptmrk(rptlop).val(cndnumind);
            if endtim-begtim>=0 %why wouldn't always be > 0???
                trl = [trl; [begtim endtim -offset cnd]];
            end
        end
    end
end

% if strcmp(cfg1.dataset(end-15:end-7),'IW0602213')==1
%     trl=[trl(1:244,:); trl(246:399,:)];
% end
%
% if strcmp(cfg1.dataset(end-15:end-7),'IW0604144')==1
%     trl=[trl(1:204,:); trl(247:444,:)];
% end

numrpt = size(trl,1);
i=1;
for rptlop = 1:numrpt
    lt(i)=trl(rptlop,2)-trl(rptlop,1)-trl(rptlop,3);
    cnd(i)=trl(rptlop,4);
    i=i+1;
end

%Sort conditions to pair first and second presentations of a stimulus
%Create an index of first presentations - encind
%Create an index of second presentations - recind
%Determine the delay between first and second presentations - delind
%Calculate looking times for first and second presentations - ltenc and ltrec
[cndsrt,indx]=sort(cnd,2,'ascend');%cnd is 1xnumcndoccurrences

% %%Next two lines (4:405) for sessions 4/21/06-6/13/06
% if str2num(cfg1.dataset(end-12:end-7))>=604212 && str2num(cfg1.dataset(end-12:end-7))<=606132
%     cndsrt  =   cndsrt(4:405);
%     indx    =   indx(4:405);
% end

for cndlop=(cndsrt(1,1)):(cndsrt(1,end))
    if size(find(cndsrt==cndlop),2)~=2
        disp(strcat('Error in condition matrix:  ',num2str(cndlop)));
        if size(find(cndsrt==cndlop),2)==0
            disp('Condition does not occur')
        end
        if size(find(cndsrt==cndlop),2)==4
            h=find(cndsrt==cndlop);
            cndsrt=cndsrt([1:(h(1,end)-2) (h(1,end)+1):size(cndsrt,2)]);
            indx=indx([1:(h(1,end)-2) (h(1,end)+1):size(indx,2)]);
            disp('Removing third & fourth occurrences of condition')
        end
        if size(find(cndsrt==cndlop),2)==3
            h=find(cndsrt==cndlop);
            cndsrt=cndsrt([1:(h(1,end)-1) (h(1,end)+1):size(cndsrt,2)]);
            indx=indx([1:(h(1,end)-1) (h(1,end)+1):size(indx,2)]);
            disp('Removing third occurrence of condition')
        end
        if size(find(cndsrt==cndlop),2)==1
            h=find(cndsrt==cndlop);
            cndsrt=cndsrt([1:(h-1) (h+1):size(cndsrt,2)]);
            indx=indx([1:(h-1) (h+1):size(indx,2)]);
            disp('Removing first (only) occurrence of condition')
        end
    end
end

cndmat=reshape(cndsrt,2,size(cndsrt,2)/2);
indmat=reshape(indx,2,size(indx,2)/2);
encind=indmat(1,:);
recind=indmat(2,:);

trl1=trl(encind,:);
trl2=trl(recind,:);

ltenc=lt(encind);%msec
ltrec=lt(recind);



% dum=find(ltenc>=750);%USE ONLY TRIALS WHERE ENCODING LOOKING TIME IS > 750 MS
% trl1 = trl1(dum,:);

% trl2 = trl2(dum,:);
% ltrec=ltrec(dum);
% ltenc=ltenc(dum);

%put in chronological order
[dum Index] = sort(trl1(:,2),'ascend');

trl1 = trl1(Index,:);
trl2 = trl2(Index,:);
%this works because the ltenc and ltrec are ordered pairs:
ltenc = ltenc(Index);
ltrec = ltrec(Index);

% trl = trl1;%TAKE JUST THE ENCODING TRIALS FOR ANALYSIS
LT = [ltenc;ltrec]';

NP = [ltenc./(ltenc+ltrec)]';
PRLT = [(ltenc-ltrec)./ltenc*100]';
[dum order1] = sort(NP,'ascend');
% [dum order2] = sort(PRLT,'descend');

trlp1 = [trl1 LT NP PRLT order1 1*ones(size(trl1,1),1)];
trlp2 = [trl2 LT NP PRLT order1 2*ones(size(trl2,1),1)];
trl = [trlp1;trlp2];
[dum Index2] = sort(trl(:,2),'ascend');
trl = trl(Index2,:);

% trl(order1,9) = 1:length(order1);%fixed 101018 nk



% ltred=ltenc-ltrec;
% ltper=(ltenc-ltrec)./ltenc;
% [ltpersrt,ltperindx]=sort(ltper,2,'ascend');
% temp=find(ltpersrt,30,'last');
% trl=trl(ltperindx(temp),:)

