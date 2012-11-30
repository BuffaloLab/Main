VideoFilename = 'C:\presentation\movies\stimuli\gong.avi';
LogFile = 'C:\Presentation\Movies\Data\11_16_2012_12_57.txt';


file = LogFile;
fid = fopen(file);

passes = 1;
while feof(fid) ~= 1
    textscan(fid, '%s', 2)
	iteration{passes} = textscan(fid, '%d %f %f %d');
    passes = passes + 1;
end

movieObj = VideoReader(VideoFilename)
mov(1:movieObj.NumberOfFrames) = struct('cdata', zeros(movieObj.Height, movieObj.Width, 3, 'uint8'), 'colormap', []);
for k = 1:movieObj.NumberOfFrames
    mov(k).cdata = read(movieObj, k);
end

hf = figure;
set(hf, 'position', [150 150 928 588])
set(gca, 'Units', 'pixels')
set(gca, 'Position', [75 75 720 480])

for t = 1:length(iteration)
    clear M1
    framesShown = unique(iteration{t}{4});
    M1(1:length(framesShown)) = struct('cdata', zeros(movieObj.Height, movieObj.Width, 3, 'uint8'), 'colormap', []);

    for i = 1:length(framesShown)
        frame = framesShown(i);
        x = iteration{t}{2}(find(iteration{t}{4}==frame));
        y = iteration{t}{3}(find(iteration{t}{4}==frame));
        image(mov(frame).cdata);
        axis off
        hold on
        axes('Units', 'pixels','Position',get(gca,'Position'),'Layer','top');
        scatter(x, y, 3,'ob','MarkerFaceColor','b');
        axis([-360 360 -240 240]);
        set(gca, 'Color', 'None');
        M1(i)=getframe;
    end

    eyevid = VideoWriter(['c:\presentation\movies\data\' 'gong' num2str(t) '.avi']);
    open(eyevid);
    writeVideo(eyevid, M1);
    close(eyevid);
end