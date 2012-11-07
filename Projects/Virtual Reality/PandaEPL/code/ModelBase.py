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

from Geom     import Geom
from VrObject import VrObject

class ModelBase(VrObject):
    """
    Base class for all objects converted and loaded 
    from a 3D modeling package.
    """

    def __init__(self, identifier, nodePath, location, callback=None):
        """
        Creates a ModelBase object.

        A ModelBase object SHOULD NOT BE CREATED DIRECTLY BY A CLIENT
        SCRIPT. Create a specific type of model instead (e.g.
        Model, MovingModel, etc.).

        identifier - string, a unique identifier for this model
        nodePath   - A Panda3D NodePath object.
        location   - Point3, where the model goes
        callback   - A function to call when this object collides with
                     a MovingObject.
        """
        VrObject.__init__(self, identifier, nodePath, callback)
        if location != None:
            self.setPos(location)

    def __del__(self):
        """
        Destroys the object.
        """
        VrObject.__del__(self)

    def findTag(self, tag):
        """
        Returns a List of Geom objects matching the model 
        subparts with the given label.    
        """
        out = []
        for nodePath in self.retrNodePath().findAllMatches("**/" + str(tag) + "/**").asList():
            out.append(Geom(self.getIdentifier()+"_"+tag, nodePath))
        return out

