In our version of the Delayed Match-to-Sample (DMS) task, the animal has to hold the touch-bar and fixate in the center of the screen for a sample picture to appear.  Then the animal has to continue holding the bar and fixating in the center of the screen.  In the meantime, between 0 and 4 images that are different from the sample (distractors) may appear in succession, until an image identical to the sample picture displays (the matching picture).  Then the animal has to release the bar when the matching image appears to receive reward and for the trial to be marked as 'correct'.
 
### Training [[Files](https://github.com/BuffaloLab/BehavioralTasks/tree/master/DMS/Training)]
These files only display single-color squares (not complicated pictures) and, as they are, give you the very first training step with these variables at the top of the .TIM file:

    /* Set timdelay to the desired delay between images in milliseconds */
    #define timdelay 150
    
    /* Set nonmatches to max # of nonmatching stimuli */
    #define nonmatches 0
    
    /* Set nonmatchtim to the amount of time the distractors should display for */
    #define nonmatchtim 150

Once the animal has mastered the task with those variables, start increasing _timdelay_ gradually, making sure the animal does each step successfully, until finally arriving at a 500ms delay.

Next, start introducing nonmatching stimuli by changing _nonmatches_ to 1.  Once the monkey can do that, _nonmatchtim_ should be increased until it reaches 500.

Finally, increase _nonmatches_ to 2.

### Final Task [[CORTEX Files](https://github.com/BuffaloLab/BehavioralTasks/tree/master/DMS/Final%20Task)] [[BMP Stimuli](http://research.yerkes.emory.edu/Buffalo/Repository%20Files/Stimuli/DMS%20Stimuli.zip)]
The CORTEX files for the final version of DMS are [here](https://github.com/BuffaloLab/BehavioralTasks/tree/master/DMS/Final%20Task)

The stimuli needed for all of the ITM files are packaged [here](http://research.yerkes.emory.edu/Buffalo/Repository%20Files/Stimuli/DMS%20Stimuli.zip)


### Analysis [[Files](https://github.com/BuffaloLab/BehavioralTasks/tree/master/DMS/Analysis)]
The following are MATLAB analysis scripts to run on raw CORTEX behavioral data:
* [dmsplot](https://github.com/BuffaloLab/BehavioralTasks/blob/master/DMS/Analysis/dmsplot.m) - Provides bar graphs for a chosen monkey's percent accuracy, percent early, percent break fixation, and percent late for each session in a given a timespan.
* [dmsplotnm](https://github.com/BuffaloLab/BehavioralTasks/blob/master/DMS/Analysis/dmsplotnm.m) - Provides bar graphs for a chosen monkey's percent accuracy and percent early _by number of distractors_ for each session in a given timespan.