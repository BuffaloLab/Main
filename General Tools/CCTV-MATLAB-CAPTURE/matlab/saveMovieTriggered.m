% SAMPLE_AVERAGE uses FrameGrabM to grab a series of frames and averages
% them together to reduce the amount of noise that may appear in the image.
% This is especially useful in low-light situations.  This also shows a
% technique for preallocation of memory to ensure that consecutive frames
% are captured without gaps in time.
%
% Version 0.8 - 06 March 2012
%modified by Nathan Killian 121103

%todo: have receive a ttl pulse to start capture and save to a .mat file
%and/or .wmv file
% 640 x 480 at 29.97 fps is format 1, all are 29.97, see formatInfos
% all are RGB24 bit
% format 2 is 160x120
% could crop out a 500 pixel region and send into plexon as a 1 kHz signal
% -> 1 fps
% anyway to reduce image size even more? taking up too much memory
% can only do about 20 seconds at 10 fps
% correct for the gained frames when doing long time segments (i.e. 30
% instead of 29.97 is used)
if exist('s'),fclose(s);end;fgrabm_shutdown;
clar
warnins = warning('off','all');
% setup arduino, only if a good arduino!==============================
% need to have run: S:\arduino-1.01\arduinoIO\install_arduino.m
% threshold = 512;
% aInPin = 5;
% read digital input from pin 4
% SS =a.analogRead(aInPin);%start/stop signal, 0 to 1023
% ==========================================

% load this onto the arduino: S:\arduino-1.0.1\recordStartStop_bare\recordStartStop_bare.ino

%FOR THE FOLLOWING, WILL RUN FASTER IF YOU COPY TO C:\ AND RUN FROM THERE
% put S:\framegrabm\mmwriteFiles and S:\framegrabm\matlab in matlab path
% do this in matlab:
% edit([matlabroot '/toolbox/local/classpath.txt'])
% add this line: S:/framegrabm/bin
% add this line: S:/framegrabm/lti-civil-20070920-1721/lti-civil.jar
% edit([matlabroot '/toolbox/local/librarypath.txt'])
% add this line: S:/framegrabm/lti-civil-20070920-1721/native/win32-x86

% USE THESE COMMANDS IN CORTEX:
% DEVoutp(0,0x1,0x02);%put this right below the main{} loop to initialize
% DEVoutp(0,0x1,0x01);%start recording with this command
% DEVoutp(0,0x1,0x02);%stop recording with this command

% OPTIONS====================================================================
saveMAT = 1;saveWMV = 0;%SAVE A MAT FILE? SAVE A WINDOWS MEDIA VIDEO FILE?

MONKEY = 'IW';

