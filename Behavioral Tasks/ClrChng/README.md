##ClrChng
This task requires the animal to hold the bar for a little gray square to appear.  It must continue to hold the bar until the gray square turns yellow, at which point it must release the bar to get a reward.  This task is used to do eyetracking calibration once the animal is headposted, but it is also a very simple task that all animals learn in early training.

### Training [[Files](./Behavioral Tasks/ClrChng/Training)]
Check the README in the training files for detailed instructions on training the animal.

### Final Task [[Files](Final Task)]
There are three variations of the final task:

* [ClrChng](Final Task/ClrChng) - In this version, the square appears at a random different location on the screen every trial.
* [ClrCalTL](Final Task/ClrCalTL) - Allows you to use the numerical keypad to control the location of where the next stimulus will appear on the screen.  This is very useful for calibrating a headposted monkey's eyetracking, and is used daily for that purpose.
* [ClrCal] (Final Task/ClrCal) - the same as ClrCalTL, but the stimuli don't go out as far.  We only use this on Cortex Computer #2 for calibrating because it has some issues with the regular ClrCalTL.

### Analysis [[Files](Analysis)]
The following are analysis scripts run on raw behavioral data from ClrChng:
* [reactiontime](Analysis/reactiontime.m) - This script plots the animal's reaction times to the stimulus throughout a chosen session.


