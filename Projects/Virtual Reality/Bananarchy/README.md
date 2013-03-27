## BANANARCHY
### Training Steps
Change the 'training' variable at the top of the config file to set the task to any one of the following training steps:

0 = Final Task [BROKEN].

1.x = Left-Right Training.  No background.  Crosshairs in center of screen, and banana appears on left or right of crosshairs.  Subject has to push joystick to right or left to align the crosshairs with the banana.  Once the crosshairs hit the banana, the position is locked in place until all the reward is dispensed.  Then the tasks restarts with the banana in a new random location.
* 1.1 = Left only. [Perhaps need to add a variable to control max distance, and vary within that.  That's what increaseDistance and decreaseDistance should do.]
* 1.2 = Right only. [Perhaps need to add a variable to control max distance, and vary within that.  That's what increaseDistance and decreaseDistance should do.]
* 1.3 = Both, randomized location and distance.

2.x = Continuation of the left-right training in 1.x.  When the crosshairs align wih the target, some reward is dispensed, but the positions don't lock in and the crosshairs are allowed to leave the target, at which point reward stops being dispensed, until the crosshairs and target are aligned again.  The goal is to get the animal to leave the crosshairs 
* 2.1 = The window within which the crosshair has to fall is fairly large

3.x = Introducing forward movement. 
* 3.1 = Start out with banana centered, just go forward to get reward.
* 3.2 = Left-right to banana, with crosshairs on it, then go forward to get rewarded again. Forward movement is blocked until crosshair turns blue.  When crosshairs hit banana, further turning is blocked. Only forward movement is allowed.
* 3.3 = Require him to stop on his own on the banana.  As soon as he moves forward a bit, left and right turning is blocked, only more forward movement is allowed.    He is rewarded up to 6 beeps at a time for turning until the crosshairs are blue, and then he can only get more reward by actually going up to the banana.

4.x = Introducing the environment. 
* 4.0 = Starts off the same place as 3.3. Except the background is present and there is a massive, and very dense fog over it.  Press F to remove the fog and eluminate the environment/backround little by little.
* 4.1 = Remove the block for turning after he moves forward.
* 4.2 = Allow forward movement even when he's not with a blue cross.
* 4.25 = Remove FOV rays blocking turning.
* 4.3 = At beginning of new trial, face same direction as end of previous one. FOV rays blocking turning still on.
* 4.35 = Remove FOV rays blocking turning from 4.3.

5.x = More bananas come in.
* 5.1 = Same as 4.25, except now there are multiple bananas that he has to go around and pick up.  Position resets to the center and faces the original 0-header position after gathering each batch of bananas.
* 5.2 = A given number of bananas appear on the field and you have to go gather them all, then a new set appears.  Position doesn't reset, neither does header direction.

### To Do

Structural additions and improvements:
* Set emails to send out one message (constructed throughout a trial) only between trials.
* Add other 3D objects/models to the environment.
* A separate nidaq class should be made, akin to the EEG class.
* Get a higher quality banana
* Setup to use the rays as much as possible and maybe avoid having to do the whole clunky trig calculations for the training steps < 4.0
* Make a GUI!
* OS detection for font directory.
* Real stereo 3D.
* Eyetracker and sync-pulsing interface!!!!!!
* Work on the logging!
* Perhaps some of the tasks don't need the inputEvent argument??
* Solve possible bug where the maximum turning speed suddenly gets stuck at 0 or fails to be set to actual full speed.
* Remove backface culling for the Bananas??  Would that do anything? Is there texture on the inside??
* Use Intervals (perhaps for banana rotation) and event handling where appropriate.

Make code prettier:
* Figure out what to do with the window sizes for each training step, the speeds, distances, etc.  
* Use assignment operators where possible
* Use modulus if it would improve anything.
* Use words for the logical operators for the sake of readability.
* Use membership operators where possible, if they would improve anything.
* Make if statements more readable by by starting new line after each conditional
* Write method to initialize / import all config variables.

### Changelog

Version 0.3.2:
* Adjusted to use only one banana, instead of unnecessarily using 3 in the code.
* Added 4.1, to remove the block on turning once the avatar has moved forward a bit.

Version 0.3.3:
* Added framework for email updates.
* Added a palm tree to the field.

Version 0.3.4:
* Made NI-Daq use optional for testing purposes on computers with no nidaq.  However, at this point, it is necessary to also comment out the 'nidaq = ctypes.windll.nicaiu' line at the top of the main bananarchy file to ignore the nidaq.  It is not enough to just change the variable in the config file to 0.
* The banana now rotates!
* Implemented collision rays instead of doing all the angle/header calculations.
* Added Training 4.2
* Added option to visualize collisions with the collision rays.
* Added option to change FOV boundary ray vectors on the fly.
* Training steps < 4.0 are broken now due to the collision rays.  Line 485 is where the problem happens here.  Probably there is more to it.
* Training 3.1 fixed.
* Added system beep bell character as non-nidaq alternative reward.

Version 0.3.5:
* Added ability to change maxFwDistance on the fly.
* Added ability to change the max turning speed on the fly.
* Added ability to change minFwDistance on the fly.
* Added training step 4.25, removing the fov Rays.
* Added training 4.3, 4.35, and 5.1
* Fixed the cross centering problem and now crosshair size can be changed on the fly.
* Change crosshair transparency/alpha on the fly and in config file.
* Added no beeps option!
* Other little things probably.  Possible some past things are broken.
* Fine-tuned pump output settings to pump more food per pulse, etc.

Version 0.4.0
* Mouse cursor now disappears.  Window title is 'Bananarchy'.
* Reorganized and cleaned up module imports.
* Created little icon and shortcuts.
* Bananas spin in opposing directions, and different phases.
* Solved the goddamn off-screen collision issue.
* Fine-tuned various parameters here and there.
* Changed the way ray collisions are checked and processed a little bit.
* Created division between 5.1 and 5.2 (5.1 different from in the last version.  5.2 = previous 5.1.
* Added option to replenish bananas.
* Added fog effect to signify end of trial and the arrival of new bananas.
* Added option for last banana in trial to get double reward.
* Made field smaller.  Added streetlight and skyscraper.

03/27/2013:
* Automatic OS detection for font directory selection
* fixed skyscraper textures

