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

class InputEvent:
    """
    Stores information about input from an arbitrary
    InputDevice.
    """

    def __init__(self, eventName, magnitude=1):
        """
        Creates an InputEvent object.

        eventName - string, the name of the event.
        magnitude - float, a value in the range [0, 1]
                    that specifies how hard the key(s)
                    that were bound to the event were
                    pressed. This allows the client to
                    e.g. move an avatar slower if the
                    directional arrows are only slightly
                    depressed.
        """
        self.eventName = eventName
        self.magnitude = magnitude

    def __eq__(self, other):
        """
        Returns True if the event names or magnitudes
        don't match, False otherwise.
        """
        return self.getName()==other.getName() and \
               self.getMagnitude()==other.getMagnitude()

    def __ne__(self, other):
        """
        Returns True if the event names or magnitudes
        don't match, False otherwise.
        """
        return not self.__eq__(other)

    def __str__(self):
        return "InputEvent: "+self.eventName+", mag:"+str(self.magnitude)

    def getName(self):
        """
        Returns the name of the event.
        """
        return self.eventName

    def getMagnitude(self):
        """
        Returns a value in the range [0, 1] that 
        specifies how hard the key(s) that were
        bound to the event were pressed.
        """
        return self.magnitude
 
