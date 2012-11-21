## CORTEX-Triggered Capturing of CCTV Video in MATLAB [[Files](./)]

### Requirements

* Arduino
* [EasyCap DC60](http://www.amazon.com/s/ref=nb_sb_noss?url=search-alias%3Daps&field-keywords=easycap+dc60) and the corresponding [driver](http://easycapexpertti.mybisi.com/pages/drivers#1.)
* [LTI-Civil JAVA libaries](http://sourceforge.net/projects/lti-civil/files/lti-civil/lti-civil-20070920-1721/lti-civil-20070920-1721.zip)

### Connecting the Arduino

### Adding Toolbox in MATLAB

### Edit the desired CORTEX Timing File

### Running the Experiment
Don't run from the S Drive or save anything to the S drive - it is too slow.  

* edit the save location, monkey name, and arduino com port if you have unplugged/replugged the arduino for any reason (find the com port in device manager)
* run saveMovieTriggered.m from the C drive
* if saving .mat files, run the code at the end to convert the .mat files to .wmv files


see the saveMovieTriggered.m comments for instructions to setup on a new computer 