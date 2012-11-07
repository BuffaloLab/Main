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

from direct.showbase.DirectObject import DirectObject
from InputDevice                  import InputDevice
from InputEvent                   import InputEvent
from Log                          import Log
from Options                      import Options
from ptime                        import *

pygameFound = True
try:
    import pygame
except ImportError:
    pygameFound = False

instructCalibrate = """
Please calibrate the JOYSTICK(S) now...

Move the JOYSTICK(S) all the way UP.

Move the JOYSTICK(S) all the way DOWN.

Move the JOYSTICK(S) all the way LEFT.

Move the JOYSTICK(S) all the way RIGHT.

Press the 0 button on JOYSTICK 0 when finished.
"""

class Joystick(InputDevice, DirectObject):

    singletonInstance = None

    Log.getInstance().addType("JOY_DOWN", [('key',basestring), ('magnitude',Log.number)], False)
    Log.getInstance().addType("JOY_UP", [('key',basestring)], False)

    def __init__(self):
        """
        Creates a Joystick object. Client scripts
        should treat Joystick as a singleton and get 
        references to it using getInstance() instead
        of creating a new instance.
        """
        InputDevice.__init__(self)

        if not pygameFound:
            return

        # Initialize pygame video module. This is not used,
        # but for some silly reason is needed to get pygame's
        # event queue going.
        pygame.display.init()

        # The one we actually need.
        pygame.joystick.init()

        # Initialize the first joystick, if any are present.
        if pygame.joystick.get_count()>0:
            self.joystickFound = True
            pygame.joystick.Joystick(0).init()
            pygame.event.set_allowed([pygame.JOYAXISMOTION,pygame.JOYBUTTONUP,pygame.JOYBUTTONDOWN])

            # Default priority of joystick device.
            self.setPriority(2)

            # Threshold.
            self.threshold = Options.getInstance().get().js_zero_threshold

            # Default bindings.
            self.bind("moveForward", "joy_up", True)
            self.bind("moveBackward", "joy_down", True)
            self.bind("turnLeft", "joy_left", True)
            self.bind("turnRight", "joy_right", True)
            self.bind("dismiss", "joy_button0", False)

            # Whether the axis buttons are currently pressed down.
            # Axis events are continuous, i.e. even if the user
            # doesn't move the joystick, events with small magnitudes
            # (that are subsequently rounded down to zero) pop up on
            # each polling. We keep track of axis status separately,
            # so that for instance we don't log multiple JOY_UP
            # events in a row when the axis isn't being touched.
            self.axisDown = {'joy_up':False, 'joy_down':False, 'joy_left':False, 'joy_right':False}
        # If no joysticks found, free up resources.
        else:
            self.joystickFound = False
            pygame.quit()

    def calibrate(self):
        """
        Display joystick calibration instructions.
        """
        if pygameFound and self.joystickFound:
            from Instructions import Instructions
            Instructions("PandaEPL_instructCalibrate", instructCalibrate).display()

    def getInstance(cls):
        """
        Returns a reference to (the one and only) Joystick
        instance. Use this instead of instantiating a copy
        directly.
        """
        if Joystick.singletonInstance == None:
            Joystick.singletonInstance = Joystick()
        return Joystick.singletonInstance

    getInstance = classmethod(getInstance)

    def getEvents(self):
        """
        Returns a dictionary of events that occured since 
        the last call to getEvents(). The keys of the 
        dictionary are the event names and the values are
        the magnitude with which the key that triggered
        the event was pressed.
        """
        if not pygameFound or not self.joystickFound:
            return {}

        # Calculate maximum latency for new inputs.
        now                = mstime()
        timestamp          = (self.getEventsTime, now - self.getEventsTime)
        self.getEventsTime = now

        # List of axis events to log, a bit cleaner to do
        # all at once than logging them individually.
        axisEvents = []

        log = Log.getInstance()
        for event in pygame.event.get():
            # We translate an axis motion event into one
            # of four buttons.
            if event.type == pygame.JOYAXISMOTION:
                # If the range the axis is depressed is
                # less than the threshold, treat it as 
                # unpressed.
                if abs(event.value) < self.threshold:
                    magnitude = 0
                else:
                    magnitude = abs(event.value)

                if event.axis == 0:
                    if event.value <= 0:
                        tmp = InputEvent("joy_left", magnitude)
                        self._setKey(tmp)
                        axisEvents.append(tmp)

                    if event.value >= 0:
                        tmp = InputEvent("joy_right", magnitude)
                        self._setKey(tmp)
                        axisEvents.append(tmp)

                elif event.axis == 1:
                    if event.value <= 0:
                        tmp = InputEvent("joy_up", magnitude)
                        self._setKey(tmp)
                        axisEvents.append(tmp)

                    if event.value >= 0:
                        tmp = InputEvent("joy_down", magnitude)
                        self._setKey(tmp)
                        axisEvents.append(tmp)

            elif event.type == pygame.JOYBUTTONDOWN:
                self._setKey(InputEvent("joy_button"+str(event.button), 1))
                log.writeLine(timestamp, "JOY_DOWN", ["joy_button"+str(event.button), 1])
                
            elif event.type == pygame.JOYBUTTONUP:
                self._setKey(InputEvent("joy_button"+str(event.button), 0))
                log.writeLine(timestamp, "JOY_UP", ["joy_button"+str(event.button)])

        # Log axis events.
        for axisEvent in axisEvents:
            if axisEvent.getMagnitude() == 0 and self.axisDown[axisEvent.getName()]:
                log.writeLine(timestamp, "JOY_UP", [axisEvent.getName()])
                self.axisDown[axisEvent.getName()] = False
            elif axisEvent.getMagnitude() > 0:
                log.writeLine(timestamp, "JOY_DOWN", \
                              [axisEvent.getName(), axisEvent.getMagnitude()])
                self.axisDown[axisEvent.getName()] = True 

        return InputDevice.getEvents(self)