filePrefix = [MONKEY datestr(now,'yymmdd') '_'];%FILE NAME PREFIX
fileDir = ['C:\' MONKEY '_Movies\'];% WHERE TO SAVE THE MOVIES
if ~exist(fileDir),mkdir(fileDir);end
seconds = 20;%ALLOCATE MORE THAN MAX LENGTH OF EACH CLIP, can save up to 5 minutes, 300 seconds, with current settings
newFramesPerSec = 10;% option to reduce the FPS to save memory, 15 AND 10 WORK
%====================================================================

framesPerSec = 30;%original FPS from USB camera
skip = framesPerSec/newFramesPerSec;

% FRAMECONSEC is the number of consecutive frames to grab in each cycle:
FRAMECONSECorig = framesPerSec * seconds;
if newFramesPerSec < framesPerSec
    FRAMECONSEC = round(FRAMECONSECorig*newFramesPerSec/framesPerSec);
end

% MYDEVICE is the capture device index that I want to use:
MYDEVICE = 1;
% MYFORMAT is the format index that I want to use for MYDEVICE:
MYFORMAT = 2;

% Initialize the capture framework:
fprintf('Initializing...\n');
fgrabm_init

% You can set the desired capture device and framework here:
fgrabm_setdefault(MYDEVICE);
fgrabm_setformat(MYFORMAT);

% Get the format information so we can preallocate memory:
fprintf('Allocating buffer...');
formatInfos = fgrabm_formats;
formatInfo = formatInfos(MYFORMAT);
capArray = zeros([formatInfo.height formatInfo.width 3 FRAMECONSEC], ...
    'uint8');
trashArray = zeros([formatInfo.height formatInfo.width 3 1],'uint8');
% We'll grab in the native format and do calculation later to avoid losing
% frames.
fprintf('Starting continuous capture...\n');
fgrabm_start;

% Wait for the device to warm up:
fprintf('Waiting for the capture device to warm up...\n');
pause(2);

running = 1;
clipSuffix = 1;% filename suffix, start at 1
s = serial('COM8','BaudRate',9600,'DataBits',8,'Terminator','CR');%configure \n to be a carriage return
s.InputBufferSize = 1;

fopen(s);
% ba = s.BytesAvailable;if ba, dump = fread(s);end
s.InputBufferSize = 1;
fprintf('Opened serial port... \n')
fprintf('Waiting for command to start... \n')

%%
while running
    % % %     SS =a.analogRead(aInPin)%start/stop signal, 0 to 1023
    stopRead = 0;
    byteAvailable = s.BytesAvailable;
    if byteAvailable,
        %         fprintf('got a byte... \n');
        cmd = str2num(fgetl(s));
        %         s.InputBufferSize = 1;
    else continue;
    end
    
    if cmd == 1,% GET A CLIP!
        % % %     if SS > threshold % GET A CLIP!
        % Grab the frames:
        %         tic
        fprintf('Clip Number %d \n', clipSuffix);
        fprintf('Grabbing AT MOST %d seconds at %d FPS...\n', seconds, newFramesPerSec);
        fc = 1;cmd = 0;
        %         byteAvailable = s.BytesAvailable;
        tic
        for index = 1:FRAMECONSECorig
            %             byteAvailable = s.BytesAvailable;
            
            if mod(index,skip)==0
                capArray(:, :, :, fc) = fgrabm_grab();
            else trashArray = fgrabm_grab();continue;
            end
            byteAvailable = s.BytesAvailable;
            %             toc
            if byteAvailable
                cmd = str2num(fgetl(s));
                % % %             SS =a.analogRead(aInPin);%start/stop signal, 0 to 1023
                % % %             if SS < threshold, stopRead = 1;
                if cmd == 2, stopRead = 1;
                    %                     fc
                    disp('stopped recording')
                    capArrayTemp = capArray(:,:,:,1:fc);
                    break;
                elseif cmd > 0
                    error('problem with communication, should only get a 2 here');
                end
            end
            fc = fc + 1;
        end
        toc
        if ~stopRead, capArrayTemp = capArray;end%got to the end without a stop signal
        
        
        % % %     imagesc(capArray(:,:,1,1));colormap('gray')
        
        if saveMAT
            % it takes 0.1 seconds to save a 6-second 10-FPS movie on PLX 2
            % C-Drive and 30 seconds to save to the S-Drive!
            tic
            save([ fileDir filePrefix num2str(clipSuffix) '.mat'],'capArrayTemp','formatInfo','newFramesPerSec','fileDir','filePrefix')%9.5 MB per minute
            toc
        end
        
        if saveWMV
            % it takes 1.23 seconds to save a 6-second 10-FPS movie on PLX 2

            video = formatInfo;
            %         video = setdefaults(video,'width',formatInfo.width,'height',formatInfo.height);%values must be in pixels and be even integers
            for k = 1:size(capArrayTemp,4);
                video.frames(k) = im2frame(capArrayTemp(:,:,:,k));
            end
            video.times( 1:length(video.frames) ) = (1:length(video.frames))/newFramesPerSec;
            mmwrite([fileDir filePrefix num2str(clipSuffix)  '.wmv'],video)
            %             break;
        end
        
        clipSuffix = clipSuffix + 1;
    end
end
fclose(s);
% Shut down capturing:
fgrabm_shutdown;

%% RUN THIS IF SAVING .MAT ONLY
% OPTIONALLY CROP THE VIDEO USING A SPECIFIED ROI
% ROI = [X_LEFT X_RIGHT Y_TOP Y_BOTTOM];
% set ROI = []; if don't want to use an ROI
% original dimensions are 160 width and 120 height pixels
ROI = [40 119 20 79];newWidth = ROI(2)-ROI(1)+1,newHeight = ROI(4)-ROI(3)+1
% ROI = [];

if ~isempty(ROI),if ~iseven(newWidth)|~iseven(newHeight),error('height and width must be even values');end;end

% convert saved .mat movies to .wmv
if saveMAT && ~saveWMV
    clipset = 1:clipSuffix-1;
    for clipInd = clipset
        file = [fileDir filePrefix num2str(clipInd)];
        load(file);
        tic
        if ~isempty(ROI)
            vide = formatInfo;
            video.width = newWidth;video.height = newHeight;
            for k = 1:size(capArrayTemp,4);
                video.frames(k) = im2frame(capArrayTemp(ROI(3):ROI(4),ROI(1):ROI(2),:,k));
            end
        else
            video = formatInfo;
            for k = 1:size(capArrayTemp,4);
                video.frames(k) = im2frame(capArrayTemp(:,:,:,k));
            end
        end
        video.times( 1:length(video.frames) ) = (1:length(video.frames))/newFramesPerSec;
        mmwrite([fileDir filePrefix num2str(clipInd)  '.wmv'],video)
        toc
    end
end

