##      HELP ME WITH MY APP AND RESTORE MY FAITH IN THE AMERICAN DREAM
##
##              A lot of jerks sleepwalk through life. They think they don't have
##      any good ideas, so they take the easy way out: a paycheck, a mortgage,
##      and retired at 85 if they're lucky.
##              Do you know what a human brain is? It is a lightning rod for million dollar ideas.
##      Most people are too numb to know when they've got 50,000 volts of idea going through them.
##      My rod is extra long; I have maybe 10 of these ideas a day. But I'm going to let you in on
##      the granddaddy of them all:
##
##              Bananarchy.
##
##              I've got about every cent to my name tied up in Bananarchy right now. All I need is
##      a little help from you (a programmer or coder) to get it off the ground.  Two months ago I got
##      laid off and nobody would hire me because all my experience was with the old kind of fork lift.
##      Nobody would take a chance on teaching an old dog a new trick.  I didn't want my family to see
##      or look at me until I was already pretty successful, so I moved out into the garage. I spent my
##      new-found free time trying to put some of that lightning into the proverbial bottle. Extended-wear
##      fragrances. Hot Pocket pockets. Pretend skunks for camping. Wacky Sacks. All the ideas were great
##      but there was always some fatal flaw or catch. Pretty soon I wasn't taking care of myself at all.
##              Recently I was startled. I woke up to find myself already laughing at how my troubles were over.
##      Laughing super hard at how simple and obvious Bananarchy was in retrospect. I pulled into the
##      garage and parked the car but I still couldn't stop laughing; It was an enormous release for me.
##      My wife came in to check on me. I thought maybe she wanted me to quiet down, but she was looking
##      for the bread maker. I told her I would buy her five bread makers when my idea took off, but, for
##      now, I had burned it for warmth. She wanted to know my idea. I asked her whether she had ever heard
##      of a little app called "Angry Birds" and raised my eyebrows a little. She had. I nodded and then
##      mouthed "Bananarchy, baby." I don't think she understood me and she seemed to want me to say
##      something else. After what I would call four or five seconds she asked me for a divorce. I say
##      good riddance to bad rubbish; pretty soon I'll be able to afford FIVE divorces.
##              Reader, that is where you come in. I have already done all the legwork; the name of the app is
##      Bananarchy. Message me if you want to design the app.  I can't pay you, but I can probably get
##      you a free download, if the appstore has an option for that.  Also, please on the title screen
##      make the name "Bananarchy" squeeze out of a peel after a clown slips on it.
##              I will respond to applications in the order I receive them.
##
##      No SpAm oR bOtS!

####################################################
####################################################
#####################BANANARCHY#####################
##############Written by Kiril Staikov##############
####################################################
####################################################
#TO DO:
#------------

#1.) Figure out what to do with the window sizes for each training step, the speeds, distances, etc.  
#2.) Use assignment operators where possible
#3.) Use modulus if it would improve anything.
#4.) Use words for the logical operators for the sake of readability.
#5.) Use membership operators where possible, if they would improve anything.
#6.) Make if statements more readable by by starting new line after each conditional


#10.) Write method to initialize / import all config variables.
#11.) Set emails to send out one message (constructed throughout a trial) only between trials.
#12.) Add other 3D objects/models to the environment.
#13.) A separate nidaq class should be made, akin to the EEG class.
#14.) Get a higher quality banana
#---  Setup to use the rays as much as possible and maybe avoid having to do the whole clunky trig
#     calculations for the training steps < 4.0
#---  Make a GUI!
#---  OS detection for font directory.
#---  Write a batch file that opens the config and everything?  Or even a batch file instead of shortcut.
#---  Real stereo 3D.
#---  Eyetracker and sync-pulsing interface!!!!!!
#---  Work on the logging!
#---  Perhaps some of the tasks don't need the inputEvent argument??
#---  Solve possible bug where the maximum turning speed suddenly gets stuck at 0 or fails to be set to
#     actual full speed.
#---  Remove backface culling for the Bananas??  Would that do anything? Is there
#     texture on the insie??
#---  Use Intervals (perhaps for banana rotation) and event handling where appropriate.

