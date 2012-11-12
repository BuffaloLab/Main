function number = leadz(k,digits)
% function number = leadz(k,digits)
% k is a number not a string
% Leading zeros strings
% given the number k and desired number of digits,
% add leading zeros and generate a string
% Nathan Killian 090811
numkdigits = floor(log10(k))+1;
nzeros = digits - numkdigits;
number = num2str(k);
if nzeros>=1
    for i = 1:nzeros
        number = ['0' number];
    end
end




