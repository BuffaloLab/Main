% Written by Kiril Staikov
% 12/19/2012
clear all; close all; pack all; clc;

itemFile = 's:\kiril\eyecal\cchFS.itm';
cndFile = 's:\kiril\eyecal\cchFS.cnd';

% Units here are degrees of visual angle
spacingWidth = 3;
spacingHeight = 3;
gridWidth = 33;  % Full Screen = 33
gridHeight = 24; % Full screen = 24

gridX = zeros((gridHeight / spacingHeight) + 1, (gridWidth / spacingWidth) + 1);
gridY = zeros((gridHeight / spacingHeight) + 1, (gridWidth / spacingWidth) + 1);

for i = 1:size(gridX, 2)
    gridX(:, i) = (gridWidth / 2) - (spacingWidth * (i - 1));
end

for i = 1:size(gridY, 1)
    gridY(i, :) = (gridHeight / 2) - (spacingHeight * (i - 1));
end

% Make ITM file
inner = []; int1 = []; C = [];
threeR = [150; 150; 195];
threeG = [150; 150; 195];
threeB = [150; 150; 130];
points = size(gridX, 2) * size(gridX, 1);

% items <=0
height = [.2; .1; .1; 2.5];
width = [.2; .1; .1; .1];
outer = [.5; .5; .5; NaN];
centerx = [0; 0; 0; 0];
centery = [0; 0; 0; 0];
R = [100; 200; 200; 150];
G = [100; 200; 200; 150];
B = [100; 200; 200; 150];


% items > 0
for i = 1:points
    R = [R; threeR];
    G = [G; threeG];
    B = [B; threeB];
    height = [height; .3; .3; .3];
    width = [width; .3; .3; .3];    
    outer = [outer; .5; .5; .5];
    centerx = [centerx; gridX(i); gridX(i); gridX(i)];
    centery = [centery; gridY(i); gridY(i); gridY(i)];
end

item = (-3:points * 3)';
angle = zeros(length(item), 1);
type = ones(length(item), 1);
bitpan = zeros(length(item), 1);
filled = ones(length(item), 1);
inner = {};
int1 = {};
C = {};
A = {};
filename = {};

for i = 1:length(item)
    C{i, 1} = 'x';
end


writeITM(itemFile, item, type, height, width, angle, inner, outer, bitpan, filled, centerx, centery, int1, R, G, B, C, A, filename)

stimLocs = readITM(itemFile);
stimX = stimLocs(:, 1);
stimY = stimLocs(:, 2);

scatter(stimX, stimY, 'y', 'filled', 'marker', 's');
set(gca, 'Color', 'k')

% Now make the CND file.
cond = (1:points)';
fix_id = (1:3:points * 3)';
test0 = (2:3:points * 3)';
test1 = (3:3:points * 3)';
bckgnd = ones(length(cond), 1) * -3;
timing = ones(length(cond), 1);
trial_type = ones(length(cond), 1) * 2;
test2 = [];
test3 = [];
test4 = [];
test5 = [];
test6 = [];
test7 = [];
test8 = [];
test9 = [];
color_palette= {};

writeCND(cndFile, cond, test0, test1, test2, test3, test4, test5, test6, test7, test8, test9, bckgnd, timing, trial_type, fix_id, color_palette);

