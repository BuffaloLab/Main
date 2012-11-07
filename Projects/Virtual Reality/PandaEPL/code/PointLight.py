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

from Log                  import Log
from Light                import Light
from Tuples               import *
from UniquelyIdentifiable import UniquelyIdentifiable
from VideoLogQueue        import VideoLogQueue as VLQ
from ptime                import *
from pandac.PandaModules  import PointLight as Panda3D_PointLight, NodePath

class PointLight(Light, UniquelyIdentifiable):
    """
    A light originating from a single point in space.
    """
  
    Log.getInstance().addType("LIGHT_POINT_INIT", [('identifier',basestring)])
    Log.getInstance().addType("LIGHT_POINT_CREATED", [('identifier',basestring)])
    Log.getInstance().addType("LIGHT_POINT_ATTENUATION", [('identifier',basestring), ('value',VBase3)])

    def __init__(self, identifier, pos, attenuation, color=None):
        """
        Creates a PointLight object.

        identifier  - string, a unique identifier for this light
        pos         - Point3, the light's position
        attenuation - Point3 the constant, linear, and quadratic terms
                      of the attenuation equation.
        color       - Point3, default is Point3(1, 1, 1).
        """
        Log.getInstance().writeLine((mstime(), 0), "LIGHT_POINT_INIT", [identifier])
        UniquelyIdentifiable.__init__(self, identifier)

        pointLight = Panda3D_PointLight(identifier)
        Light.__init__(self, identifier, color, NodePath(pointLight))

        self.setPos(pos)
        self.setAttenuation(attenuation)
        VLQ.getInstance().writeLine("LIGHT_POINT_CREATED", [identifier])

    def __del__(self):
        """
        Destroys the object.
        """
        Light.__del__(self)
        UniquelyIdentifiable.__del__(self)

    def getAttenuation(self):
        """
        Returns the terms of the attenuation equation for the
        light. See setAttenuation(..) for details.
        """
        return self.retrNodePath().node().getAttenuation()

    def setAttenuation(self, newAttenuation):
        """
        Sets the terms of the attenuation equation for the
        light. A Point3 where the components respectively
        are the constant, linear, and quadratic terms of the
        equation.
        """
        self.retrNodePath().node().setAttenuation(newAttenuation)
        VLQ.getInstance().writeLine("LIGHT_POINT_ATTENUATION", \
                                    [self.getIdentifier(), newAttenuation])

