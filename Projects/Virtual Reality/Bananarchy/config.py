####################################################
####################################################
#####################BANANARCHY#####################
##############Written by Kiril Staikov##############
####################################################
####################################################

training = 5.2

nidaq = 1


from random import uniform
import sys
import platform

##########################
# Core PandaEPL settings.#
##########################

FOV = 60

# Movement.
linearAcceleration  = 30
if int(training) >= 3:
        fullForwardSpeed = 2.8
else:
        fullForwardSpeed    = 0
fullBackwardSpeed   = 0
turningAcceleration = 130
if training == 3.1:
        fullTurningSpeed = 0
elif training >= 2:
        fullTurningSpeed    = 55
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
if sys.platform.startswith('win'):
        instructFont = '/c/WINDOWS/Fonts/times.ttf'
        if platform.release()=='7':
                instructFont = '/c/Windows/Fonts/times.ttf'
elif sys.platform.startswith('linux'):
        instructFont = '/usr/share/fonts/truetype/freefont/FreeSans.ttf'
#instructFont    = '/usr/share/fonts/truetype/freefont/FreeSans.ttf';  #Linux
#instructFont    = '/c/Windows/Fonts/times.ttf';                      # Windows 7
#instructFont    = '/c/WINDOWS/Fonts/times.ttf';                 #Windows XP
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
windmillModel = './models/windmill/amill.bam'
windmillLoc = Point3(13, -13, 0)
windmillScale = .2
windmillH = 45


# Some reward pump parameters.
alignmentReward = 0 # Reward for initial alignment? Yes(1) or No(0)
pulseInterval = 200 # in ms
if int(training) == 2:
        numBeeps = 40 # Number of pulses/beeps in typical reward sequence
else:
        numBeeps = 3

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
eotEffect = 0 #Signify the End of Trial with fog effect? 1= yes; 0=no.
eotEffectSpeed = 17 #ms per 1/70th fog density change.

# Email Info
emailNotifications = 0 # 1 = yes; 0 = no.
emailServer = 'smtp.gmail.com:465'
emailUsername = 'monkeyjn9'
emailPassword = 'MonkeyLabGiz'
emailFrom = 'Giuseppe Buffalo <monkeyjn9@gmail.com>'
emailTo = ['kstaikov@gmail.com', 'drewsolyst@gmail.com']
subject = 'Giz Log'
