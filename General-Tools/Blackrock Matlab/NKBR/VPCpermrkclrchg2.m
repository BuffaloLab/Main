function per = VPCpermrkclrchg2(mrk)
rptdef.rptbeg   = 150;%trial start
rptdef.rptend   = 151;%trial end
rptmrk = prorptmrkFT(mrk,rptdef);

numrpt = size(rptmrk,2);
valrptcnt = 0;
for rptlop = 1:numrpt
    if size(find(rptmrk(rptlop).val(find(rptmrk(rptlop).val>1000,1,'last')) < 1010)) ~=0
        if size(find(rptmrk(rptlop).val == 200)) ~=0
            perbegind = find(rptmrk(rptlop).val == 25);%yellow on?
            perendind = find(rptmrk(rptlop).val == 4);
            cndnumind = find(rptmrk(rptlop).val >= 1000 & rptmrk(rptlop).val <=2000);
            blknumind = find(rptmrk(rptlop).val >=500 & rptmrk(rptlop).val <=999);
            begtimdum = rptmrk(rptlop).tim(perbegind);
            endtimdum = rptmrk(rptlop).tim(perendind);
            if endtimdum > begtimdum
                valrptcnt = valrptcnt + 1;
                per(valrptcnt).begsmpind = begtimdum;
                per(valrptcnt).endsmpind = endtimdum;
                per(valrptcnt).begpos = 1;
                per(valrptcnt).cnd = rptmrk(rptlop).val(cndnumind);
                per(valrptcnt).blk = rptmrk(rptlop).val(blknumind);
                per(valrptcnt).allcnd = rptmrk(rptlop).val;
                per(valrptcnt).allmrk = rptmrk(rptlop).tim;
           end
        end
    end
end

% per=per(1:30);

