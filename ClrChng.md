This task requires the animal to hold the bar for a little gray square to appear.  It must continue to hold the bar until the gray square turns yellow, at which point it must release the bar to get a reward.  This task is used to do eyetracking calibration once the animal is headposted, but it is also a very simple task that all animals learn in early training.

### Training [[Files](https://github.com/BuffaloLab/BehavioralTasks/tree/master/ClrChng/Training)]

As they are, the files give you the very first training step, with these initial values for key variables:
* The ITI is set to 150ms.
* The grey square is displayed for a variable time of 150 to 300ms.
* The yellow square / max response time allowed is set to 1500ms.
* The squares have a 6 degree height and width.

Once the animal has mastered these settings, change each variable gradually, waiting with each change for the animal has mastered it, until finally the monkey can successfully do these final settings:
* ITI = 1000ms
* Grey = 500-150ms
* Yellow / Response Time = 500ms
* Square = .3 height and width

The ITI, grey square time, and yellow-square/response-time can be edited at the top of the .TIM file:

    /* Set min and max time for duration of grey square on screen in milliseconds */
    #define mintim 150
    #define maxtim 300
    
    /* Set ITI duration in milliseconds */
    #define ititim 150
    
    /* Set duration of yellow square on screen / time animal has to respond in milliseconds */
    #define maxrsptim 1500

The square size, however, must be edited in the .ITM file by changing the height and width of items #1-3 from 6.0 to whatever size is desired.

### Final Task [[Files](https://github.com/BuffaloLab/BehavioralTasks/tree/master/ClrChng/Final%20Task/)]
There are three variations of the final task:

* [ClrChng](https://github.com/BuffaloLab/BehavioralTasks/tree/master/ClrChng/Final%20Task/ClrChng) - In this version, the square appears at a random different location on the screen every trial.
* [ClrCalTL](https://github.com/BuffaloLab/BehavioralTasks/tree/master/ClrChng/Final%20Task/ClrCalTL) - Allows you to use the numerical keypad to control the location of where the next stimulus will appear on the screen.  This is very useful for calibrating a headposted monkey's eyetracking, and is used daily for that purpose.
* [ClrCal] (https://github.com/BuffaloLab/BehavioralTasks/tree/master/ClrChng/Final%20Task/ClrCal) - the same as ClrCalTL, but the stimuli don't go out as far.  We only use this on Cortex Computer #2 for calibrating because it has some issues with the regular ClrCalTL.

### Analysis [[Files](https://github.com/BuffaloLab/BehavioralTasks/tree/master/ClrChng/Analysis)]
The following are analysis scripts run on raw behavioral data from ClrChng:
* [reactiontime](https://github.com/BuffaloLab/BehavioralTasks/blob/master/ClrChng/Analysis/reactiontime.m) - This script plots the animal's reaction times to the stimulus throughout a chosen session.

