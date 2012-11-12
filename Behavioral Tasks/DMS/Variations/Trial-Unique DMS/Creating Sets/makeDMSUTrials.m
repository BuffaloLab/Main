function [] = makeDMSUTrials(sets)
% Make DMS images and item files
% sets = set numbers desired
% Nathan Killian 120614
% specify details about the sets to be made
numperset   = 600;%number of images to put in each set
picdir      = 'S:\Flickr pics\';%picture source
topdir      = 'S:\Aaron\DMS\BMP Stimuli\';%picture output
itmdir      = 'S:\Aaron\DMS\ITMs\';%Item File output
tag         = 'dmsUT';%prefix on output folder names
outputsize  = [64 64];%(x,y)/(w,h) output image size in pixels
%------------------------------------------

curdir = dir([topdir tag '*']);clear cursets
cursets = zeros(length(curdir),1);
for i = 1:length(curdir),
    if ~isempty(str2num(curdir(i).name(4:end)))
        cursets(i) = str2num(curdir(i).name(4:end));end
end
cursets = sort(cursets);
for i = 1:length(sets)
    if any(sets(i) == cursets), error(['set number ' num2str(sets(i)) ' already exists -check your set selection']);end
end

% read image, resize (interpolate), save in new location, move original
%24 bit jpg colormap is 3-valued 8-bit (RGB in uint8 number format)
allpics = dir([picdir '*.jpg']);
numpics = size(allpics,1);
numwanted = length(sets);numpossible = floor(numpics/numperset);
if numwanted > numpossible
    if numpossible > 0, lastset = sets(numpossible);else lastset = NaN;end
    sets = sets(1:numpossible);
    disp(sprintf('you asked for %g sets\nand can make up to %g sets\nlast set will be %g\nrun getflickr.m to get more pictures!',numwanted,numpossible,lastset));
else
    lastset = sets(end);
    disp(sprintf('you asked for %g sets\nand can make up to %g sets -nice planning.\nlast set will be %g\nrun getflickr.m to get more pictures.',numwanted,numpossible,lastset));
end

for setnum = 1:length(sets)
    if any(sets(setnum) == cursets), error(['set number ' num2str(sets(setnum)) ' already exists -check your set selection']);end
    picnums = ((setnum-1)*numperset + 1):(setnum*numperset);
    pics = allpics(picnums,1);
    number = leadz(sets(setnum),2);mkdir([topdir tag number]);
    for k = 1:numperset
        pic = double(imread([picdir pics(k).name]));
        [numypixels numxpixels dummy] = size(pic);
        xi = linspace(1,numxpixels,outputsize(1));
        yi = linspace(1,numypixels,outputsize(2));
        [Xi Yi Zi] = meshgrid(xi,yi,1:3);
        newpic = uint8(interp3(pic,Xi,Yi,Zi));
        imwrite(newpic,[topdir tag number '\' num2str(k) '.bmp']);
        movefile([picdir pics(k).name],[topdir tag number '\'])
    end
    disp(['new set in ' topdir tag number])
    
    
    
end

sets = num2cell(sets);
for k = 1:length(sets)
    number = num2str(sets{k});
    if sets{k}<10
        number = ['0' number];
    end
    %make an item file
    itm=['ITEM TYPE HEIGHT WIDTH ANGLE INNER OUTER BITPAN FILLED CENTERX CENTERY INT1 -R- -G- -B- C A ------FILENAME------';
        '  -3    1   0.20  0.20  0.00        0.50      0      1    0.00    0.00       50  50  50 x                       ';
        '  -2    1   0.10  0.10  0.00        0.50      0      1    0.00    0.00      200 200 200 x                       ';
        '  -1    1   0.10  0.10  0.00        0.50      0      1    0.00    0.00      200 200 200 x                       ';
        '   0    1   0.30  0.30  0.30                  0      1    0.00    0.00      150 150 150 x                       ';];
   
    for u = 1:numperset
        if u<=9
            nextline = ['   '];
        elseif u>99
            nextline = [' '];
        else  
            nextline = ['  '];
        end
        item = num2str(u);
        nextline = [nextline item];
        nextline = [nextline '    8                                     0           0.00    0.00       75  75  75 x   C:\DMSUT' number '\' item '.bmp';];
       if u<=9
            nextline = [nextline '    '];
       elseif u<100
            nextline = [nextline '   '];
       else 
           nextline = [nextline '  '];
       end 
        
        itm = [itm; nextline];
    end 

    if exist(strcat(itmdir,['dmsUT' number '.itm']),'file')
        delete(strcat(itmdir,['dmsUT' number '.itm']))
    end
    itmfil=strcat(itmdir,['dmsUT' number '.itm']);
    fid = fopen(itmfil, 'wt');
    fprintf(fid,'%s',itm(1,:)');
    for k=1:size(itm,1)-1
        fprintf(fid,'\n%s',itm(k+1,:)');
    end
    fclose(fid);
    disp(['Generated item file ' tag number '.itm'])
end

