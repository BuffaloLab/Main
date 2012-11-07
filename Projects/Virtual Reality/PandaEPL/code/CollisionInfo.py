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

class CollisionInfo:
    """
    Stores information about a collision event.
    """

    def __init__(self, fromObj, intoObj, entry):
        """
        Creates a CollisionInfo object.

        fromObj - MovingObject, source of the collision
        intoObj - VrObject, receiver of the collision
        entry - panda collision queue entry for collision
        """
        self.fromObj = fromObj
        self.intoObj = intoObj
        self.entry = entry

    def getFrom(self):
        """
        Returns the source of the collision (VrObject).
        """
        return self.fromObj

    def getInto(self):
        """
        Returns the receiver of the collision.
        """
        return self.intoObj

    def getEntry(self):
        """
        Returns the entire collision entry
        """
        return self.entry

    def getSurfaceNormal(self):
        """
        Returns the surface normal for the receiver of the collision
        """
        return self.entry.getSurfaceNormal(base.render)

    def getSurfacePoint(self):
        """
        Returns the surface point for the reciever of the collision
        """
        return self.entry.getSurfacePoint(base.render)

    def getIntPoint(self):
        """
        Returns the interior point for the receiver of the collision
        """
        return self.entry.getInteriorPoint(base.render)

    def getLastTime(self):
        """
        Returns the amount of time in seconds
        since the last frame was drawn.
        """
        return globalClock.getDt()

