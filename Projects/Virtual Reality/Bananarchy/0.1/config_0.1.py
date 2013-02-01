#Training Steps? 
training = 0	#0 = Final Task; 1 = Directional Training

from random import uniform

##########################
# Core PandaEPL settings.#
##########################

FOV = 60

# Movement.
linearAcceleration  = 20
fullForwardSpeed    = 5
fullBackwardSpeed   = -5 
turningAcceleration = 25
fullTurningSpeed    = 25
turningLinearSpeed  = 0.25 # Factor

maxTurningLinearSpeed          = 5.0
minTurningLinearSpeedReqd      = 1.0
minTurningLinearSpeed          = 1.5
minTurningLinearSpeedIncrement = 0.5 

initialPos   = Point3(0, 0, 0.5)
avatarRadius = 0.5
cameraPos    = Point3(0, 0, 0.5)
friction     = .4
movementType = 'walking' # car | walking

# Instructions.
instructSize    = 0.075
#instructFont    = '/usr/share/fonts/truetype/freefont/FreeSans.ttf';  #Linux
instructFont    = '/c/Windows/Fonts/times.ttf';                      # Windows
instructBgColor = Point4(0, 0, 0, 1)
instructFgColor = Point4(1, 1, 1, 1)
instructMargin  = 0.06
instructSeeAll  = False

################################
# Experiment-specific settings.#
################################

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

if training == 1:
	numBananas = 3
	bananaLocs[0] = [initialPos[0] - 1.15, initialPos[1] + 2, 90]
	bananaLocs[1] = [initialPos[0], initialPos[1] + 2, 90]
	bananaLocs[2] = [initialPos[0] + 1.15, initialPos[1] + 2, 90]
	
# Terrain, sky.
terrainModel  = './models/towns/final.bam'
terrainCenter = Point3(0,0,0)
skyModel      = './models/sky/sky.bam'
skyScale      = 1.6

# Heads-up display.
scorePos   = Point3(0.83,0,1)
scoreSize  = 0.1
scoreColor = Point4(1,0,0,1)
scoreDecrementInterval = 150 # in ms

assignmentPos   = Point3(-1,0,1)
assignmentSize  = 0.1
assignmentColor = Point4(1,0,0,1)

# (Non-default) command keys.
keyboard = Keyboard.getInstance()
keyboard.bind("exit", ["escape", "q"])
keyboard.bind("toggleDebug", ["escape", "d"])
keyboard.bind("left", "l")
keyboard.bind("right", "r")
keyboard.bind("restart", "y")
keyboard.bind("center", "c")

joystick = Joystick.getInstance()
joystick.bind("toggleDebug", "joy_button0")
