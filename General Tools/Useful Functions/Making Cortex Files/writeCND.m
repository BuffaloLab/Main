% Written by Kiril Staikov
% 12/19/2012

% The color palette section might need to be changed to include a longer field
% for longer paths.  I haven't used this field yet for anything so I
% haven't really tested it. 

function [] = writeCND(cndFile, cond, test0, test1, test2, test3, test4, test5, test6, test7, test8, test9, bckgnd, timing, trial_type, fix_id, color_palette)  
    fid = fopen(cndFile, 'wt');
    headers = 'COND# TEST0 TEST1 TEST2 TEST3 TEST4 TEST5 TEST6 TEST7 TEST8 TEST9 BCKGND TIMING TRIAL_TYPE FIX_ID ---COLOR-PALETTE---';
    fprintf(fid, '%s', headers);

    for i = 1:length(cond)
        fprintf(fid, '\n%5.0f', cond(i));
        if isempty(test0) || isnan(test0(i))
            fprintf(fid, '%6s', '');
        else fprintf(fid, '%6.0f', test0(i)); end
        if isempty(test1) || isnan(test1(i))
            fprintf(fid, '%6s', '');
        else fprintf(fid, '%6.0f', test1(i)); end
        if isempty(test2) || isnan(test2(i))
            fprintf(fid, '%6s', '');
        else fprintf(fid, '%6.0f', test2(i)); end
        if isempty(test3) || isnan(test3(i))
            fprintf(fid, '%6s', '');
        else fprintf(fid, '%6.0f', test3(i)); end
        if isempty(test4) || isnan(test4(i))
            fprintf(fid, '%6s', '');
        else fprintf(fid, '%6.0f', test4(i)); end
        if isempty(test5) || isnan(test5(i))
            fprintf(fid, '%6s', '');
        else fprintf(fid, '%6.0f', test5(i)); end
        if isempty(test6) || isnan(test6(i))
            fprintf(fid, '%6s', '');
        else fprintf(fid, '%6.0f', test6(i)); end
        if isempty(test7) || isnan(test7(i))
            fprintf(fid, '%6s', '');
        else fprintf(fid, '%6.0f', test7(i)); end
        if isempty(test8) || isnan(test8(i))
            fprintf(fid, '%6s', '');
        else fprintf(fid, '%6.0f', test8(i)); end
        if isempty(test9) || isnan(test9(i))
            fprintf(fid, '%6s', '');
        else fprintf(fid, '%6.0f', test9(i)); end
        if isempty(bckgnd) || isnan(bckgnd(i))
            fprintf(fid, '%7s', '');
        else fprintf(fid, '%7.0f', bckgnd(i)); end
        if isempty(timing) || isnan(timing(i))
            fprintf(fid, '%7s', '');
        else fprintf(fid, '%7.0f', timing(i)); end
        if isempty(trial_type) || isnan(trial_type(i))
            fprintf(fid, '%11s', '');
        else fprintf(fid, '%11.0f', trial_type(i)); end
        if isempty(fix_id) || isnan(fix_id(i))
            fprintf(fid, '%7s', '');
        else fprintf(fid, '%7.0f', fix_id(i)); end
        if isempty(color_palette) || isempty(color_palette{i})
            fprintf(fid, '%20s', '');
        else fprintf(fid, '%20s', color_palette{i}); end
    end

    fclose(fid);
    
end