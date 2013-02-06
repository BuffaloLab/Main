####################################################
####################################################
#####################BANANARCHY#####################
##############Written by Kiril Staikov##############
####################################################
####################################################

from pandaepl.common import *
import os
from numpy import *
import numpy
import ctypes
nidaq = ctypes.windll.nicaiu
import time
import random

class bananarchy:

    def __init__(self):
        """
        Initialize the experiment.
        """
        
        exp = Experiment.getInstance() #Get experiment instance.        
        vr = Vr.getInstance() #Get VR environment object.

        # Set Session# to +1 the # of sessions the subject has data for so far. 
	if not os.access(exp.getExpDirectory(), os.F_OK):
	        exp.setSessionNum(0)
	else:
		i = 0
		while os.access(exp.getExpDirectory() + '/session_' + str(i), os.F_OK):
			i = i + 1
		exp.setSessionNum(i) 

        config = Conf.getInstance().getConfig() #Get configuration dictionary.
        avatar = Avatar.getInstance()
        self.nidaqSetup() #Setup the basic NI-DAQ Hardware Controls
        self.loadEnvironment(config) #Load environment.
        
        # Register Custom Log Entries
       	Log.getInstance().addType("YUMMY",[("BANANA",basestring)], False) #This one corresponds to colliding with a banana.
        
        # Create crosshairs around what seems to be the center of the screen
	self.cross = Text("cross", '+', Point3(-.08,0,.1), .3, Point4(1,0,0,1), config['textFont'])
		
        # Register tasks to be performed between frames
        vr.addTask(Task("pumpOut",
                        lambda taskInfo: 
                          self.pumpOut(config), 
                        config['pulseInterval'])) # Outputs pulses to pump when reward is called for.

        vr.addTask(Task("trackHeader", 
                        lambda taskInfo: 
                          self.trackHeader(config, avatar))) # Monitors header position and calls for reward when necessary.
                   
        # Register the handling of keyboard events.
        vr.inputListen("toggleDebug", 
                       lambda inputEvent: 
                         Vr.getInstance().setDebug(not Vr.getInstance().isDebug()))
	vr.inputListen("restart", self.restart)
	if config['training'] > 0:
		vr.inputListen("left", self.left)
		vr.inputListen("center", self.center)
		vr.inputListen("right", self.right)
		vr.inputListen("increaseDist", self.increaseDist)
		vr.inputListen("decreaseDist", self.decreaseDist)

        # Starting banana location
        if ((config['training'] == 1.1) | (random.randrange(0, 2) > 0)) & (config['training'] != 1.2):
            self.left(self)
        else:
            self.right(self)
        
    def nidaqSetup(self):
        """
        Setup basic NI-DAQ hardware controls
        """

        #Set ctypes
        self.int32 = ctypes.c_long
        self.uInt32 = ctypes.c_ulong
        self.uInt64 = ctypes.c_ulonglong
        self.float64 = ctypes.c_double
        self.bool32 = ctypes.c_bool
        self.TaskHandle = self.uInt32

        #Import certain constants defined in the NI-DAQ API header file
        self.DAQmx_Val_Cfg_Default = self.int32(-1)
        self.DAQmx_Val_RSE = 10083
        self.DAQmx_Val_Volts = 10348
        self.DAQmx_Val_Rising = 10280
        self.DAQmx_Val_FiniteSamps = 10178
        self.DAQmx_Val_GroupByChannel = 0
        
        
        #Initialize variables
        self.taskHandle = self.TaskHandle(0)

        #Set some basic variables that control the reward pulses.
        self.Rate = 115
        self.samps = 3
        self.data = numpy.zeros( ( self.samps, ), dtype=numpy.float64 )
        self.beeps = 0   #Beep/Pulse counter
        self.reward = 2  #When set to 1, reward output is triggered.

        #Setup NI-DAQ task
        nidaq.DAQmxCreateTask("",
                ctypes.byref( self.taskHandle ))
        nidaq.DAQmxCreateAOVoltageChan( self.taskHandle,
                                           "Dev1/ao0",
                                           "",
                                           self.float64(3.0),
                                           self.float64(10.0),
                                           self.DAQmx_Val_Volts,
                                           None)
        nidaq.DAQmxCfgSampClkTiming( self.taskHandle,
                                        "",
                                        self.float64(self.Rate),
                                        self.DAQmx_Val_Rising,
                                        self.DAQmx_Val_FiniteSamps,
                                        self.uInt64(self.samps));


        nidaq.DAQmxWriteAnalogF64( self.taskHandle,
                                      self.int32(self.samps),
                                      0,
                                      self.float64(-1),
                                      self.DAQmx_Val_GroupByChannel,
                                      self.data.ctypes.data,
                                      None,
                                      None)        

    def loadEnvironment(self, config):
        """
        Load terrain, sky, and bananas.
        """
        
        if config['training'] == 0:       
            # Load terrain.
            self.terrainModel = Model("terrain", config['terrainModel'], 
                                      config['terrainCenter'])

            # When hitting an object that is part of the terrain, repel or slide?
            self.terrainModel.setCollisionCallback(MovingObject.handleRepelCollision)

            # Load sky.
            self.skyModel = Model("sky", config['skyModel'])
            self.skyModel.setScale(config['skyScale'])


        # Load bananas.
        self.bananaModels = []
        for i in range(0, config['numBananas']):
            bananaModel = Model("banana"+str(i), 
                               os.path.join(config['bananaDir'],"banana"+".bam"),
                               Point3(config['bananaLocs'][i][0], 
                                      config['bananaLocs'][i][1], 
                                      config['bananaZ']),
                               self.collideBanana)
	    bananaModel.setScale(config['bananaScale'])
            self.bananaModels.append(bananaModel)
	    if config['training'] > 0:
		self.bananaModels[i].setStashed(1)

    
    def restart(self, inputEvent):
	'''
	Reload config file, give bananas new locations, make them visible, set new session number
	and return the subject to the original location, with no movement/momentum in any direction.
	'''

	config = config = Conf.getInstance().getConfig()
	for y in range(len(self.bananaModels)):
		self.bananaModels[y].setPos(Point3(config['bananaLocs'][y][0], 
                                     		 config['bananaLocs'][y][1], 
                                     		 config['bananaZ']))
		if config['training'] == 0:
			self.bananaModels[y].setStashed(0)

	Experiment.getInstance().setSessionNum(Experiment.getInstance().getSessionNum() + 1)
        self.cross.setColor(Point4(1, 0, 0, 1))
	avatar = Avatar.getInstance()
	avatar.setLinearAccel(0)
	avatar.setLinearSpeed(0)
	avatar.setTurningSpeed(0)
	avatar.setTurningAccel(0)	
	avatar.setH(0)
	avatar.setPos(Point3(0, 0, 0.5))
	
    def left(self, inputEvent):
	self.bananaModels[1].setStashed(1)
	self.bananaModels[2].setStashed(1)
	if self.bananaModels[0].isStashed() == 0:
		self.bananaModels[0].setStashed(1)
		self.targetHeader = float('nan')
	else:
		self.bananaModels[0].setStashed(0)
                a = self.bananaModels[0].getPos()[0]
                b = self.bananaModels[0].getPos()[1]
                self.targetHeader = rad2deg(arccos(b/sqrt(square(a) + square(b))))


    def center(self, inputEvent):
	self.bananaModels[0].setStashed(1)
	self.bananaModels[2].setStashed(1)
	if self.bananaModels[1].isStashed() == 0:
		self.bananaModels[1].setStashed(1)
	else:
		self.bananaModels[1].setStashed(0)

    def right(self, inputEvent):
	self.bananaModels[0].setStashed(1)
	self.bananaModels[1].setStashed(1)
	if self.bananaModels[2].isStashed() == 0:
		self.bananaModels[2].setStashed(1)
		self.targetHeader = float('nan')
	else:
		self.bananaModels[2].setStashed(0)
                a = self.bananaModels[2].getPos()[0]
                b = self.bananaModels[2].getPos()[1]
                self.targetHeader = -rad2deg(arccos(b/sqrt(square(a) + square(b))))

    def increaseDist(self, inputEvent):
        self.bananaModels[0].setPos(Point3(self.bananaModels[0].getPos()[0] - .05, 2, 1))
        a = self.bananaModels[0].getPos()[0]
        b = self.bananaModels[0].getPos()[1]
        if not self.bananaModels[0].isStashed():
            self.targetHeader = rad2deg(arccos(b/sqrt(square(a) + square(b))))

        self.bananaModels[2].setPos(Point3(self.bananaModels[2].getPos()[0] + .05, 2, 1))
        a = self.bananaModels[2].getPos()[0]
        b = self.bananaModels[2].getPos()[1]
        if not self.bananaModels[2].isStashed():
            self.targetHeader = -rad2deg(arccos(b/sqrt(square(a) + square(b))))

    def decreaseDist(self, inputEvent):
        self.bananaModels[0].setPos(Point3(self.bananaModels[0].getPos()[0] + .05, 2, 1))
        a = self.bananaModels[0].getPos()[0]
        b = self.bananaModels[0].getPos()[1]
        if not self.bananaModels[0].isStashed():
            self.targetHeader = rad2deg(arccos(b/sqrt(square(a) + square(b))))

        self.bananaModels[2].setPos(Point3(self.bananaModels[2].getPos()[0] - .05, 2, 1))
        a = self.bananaModels[2].getPos()[0]
        b = self.bananaModels[2].getPos()[1]
        if not self.bananaModels[2].isStashed():
            self.targetHeader = -rad2deg(arccos(b/sqrt(square(a) + square(b))))
	
    def start(self):
        """
        Start the experiment.
        """

        Experiment.getInstance().start()
        
    def collideBanana(self, collisionInfoList):
        """
        Handle the participant colliding with a banana.
        """
        # ID of the banana the participant collided with.
        banana = collisionInfoList[0].getInto().getIdentifier()

        # Log collision.
        VLQ.getInstance().writeLine("YUMMY", [banana])
            
        # Upon touching banana, repel movement.  Banana disappears.
        MovingObject.handleRepelCollision(collisionInfoList)
	collisionInfoList[0].getInto().setStashed(1)      
        
    def pumpOut(self, config):
        """
        Carry out reward delivery process when self.reward is set to 1.
        """
	#config = Conf.getInstance().getConfig()
        
        if (self.beeps < config['numBeeps']) & (self.reward == 1):
            nidaq.DAQmxStartTask( self.taskHandle )
            nidaq.DAQmxWaitUntilTaskDone( self.taskHandle, self.float64(-1) )
            nidaq.DAQmxStopTask( self.taskHandle )
            self.beeps = self.beeps + 1
        else:                
            self.beeps = 0
            self.reward = 0             
                           
    def trackHeader(self, config, avatar):
        """
        Monitor the header between every frame and perform the relevant
        header-dependent functions.
        """

        hedder = avatar.getH()
        
        #Maintain boundaries to ensure Avatar never rotates so much that banana disappears from screen
        if (self.bananaModels[0].isStashed() == 0) & (-hedder >= (config['FOV']/2 - 1) - abs(self.targetHeader)):
            avatar.setLinearAccel(0)
            avatar.setLinearSpeed(0)
            avatar.setTurningSpeed(0)
            avatar.setTurningAccel(0)
            avatar.setH(hedder+.02)
        elif (self.bananaModels[2].isStashed() == 0) & (hedder >= (config['FOV']/2 - 1) - abs(self.targetHeader)):
            avatar.setLinearAccel(0)
            avatar.setLinearSpeed(0)
            avatar.setTurningSpeed(0)
            avatar.setTurningAccel(0)
            avatar.setH(hedder-.02)

        if (self.bananaModels[0].isStashed() == 0) & (hedder >= (config['FOV']/2 - 1) + self.targetHeader):
            avatar.setLinearAccel(0)
            avatar.setLinearSpeed(0)
            avatar.setTurningSpeed(0)
            avatar.setTurningAccel(0)
            avatar.setH(hedder-.02)
        elif (self.bananaModels[2].isStashed() == 0) & (hedder <= -(config['FOV']/2 - 1) + self.targetHeader):
            avatar.setLinearAccel(0)
            avatar.setLinearSpeed(0)
            avatar.setTurningSpeed(0)
            avatar.setTurningAccel(0)
            avatar.setH(hedder+.02)
            
        #What to do when the current header matches the target header:
        #Reward, make crosshairs blue, and freeze rotation until reward is complete.  Then hide banana, reset position,
        #allow rotation, and present new target banana in random location.
        if (hedder < self.targetHeader + config['targetHwinL']) & (hedder > self.targetHeader - config['targetHwinR']):
            self.reward = 1
            self.cross.setColor(Point4(0, 0, 1, 1))
            if int(config['training']) == 1:
                avatar.setMaxTurningSpeed(0)
            if self.beeps >= config['numBeeps']:
                self.bananaModels[0].setStashed(1)
                self.bananaModels[2].setStashed(1)
                avatar.setH(0)
		if ((config['training'] == 1.1) | (random.randrange(0, 2) < 1)) & (config['training'] != 1.2):
			self.bananaModels[0].setPos(Point3(random.uniform(-.15, -1.15), 2, 1))
			a = self.bananaModels[0].getPos()[0]
		        b = self.bananaModels[0].getPos()[1]
		        self.targetHeader = rad2deg(arccos(b/sqrt(square(a) + square(b))))
			self.bananaModels[0].setStashed(0)
		else: 
			self.bananaModels[2].setPos(Point3(random.uniform(.15, 1.15), 2, 1))
		        a = self.bananaModels[2].getPos()[0]
		        b = self.bananaModels[2].getPos()[1]
		        self.targetHeader = -rad2deg(arccos(b/sqrt(square(a) + square(b))))	
                        self.bananaModels[2].setStashed(0)

                self.cross.setColor(Point4(1, 0, 0, 1))
                avatar.setMaxTurningSpeed(config['fullTurningSpeed'])
        else:
            self.cross.setColor(Point4(1, 0, 0, 1))
            if self.beeps >= 10:
                self.reward = 0

# Create a new instance of the experiment and start it up.
bananarchy().start()