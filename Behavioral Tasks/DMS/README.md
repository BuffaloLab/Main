## Delayed Match to Sample (DMS)

In our version of the Delayed Match-to-Sample (DMS) task, the animal has to hold the touch-bar and fixate in the center of the screen for a sample picture to appear.  Then the animal has to continue holding the bar and fixating in the center of the screen.  In the meantime, between 0 and 4 images that are different from the sample (distractors) may appear in succession, until an image identical to the sample picture displays (the matching picture).  Then the animal has to release the bar when the matching image appears to receive reward and for the trial to be marked as 'correct'.
 
### Training [[Files](https://github.com/BuffaloLab/BehavioralTasks/tree/master/DMS/Training)]
Check the README in the linked files for detailed instructions on training the animal.

### Final Task [[Files](https://github.com/BuffaloLab/BehavioralTasks/tree/master/DMS/Final%20Task)] 

### Variations [[Files](https://github.com/BuffaloLab/BehavioralTasks/tree/master/DMS/Variations)]
* [Trial-Unique DMS](https://github.com/BuffaloLab/BehavioralTasks/tree/master/DMS/Variations/Trial-Unique%20DMS) - Each trial has its own totally novel set of images that the animal has never seen before.

### Analysis [[Files](https://github.com/BuffaloLab/BehavioralTasks/tree/master/DMS/Analysis)]
The following are MATLAB analysis scripts to run on raw CORTEX behavioral data:
* [dmsplot](https://github.com/BuffaloLab/BehavioralTasks/blob/master/DMS/Analysis/dmsplot.m) - Provides bar graphs for a chosen monkey's percent accuracy, percent early, percent break fixation, and percent late for each session in a given a timespan.
* [dmsplotnm](https://github.com/BuffaloLab/BehavioralTasks/blob/master/DMS/Analysis/dmsplotnm.m) - Provides bar graphs for a chosen monkey's percent accuracy and percent early _by number of distractors_ for each session in a given timespan.