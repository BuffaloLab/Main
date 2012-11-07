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

from Fog                  import Fog
from Log                  import Log
from Tuples               import *
from UniquelyIdentifiable import UniquelyIdentifiable
from VideoLogQueue        import VideoLogQueue as VLQ
from ptime                import *
from pandac.PandaModules  import Fog as Panda3D_Fog, NodePath

class LinearFog(Fog, UniquelyIdentifiable):
    """
    Fog that extends in a single direction.
    """

    Log.getInstance().addType("FOG_LINEAR_INIT", \
                              [('identifier',basestring)])
    Log.getInstance().addType("FOG_LINEAR_CREATED", \
                              [('identifier',basestring)])
    Log.getInstance().addType("FOG_LINEAR_DISTANCE", \
                              [('identifier',basestring), ('value',Log.number)])

    def __init__(self, identifier, pos, orientation, color, distance):
        """
        Creates an LineaFog object. After creating a 
        fog object you must set what objects are affected
        by calling [vrobject].setFog([newfog]) on each, 
        or Vr.getInstance().setFog([newfog]) to set
        it for the entire environment.

        identifier  - string, a unique string identifier for this object.
        pos         - Point3, the fog's position
        orientation - Point3, the fog's orientation
        color       - Point3
        distance    - float, distance at which the effect ends.
        """
        Log.getInstance().writeLine((mstime(), 0), "FOG_LINEAR_INIT", [identifier])
        UniquelyIdentifiable.__init__(self, identifier)

        # Create underlying Panda3D node.
        fog = Panda3D_Fog(identifier)
        fog.setMode(Panda3D_Fog.MLinear)

        # Pass identifier and underlying node to parent class.
        Fog.__init__(self, identifier, color, NodePath(fog))

        self.setPos(pos)
        self.setHpr(orientation)
        self.setDistance(distance)
        VLQ.getInstance().writeLine("FOG_LINEAR_CREATED", [identifier])

    def __del__(self):
        """
        Destroys the object.
        """
        Fog.__del__(self)
        UniquelyIdentifiable.__del__(self)

    def setDistance(self, newDistance):
        """
        Sets the distance at which the fog 
        effect ends (float).
        """
        self.retrNodePath().node().setLinearRange(0, newDistance)
        VLQ.getInstance().writeLine("FOG_LINEAR_DISTANCE", [self.getIdentifier(), newDistance])

