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

from Light                import Light
from VideoLogQueue        import VideoLogQueue as VLQ
from Log                  import Log
from UniquelyIdentifiable import UniquelyIdentifiable
from ptime                import *
from pandac.PandaModules  import AmbientLight as Panda3D_AmbientLight, NodePath

class AmbientLight(Light, UniquelyIdentifiable):
    """
    A light source that illuminates the entire VR 
    world, regardless of position. 
    """
  
    Log.getInstance().addType('LIGHT_AMBIENT_CREATED', [('identifier',basestring)])
    Log.getInstance().addType('LIGHT_AMBIENT_INIT', [('identifier',basestring)])

    def __init__(self, identifier, color=None):
        """
        Creates an AmbientLight object.

        identifier - string, a unique identifier for this light
        color      - Point3, default Point3(1, 1, 1)
        """
        Log.getInstance().writeLine((mstime(), 0), "LIGHT_AMBIENT_INIT", [identifier])
        UniquelyIdentifiable.__init__(self, identifier)
        ambientLight = Panda3D_AmbientLight(identifier)
        Light.__init__(self, identifier, color, NodePath(ambientLight))
        VLQ.getInstance().writeLine("LIGHT_AMBIENT_CREATED", [identifier])

    def __del__(self):
        """
        Destroys the object.
        """
        Light.__del__(self)
        UniquelyIdentifiable.__del__(self)

