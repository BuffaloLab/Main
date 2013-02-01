from pandaepl.common import *
import os

class bananarchy:

    def __init__(self):
        """
        Initialize the experiment.
        """
        # Get experiment instance.
        exp = Experiment.getInstance()

        # The example experiment consists of a single session.
	if not os.access(exp.getExpDirectory(), os.F_OK):
	        exp.setSessionNum(0)
	else:
		i = 0
		while os.access(exp.getExpDirectory() + '/session_' + str(i), os.F_OK):
			i = i + 1
		exp.setSessionNum(i)
		

        # Get configuration dictionary.
        config = Conf.getInstance().getConfig()

        # Get VR environment object.
        vr = Vr.getInstance()

        # Register custom log entry types.
        # This one corresponds to colliding with a banana.
	Log.getInstance().addType("YUMMY",[("BANANA",basestring)], False)

        # Load environment.
        self.loadEnvironment()


        # Create text field to mark when a banana is eaten.
        self.score = Text("score", ' ', 
                         config['scorePos'], config['scoreSize'], 
                         config['scoreColor'], config['instructFont'])

        # Register task to clear the mark at a specified interval.
        vr.addTask(Task("decrementScore", 
                        lambda taskInfo: 
                          self.clearScore(), 
                        config['scoreDecrementInterval']))

        # Handle keyboard events.
        vr.inputListen("toggleDebug", 
                       lambda inputEvent: 
                         Vr.getInstance().setDebug(not Vr.getInstance().isDebug()))
	vr.inputListen("restart", self.restart)
	if config['training'] == 1:
		vr.inputListen("left", self.left)
		vr.inputListen("center", self.center)
		vr.inputListen("right", self.right)

    def loadEnvironment(self):
        """
        Load terrain, sky, and bananas.
        """
        # Get configuration dictionary.
        config = Conf.getInstance().getConfig()

        # Get experiment parameters.
        state = Experiment.getInstance().getState()

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
	    if config['training'] == 1:
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
	else:
		self.bananaModels[0].setStashed(0)

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
	else:
		self.bananaModels[2].setStashed(0)
	
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

        # Update score.
        self.score.setText('.')
            
        # Upon touching banana, repel movement.  Banana disappears.
        MovingObject.handleRepelCollision(collisionInfoList)
	collisionInfoList[0].getInto().setStashed(1)
        
    def clearScore(self):
        """
        Update the participant's score.
        """

        # Update heads-up display.
        self.score.setText(' ')


# Create a new instance of the experiment and start it up.
bananarchy().start()

