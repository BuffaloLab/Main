% Written by Kiril Staikov
% 12/19/2012
%
% The filename section might need to be changed to include a longer field
% for longer paths.  I haven't used this field yet for anything so I
% haven't really tested it. 

function [] = writeITM(itemFile, item, type, height, width, angle, inner, outer, bitpan, filled, centerx, centery, int1, R, G, B, C, A, filename)  
    fid = fopen(itemFile, 'wt');
    headers = 'ITEM TYPE HEIGHT WIDTH ANGLE INNER OUTER BITPAN FILLED CENTERX CENTERY INT1 -R- -G- -B- C A ------FILENAME------';
    fprintf(fid, '%s', headers);

    for i = 1:length(item)
        fprintf(fid, '\n%4.0f', item(i));
        if isempty(type) || isnan(type(i))
            fprintf(fid, '%5s', '');
        else fprintf(fid, '%5.0f', type(i)); end
        if isempty(height) || isnan(height(i))
            fprintf(fid, '%7s', '');
        else fprintf(fid, '%7.2f', height(i)); end
        if isempty(width) || isnan(width(i))
            fprintf(fid, '%6s', '');
        else fprintf(fid, '%6.2f', width(i)); end
        if isempty(angle) || isnan(angle(i))
            fprintf(fid, '%6s', '');
        else fprintf(fid, '%6.2f', angle(i)); end
        if isempty(inner) || isnan(inner(i))
            fprintf(fid, '%6s', '');
        else fprintf(fid, '%6.2f', inner(i)); end
        if isempty(outer) || isnan(outer(i))
            fprintf(fid, '%6s', '');
        else fprintf(fid, '%6.2f', outer(i)); end
        if isempty(bitpan) || isnan(bitpan(i))
            fprintf(fid, '%7s', '');
        else fprintf(fid, '%7.0f', bitpan(i)); end
        if isempty(filled) || isnan(filled(i))
            fprintf(fid, '%7s', '');
        else fprintf(fid, '%7.0f', filled(i)); end
        if isempty(centerx) || isnan(centery(i))
            fprintf(fid, '%8s', '');
        else fprintf(fid, '%8.2f', centerx(i)); end
        if isempty(centery) || isnan(centery(i))
            fprintf(fid, '%8s', '');
        else fprintf(fid, '%8.2f', centery(i)); end
        if isempty(int1) || isnan(int1(i))
            fprintf(fid, '%5s', '');
        else fprintf(fid, '%5f.0', int1(i)); end
        if isempty(R) || isnan(R(i))
            fprintf(fid, '%4s', '');
        else fprintf(fid, '%4.0f', R(i)); end
        if isempty(G) || isnan(G(i))
            fprintf(fid, '%4s', '');
        else fprintf(fid, '%4.0f', G(i)); end
        if isempty(B) || isnan(B(i))
            fprintf(fid, '%4s', '');
        else fprintf(fid, '%4.0f', B(i)); end
        if isempty(C) || isempty(C{i})
            fprintf(fid, '%2s', '');
        else fprintf(fid, '%2s', C{i}); end
        if isempty(A) || isempty(A{i})
            fprintf(fid, '%2s', '');
        else fprintf(fid, '%2s', A{i}); end
        if isempty(filename) || isempty(filename{i})
            fprintf(fid, '%21s', '');
        else fprintf(fid, '%21s', filename{i}); end
    end

    fclose(fid);
    
end