#============================================================================================================
#Version 0.3.2 Changelog
#-------------
#1) Adjusted to use only one banana, instead of unnecessarily using 3 in the code.
#2) Added 4.1, to remove the block on turning once the avatar has moved forward a bit.
#============================================================================================================
#Version 0.3.3 Changelog
#1) Added framework for email updates.
#   -Added email updates for the fogScheme
#   -Notification email for when new session begins.
#2) Added a palm tree to the field.
#============================================================================================================
#Version 0.3.4 Changelog
#1) Made NI-Daq use optional for testing purposes on computers with no nidaq.  However,
#   at this point, it is necessary to also comment out the 'nidaq = ctypes.windll.nicaiu' line
#   at the top of the main bananarchy file to ignore the nidaq.  It is not enough to just change
#   the variable in the config file to 0.
#2) The banana now rotates!
#3) Implemented collision rays instead of doing all the angle/header calculations.
#4) Added Training 4.2
#5) Added option to visualize collisions with the collision rays.
#6) Added option to change FOV boundary ray vectors on the fly.
#7) Training steps < 4.0 are broken now due to the collision rays.  Line 485 is where the problem
#   happens here.  Probably there is more to it.
#8) Training 3.1 fixed.
#9) Added system beep bell character as non-nidaq alternative reward.
#============================================================================================================
#Version 0.3.5 Changelog
#1) Added ability to change maxFwDistance on the fly.
#2) Added ability to change the max turning speed on the fly.
#3) Added ability to change minFwDistance on the fly.
#4) Added training step 4.25, removing the fov Rays.
#5) Added training 4.3, 4.35, and 5.1
#6) Fixed the cross centering problem and now crosshair size can be changed on the fly.
#6) Change crosshair transparency/alpha on the fly and in config file.
#7) Added no beeps option!
#8) Other little things probably.  Possible some past things are broken.
#9) Fine-tuned pump output settings to pump more food per pulse, etc.
#============================================================================================================
#Version 0.4.0 Changelog
#1) Mouse cursor now disappears.  Window title is 'Bananarchy'.
#2) Reorganized and cleaned up module imports.
#3) Created little icon and shortcuts.
#4) Bananas spin in opposing directions, and different phases.
#5) Solved the goddamn off-screen collision issue.
#6) Fine-tuned various parameters here and there.
#7) Changed the way ray collisions are checked and processed a little bit.
#8) Created division between 5.1 and 5.2 (5.1 different from in the last version.  5.2 = previous 5.1.
#9) Added option to replenish bananas.
#10) Added fog effect to signify end of trial and the arrival of new bananas.
#11) Added option for last banana in trial to get double reward.
#============================================================================================================


