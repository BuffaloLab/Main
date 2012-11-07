%% heat_stats_xy.m example
function [] = example_usage()
%% two conditions, two heat maps, and difference stats
figure(101);

% STEP 1, PLUG IN VALUES
% create viewing position as two random 2D Gaussians:
% make slightly different:
xy1 = randn(2,1e5)*10;%degrees visual angle
xy2 = randn(2,1e5)*10+5;%degrees visual angle

[vals maps options] = heat_stats_xy(xy1,xy2)

% STEP 2, PLOT
subplot 121;imagescnan(maps.xb,maps.yb,maps.t1);axis xy;axis square;grid on;hold on;
drawbox([-options.sqr options.sqr options.sqr -options.sqr])
xyl('x dva','y dva','slghtly different heat maps');
subplot 122;imagescnan(maps.xb,maps.yb,maps.t2);axis xy;axis square;grid on;hold on;
drawbox([-options.sqr options.sqr options.sqr -options.sqr])


%% just a single heat map
xy = randn(2,1e5)*10;%degrees visual angle
[vals maps options] = heat_stats_xy(xy);

figure(102);
imagescnan(maps.xb,maps.yb,maps.t1);axis xy;axis square;grid on;hold on;
drawbox([-options.sqr options.sqr options.sqr -options.sqr])
title('just a single heat map')


%% if you already have the heat maps!
map1 = rand(100);
map2 = rand(100);
disp('example results from pregenerated heat maps:')
[vals] = heat_stats(map1,map2);vals

%%
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
function h = xyl(xl,yl,tl,fontsize)
% Plot labels with increased ease! hooray!
% Nathan Killian 120117
if nargin<4,fontsize = 9;end
if ~isempty(xl)
    h(1) = xlabel(xl,'fontsize',fontsize,'fontname','arial');
end
if nargin == 2 | (nargin>2 & isempty(tl)) & ~isempty(yl)
    h(2) = ylabel(yl,'fontsize',fontsize,'fontname','arial');
elseif nargin > 2 & ~isempty(tl)
    if ~isempty(yl)
        h(2) = ylabel(yl,'fontsize',fontsize,'fontname','arial');
    end
    h(3) = title(tl,'fontsize',fontsize,'fontname','arial');
end
return;

%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
% Draw Boxes with given colors
function [] = drawbox(bounds,colors,axisbounds)
% bounds  = rectangles x 4 values: [top left x y, bottom right x y;next rectangle]
% colors = cell array of colors
if nargin<3, axisbounds = [];end
if nargin<2,  colors = {'r'};end
clr = colors{1};
for k = 1:size(bounds,1)
    if length(colors)>1,clr = colors{k};end
    L1 = bounds(k,1);R1 = bounds(k,3);T1 = bounds(k,2);B1 = bounds(k,4);
    
    lwid = .15;
    Left1 = line([L1 L1],[B1 T1],'color',clr,'linewidth',lwid);Right1 = line([R1 R1],[B1 T1],'color',clr,'linewidth',lwid);
    Top1 = line([L1 R1],[T1 T1],'color',clr,'linewidth',lwid);Bottom1 = line([L1 R1],[B1 B1],'color',clr,'linewidth',lwid);

    set(Left1,'HandleVisibility','off')
    set(Right1,'HandleVisibility','off')
    set(Top1,'HandleVisibility','off')
    set(Bottom1,'HandleVisibility','off')
end
if ~isempty(axisbounds)
    axis(axisbounds)
end
return;