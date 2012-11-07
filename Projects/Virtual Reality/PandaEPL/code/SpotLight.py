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
from pandac.PandaModules  import Spotlight as Panda3D_Spotlight, NodePath, PerspectiveLens

class SpotLight(Light, UniquelyIdentifiable):
    """
    A light originating from a single point in space, and 
    shining in a particular direction, with a cone-shaped
    falloff.
    """

    Log.getInstance().addType("LIGHT_SPOTLIGHT_INIT", [('identifier',basestring)])
    Log.getInstance().addType("LIGHT_SPOTLIGHT_CREATED", [('identifier',basestring)])
    Log.getInstance().addType("LIGHT_SPOTLIGHT_FALLOFF", [('identifier',basestring), \
                                ('value',Log.number)])
    Log.getInstance().addType("LIGHT_SPOTLIGHT_FOV", [('identifier',basestring), \
                                ('horzFov',Log.number), ('vertFov',Log.number)])
  
    def __init__(self, identifier, pos, falloff, horzFov, vertFov=None, color=None):
        """
        Creates a SpotLight object.

        identifier - string, a unique identifier for this light
        pos        - Point3, light's position
        falloff    - float, falloff from center of the spotlight, higher
                     values correspond to a more focused light source.
        horzFov    - Horizontal field of view.
        vertFov    - Vertical field of view. If not given, it is
                     taken to bee the same as the horizontal (i.e.
                     aspect ratio = 1).
        color      - Point3, default is Point3(1, 1, 1).
        """
        Log.getInstance().writeLine((mstime(), 0), "LIGHT_SPOTLIGHT_INIT", [identifier])
        UniquelyIdentifiable.__init__(self, identifier)

        # Create underlying Panda3D node.
        spotlight = Panda3D_Spotlight(identifier)
        spotlight.setLens(PerspectiveLens())

        Light.__init__(self, identifier, color, NodePath(spotlight))

        self.setPos(pos)
        self.setFalloff(falloff)
        self.setFov(horzFov, vertFov)
        VLQ.getInstance().writeLine("LIGHT_SPOTLIGHT_CREATED", [identifier])

    def __del__(self):
        """
        Destroys the object.
        """
        Light.__del__(self)
        UniquelyIdentifiable.__del__(self)

    def getFalloff(self):
        """
        Returns a factor controlling the amount of light
        falloff from the center of the spotlight. See
        setFallOff(..) for more.
        """
        return self.retrNodePath().node().getExponent()

    def getFov(self):
        """
        Returns the horizontal and vertical field of 
        view in a Vec2.
        """
        return self.retrNodePath().node().getLens().getFov()

    def setFalloff(self, newFalloff):
        """
        Sets a factor controlling the amount of light
        falloff from the center of the spotlight. Higher
        values correspond to a more focused light source.
        """
        self.retrNodePath().node().setExponent(newFalloff)
        VLQ.getInstance().writeLine("LIGHT_SPOTLIGHT_FALLOFF", \
                                    [self.getIdentifier(), newFalloff])

    def setFov(self, newHorzFov, newVertFov=None):
        """
        Sets the spotlight's field of view. If the vertical
        fov is not given, it is taken to be the same as the
        horizontal (i.e. aspect ratio = 1).
        """
        if newVertFov == None:
            self.retrNodePath().node().getLens().setFov(newHorzFov)
            VLQ.getInstance().writeLine("LIGHT_SPOTLIGHT_FOV", [self.getIdentifier(), newHorzFov, \
                                                  self.retrNodePath().node().getLens().getVfov()])
        else:
            self.retrNodePath().node().getLens().setFov(newHorzFov, newVertFov)
            VLQ.getInstance().writeLine("LIGHT_SPOTLIGHT_FOV", [self.getIdentifier(), newHorzFov, newVertFov])

