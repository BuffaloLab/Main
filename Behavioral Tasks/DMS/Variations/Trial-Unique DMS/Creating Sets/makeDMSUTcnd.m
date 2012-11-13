cnddir      = 'S:\Aaron\DMS\';
numconditions = 100;
filename = 'dmsUT.cnd';
%------------------------------------------

cndtxt=[
    'COND# TEST0 TEST1 TEST2 TEST3 TEST4 TEST5 TEST6 TEST7 TEST8 TEST9 BCKGND TIMING TRIAL_TYPE FIX_ID ---COLOR-PALETTE--- ';];
maxlength=132;
while length(cndtxt)<maxlength
    cndtxt=[cndtxt ' '];
end

for u=1:numconditions
    if u<=9
        nextline = ['    '];
    elseif u>999
        nextline = [' '];
    elseif u>99
        nextline= ['  '];
    else 
        nextline=['   '];    
    end
    COND = num2str(u);
    Test0 = u;

    if u==1
        Test1 = u + 1;
        Test2 = Test1 + 1;
        Test3 = Test2 + 1;
        Test4 = Test3 + 1;
        Test5 = Test4 + 1;
    else 
        Test0 = Test5 + 1;
        Test1 = Test0 + 1;
        Test2 = Test1 + 1;
        Test3 = Test2 + 1;
        Test4 = Test3 + 1;
        Test5 = Test4 + 1;
    end
    nextline = [nextline COND ' ' num2str(Test0)];
        if Test0<=9
            nextline=[nextline '     '];
        elseif Test0>999
            nextline=[nextline '  '];
        elseif Test0>99
            nextline=[nextline '   '];
        else 
            nextline=[nextline '    '];
        end

        nextline = [nextline num2str(Test1)];
        if Test1<=9
            nextline=[nextline '     '];
        elseif Test1>999
            nextline=[nextline '  '];
        elseif Test1>99
            nextline=[nextline '   '];
        else 
            nextline=[nextline '    '];
        end

        nextline = [nextline num2str(Test2)];
        if Test2<=9
            nextline=[nextline '     '];
        elseif Test2>999
            nextline=[nextline '  '];
        elseif Test2>99
            nextline=[nextline '   '];
        else 
            nextline=[nextline '    '];
        end

        nextline = [nextline num2str(Test3)];
        if Test3<=9
            nextline=[nextline '     '];
        elseif Test3>999
            nextline=[nextline '  '];
        elseif Test3>99
            nextline=[nextline '   '];
        else 
            nextline=[nextline '    '];
        end

        nextline = [nextline num2str(Test4)];
        if Test4<=9
            nextline=[nextline '     '];
        elseif Test4>999
            nextline=[nextline '  '];
        elseif Test4>99
            nextline=[nextline '   '];
        else 
            nextline=[nextline '    '];
        end

        nextline = [nextline num2str(Test5)];

        if Test5<=9
            nextline=[nextline '                               '];
        elseif Test5>999
            nextline=[nextline '                            '];
        elseif Test5>99
            nextline=[nextline '                             '];
        else 
            nextline=[nextline '                              '];
        end
        nextline = [nextline '-3     1          2      0']; 
    while length(nextline)<maxlength
            nextline=[nextline ' '];
    end
    cndtxt=[cndtxt; nextline];
end
        
    
    cndfil=strcat(cnddir,filename);
    fid = fopen(cndfil, 'wt');
    fprintf(fid,'%s',cndtxt(1,:)');
    for k=1:size(cndtxt,1)-1
        fprintf(fid,'\n%s',cndtxt(k+1,:)');
    end
    fclose(fid);
    disp(['Generated condition file ' filename])
        
       
    
  