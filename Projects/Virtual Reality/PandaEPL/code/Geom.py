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

from VrObject import VrObject

class Geom(VrObject):
    """
    The most primitive type of object in the VR world,
    a subpart of a Model.
    """

    def __init__(self, identifier, nodePath):
        """ 
        A Geom SHOULD NOT BE CREATED DIRECTLY BY
        A CLIENT SCRIPT.  Use Model::findTag(..)
        instead.

        identifier - string, a unique identifier for this object
        nodePath   - A Panda3D NodePath object.
        """
        VrObject.__init__(self, identifier, nodePath)

    def __del__(self):
        """
        Destroys the object.
        """
        VrObject.__del__(self)
