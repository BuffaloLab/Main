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
from UniquelyIdentifiable import UniquelyIdentifiable
from VideoLogQueue        import VideoLogQueue as VLQ
from VrObject             import VrObject
from ptime                import *
from pandac.PandaModules  import CardMaker, PandaNode, NodePath

class Image(VrObject, UniquelyIdentifiable):
    """
    A 2D graphical object.
    """

    Log.getInstance().addType("IMAGE_INIT", [('identifier',basestring)])
    Log.getInstance().addType("IMAGE_CREATED", [('identifier',basestring)])
    Log.getInstance().addType("IMAGE_FILENAME", [('identifier',basestring),('value',basestring)])

    def __init__(self, identifier, filename, pos, scale):
        """
        Creates an Image object.

        identifier - string, a unique identifier for this object
        filename   - string, path to an image file.
        pos        - Point3, position of the image. If the image
                     is in "front" of the VR environment (default),
                     only the x and z components of the position are 
                     used; each is in the range [-1, 1].
        scale      - Point3, image size. If the image sticks to the 
                     screen, the same rules apply as for 'pos'.
        """
        Log.getInstance().writeLine((mstime(), 0), "IMAGE_INIT", [identifier])
        UniquelyIdentifiable.__init__(self, identifier)

        # Create a 2D "card" to hold the image.
        cm = CardMaker(identifier + "_card")
        cm.setFrame(-1, 1, -1, 1)

        VrObject.__init__(self, identifier, NodePath(cm.generate()))

        self.setFilename(filename)
        self.setPos(pos)
        self.setScale(scale)
        self.setSticksToScreen(True)
        VLQ.getInstance().writeLine("IMAGE_CREATED", [identifier])

    def __del__(self):
        """
        Destroys the object.
        """
        VrObject.__del__(self)
        UniquelyIdentifiable.__del__(self)

    def getFilename(self):
        """
        Returns the supplied image filename.
        """
        return self.filename

    def setFilename(self, newFilename):
        """
        Reads a new image in from the specified
        file.
        """
        self.retrNodePath().setTexture(base.loader.loadTexture(newFilename))
        self.filename = newFilename
        VLQ.getInstance().writeLine("IMAGE_FILENAME", [self.getIdentifier(), newFilename])

