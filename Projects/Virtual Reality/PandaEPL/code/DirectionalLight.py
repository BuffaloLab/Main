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
from UniquelyIdentifiable import UniquelyIdentifiable
from VideoLogQueue        import VideoLogQueue as VLQ
from ptime                import *
from pandac.PandaModules  import DirectionalLight as Panda3D_DirectionalLight, NodePath

class DirectionalLight(Light, UniquelyIdentifiable):
    """
    A light shining in a set direction.
    """
  
    Log.getInstance().addType("LIGHT_DIRECTIONAL_INIT", [('identifier',basestring)])
    Log.getInstance().addType("LIGHT_DIRECTIONAL_CREATED", [('identifier',basestring)])

    def __init__(self, identifier, orientation, color=None):
        """
        Creates a DirectionalLight object.

        identifier  - string, a unique identifier for this light
        orienation  - Point3, the light's orientation
        color       - Point3, default is Point3(1, 1, 1).
        """
        Log.getInstance().writeLine((mstime(), 0), "LIGHT_DIRECTIONAL_INIT", [identifier])
        UniquelyIdentifiable.__init__(self, identifier)

        directionalLight = Panda3D_DirectionalLight(identifier)
        Light.__init__(self, identifier, color, NodePath(directionalLight))

        self.setHpr(orientation)
        VLQ.getInstance().writeLine("LIGHT_DIRECTIONAL_CREATED", [identifier])

    def __del__(self):
        """
        Destroys the object.
        """
        Light.__del__(self)
        UniquelyIdentifiable.__del__(self)

