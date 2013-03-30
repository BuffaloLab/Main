##imgEyeScatTimeLapse [[File](imgEyeScatTimeLapse.m)]

###Description
Creates a time-lapse visualization of eye position overlaid onto the image the animal was looking at.  A line isn't drawn to connect the past and present points.  Rather, only a handful of eye samples (as you many as you choose) are displayed each frame.  It looks like this:

![example](example.gif)

###Caveats
* At present, this only works with images that were displayed full-screen, or in the center of the screen.  Some tweaking would need to be done to allow for other options. 
* The eye data fed into the function needs to be in pixel coordinates.
* While the script runs, make sure that the figure is fully in view and not obscured by any other windows, otherwise they will show up in the capture of the final video.

###Syntax: 
    imgEyeScatTimeLapse(imagePath, xEyeData, yEyeData, xEyeDataMin, xEyeDataMax, yEyeDataMin, yEyeDataMax, eyeSampRate, eyeSamplesPerFrame, outputVidPath, outputSpeed)

* imagePath = String of the filepath of the image the animal was looking at (i.e. 's:\eblab\image.bmp')
* xEyeData = Matrix of the X eye positions
* yEyeData = Matrix of the Y eye positions
* xEyeDataMin, XEyeDataMax, yEyeDataMin, and yEyeDataMax = Numbers that describe the range of possible pixel coordinates of your eye data that you would want to be shown on the plot.  This is going to depend on how you formatted your data.  For example, for an 800x600 image, your X eye data could either be recorded between -400 and 400 pixels, or 0 and 800, or 0 and -800, etc., and the min and max values you input should match that information.
* eyeSampRate = The rate at which the eye data was sampled in milliseconds/Sample.  In CORTEX, we usually have it set to sample every 5 msec.
* eyeSamplesPerFrame = The number of eye data points that you want displayed in a single frame of the final visualization. You could display only one, but it usually looks cooler to have like 5 or 10 points at a time shown.
* outputVidPath = String of the filepath where you want the video this function creates to be saved (i.e. 's:\eblab\video.avi').  It should be an .avi file.
* outputSpeed = The speed at which you want the video to be displayed.  A value of 1 would set it to real time.  A value of .5 will create a video that plays at half speed (and is thus twice as long). 
