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

from InputDevice                  import InputDevice
from InputEvent                   import InputEvent
from Log                          import Log
from ptime                        import *
from direct.showbase.DirectObject import DirectObject

class Keyboard(InputDevice, DirectObject):

    singletonInstance = None

    Log.getInstance().addType("KEYBOARD_DOWN", [('key',basestring)], False)
    Log.getInstance().addType("KEYBOARD_UP", [('key',basestring)], False)

    def __init__(self):
        """
        Creates a Keyboard object. Client scripts
        should treat Keyboard as a singleton and get 
        references to it using getInstance() instead
        of creating a new instance.
        """
        InputDevice.__init__(self)

        # 2-tuple timestamp (base, base+latency) representing when key events 
        # were last polled; used to log key events when they eventually
        # trigger the registered callbacks (see getEvents, __keyDown, __keyUp).
        self.pollTimestamp = None

        # Default priority.
        self.setPriority(1)

        # Default bindings.
        self.bind("moveForward", "arrow_up", True)
        self.bind("moveBackward", "arrow_down", True)
        self.bind("turnLeft", "arrow_left", True)
        self.bind("turnRight", "arrow_right", True)
        self.bind("dismiss", "enter", False)

        # Listen for VR events.
        from Vr import Vr
        Vr.getInstance().registerObserver(self.vrEvent)

    def __keyDown(self, key):
        """
        Registers key down events.
        """
        self._setKey(InputEvent(key, 1))
        Log.getInstance().writeLine(self.pollTimestamp, "KEYBOARD_DOWN", [key])

    def __keyUp(self, key):
        """
        Registers key up events.
        """
        self._setKey(InputEvent(key, 0))
        Log.getInstance().writeLine(self.pollTimestamp, "KEYBOARD_UP", [key])

    def getInstance(cls):
        """
        Returns a reference to (the one and only) Keyboard
        instance. Use this instead of instantiating a copy
        directly.
        """
        if Keyboard.singletonInstance == None:
            Keyboard.singletonInstance = Keyboard()
        return Keyboard.singletonInstance

    getInstance = classmethod(getInstance)

    def vrEvent(self, eventName, **dargs):
        """
        Listens for VR events. Generally called by 
        the VR class and should not be used by 
        PandaEPL client code directly.
        """
        if eventName == "loopStarted":
            base.buttonThrowers[0].node().setButtonDownEvent('buttonDown')
            base.buttonThrowers[0].node().setButtonUpEvent('buttonUp')
            self.accept('buttonDown', self.__keyDown)
            self.accept('buttonUp', self.__keyUp)

    def getEvents(self):
        """
        Returns a dictionary of events that occured since 
        the last call to getEvents(). The keys of the 
        dictionary are the event names and the values are
        the magnitude with which the key that triggered
        the event was pressed.
        """
        # Calculate maximum latency for new inputs.
        now                = mstime()
        self.pollTimestamp = (self.getEventsTime, now - self.getEventsTime)
        self.getEventsTime = now

        # Poll Panda3D for new inputs.
        base.dgTrav.traverse(base.dataRootNode)

        return InputDevice.getEvents(self)

