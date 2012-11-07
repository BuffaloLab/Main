function rptmrk = prorptmrkFT(mrk,rptdef)

[bgntim,endtim] = cormrkFT(mrk,rptdef);

for rptlop = 1:size(bgntim)
    rptmrkind = find(mrk.tim >= bgntim(rptlop) & mrk.tim <= endtim(rptlop));
    rptmrk(rptlop).tim = mrk.tim(rptmrkind); % - bgntim(rptlop);
    rptmrk(rptlop).val = mrk.val(rptmrkind);
end