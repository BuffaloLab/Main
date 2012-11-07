# Copyright (c) 2007-2012, Michael J. Kahana.
#
# This file is part of PandaEPL.
#
# PandaEPL is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 2.1 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# Author: Alec Solway
# URL: http://memory.psych.upenn.edu/PandaEPL

from CollisionInfo                import CollisionInfo
from Conf                         import Conf
from Exceptions                   import *
from Experiment                   import Experiment
from Joystick                     import Joystick
from Keyboard                     import Keyboard
from Log                          import Log
from Model                        import Model
from Observable                   import Observable
from Options                      import Options
from TaskInfo                     import TaskInfo
from Tuples                       import *
from UniquelyIdentifiable         import UniquelyIdentifiable
from VideoLogQueue                import VideoLogQueue as VLQ
from ptime                        import *
from pandac.PandaModules          import CardMaker, TransparencyAttrib, WindowProperties, loadPrcFileData, AntialiasAttrib
from direct.task.Task             import Task as Panda3D_Task 
from pandac.PandaModules          import CollisionTraverser, CollisionHandlerQueue
from weakref                      import WeakValueDictionary
import random
import weakref
import sys
import ctypes
import ctypes.util

class Vr(Observable):
    """
    The main interface to the VR environment.
    """
   
    singletonInstance = None

    # Initialize log events.
    Log.getInstance().addType("INPUT_EVENT", [('name',basestring),('magnitude',Log.number)], False)
    Log.getInstance().addType("TASK_SCHEDULE", [('identifier',basestring)])
    Log.getInstance().addType("TASK_UNSCHEDULE", [('identifier',basestring)])
    Log.getInstance().addType("TASK_RUN", [('identifier',basestring)])
    Log.getInstance().addType("VR_INIT", [])
    Log.getInstance().addType("VR_CREATED", [])
    Log.getInstance().addType("VR_BLANKSCREEN", [('color',Point4)])
    Log.getInstance().addType("VR_BLANKSCREENOFF", [])
    Log.getInstance().addType("VR_FOGOFF", [])
    Log.getInstance().addType("VR_FOGON", [('fogIdentifier',basestring)])
    Log.getInstance().addType("VR_INPUTLISTEN", [('key',basestring), ('callback',basestring)])
    Log.getInstance().addType("VR_INPUTLISTENOFF", [('key',basestring)])
    Log.getInstance().addType("VR_REGISTERFROMOBJ", [('identifier',basestring)])
    Log.getInstance().addType("VR_REGISTERINTOOBJ", [('identifier',basestring)])
    Log.getInstance().addType("VR_UNREGISTERFROMOBJ", [('identifier',basestring)])
    Log.getInstance().addType("VR_UNREGISTERINTOOBJ", [('identifier',basestring)])
    Log.getInstance().addType("VR_DEBUG", [('value',bool)])
    Log.getInstance().addType("VR_INTERMISSION", [('value',bool)])
    Log.getInstance().addType("VR_MODELPATH", [('value',basestring)])

    def __init__(self):
        """
        Creates a Vr object. Client scripts should treat
        Vr as a singleton and get references to it using
        getInstance() instead of creating a new instance.
        """
        Log.getInstance().writeLine((mstime(), 0), "VR_INIT", [])
        Observable.__init__(self)

        # A list of client tasks to perform before each frame 
        # is rendered.
        self.tasks  = []
       
        # A dictionary of MovingObjects that can collide with
        # other objects, indexed by collision identifier.
        self.collisionFromObjects = WeakValueDictionary()

        # A dictionary of VrObjects that can be collided with,
        # indexed by identifier.
        self.collisionIntoObjects = WeakValueDictionary()

        # Keeps track of all input event callbacks so they can 
        # easily be turned on and off as a group (e.g. during 
        # intermissions). Each callback is a indexed by the 
        # corresponding event name.
        self.inputCallbacks = {}

        # Same as 'inputCallbacks', but tracks callbacks registered 
        # during an intermission.
        self.intermissionInputCallbacks = {}

        # See getInputEvents(..) for details about this member.
        self.inputEvents = {}

        # See setIntermission(..) for details about this member.
        self.intermission = False

        # When set to True, disengages the keyboard and enables 
        # the user to explore the world using the mouse.
        self.debug  = False

        # A CardMaker that blocks the 3D environment.
        self.blankScreenNode = None

        # List of Panda3D nodes that were stashed
        # as a result of blankScreen(..) call.
        # They are restored when blankScreenOff(..)
        # is called.
        self.stashed = []

        # Whether the main loop has started.
        self.running = False

        # The earliest the main loop could have started.
        self.startTime = None

        # Collision traverser and event queue.
        self.cTrav  = CollisionTraverser()
        self.cQueue = CollisionHandlerQueue()

        # Listen for configuration changes.
        Conf.getInstance().registerObserver(self.configEvent)

        # Make sure the render loop in Panda3D only
        # renders to the back-buffer and doesn't flip it.
        # We do the latter ourselves.
        base.graphicsEngine.setAutoFlip(0)

        Log.getInstance().writeLine((mstime(), 0), "VR_CREATED", [])

    def __setInputEvents(self):
        """
        Private

        Reads and caches all input events in self.inputEvents, 
        calls registered callbacks for each event; called once 
        per frame. See getInputEvents(..) for more.
        """
        inputDevices = [Joystick.getInstance(), Keyboard.getInstance()]

        log                  = Log.getInstance()
        self.inputEvents     = {}
        inputEventPriorities = {}

        # See what events occurred.
        for device in inputDevices:
            events    = device.getEvents()
            for event in events.values():
                # If this event has not been recorded yet,
                # or if the device that generated such an
                # event has lower priority than this one,
                # record the event.
		eventName = event.getName()
                if not self.inputEvents.has_key(eventName) or \
                       inputEventPriorities[eventName] < device.getPriority():
                    self.inputEvents[eventName] = event
                    inputEventPriorities[eventName] = device.getPriority()

        # Log all events.
        now = mstime()
        for event in self.inputEvents.values():
            log.writeLine((now, 0), "INPUT_EVENT", [event.getName(), event.getMagnitude()])
 
        # Call all registered callbacks.
        if self.intermission:
            callbackList = self.intermissionInputCallbacks
        else:
            callbackList = self.inputCallbacks
        for eventName in callbackList.keys():
            if self.inputEvents.has_key(eventName):
                callback = callbackList[eventName]
                callback(self.inputEvents[eventName])

    def addTask(self, task):
        """
        Runs a callback every frame.

        task - a Task object
        """
        self.tasks.append(task)
        Log.getInstance().writeLine((mstime(), 0), "TASK_SCHEDULE", [task.getIdentifier()])
        
    def blankScreen(self, color):
        """
        Draws a rectangle covering the full screen with the given color (Point4).
        """
        self.blankScreenOff()
        cm = CardMaker("PandaEPL_blankScreen")
        cm.setFrame(-1, 1, -1, 1)
        cm.setColor(color)

        # Stash everything that also "sticks to the screen".
        for node in base.aspect2d.getChildren().asList():
            if UniquelyIdentifiable.globalIds.has_key(node.getName()) and \
               not node.isStashed():
                vrObject = UniquelyIdentifiable.globalIds[node.getName()]
                vrObject.setStashed(True)
                self.stashed.append(weakref.ref(vrObject))

        self.blankScreenNode = base.render2d.attachNewNode(cm.generate())
        self.blankScreenNode.setTransparency(TransparencyAttrib.MAlpha)
        VLQ.getInstance().writeLine("VR_BLANKSCREEN", [color])

    def blankScreenOff(self):
        """
        Removes the full-screen rectangle created with blankScreen(). If blankScreen()
        was not called, does nothing.
        """
        if self.blankScreenNode != None:
            # Unstash everything hidden during the blankScreen(..) call.
            for vrObject in self.stashed:
                # The members of stashed are weakly referenced.
                # If this member still exists, unstash it.
                if vrObject()!=None:
                    vrObject().setStashed(False)
            self.stashed = []

            self.blankScreenNode.removeNode()
            VLQ.getInstance().writeLine("VR_BLANKSCREENOFF", [])

    def clearTasks(self):
        """
        Stops all running tasks.
        """
        self.tasks = []

    def configEvent(self, eventName, **dargs):
        """
        Updates the environment with the current 
        configuration values. Generally called by the 
        Conf class and should not be used by PandaEPL 
        client code directly.
        """
        config = Conf.getInstance().getConfig()

        if eventName == "configChanged":
            if config.has_key('modelPath'):
                self.setModelPath(config['modelPath'])

    def flipFrameTask(self, pandaTaskInfo):
        """
        Flips the render buffer and flushes the VideoLogQueue.
        """
        timestamp, returnVal = timedCall(base.graphicsEngine.flipFrame)
        VLQ.getInstance().flush(timestamp)
        return Panda3D_Task.cont

    def getInputEvents(self):
        """
        Checks all supported InputDevices for input
        events. Returns a dictionary of InputEvents,
        indexed by event name, of events that occured 
	since the last frame was drawn. If more than 
        one device generated the same event, the magnitude 
        of the device with the higher priority is used.
        Events are polled once per frame and cached.
        """
        return self.inputEvents

    def getInstance(cls):
        """
        Returns a reference to (the one and only) Vr instance.
        Use this instead of instantiating a copy directly.
        """
        if Vr.singletonInstance == None:
            Vr.singletonInstance = Vr()

        return Vr.singletonInstance

    getInstance = classmethod(getInstance)

    def inputListen(self, event, callback):
        """
        Associates an input event with a callback. 'event' is
        the event name (see the 'Input' section of 
        doc/CONFIG to read more about input events). Instead
        of associating a callback with an event, you can also
        see what's happening by creating a new task that
        checks the result of getInputEvents(). 
        """
        if self.intermission:
            self.intermissionInputCallbacks[event] = callback
        else:
            self.inputCallbacks[event] = callback

        Log.getInstance().writeLine((mstime(), 0), "VR_INPUTLISTEN", [event, callback.__name__])

    def inputListenOff(self, event):
        """
        Removes an input event callback binding established with 
        inputListen(..).
        """
        if self.intermission:
            del self.intermissionInputCallbacks[event]
        else:
            del self.inputCallbacks[event]

        Log.getInstance().writeLine((mstime(), 0), "VR_INPUTLISTENOFF", [event])
        
    def loadModels(self, baseIdentifier, model, location, callback):
        """
        Loads a set of models into the current environment.

        baseIdentifier - Base for a unique string identifier for each model.
                         Model identifiers will be:
                         [baseIdentifier]0, [baseIdentifier]1, etc.
                         e.g. 'southWall'
        model          - string or list of strings
        location       - Point3 or list of Point3's
        callback       - Called when a collision occurs

        If len(location)>len(model), then copies of model are loaded starting from
        the first in a round robin fashion. This is useful, for instance, when 
        building a wall from a segment model. In that case, 
        len(model)=1 and len(location)=enough to fill one side.
        """
        out = []

        # If given one model and/or location, wrap it in a list
        # and continue as if given a one-element list.
        if not isinstance(location, list):
            location = [location]
        if not isinstance(model, list):
            model    = [model]

        for i, curLocation in enumerate(location):
            curModel = model[i % len(model)]
            out.append(Model(baseIdentifier+str(i), curModel, curLocation, callback))

        return out
           
    def lookAtAvatar(self):
        """
        Resets the main camera to look at the avatar
        if not in debug mode.
        """
        from Avatar import Avatar
        from Camera import Camera
        config = Conf.getInstance().getConfig()
        avatar = Avatar.getInstance()
        camera = Camera.getDefaultCamera()

        if not self.isDebug():
            # Set position.
            cameraPos = Vec3(0, 0, 0)
            if config.has_key('cameraPos'):
                cameraPos = config['cameraPos']
            camera.retrNodePath().setPos(avatar.retrNodePath(),  cameraPos)

            # If the avatar has an associated model,
            # slowly rotate the camera to match it. 
            # Otherwise, turn it all the way immediately.
            #if config.has_key('avatarModel') and avatar.getTurningSpeed()>0:
            #    headingCatchupDuration = 1.05*abs(camera.getH()-avatar.getH())/avatar.getTurningSpeed()
            #    camera.retrNodePath().hprInterval(headingCatchupDuration, avatar.getHpr()).start()
            #else:
            #    camera.setHpr(avatar.getHpr())

            camera.setHpr(avatar.getHpr())

    def loop(self):
        """
        The main loop of the VR world.
        """
        # Check to make sure everything that needs to be set is.
        if not Conf.getInstance().isLoaded():
           raise MainLoopException, "A configuration file must be " + \
                                    "loaded before entering the main loop."
    
        # Disable default controls.
        if not self.isDebug():
            base.disableMouse()

        # Register a Panda3D task that will process basic collision
        # detection, avatar movement, and then all client tasks.
        base.taskMgr.add(self.mainTask, "PandaEPL_mainTask")

        # Find the sort order (Panda3D >= 1.6.0) or priority of the Panda3D render task.
        if 'getSort' in dir(base.taskMgr.getTasksNamed('igLoop')[0]):
            renderSort = base.taskMgr.getTasksNamed('igLoop')[0].getSort()
        else:
            renderSort = base.taskMgr.getTasksNamed('igLoop')[0].getPriority()

        # Register a Panda3D task that will flip the back-buffer
        # and flush the VideoLogQueue.
        base.taskMgr.add(self.flipFrameTask, "PandaEPL_flipFrameTask", renderSort+1)

        # Remove Panda3D's default data/input processing task,
        # the Keyboard module takes cares of these things.
        base.taskMgr.remove(base.taskMgr.getTasksNamed('dataLoop')[0])

        # Register a Panda3D task that will run once and tell
        # observers that the loop has started.
        base.taskMgr.add(self.loopStartedTask, "PandaEPL_loopStartedTask", -1000)
        
        # Full-screen antialiasing.
        base.render.setAntialias(AntialiasAttrib.MMultisample,1)

        # Make sure vertical sync is on.
        enableVsync()

        # Pre-load textures, other internal Panda3D initializations.
        base.render.prepareScene(base.win.getGsg())

        # Enter the main loop.
        self.startTime = mstime()
        base.run()

    def loopStartedTask(self, pandaTaskInfo):
        """
        A Panda3D task that runs once after the main loop
        is started. This notifies observers and does
        other initializations.
        """
        self.running = True
        self.notify("loopStarted")
        return Panda3D_Task.done

    def mainTask(self, pandaTaskInfo):
        """
        A Panda3D task that handles collision detection,
        avatar movement, and client tasks.
        """
        from Avatar import Avatar
        config = Conf.getInstance().getConfig()
        avatar = Avatar.getInstance()
                
        # See what kind of input we've received.
        self.__setInputEvents()

        # Have we been asked to exit?
        if self.inputEvents.has_key('exit'):
            Experiment.getInstance().stop()

        # How much time has elapsed since the last frame?
        dt = globalClock.getDt()

        # Update avatar's speed and acceleration using requested controller type.
        if not config.has_key('movementType') or config['movementType'] == 'car':
            self.simulateCarMotion(dt)
        elif config['movementType'] == 'walking':
            self.simulateWalkingMotion(dt)
        else:
            raise MainLoopException, "Unknown movementType configured."
        
        # Move avatar depending on its current speed.
        avatar.move(dt)

        # Process collisions.
        self.cTrav.traverse(render)
        # Panda3D reports primitive-primitive collisions.
        # We pool all collisions for each pair of objects
        # and give them all to the registered callback at once.
        collisions = dict()
        for i in xrange(self.cQueue.getNumEntries()):
            entry = self.cQueue.getEntry(i)
            # If these From and Into objects were registered.
            if self.collisionFromObjects.has_key(entry.getFromNode().getName()) and \
               self.collisionIntoObjects.has_key(entry.getIntoNode().getName()):
                collisionKey = entry.getFromNode().getName()+'$$'+entry.getIntoNode().getName()
                if not collisions.has_key(collisionKey):
                    collisions[collisionKey] = []
                collisions[collisionKey].append(CollisionInfo(self.collisionFromObjects[entry.getFromNode().getName()], \
                                                              self.collisionIntoObjects[entry.getIntoNode().getName()], \
                                                              entry))

        # Call collision callbacks.
        for collisionInfoObjs in collisions.values():
            callback = self.collisionIntoObjects[collisionInfoObjs[0].getInto().getIdentifier()].getCollisionCallback()
            callback(collisionInfoObjs)

        # Move the camera to look at the avatar's new position.
        self.lookAtAvatar()

        # Process any tasks the client code registered.
        self.runClientTasks()

        return Panda3D_Task.cont

    def simulateCarMotion(self, dt):
        """
        Adjust participant's acceleration and speed according
        to the current inputs so as to simulate driving a car.
        """
        from Avatar import Avatar
        config = Conf.getInstance().getConfig()
        avatar = Avatar.getInstance()

        newLinearSpeed  = avatar.getLinearSpeed()
        newTurningSpeed = avatar.getTurningSpeed()

        # If move forward command, provide forward acceleration.
        if self.inputEvents.has_key('moveForward') and   \
           not self.inputEvents.has_key('turnLeft') and  \
           not self.inputEvents.has_key('turnRight') and \
           not self.intermission:
            # Acceleration is scaled by how hard the
            # user is pressing the forward key. 
            avatar.setLinearAccel(config['linearAcceleration'] * \
                                      self.inputEvents['moveForward'].getMagnitude())
            # Update instantaneous speed. 
            newLinearSpeed = newLinearSpeed + dt*avatar.getLinearAccel()

        # If move backward command, provide backward acceleration.
        if self.inputEvents.has_key('moveBackward') and  \
           not self.inputEvents.has_key('turnLeft') and  \
           not self.inputEvents.has_key('turnRight') and \
           not self.intermission:
            # Acceleration is scaled by how hard the
            # user is pressing the backward key.
            avatar.setLinearAccel(config['linearAcceleration'] * \
                                      self.inputEvents['moveBackward'].getMagnitude())
            # Update instantaneous speed.                                                                          
            newLinearSpeed = newLinearSpeed - dt*avatar.getLinearAccel()

        # If linear speed is negligible, clamp it to zero.
        if not self.inputEvents.has_key('moveForward') and  \
           not self.inputEvents.has_key('moveBackward') and \
           abs(newLinearSpeed) < 0.1:
            newLinearSpeed = 0
            avatar.setLinearAccel(0)

        # If turn left command and avatar is moving.
        if self.inputEvents.has_key('turnLeft') and         \
           not self.inputEvents.has_key('moveForward') and  \
           not self.inputEvents.has_key('moveBackward') and \
           newLinearSpeed != 0.0 and \
           not self.intermission:
            # Turning acceleration is scaled by how hard the 
            # user is pressing the left key.
            avatar.setTurningAccel(config['turningAcceleration'] * \
                                       self.inputEvents['turnLeft'].getMagnitude())
            # Update instantaneous turning speed.
            newTurningSpeed = newTurningSpeed + dt*avatar.getTurningAccel()
            # Update linear speed.
            initialLinearSpeed = newLinearSpeed
            if initialLinearSpeed < config['minTurningLinearSpeed']:
                initialLinearSpeed += config['minTurningLinearSpeedIncrement']
                newLinearSpeed      = initialLinearSpeed + dt*avatar.getLinearAccel()* \
                                      config['turningLinearSpeed']
            elif initialLinearSpeed > config['maxTurningLinearSpeed']:
                newLinearSpeed = initialLinearSpeed - dt*avatar.getLinearAccel()* \
                                 config['turningLinearSpeed']
            else:
                newLinearSpeed = initialLinearSpeed

        # If turn left and move forward commands.
        if self.inputEvents.has_key('turnLeft') and    \
           self.inputEvents.has_key('moveForward') and \
           not self.intermission:
            # Turning acceleration is scaled by how hard the 
            # user is pressing the left key. 
            avatar.setTurningAccel(config['turningAcceleration'] * \
                                       self.inputEvents['turnLeft'].getMagnitude())
            # Update instantaneous turning speed.
            newTurningSpeed = newTurningSpeed + dt*avatar.getTurningAccel()
            # Update linear speed.
            initialLinearSpeed = newLinearSpeed
            if initialLinearSpeed < config['minTurningLinearSpeedReqd']:
                newLinearSpeed = initialLinearSpeed
            elif initialLinearSpeed > config['minTurningLinearSpeed'] \
                 and initialLinearSpeed < config['maxTurningLinearSpeed']:
                newLinearSpeed = initialLinearSpeed + dt*avatar.getLinearAccel()* \
                                 config['turningLinearSpeed']
            elif initialLinearSpeed > config['maxTurningLinearSpeed']:
                newLinearSpeed = initialLinearSpeed - dt*avatar.getLinearAccel()* \
                                 (config['turningLinearSpeed']*config['turningLinearSpeed'])
            else:
                newLinearSpeed = initialLinearSpeed

        # If turn left and move backward commands.
        if self.inputEvents.has_key('turnLeft') and     \
           self.inputEvents.has_key('moveBackward') and \
           not self.intermission:
            # Turning acceleration is scaled by how hard the
            # user is pressing the left key.
            avatar.setTurningAccel(config['turningAcceleration'] * \
                                       self.inputEvents['turnLeft'].getMagnitude())
            # Update instantaneous turning speed. 
            newTurningSpeed = newTurningSpeed + dt*avatar.getTurningAccel()
            # Update linear speed.
            newLinearSpeed = newLinearSpeed - dt*avatar.getLinearAccel()*\
                             config['turningLinearSpeed']

        # If turn right command and avatar is moving.
        if self.inputEvents.has_key('turnRight') and        \
           not self.inputEvents.has_key('moveForward') and  \
           not self.inputEvents.has_key('moveBackward') and \
           newLinearSpeed != 0.0 and \
           not self.intermission:
            # Turning acceleration is scaled by how hard the 
            # user is pressing the right key.                                                                      
            avatar.setTurningAccel(config['turningAcceleration'] * \
                                       self.inputEvents['turnRight'].getMagnitude())
            # Update instantaneous turning speed.
            newTurningSpeed = newTurningSpeed - dt*avatar.getTurningAccel()
            # Update linear speed.
            initialLinearSpeed = newLinearSpeed
            if initialLinearSpeed < config['minTurningLinearSpeedReqd']:
                newLinearSpeed = initialLinearSpeed
            elif initialLinearSpeed > config['minTurningLinearSpeed'] \
                and initialLinearSpeed < config['maxTurningLinearSpeed']:
                initialLinearSpeed += config['minTurningLinearSpeedIncrement']
                newLinearSpeed      = initialLinearSpeed + dt*avatar.getLinearAccel()* \
                                      config['turningLinearSpeed']
            elif initialLinearSpeed > config['maxTurningLinearSpeed']:
                newLinearSpeed = initialLinearSpeed - dt*avatar.getLinearAccel()* \
                                 config['turningLinearSpeed']
            else:
                newLinearSpeed = initialLinearSpeed

        # If turn right and move forward commands.
        if self.inputEvents.has_key('turnRight') and   \
           self.inputEvents.has_key('moveForward') and \
           not self.intermission:
            # Turning acceleration is scaled by how hard the
            # user is pressing the right key.
            avatar.setTurningAccel(config['turningAcceleration'] * \
                                       self.inputEvents['turnRight'].getMagnitude())
            # Update instantaneous turning speed.
            newTurningSpeed = newTurningSpeed - dt*avatar.getTurningAccel()
            # Update linear speed.
            initialLinearSpeed = newLinearSpeed
            if initialLinearSpeed < config['minTurningLinearSpeed']:
                newLinearSpeed = initialLinearSpeed + dt*avatar.getLinearAccel()* \
                                 config['turningLinearSpeed']
            elif initialLinearSpeed > config['minTurningLinearSpeed'] \
                and initialLinearSpeed < config['maxTurningLinearSpeed']:
                 newLinearSpeed = initialLinearSpeed
            elif initialLinearSpeed > config['maxTurningLinearSpeed']:
                newLinearSpeed = initialLinearSpeed - dt*avatar.getLinearAccel()* \
                                 (config['turningLinearSpeed']*config['turningLinearSpeed'])
            else:
                newLinearSpeed = initialLinearSpeed

        # If turn right and move backward commands.
        if self.inputEvents.has_key('turnRight') and   \
           self.inputEvents.has_key('moveBackward') and \
           not self.intermission:
            # Turning acceleration is scaled by how hard the
            # user is pressing the right key.                                                                      
            avatar.setTurningAccel(config['turningAcceleration'] * \
                                       self.inputEvents['turnRight'].getMagnitude())
            # Update instantaneous turning speed.
            newTurningSpeed = newTurningSpeed - dt*avatar.getTurningAccel()
            # Update linear speed.
            newLinearSpeed = newLinearSpeed - dt*avatar.getLinearAccel()* \
                             config['turningLinearSpeed']

        # If turning speed is negligible, clamp it to zero.
        if not self.inputEvents.has_key('turnLeft') and  \
           not self.inputEvents.has_key('turnRight') and \
           abs(newTurningSpeed) < 0.1:
            newTurningSpeed = 0
            avatar.setTurningAccel(0)

        # Simulate friction.
        # If turning but no longer moving forward/backward, decrease turning speed just a bit.
        if not self.intermission and abs(newTurningSpeed) > 0 and \
               abs(newLinearSpeed) == 0:
            if newTurningSpeed > 0:
                newTurningSpeed = newTurningSpeed \
                                  - dt*config['turningAcceleration']*config['friction']*\
                                    config['friction']
            else:
                newTurningSpeed = newTurningSpeed \
                                  + dt*config['turningAcceleration']*config['friction']*\
                                    config['friction']

        # Simulate friction.
        # If moving forward/backward but no longer turning, decrease linear speed.
        if not self.intermission and abs(newLinearSpeed) > 0 and \
               abs(newTurningSpeed) == 0:
            if newLinearSpeed > 0:
                newLinearSpeed = newLinearSpeed \
                                 - dt*config['linearAcceleration']*config['friction']
            else:
                newLinearSpeed = newLinearSpeed \
                                 + dt*config['linearAcceleration']*config['friction']

        # Simulate friction.
        # If both moving forward/backward and turning, decrease linear and turning speeds.
        if not self.intermission and abs(newLinearSpeed) > 0 and \
               abs(newTurningSpeed) > 0:
            # Simulate turning friction.
            if newTurningSpeed > 0:
                newTurningSpeed = newTurningSpeed \
                                  - dt*config['turningAcceleration']*config['friction']
            else:
                newTurningSpeed = newTurningSpeed \
                                  + dt*config['turningAcceleration']*config['friction']
            # Simulate forward/backward friction. 
            if newLinearSpeed > 0:
                newLinearSpeed = newLinearSpeed \
                                 - dt*config['linearAcceleration']*config['friction']
            else:
                newLinearSpeed = newLinearSpeed \
                                 + dt*config['linearAcceleration']*config['friction']

        # If speeds have changed, update them.
        if newLinearSpeed != avatar.getLinearSpeed():
            avatar.setLinearSpeed(newLinearSpeed)
        if newTurningSpeed != avatar.getTurningSpeed():
            avatar.setTurningSpeed(newTurningSpeed)

    def simulateWalkingMotion(self, dt):
        """
        Adjust participant's acceleration and speed according
        to the current inputs so as to simulate walking.
        """
        from Avatar import Avatar
        config = Conf.getInstance().getConfig()
        avatar = Avatar.getInstance()

        newLinearSpeed  = avatar.getLinearSpeed()
        newTurningSpeed = avatar.getTurningSpeed()

        if not self.intermission:
            # Adjust linear speed.
            if self.inputEvents.has_key('moveForward'):
                # Acceleration is scaled by how hard the
                # user is pressing the forward key.
                avatar.setLinearAccel(config['linearAcceleration'] * \
                                      self.inputEvents['moveForward'].getMagnitude())
                # Update instantaneous speed.
                newLinearSpeed = newLinearSpeed + dt*avatar.getLinearAccel()
            if self.inputEvents.has_key('moveBackward'):
                # Acceleration is scaled by how hard the
                # user is pressing the backward key.
                avatar.setLinearAccel(config['linearAcceleration'] * \
                                      self.inputEvents['moveBackward'].getMagnitude())
                # Update instantaneous speed.
                newLinearSpeed = newLinearSpeed - dt*avatar.getLinearAccel()
            # If speed is negligible, clamp it to zero.
            if not self.inputEvents.has_key('moveForward') and \
               not self.inputEvents.has_key('moveBackward') and \
                abs(newLinearSpeed) < 0.1:
                newLinearSpeed = 0
                avatar.setLinearAccel(0)

            # Adjust turning speed.
            if self.inputEvents.has_key('turnLeft'):
                # Acceleration is scaled by how hard the
                # user is pressing the left key.
                avatar.setTurningAccel(config['turningAcceleration'] * \
                                       self.inputEvents['turnLeft'].getMagnitude())
                # Update instantaneous speed.
                newTurningSpeed = newTurningSpeed + dt*avatar.getTurningAccel()
            if self.inputEvents.has_key('turnRight'):
                # Acceleration is scaled by how hard the
                # user is pressing the right key.
                avatar.setTurningAccel(config['turningAcceleration'] * \
                                       self.inputEvents['turnRight'].getMagnitude())
                # Update instantaneous speed.
                newTurningSpeed = newTurningSpeed - dt*avatar.getTurningAccel()
            # If speed is negligible, clamp it to zero.
            if not self.inputEvents.has_key('turnLeft') and \
               not self.inputEvents.has_key('turnRight') and \
                abs(newTurningSpeed) < 0.1:
                newTurningSpeed = 0
                avatar.setTurningAccel(0)

            # Simulate some friction.
            if newLinearSpeed > 0:
                newLinearSpeed = newLinearSpeed \
                                 - dt*config['linearAcceleration']*config['friction']
            elif newLinearSpeed < 0:
                newLinearSpeed = newLinearSpeed \
                                 + dt*config['linearAcceleration']*config['friction']

            if self.inputEvents.has_key('turnLeft') or self.inputEvents.has_key('turnRight'):
                turningFriction = config['friction']
            else:
                turningFriction = config['friction']*3
            if newTurningSpeed > 0:
                newTurningSpeed = newTurningSpeed \
                                  - dt*config['turningAcceleration']*turningFriction
            elif newTurningSpeed < 0:
                newTurningSpeed = newTurningSpeed \
                                  + dt*config['turningAcceleration']*turningFriction

            # If speeds have changed, update them.
            if newLinearSpeed != avatar.getLinearSpeed():
                avatar.setLinearSpeed(newLinearSpeed)
            if newTurningSpeed != avatar.getTurningSpeed():
                avatar.setTurningSpeed(newTurningSpeed)

    def registerFromObject(self, object):
        """
        Registers the given object as a collision source
        in the Vr world.

        object - MovingObject
        """
        # Add it as a valid "From" object to Panda3D's collision
        # traverser.
        if not self.collisionFromObjects.has_key(object.getCollisionIdentifier()):
            self.cTrav.addCollider(object.retrColNodePath(), self.cQueue)
            self.collisionFromObjects[object.getCollisionIdentifier()] = object
            VLQ.getInstance().writeLine("VR_REGISTERFROMOBJ", [object.getIdentifier()])

    def registerIntoObject(self, object):
        """
        Registers the given object as a collision receiver
        in the Vr world.

        object - VrObject
        """
        if not self.collisionIntoObjects.has_key(object.getIdentifier()):
            self.collisionIntoObjects[object.getIdentifier()] = object
            VLQ.getInstance().writeLine("VR_REGISTERINTOOBJ", [object.getIdentifier()])

    def registerObserver(self, observer):
        """
        Adds the given callback to the list of entities
        that receive calls made by notify.
        """
        Observable.registerObserver(self, observer)
        if self.running:
            observer("loopStarted")

    def removeTask(self, task):
        """
        Stops the given task from running.
        """
        self.tasks.remove(task)
        Log.getInstance().writeLine((mstime(), 0), "TASK_UNSCHEDULE", [task.getIdentifier()])

    def runClientTasks(self):
        """
        Runs all registered client tasks.
        """
        for task in self.tasks:
            if task.getInterval() == None or \
               task.getLastRun() == None or \
               mstime()-task.getLastRun() >= task.getInterval():
                callback = task.getCallback()

                # Run the callback, if it returns False, auto-remove it.
                # If it returns None or True, do nothing.
                timestamp, callbackVal = timedCall(callback, TaskInfo())
                if callbackVal!=None and not callbackVal:
                    self.removeTask(task)

                task.setLastRun(timestamp[0])
                Log.getInstance().writeLine(timestamp, "TASK_RUN", [task.getIdentifier()])

    def unregisterFromObject(self, object):
        """
        Un-registers the given object as a collision source
        in the Vr world.

        object - MovingObject
        """
        # Remove it as a valid "from" object from Panda3D's
        # collision traverser and delete it form the local dict.
        if self.collisionFromObjects.has_key(object.getCollisionIdentifier()):
            self.cTrav.removeCollider(object.retrColNodePath())
            del self.collisionFromObjects[object.getCollisionIdentifier()]
            VLQ.getInstance().writeLine("VR_UNREGISTERFROMOBJ", [object.getIdentifier()])

    def unregisterIntoObject(self, object):
        """
        Un-registers the given object as a collision receiver
        in the Vr world.

        object - VrObject
        """
        if self.collisionIntoObjects.has_key(object.getIdentifier()):
            del self.collisionIntoObjects[object.getIdentifier()]
            VLQ.getInstance().writeLine("VR_UNREGISTERINTOOBJ", [object.getIdentifier()])

    def isDebug(self):
        """
        Returns the debug status.
        When set to True, disengages the keyboard and enables 
        the user to explore the world using the mouse.
        """
        return self.debug

    def isIntermission(self):
        """
        Returns a boolean specifying whether the VR world is 
        currently in an intermission. See setIntermission(..)
        for more.
        """
        return self.intermission

    def setDebug(self, newDebug):
        """
        Sets the debug status.
        See isDebug() for a description of what this means.
        """
        self.debug = newDebug
        if newDebug:
            base.enableMouse()
        else:
            base.disableMouse()
        
        VLQ.getInstance().writeLine("VR_DEBUG", [newDebug])
     
    def setFog(self, fog):
        """
        Sets the given Fog object to act on the entire
        environment. If None, any existing fog effect 
        on the environment is removed.
        """
        if fog==None:
            base.render.clearFog()
            VLQ.getInstance().writeLine("VR_FOGOFF", [])
        else:
            base.render.setFog(fog.retrNodePath().node())
            VLQ.getInstance().writeLine("VR_FOGON", [fog.getIdentifier()])
      
    def setIntermission(self, newIntermission):
        """
        If True, the environment saves all currently registered 
        input callbacks and then ignores them (except for exitKeys 
        set in the configuration). Newly registered callbacks after
        an intermission begins will work as usual. When an 
        intermission ends, (i.e. False is passed here) all callbacks 
        registered since the beginning are thrown away and the 
        original bindings are restored.
        """
        # If the status has not changed, do nothing.
        if self.intermission == newIntermission:
            return

        self.intermission = newIntermission
        if not self.intermission:
            self.intermissionInputCallbacks = {}

        Log.getInstance().writeLine((mstime(), 0), "VR_INTERMISSION", [newIntermission])

    def setModelPath(self, newModelPath):
        """
        Sets the path to look in when creating a new model,
        either via Vr.loadModels(..) or by creating a new Model
        object.
        """
        loadPrcFileData("", "model-path "+newModelPath)
        Log.getInstance().writeLine((mstime(), 0), "VR_MODELPATH", [newModelPath])

def enableVsync():
    """
    Enables vsync on Mac OS X.
    """
    if sys.platform != 'darwin':
        return
    ogl = ctypes.cdll.LoadLibrary(ctypes.util.find_library("OpenGL"))
    # set v to 1 to enable vsync, 0 to disable vsync
    v = ctypes.c_int(1)
    ogl.CGLSetParameter(ogl.CGLGetCurrentContext(), ctypes.c_int(222), ctypes.pointer(v))


