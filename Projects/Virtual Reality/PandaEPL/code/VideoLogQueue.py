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

from LogQueue import LogQueue

class VideoLogQueue(LogQueue):
    """
    A singleton log queue that caches display events.
    When a new, visible object is created, clients
    should write to the VLQ instead of directly to the Log.
    The VLQ will be flushed to the Log with the appropriate
    timestamp the next time the video back-buffer is flipped.
    """

    singletonInstance = None

    def getInstance(cls):
        """
        Returns a reference to (the one and only) VLQ instance.
        Use this instead of instantiating a copy directly.
        """
        if VideoLogQueue.singletonInstance == None:
            VideoLogQueue.singletonInstance = VideoLogQueue()

        return VideoLogQueue.singletonInstance 

    getInstance = classmethod(getInstance)
    
