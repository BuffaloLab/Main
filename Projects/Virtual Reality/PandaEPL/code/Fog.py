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

from Log            import Log
from Tuples         import *
from VideoLogQueue  import VideoLogQueue as VLQ
from VrObject       import VrObject

class Fog(VrObject):
    """
    Base class for all fog objects.
    """

    Log.getInstance().addType("FOG_COLOR", [('identifier',basestring), ('color',VBase3)])
    
    def __init__(self, identifier, color, nodePath):
        """
        Creates a Fog object.

        A Fog object SHOULD NOT BE CREATED DIRECTLY BY A CLIENT
        SCRIPT. Create a specific type of fog instead,
        (e.g. FogExp, FogLinear).

        identifier - string, a unique identifier for this object.
        color      - Point3
        nodePath   - A Panda3D NodePath object.
        """
        VrObject.__init__(self, identifier, nodePath)
        self.setColor(color)

    def __del__(self):
        """
        Destroys the object.
        """
        VrObject.__del__(self)

    def getColor(self):
        """
        Returns the color of the fog (Point3).
        """
        p4Color = self.retrNodePath().node().getColor()
        return Point3(p4Color.getX(), p4Color.getY(), p4Color.getZ())

    def setColor(self, newColor):
        """
        Sets the color of the fog (Point3).
        """
        self.retrNodePath().node().setColor(newColor.getX(), newColor.getY(), newColor.getZ())
        VLQ.getInstance().writeLine("FOG_COLOR", [self.getIdentifier(), newColor])

