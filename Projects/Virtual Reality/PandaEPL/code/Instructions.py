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

from Conf                 import Conf
from Experiment           import Experiment
from Log                  import Log
from Text                 import Text
from Tuples               import *
from UniquelyIdentifiable import UniquelyIdentifiable
from VideoLogQueue        import VideoLogQueue as VLQ
from VrObject             import VrObject
from Vr                   import Vr
from ptime                import *
from pandac.PandaModules  import NodePath, PandaNode, TextNode

class Instructions(VrObject, UniquelyIdentifiable):
    """
    Helps display instructions to the user.
    """

    Log.getInstance().addType("INSTRUCT_INIT", [('identifier',basestring)])
    Log.getInstance().addType("INSTRUCT_CREATED", [('identifier',basestring)])
    Log.getInstance().addType("INSTRUCT_ON", [('identifier',basestring)])
    Log.getInstance().addType("INSTRUCT_UP", [('identifier',basestring), ('amount',Log.number)])
    Log.getInstance().addType("INSTRUCT_DOWN", [('identifier',basestring), ('amount',Log.number)])
    Log.getInstance().addType("INSTRUCT_SEENALL", [('identifier',basestring)])
    Log.getInstance().addType("INSTRUCT_OFF", [('identifier',basestring)])

    # The Instructions object that's currently being displayed.
    currentlyDisplayed = None

    # The Instructions objects that have issued a display command
    # and are waiting to be displayed.
    waitingForDisplay  = []

    def __init__(self, identifier, text, callback=None):
        """
        Creates an Instructions object.

        identifier - string, a unique identifier for this object
        text       - string
        callback   - function, if given, this is called each time the 
                     instructions are dismissed
        """
        Log.getInstance().writeLine((mstime(), 0), "INSTRUCT_INIT", [identifier])
        UniquelyIdentifiable.__init__(self, identifier)

        # Create a dummy Panda3D node to attach all
        # instruction objects to.
        dummyNode = NodePath(PandaNode(identifier))

        VrObject.__init__(self, identifier, dummyNode)

        # Hide dummy node for now.
        dummyNode.stash()

        # Called each time instructions are dismissed.
        self.callback = callback

        # Whether the user has seen all of the instructions since
        # the latest call to display.
        self.seenAll = False

        # Initialize text object with default values.
        self.text = Text(identifier+"_text", text, Point3(0, 0, 0), 0.1, 
                         Point4(1,1,1,1))

        # Attach the underlying Panda3D node of the text object
        # to the instructions node.
        self.text.retrNodePath().reparentTo(dummyNode)

        # Keep it in front of the 3D world.
        self.setSticksToScreen(True)

        # Listen for configuration changes.
        Conf.getInstance().registerObserver(self.configEvent)

        # Listen for VR events.
        Vr.getInstance().registerObserver(self.vrEvent)

        # Log creation.
        Log.getInstance().writeLine((mstime(), 0), "INSTRUCT_CREATED", [identifier])        

    def __del__(self):
        """
        Destroys the object.
        """
        VrObject.__del__(self)
        UniquelyIdentifiable.__del__(self)

    def __getScrollAmount(self):
        """
        Private

        Returns the amount to scroll up and down in screen units.
        """
        config = Conf.getInstance().getConfig()
        return config['instructSize'] * 0.2

    def __checkSeenAll(self):
        """
        Checks if the user has already seen the instructions in their 
        entirety, and if so, sets a flag.
        """
        config  = Conf.getInstance().getConfig()
        bounds  = self.retrNodePath().getTightBounds()
        height  = bounds[1][2]-bounds[0][2]
        if self.text.getPos().getZ() - height >= config['instructMargin'] - 1:
            self.seenAll = True
            VLQ.getInstance().writeLine("INSTRUCT_SEENALL", [self.getIdentifier()])

    def configEvent(self, eventName, **dargs):
        """
        Updates the object with the current configuration
        values. Generally called by the Conf class
        and should not be used by PandaEPL client code
        directly.
        """
        config = Conf.getInstance().getConfig()

        if eventName == "configChanged":
            config = Conf.getInstance().getConfig()

            self.text.setScale(config['instructSize'])
            self.text.setFont(config['instructFont'])
            self.text.setColor(config['instructFgColor'])

            self.setPos(Point3(config['instructMargin']-1, 0, 
                         1-config['instructMargin']))

            # Set the text width. The first two is the total 
            # size of the screen width in local units, the 
            # second two is for the left and right margin.
            self.text.setWordwrap(2 - 2*config['instructMargin'])

    def display(self):
        """
        Display the instructions and wait for the dismissal
        key to be pressed. If a configuration file has not yet
        been loaded, this action is queued and executed after
        one is loaded.
        """
        vr           = Vr.getInstance()
        config       = Conf.getInstance().getConfig()
        self.seenAll = False

        # If configuration is loaded, no other instructions 
        # are currently up, and none are waiting (except possibly
        # these instructions), then display these right away.
        if Experiment.getInstance().isStarted() and Instructions.currentlyDisplayed==None and \
           (len(Instructions.waitingForDisplay) == 0 or Instructions.waitingForDisplay[0] == self):
            vr.setIntermission(True)
            vr.blankScreen(config['instructBgColor'])
            vr.inputListen("moveForward", self.scrollDown)
            vr.inputListen("moveBackward", self.scrollUp)
            vr.inputListen("dismiss", self.displayOff)

            self.retrNodePath().unstash()
            VLQ.getInstance().writeLine("INSTRUCT_ON", [self.getIdentifier()])

            Instructions.currentlyDisplayed = self
            if Instructions.waitingForDisplay.count(self) > 0:
                Instructions.waitingForDisplay.remove(self)
            self.__checkSeenAll()
        # Otherwise, add them to the list.
        else:
            Instructions.waitingForDisplay.append(self)

    def displayOff(self, event):
        """
        Turns the instructions off. If instructSeeAll is set in the
        config and the user has not seen all of the instructions yet
        since the last call to display(..), does nothing.
        """
        vr     = Vr.getInstance()
        config = Conf.getInstance().getConfig()
        
        if not config['instructSeeAll'] or self.seenAll:
            vr.blankScreenOff()
            VLQ.getInstance().writeLine("INSTRUCT_OFF", [self.getIdentifier()])
            self.retrNodePath().stash()
            vr.setIntermission(False)

            # Display the next set of instructions waiting.
            Instructions.currentlyDisplayed = None
            if len(Instructions.waitingForDisplay) > 0:
                Instructions.waitingForDisplay[0].display()

            if self.callback != None:
                self.callback()

    def scrollUp(self, event):
        """
        Scrolls the instructions up __getScrollAmount() units.
        """
        config  = Conf.getInstance().getConfig()
        bounds  = self.retrNodePath().getTightBounds()
        height  = bounds[1][2]-bounds[0][2]
        scrollZ = self.__getScrollAmount()

        # If the bottom corner is below the bottom margin, we can scroll up.
        if self.getPos().getZ() - height < config['instructMargin'] - 1:
            pos = self.getPos()
            pos.setZ(pos.getZ() + scrollZ)
            self.setPos(pos)
            VLQ.getInstance().writeLine("INSTRUCT_UP", [self.getIdentifier(), scrollZ])
            self.__checkSeenAll()

    def scrollDown(self, event):
        """
        Scrolls the instructions down __getScrollAmount() units.
        """
        config  = Conf.getInstance().getConfig()
        bounds  = self.retrNodePath().getTightBounds()
        height  = bounds[1][2]-bounds[0][2]
        scrollZ = self.__getScrollAmount()

        # If the top corner is above the top margin, we can scroll down.
        if self.getPos().getZ() > 1-config['instructMargin']:
            pos = self.getPos()
            pos.setZ(pos.getZ() - scrollZ)
            self.setPos(pos)
            VLQ.getInstance().writeLine("INSTRUCT_DOWN", [self.getIdentifier(), -scrollZ])

    def vrEvent(self, eventName, **dargs):
        """
        Listens for VR events. Generally called by 
        the VR class and should not be used by 
        PandaEPL client code directly.
        """
        if eventName == "loopStarted":
            # If we're not currently displaying any instructions
            # and this is the first one waiting, show it.
            if Instructions.currentlyDisplayed == None and \
               len(Instructions.waitingForDisplay) > 0 and \
               Instructions.waitingForDisplay[0] == self:
                self.display()

