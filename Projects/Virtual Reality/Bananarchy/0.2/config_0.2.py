####################################################
####################################################
#####################BANANARCHY#####################
##############Written by Kiril Staikov##############
####################################################
####################################################
#
#Training Steps? 
#  0 = Final Task [Currently broken because of the training additions,
#      small changes necessary to get it working agian].
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
#3.x = Introducing forward movement. [SUGGESTED]
#3.1 = Start out with banana centered, just go forward to get reward.
#3.2 = Left-right to banana, with crosshairs on it, then go forward to get rewarded again.
#      Possibly restricting the wrong movement when a certain one is required.


training = 1.1

from random import uniform

##########################
# Core PandaEPL settings.#
##########################

FOV = 60

# Movement.
linearAcceleration  = 20
fullForwardSpeed    = 0
fullBackwardSpeed   = 0 
turningAcceleration = 30
if training >= 2:
        fullTurningSpeed    = 10
else:
        fullTurningSpeed = 90
turningLinearSpeed  = 2 # Factor

maxTurningLinearSpeed          = 90.0
minTurningLinearSpeedReqd      = 1.0
minTurningLinearSpeed          = 1.5
minTurningLinearSpeedIncrement = 0.5 

initialPos   = Point3(0, 0, 0.5)
avatarRadius = 0.5
cameraPos    = Point3(0, 0, 0.5)
friction     = .4
movementType = 'walking' # car | walking

################################
# Experiment-specific settings.#
################################
# Font
textFont = '/c/Windows/Fonts/times.ttf' # Used for the crosshairs plus sign

# Bananas.
bananaDir  = './models/bananas/'
bananaZ    = 1
bananaScale = .5
bananaLocs = []
numBananas = 100
for i in range(0, numBananas):
	x = uniform(-12, 12)
	y = uniform(-15.5, 15.5)
	bananaLocs.append([x, y, 90])

if training > 0:
	numBananas = 3
	distance = .15
	bananaLocs[0] = [initialPos[0] - distance, initialPos[1] + 2, 90]
	bananaLocs[1] = [initialPos[0], initialPos[1] + 2, 90]
	bananaLocs[2] = [initialPos[0] + distance, initialPos[1] + 2, 90]

# Target header window, to the left and right
if (training > 2) & (training < 2.5):
        targetHwinL = 4 - (((training - 2) * 10) - 1)
        targetHwinR = 6 - (((training - 2) * 10) - 1)
else:
        targetHwinL = 1
        targetHwinR = 2

# Terrain, sky.
terrainModel  = './models/towns/final.bam'
terrainCenter = Point3(0,0,0)
skyModel      = './models/sky/sky.bam'
skyScale      = 1.6

# Some reward pump parameters.
pulseInterval = 150 # in ms
numBeeps = 20 # Number of pulses/beeps in typical reward sequence

# (Non-default) command keys.
keyboard = Keyboard.getInstance()
keyboard.bind("exit", ["escape", "q"])
keyboard.bind("toggleDebug", ["escape", "d"])
keyboard.bind("left", "l")
keyboard.bind("right", "r")
keyboard.bind("restart", "y")
keyboard.bind("center", "c")
keyboard.bind("increaseDist", "i")
keyboard.bind("decreaseDist", "d")

joystick = Joystick.getInstance()
joystick.bind("toggleDebug", "joy_button0")
