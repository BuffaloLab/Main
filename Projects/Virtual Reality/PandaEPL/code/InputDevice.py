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

from InputBinding import InputBinding
from InputEvent   import InputEvent
from ptime        import *
from copy         import copy

class InputDevice:
    """
    Base class for all PandaEPL input methods.
    """

    def __init__(self):
        """
        Creates an InputDevice object.
        """
        # A dictionary of InputBinding objects indexed
        # by event name. See bind(..).
        self.bindings = {}

        # A dictionary of InputEvents indexed by event
        # name, where each event is a single key press. 
        self.keysDown = {}

        # A dictionary of current InputEvents indexed by event
        # name. An event is here if it's a repeat event
        # (i.e. holding down the bound keys generates the event
        #  multiple times) and the bound keys for it are pressed,
        # or if it's a non-repeat event, the bound keys for it are
        # pressed, and it has not yet been retrieved with a call
        # to getEvents(). 
        self.events = {}

        # Holds non-repeat events that were already retrieved
        # using getEvents(..), but for which the keys
        # are still pressed.
        self.eventsRetrieved = {}

        # Last time events were retrieved.
        self.getEventsTime = mstime()

        # The priority of the device, higher numbers
        # correspond to devices that should take 
        # priority.
        self.priority = None

    def _setKey(self, key):
        """
        Protected

        If key.getMagnitude() is greater than zero,
        registers the key as pressed, otherwise
        unregisters it. Sets user events based
        on updated key state.

        key - InputEvent 
        """
        if key.getMagnitude()>0:
            self.keysDown[key.getName()] = key
        elif self.keysDown.has_key(key.getName()):
            del self.keysDown[key.getName()]

        # Register 'any' key as pressed if any keys are down,
        # unregister it if all are up.
        if len(self.keysDown)>0 and not self.keysDown.has_key('any'):
            self.keysDown['any'] = InputEvent('any', self.keysDown.values()[0].getMagnitude())
        elif len(self.keysDown) == 1 and self.keysDown.has_key('any'):
            del self.keysDown['any']

        for binding in self.bindings.values():
            for key in binding.keys:
                # If a key for this binding is not pressed,
                # but the binding is in the event queue,
                # remove it.
                if not self.keysDown.has_key(key):
		    if self.events.has_key(binding.eventName):                    
                        del self.events[binding.eventName]
                    if self.eventsRetrieved.has_key(binding.eventName):
                        del self.eventsRetrieved[binding.eventName]
                    break
            # If all keys for the binding are pressed
            # and this event has not yet been retrieved,
            # make sure there's a corresponding event
            # in the queue.
            else:
                newEvent = InputEvent(binding.eventName, self.keysDown[binding.keys[0]].getMagnitude())
                if not self.eventsRetrieved.has_key(binding.eventName) or \
                   self.eventsRetrieved[binding.eventName] != newEvent:
                    self.events[binding.eventName] = newEvent
                
    def bind(self, event, key, repeat=False):
        """
        Binds a key name to an event name. The input
        device will then listen for key presses of type
        'key' and queue an event of type 'event' 
        every such occurrence. 'key' can be a list
        of keys to bind a combination key press.
        If a previous call to bind(..) was issued with
        the same event name, the previous binding is
        overwritten.

        event  - the name of the event to generate.
        key    - string or list, key names that generate
                 the event (see doc/KEYS).
        repeat - boolean, whether holding the keys down
                 will generate the event multiple times.
        """
        if not isinstance(key, list):
            key = [key]
        self.bindings[event] = InputBinding(event, key, repeat)

    def unbind(self, event):
        """
        Stops generating the given event.
        """
        del self.bindings[event]
        if self.events.has_key(event):
            del self.events[event]
        if self.eventsRetrieved.has_key(event):
            del self.eventsRetrieved[event]

    def getEvents(self):
        """
        Returns a dictionary of events that occured since 
        the last call to getEvents(). The keys of the 
        dictionary are the event names and the values are
        the magnitude with which the key that triggered
        the event was pressed.
        """
        curEvents = copy(self.events)
        
        # Mark all non-repeat events as retrieved.
        for e in self.events.keys():
            if not self.bindings[e].repeat:
                self.eventsRetrieved[e] = self.events[e]
                del self.events[e]

        self.getEventsTime = mstime()
        return curEvents

    def getPriority(self):
        """
        Returns the priority of the device. 
        See setPriority(..).
        """
        return self.priority

    def setPriority(self, newPriority):
        """
        Sets the priority of the device. If more
        than one device issues the same event, it's
        customary to use the value from the one with
        the highest priority.
        """
        self.priority = newPriority
        
