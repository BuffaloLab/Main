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
from UniquelyIdentifiable import UniquelyIdentifiable
from VideoLogQueue        import VideoLogQueue as VLQ
from ptime                import *
from pandac.PandaModules  import Fog as Panda3D_Fog, NodePath

class ExpFog(Fog, UniquelyIdentifiable):
    """
    Fog that spans the entire scene, regardless of position.
    """

    Log.getInstance().addType("FOG_EXP_INIT", [('identifier',basestring)])
    Log.getInstance().addType("FOG_EXP_CREATED", [('identifier',basestring)])
    Log.getInstance().addType("FOG_EXP_DENSITY", [('identifier',basestring), \
                                                  ('value',Log.number)])

    def __init__(self, identifier, color, density):
        """
        Creates an ExpFog object. After creating a 
        fog object you must set what objects are affected
        by calling [vrobject].setFog([newfog]) on each, 
        or Vr.getInstance().setFog([newfog]) to set
        it for the entire environment.

        identifier - A unique string identifier for this object.
        color      - Point3
        density    - float
        """
        Log.getInstance().writeLine((mstime(), 0), "FOG_EXP_INIT", [identifier])
        UniquelyIdentifiable.__init__(self, identifier)

        # Create underlying Panda3D node.
        fog = Panda3D_Fog(identifier)
        fog.setMode(Panda3D_Fog.MExponential)
        
        # Pass identifier and underlying node to parent class.
        Fog.__init__(self, identifier, color, NodePath(fog))

        self.setDensity(density)
        VLQ.getInstance().writeLine("FOG_EXP_CREATED", [identifier])

    def __del__(self):
        """
        Destroys the object.
        """
        Fog.__del__(self)
        UniquelyIdentifiable.__del__(self)

    def getDensity(self):
        """
        Returns the fog's density (float).
        """
        return self.retrNodePath().node().getExpDensity()

    def setDensity(self, newDensity):
        """
        Sets the fog's density (float).
        """
        self.retrNodePath().node().setExpDensity(newDensity)
        VLQ.getInstance().writeLine("FOG_EXP_DENSITY", [self.getIdentifier(), newDensity])