#Training Steps? 
#  0 = Final Task [BROKEN].
#
#1.x = Left-Right Training.  No background.  Crosshairs in center of screen,
#      and banana appears on left or right of crosshairs.  Subject has to
#      push joystick to right or left to align the crosshairs with the
#      bannaa.  Once the crosshairs hit the banana, the position is locked in place
#      until all the reward is dispensed.  Then the tasks restarts with the banana
#      in a new random location.
#1.1 = Left only. [Perhaps need to add a variable to 
#      control max distance, and vary within that.  That's what
#      increaseDistance and decreaseDistance should do.]
#1.2 = Right only. [Perhaps need to add a variable to 
#      control max distance, and vary within that.  That's what
#      increaseDistance and decreaseDistance should do.]
#1.3 = Both, randomized location and distance.
#
#2.x = Continuation of the left-right training in 1.x.  When the crosshairs
#      align wih the target, some reward is dispensed, but the positions
#      don't lock in and the crosshairs are allowed to leave the target, at
#      which point reward stops being dispensed, until the crosshairs and
#      target are aligned again.  The goal is to get the animal to leave
#      the crosshairs 
#2.1 = The window within which the crosshair has to fall is fairly large
#      Window to Left of Banana = 4; Right = 6.  They are different for technical
#      reasons I won't go into here.
#2.2 = Left = 3; Right = 5.
#2.3 = Left = 2; Right = 4.
#2.4 = Left = 1; Right = 3;
#2.5 = Left = 1; Right = 2; This is the final window.
#
#3.x = Introducing forward movement. 
#3.1 = Start out with banana centered, just go forward to get reward.
#3.2 = Left-right to banana, with crosshairs on it, then go forward to get rewarded again.
#      Forward movement is blocked until crosshair turns blue.  When crosshairs hit banana,
#      further turning is blocked.  Only forward movement is allowed.
#3.3 = Require him to stop on his own on the banana.  As soon as he moves forward a bit,
#      left and right turning is blocked, only more forward movement is allowed.    He is
#      rewarded up to 6 beeps at a time for turning until the crosshairs are blue, and then
#      he can only get more reward by actually going up to the banana.
#
#4.x = Introducing the environment. 
#4.0 = Starts off the same place as 3.3. Except the background is present and there is a massive,
#      and very dense fog over it.  Press F to remove the fog and eluminate the environment/backround
#      little by little.
#4.1 = Remove the block for turning after he moves forward.
#4.2 = Allow forward movement even when he's not with a blue cross.
#4.25 = Remove FOV rays blocking turning.
#4.3 = At beginning of new trial, face same direction as end of previous one. FOV rays blocking turning still on.
#4.35 = Remove FOV rays blocking turning from 4.3.
#
#5.x = More bananas come in.
#5.1 = Same as 4.25, except now there are multiple bananas that he has to go around and pick up.  Position
#      resets to the center and faces the original 0-header position after gathering each batch of bananas.
#5.2 = A given number of bananas appear on the field and you have to go gather them all,
#      then a new set appears.  Position doesn't reset, neither does header direction.


training = 5.2

nidaq = 0


from random import uniform

##########################
# Core PandaEPL settings.#
##########################

FOV = 60

# Movement.
linearAcceleration  = 30
if int(training) >= 3:
        fullForwardSpeed = 2.7
else:
        fullForwardSpeed    = 0
fullBackwardSpeed   = 0 
turningAcceleration = 50
if training == 3.1:
        fullTurningSpeed = 0
elif training >= 2:
        fullTurningSpeed    = 35
else:
        fullTurningSpeed = 200
turningLinearSpeed  = 2 # Factor

maxTurningLinearSpeed          = 90.0
minTurningLinearSpeedReqd      = 1.0
minTurningLinearSpeed          = 1.5
minTurningLinearSpeedIncrement = 0.5 

initialPos   = Point3(0, 0, 1)
avatarRadius = .3
cameraPos    = Point3(0, 0, 0)
friction     = .4
movementType = 'walking' # car | walking

# Instructions.
instructSize    = 0.3
#instructFont    = '/usr/share/fonts/truetype/freefont/FreeSans.ttf';  #Linux
#instructFont    = '/c/Windows/Fonts/times.ttf';                      # Windows 7
instructFont    = '/c/WINDOWS/Fonts/times.ttf';                 #Windows XP
instructBgColor = Point4(0, 0, 0, 1)
instructFgColor = Point4(1, 1, 1, 1)
instructMargin  = 0.06
instructSeeAll  = False

################################
# Experiment-specific settings.#
################################

# Crosshair
xHairAlpha = 0

# Bananas.
bananaDir  = './models/bananas/'
bananaZ    = 1
bananaScale = .5
bananaRotation = 1 # Rotation speed in degrees/frame.
bananaLocs = []
numBananas = 10
bananaReplenishment = 0 #Bananas replenish after eating
                        #this many bananas.
lastBananaBonus = 1 #Double the reward for the last banana in trial. 1=Yes; 0 = No.

