%Written by Kiril Staikov
%3/29/2013

function [] = imgEyeScatTimeLapse(imagePath, xEyeData, yEyeData, ...
    xEyeDataMin, xEyeDataMax, yEyeDataMin, yEyeDataMax, eyeSampRate, ...
    eyeSamplesPerFrame, outputVidPath, outputSpeed)

    %Calculate other parameters.
    numFrames = ceil(length(xEyeData) / eyeSamplesPerFrame);
    outputFPS = numFrames / (outputSpeed * length(xEyeData) * eyeSampRate / 1000) * outputSpeed;

    %Load image.
    rgb = imread(imagePath);

    %Setup Figure
    hf = figure;
    set(hf, 'position', [75 150 1200 800])
    set(gca, 'Units', 'pixels')
    set(gca, 'Position', [75 75 size(rgb, 2) size(rgb, 1)])
    
    %Create matrix of frames for the movie.
    M1(1:numFrames) = struct('cdata', zeros(size(rgb, 2), size(rgb, 1), 3, ...
        'uint8'), 'colormap', []);
    
    %For loop that creates each frame and saves it.
    for i = 1:numFrames
        
        %Load image
        image(rgb)
        
        %Prepare Axes
        axis off
        hold on
        axes('Units', 'pixels','Position',get(gca,'Position'),'Layer','top');
                 
        %Scatterplot the eye data.
        if i ~= numFrames
            scatter(xEyeData(((i-1)*eyeSamplesPerFrame)+1:i*eyeSamplesPerFrame),...
                yEyeData(((i-1)*eyeSamplesPerFrame)+1:i*eyeSamplesPerFrame), 3, ...
                'ob','MarkerFaceColor','b');
        else
            scatter(xEyeData(((i-1)*eyeSamplesPerFrame)+1:end),...
                yEyeData(((i-1)*eyeSamplesPerFrame)+1:end), 3, ...
                'ob','MarkerFaceColor','b');
        end
        
        %Set Axes
        axis([xEyeDataMin xEyeDataMax yEyeDataMin yEyeDataMax]);
        set(gca, 'Color', 'None');
        
        %Save the frame.
        M1(i) = getframe;
    end

    %Save the video.
    eyevid = VideoWriter(outputVidPath);
    eyevid.FrameRate = outputFPS;
    open(eyevid);
    writeVideo(eyevid, M1);
    close(eyevid);
end
