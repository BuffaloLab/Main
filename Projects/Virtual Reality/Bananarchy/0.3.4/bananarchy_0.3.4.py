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
import time
import random
import smtplib
from pandaepl.MovingModel import MovingModel
from pandac.PandaModules import *

#nidaq = ctypes.windll.nicaiu

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
        self.nidaqSetup(config) #Setup the basic NI-DAQ Hardware Controls
        self.loadEnvironment(config) #Load environment.

        # Set up fog.
        if int(config['training'] == 4):
            self.fogScheme = config['initialFogScheme']
            self.setUpFog()
        
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
		vr.inputListen("toggleFog", self.toggleFog)
		vr.inputListen("decreaseFog", self.decreaseFog)
		vr.inputListen("increaseFovRay", self.increaseFovRay)
		vr.inputListen("decreaseFovRay", self.decreaseFovRay)
		vr.inputListen("toggleCollisionView", self.toggleCollisionView)

        # Starting banana location
        if config['training'] == 3.1:
            self.center(self, config)
        elif ((config['training'] == 1.1) | (random.randrange(0, 2) > 0)) & (config['training'] != 1.2):
            self.left(self, config)
        else:
            self.right(self, config)

        self.deliveredInitReward = 0

        #Build Collision Rays
        self.setupCollisionRays(config, avatar)
        
        #Login into email account
        if config['emailNotifications'] == 1:
            self.email = smtplib.SMTP_SSL(config['emailServer'])
            self.email.login(config['emailUsername'], config['emailPassword'])
            self.msgHeaders = ("From: %s\r\nTo: %s\r\nSubject: %s\r\n\r\n" % (config['emailFrom'], ", ".join(config['emailTo']), config['subject']))
            self.sendEmail("New Session Started. Training = " + str(config['training']))        

    def setupCollisionRays(self, config, avatar):
        #self.terrainModel.retrNodePath().reparentTo(render)
        #self.terrainModel.retrNodePath().setCollideMask(BitMask32.bit(1))
        #self.bananaModels[0].retrNodePath().setCollideMask(BitMask32.bit(1)) #Not necessary?
        #avatar.retrNodePath().reparentTo(self.bananaModels[0].retrNodePath())
        #avatar.retrNodePath().reparentTo(self.terrainModel.retrNodePath())
        self.collTrav = CollisionTraverser() #the collision traverser. we need this to perform collide in the end
        self.targetRay = avatar.retrNodePath().attachNewNode(CollisionNode('targetRayColNode'))
        self.targetRay.node().addSolid(CollisionRay(0, 0, .5, 0, 1, 0))
        self.targetRayRight = avatar.retrNodePath().attachNewNode(CollisionNode('targetRayRightColNode'))
        self.targetRayRight.node().addSolid(CollisionRay(0, 0, .5, -sin(deg2rad(-config['targetRayWindow'])), cos(deg2rad(-config['targetRayWindow'])), 0))
        self.targetRayLeft = avatar.retrNodePath().attachNewNode(CollisionNode('targetRayLeftColNode'))
        self.targetRayLeft.node().addSolid(CollisionRay(0, 0, .5, -sin(deg2rad(config['targetRayWindow'])), cos(deg2rad(config['targetRayWindow'])), 0))
        self.fovRayR = avatar.retrNodePath().attachNewNode(CollisionNode('fovRayRightColNode'))
        self.fovRayR.node().addSolid(CollisionRay(.25, 0, .5, -sin(deg2rad(-config['fovRayVecX'])), cos(deg2rad(-config['fovRayVecX'])), 0))
        self.fovRayL = avatar.retrNodePath().attachNewNode(CollisionNode('fovRayLeftColNode'))
        self.fovRayL.node().addSolid(CollisionRay(-.25, 0, .5, -sin(deg2rad(config['fovRayVecX'])), cos(deg2rad(config['fovRayVecX'])), 0))
        #avatar.retrNodePath().node().setIntoCollideMask(BitMask32.allOff()) #Not necessary?
        #self.theRay.node().setFromCollideMask(BitMask32.bit(1)) #Not necessary?
        self.targetRayColQueue = CollisionHandlerQueue()
        self.collTrav.addCollider(self.targetRay, self.targetRayColQueue)
        self.collTrav.addCollider(self.targetRayRight, self.targetRayColQueue)
        self.collTrav.addCollider(self.targetRayLeft, self.targetRayColQueue)
        
        self.fovRayLeftColQueue = CollisionHandlerQueue()
        self.collTrav.addCollider(self.fovRayL, self.fovRayLeftColQueue)
        self.fovRayRightColQueue = CollisionHandlerQueue()
        self.collTrav.addCollider(self.fovRayR, self.fovRayRightColQueue)
        
        self.collisionView = 0
        self.fovRayVecX = config['fovRayVecX']
    
    def sendEmail(self, msg):
        config = Conf.getInstance().getConfig()
        if config['emailNotifications'] == 1:
            self.email.sendmail(config['emailFrom'], config['emailTo'], self.msgHeaders + msg)
        
    def nidaqSetup(self, config):
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

        self.beeps = 0   #Beep/Pulse counter
        self.reward = 2  #When set to 1, reward output is triggered.

        if config['nidaq'] == 1:
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
        
        if (config['training'] == 0) or (int(config['training']) == 4):       
            # Load terrain.
            self.terrainModel = Model("terrain", config['terrainModel'], 
                                      config['terrainCenter'])

            # When hitting an object that is part of the terrain, repel or slide?
            self.terrainModel.setCollisionCallback(MovingObject.handleRepelCollision)

            # Load sky.
            self.skyModel = Model("sky", config['skyModel'])
            self.skyModel.setScale(config['skyScale'])

            # Load palm tree.
            self.treeModel = Model("tree", config['treeModel'], config['treeLoc'])
            self.treeModel.setScale(config['treeScale'])


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

    
    def setUpFog(self):
        """
        Set up fog according to the current scheme.
        """
        # Get configuration dictionary.
        config = Conf.getInstance().getConfig()

        # Delete previously set fog.
        self.fog = None

        # No fog.
        if self.fogScheme == 0:
            pass
        # Exponential fog.
        elif self.fogScheme >= 1:
            self.fog = ExpFog("demoExpFog", config['expFogColor'], 
                              config['expFogDensity'] * (.9**self.fogScheme))

        # Display fog everywhere.
        #Vr.getInstance().setFog(self.fog)
        self.skyModel.setFog(self.fog)
        self.terrainModel.setFog(self.fog)

    def toggleFog(self, inputEvent):
        """
        Cycle between different fog schemes.
        """
        TOTAL_FOG_SCHEMES = 70
        if self.fogScheme > 0:
            self.fogScheme    = (self.fogScheme+1) % TOTAL_FOG_SCHEMES
        self.sendEmail('fogScheme: ' + str(self.fogScheme))
        self.setUpFog()

    def decreaseFog(self, inputEvent):
        """
        Cycle between different fog schemes.
        """
        TOTAL_FOG_SCHEMES = 70
        if self.fogScheme != 1:
            self.fogScheme    = (self.fogScheme-1) % TOTAL_FOG_SCHEMES
        self.sendEmail('fogScheme: ' + str(self.fogScheme))
        self.setUpFog()

    def restart(self, inputEvent):
	'''
	Reload config file, give bananas new locations, make them visible, set new session number
	and return the subject to the original location, with no movement/momentum in any direction.
	'''
	
	config = Conf.getInstance().getConfig()

        self.cross.setColor(Point4(1, 0, 0, 1))
        self.bananaModels[0].setStashed(1)
        if config['training'] == 3.1:
            self.center(self, config)
        else:
            randSide = random.randrange(0, 2)
            if randSide < 1:
                self.left(self, config)
            else:
                self.right(self, config)
	avatar = Avatar.getInstance()
	avatar.setLinearAccel(0)
	avatar.setLinearSpeed(0)
	avatar.setTurningSpeed(0)
	avatar.setTurningAccel(0)	
	avatar.setH(0)
	avatar.setPos(Point3(0, 0, 0.5))
	avatar.setMaxTurningSpeed(config['fullTurningSpeed'])
	self.deliveredInitReward = 0
	
    def left(self, inputEvent, config):
        self.bananaModels[0].setStashed(1)
        self.targetHeader = float('nan')
        self.bananaModels[0].setPos(Point3(random.uniform(-config['minDistance'], -config['maxDistance']), random.uniform(config['minFwDistance'], config['maxFwDistance']), 1))
        self.bananaModels[0].setStashed(0)
        a = self.bananaModels[0].getPos()[0]
        b = self.bananaModels[0].getPos()[1]
        self.targetHeader = rad2deg(arccos(b/sqrt(square(a) + square(b))))

    def center(self, inputEvent, config):
        self.bananaModels[0].setStashed(1)
        self.targetHeader = float('nan')
        self.bananaModels[0].setPos(Point3(0, random.uniform(config['minFwDistance'], config['maxFwDistance']), 1))
        self.bananaModels[0].setStashed(0)
        a = self.bananaModels[0].getPos()[0]
        b = self.bananaModels[0].getPos()[1]
        self.targetHeader = rad2deg(arccos(b/sqrt(square(a) + square(b))))

    def right(self, inputEvent, config):
        self.bananaModels[0].setStashed(1)
        self.targetHeader = float('nan')
        self.bananaModels[0].setPos(Point3(random.uniform(config['minDistance'], config['maxDistance']), random.uniform(config['minFwDistance'], config['maxFwDistance']), 1))
        self.bananaModels[0].setStashed(0)
        a = self.bananaModels[0].getPos()[0]
        b = self.bananaModels[0].getPos()[1]
        self.targetHeader = -rad2deg(arccos(b/sqrt(square(a) + square(b))))

    def increaseDist(self, inputEvent):
        pass

    def decreaseDist(self, inputEvent):
        pass

    def increaseFovRay(self, inputEvent):
        self.fovRayVecX += 1
        self.fovRayR.node().modifySolid(0).setDirection(-sin(deg2rad(-self.fovRayVecX)), cos(deg2rad(-self.fovRayVecX)), 0)
        self.fovRayL.node().modifySolid(0).setDirection(-sin(deg2rad(self.fovRayVecX)), cos(deg2rad(self.fovRayVecX)), 0)
        self.sendEmail("FOV Window: " + str(self.fovRayVecX))
        print(self.fovRayVecX)


    def decreaseFovRay(self, inputEvent):
        self.fovRayVecX -= 1
        self.fovRayR.node().modifySolid(0).setDirection(-sin(deg2rad(-self.fovRayVecX)), cos(deg2rad(-self.fovRayVecX)), 0)
        self.fovRayL.node().modifySolid(0).setDirection(-sin(deg2rad(self.fovRayVecX)), cos(deg2rad(self.fovRayVecX)), 0)
        self.sendEmail("FOV Window: " + str(self.fovRayVecX))
        print(self.fovRayVecX)

    def toggleCollisionView(self, inputEvent):
        self.collisionView = (self.collisionView + 1) % 2
        if self.collisionView == 1:
            self.cV = self.collTrav.showCollisions(render)
        else:
            render.node().removeChild(render.node().findChild(self.cV))
        
        
    def start(self):
        """
        Start the experiment.
        """

        Experiment.getInstance().start()
        
    def collideBanana(self, collisionInfoList):
        """
        Handle the participant colliding with a banana.
        """
        config = Conf.getInstance().getConfig()
        
        # ID of the banana the participant collided with.
        banana = collisionInfoList[0].getInto().getIdentifier()

        # Log collision.
        VLQ.getInstance().writeLine("YUMMY", [banana])
            
        # Upon touching banana, repel movement.  Banana disappears.
        MovingObject.handleRepelCollision(collisionInfoList)
	

        # Reward

	#self.reward = 1
        if self.cross.getColor()[2] == 1:
            if config['training'] < 3.1:
                self.targetHeader = float('nan')
            Avatar.getInstance().setMaxTurningSpeed(0)
            self.cross.setColor(Point4(0, 1, 0, 1))
            self.reward = 1

	#collisionInfoList[0].getInto().setStashed(1)

    def pumpOut(self, config):
        """
        Carry out reward delivery process when self.reward is set to 1.
        """
       
        if (self.beeps < config['numBeeps']) & (self.reward == 1):
            if config['nidaq'] == 1:
                nidaq.DAQmxStartTask( self.taskHandle )
                nidaq.DAQmxWaitUntilTaskDone( self.taskHandle, self.float64(-1) )
                nidaq.DAQmxStopTask( self.taskHandle )
            else:
                print('Beep: ' + str(self.beeps + 1))
                print('\a')
            self.beeps = self.beeps + 1
            if self.beeps == 6:
                self.deliveredInitReward = 1
        else:                
            self.beeps = 0
            self.reward = 0
            if self.cross.getColor()[1] == 1:
                self.restart(self)
                
                           
    def trackHeader(self, config, avatar):
        """
        Monitor the header between every frame and perform the relevant
        header-dependent functions.
        """
        self.collTrav.traverse(render)
        self.targetRayColQueue.sortEntries()

        if self.cross.getColor()[1] != 1:
            self.bananaModels[0].setH(self.bananaModels[0].getH() + config['bananaRotation']) #Rotate the banana

        hedder = avatar.getH()
        
        #Maintain boundaries to ensure Avatar never rotates so much that banana disappears from screen
        if config['training'] < 4.2:
            if (self.bananaModels[0].getPos()[0] < 0) & (-hedder >= (config['FOV']/2 - 1) - abs(self.targetHeader)):
                avatar.setLinearAccel(0)
                avatar.setLinearSpeed(0)
                avatar.setTurningSpeed(0)
                avatar.setTurningAccel(0)
                avatar.setH(hedder+.02)
            elif (self.bananaModels[0].getPos()[0] > 0) & (hedder >= (config['FOV']/2 - 1) - abs(self.targetHeader)):
                avatar.setLinearAccel(0)
                avatar.setLinearSpeed(0)
                avatar.setTurningSpeed(0)
                avatar.setTurningAccel(0)
                avatar.setH(hedder-.02)

            if (self.bananaModels[0].getPos()[0] < 0) & (hedder >= (config['FOV']/2 - 1) + self.targetHeader):
                avatar.setLinearAccel(0)
                avatar.setLinearSpeed(0)
                avatar.setTurningSpeed(0)
                avatar.setTurningAccel(0)
                avatar.setH(hedder-.02)
            elif (self.bananaModels[0].getPos()[0] > 0) & (hedder <= -(config['FOV']/2 - 1) + self.targetHeader):
                avatar.setLinearAccel(0)
                avatar.setLinearSpeed(0)
                avatar.setTurningSpeed(0)
                avatar.setTurningAccel(0)
                avatar.setH(hedder+.02)
        else:
            self.fovRayRightColQueue.sortEntries()
            self.fovRayLeftColQueue.sortEntries()
            if self.bananaModels[0].retrNodePath().getName() == self.fovRayRightColQueue.getEntry(0).getIntoNodePath().getName():
                avatar.setLinearAccel(0)
                avatar.setLinearSpeed(0)
                avatar.setTurningSpeed(0)
                #avatar.setTurningAccel(0)
                avatar.setMaxForwardSpeed(0)
                avatar.setH(hedder-.1)
            elif self.bananaModels[0].retrNodePath().getName() == self.fovRayLeftColQueue.getEntry(0).getIntoNodePath().getName():
                avatar.setLinearAccel(0)
                avatar.setLinearSpeed(0)
                avatar.setTurningSpeed(0)
                #avatar.setTurningAccel(0)
                avatar.setMaxForwardSpeed(0)
                avatar.setH(hedder+.1)
            else:
                avatar.setMaxForwardSpeed(config['fullForwardSpeed'])
            
        #What to do when the current header matches the target header:
        #Reward, make crosshairs blue, and freeze rotation until reward is complete.  Then hide banana, reset position,
        #allow rotation, and present new target banana in random location.

        if config['training'] < 4.0:
            alignment = (hedder < self.targetHeader + config['targetHwinL']) & (hedder > self.targetHeader - config['targetHwinR'])
        else:
            alignment = self.bananaModels[0].retrNodePath().getName() == self.targetRayColQueue.getEntry(3).getIntoNodePath().getName()
        
        if alignment:
            if int(config['training']) < 3:
                self.reward = 1
            if (config['training'] >= 3.2) & (self.deliveredInitReward == 0) & (self.beeps < 6):
                self.reward = 1
                #self.deliveredInitReward = 1
            elif self.cross.getColor()[1] == 1:
                self.reward = 1
            elif config['training'] >= 3.2:
                self.reward = 0

            if self.cross.getColor()[1] != 1:
                self.cross.setColor(Point4(0, 0, 1, 1))
              
            avatar.setMaxForwardSpeed(config['fullForwardSpeed'])

            if (int(config['training']) == 1) or (config['training'] == 3.2) or ((config['training'] >= 3.3) and (avatar.getPos()[1] > 0) and (config['training'] < 4.1)):
                avatar.setMaxTurningSpeed(0)
            if (self.beeps >= config['numBeeps']) & (config['training'] < 3.1):
                self.bananaModels[0].setStashed(1)
                avatar.setH(0)
		if ((config['training'] == 1.1) | (random.randrange(0, 2) < 1)) & (config['training'] != 1.2):
		    self.left(self, config)
		else: 
                    self.right(self, config)

                self.cross.setColor(Point4(1, 0, 0, 1))
                avatar.setMaxTurningSpeed(config['fullTurningSpeed'])
        else:
            if config['training'] >= 3.3:
                self.reward = 0
            if self.reward == 0:
                self.cross.setColor(Point4(1, 0, 0, 1))
                if config['training'] < 4.2:
                    avatar.setMaxForwardSpeed(0)
            if int(config['training']) <= 3:
                if self.beeps >= 5:
                    self.reward = 0
                    

# Create a new instance of the experiment and start it up.
bananarchy().start()