########## Position ################

minDistance = -5
maxDistance = 5
minFwDistance = -5
maxFwDistance = 5
fwDistanceIncrement = .1

for i in range(0, numBananas):
	x = uniform(minDistance, maxDistance)
	y = uniform(minFwDistance, maxFwDistance)
	bananaLocs.append([x, y, 90])

if (training > 0) and (training < 5):
	numBananas = 1
	distance = .15
	bananaLocs[0] = [initialPos[0] - distance, initialPos[1] + 2, 90]


targetRayWindow = .45
fovRayVecX = 30

# Target header window, to the left and right
if (training > 2) & (training < 2.5):
        targetHwinL = 4 - (((training - 2) * 10) - 1)
        targetHwinR = 4 - (((training - 2) * 10) - 1)
else:
        targetHwinL = 2 #1.2 is sort of the boundary.
        targetHwinR = 2 #1.2 is sort of the boundary.

# Terrain, sky.
terrainModel  = './models/towns/field.bam'
terrainCenter = Point3(0,0,0)
skyModel      = './models/sky/sky.bam'
skyScale      = 1.6
treeModel     = './models/trees/palmTree.bam'
treeLoc       = Point3(13, 13, 0)
treeScale     = .0175
skScraperModel= './models/skyscraper/skyscraper.bam'
skScraperLoc  = Point3(-13, -13, 0)
skScraperScale= .3
strtLightModel= './models/streetlight/streetlight.bam'
strtLightLoc  = Point3(-13, 13, 0)
strtLightScale= .75


# Some reward pump parameters.
alignmentReward = 0 # Reward for initial alignment? Yes(1) or No(0)
pulseInterval = 200 # in ms
if int(training) == 2:
        numBeeps = 40 # Number of pulses/beeps in typical reward sequence
else:
        numBeeps = 6

# (Non-default) command keys.
keyboard = Keyboard.getInstance()
keyboard.bind("exit", ["escape", "q"])
keyboard.bind("toggleDebug", ["escape", "d"])
keyboard.bind("left", "l")
keyboard.bind("right", "r")
keyboard.bind("restart", "y")
keyboard.bind("center", "m")
keyboard.bind("increaseDist", "i")
keyboard.bind("decreaseDist", "d")
keyboard.bind("upTurnSpeed", "t")
keyboard.bind("downTurnSpeed", "g")
keyboard.bind("decreaseXHairSize", "x")
keyboard.bind("increaseXHairSize", "z")
keyboard.bind("decreaseXHairAlpha", "a")
keyboard.bind("increaseXHairAlpha", "s")

if int(training) >= 4:
        keyboard.bind("toggleFog", "f")
        keyboard.bind("decreaseFog", "v")
        keyboard.bind("increaseFovRay", "q")
        keyboard.bind("decreaseFovRay", "w")
        keyboard.bind("toggleCollisionView", ["escape", "c"])
        keyboard.bind("increaseMaxFwDistance", "p")
        keyboard.bind("decreaseMaxFwDistance", "o")
        keyboard.bind("increaseMinFwDistance", "k")
        keyboard.bind("decreaseMinFwDistance", "j")

joystick = Joystick.getInstance()
joystick.bind("toggleDebug", "joy_button0")

# Fog.
initialFogScheme  = 0
expFogColor       = Point3(0.4,0.4,0.4)
expFogDensity     = 1
eotEffect = 1 #Signify the End of Trial with fog effect? 1= yes; 0=no.
eotEffectSpeed = 17 #ms per 1/70th fog density change.

# Email Info
emailNotifications = 0 # 1 = yes; 0 = no.
emailServer = 'smtp.gmail.com:465'
emailUsername = 'monkeyjn9'
emailPassword = 'MonkeyLabGiz'
emailFrom = 'Giuseppe Buffalo <monkeyjn9@gmail.com>'
emailTo = ['kstaikov@gmail.com', 'drewsolyst@gmail.com']
subject = 'Giz Log'
