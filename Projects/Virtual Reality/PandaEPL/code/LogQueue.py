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

from Log import Log

class LogQueue:
    """
    Works in conjunction with the Log. Caches 
    events that have occured, but have not been 
    realized, and so lack a timestamp 
    (e.g. a  model was loaded but not yet displayed). 
    Cached events can be logged as a group as soon as 
    a timestamp becomes available. This class can be
    used directly, or subclassed (e.g. see VideoLogQueue).
    """

    def __init__(self):
        """
        Creates a LogQueue object.
        """
        # List of 2-tuples. The first component is the
        # event label and the second is a list of 
        # associated values.
        self.events = []

    def writeLine(self, label, columns):
        """
        Adds a line to the queue; it is similar to
        Log.writeLine(..), but does not require
        a timestamp. Also, unlike Log.writeLine(..),
        no type checking is performed for efficiency
        sake. The events added will not be committed 
        until flush(..) is called, and type checking will 
        be performed then. A cache should be flushed
        frequently so as not to delay error reporting 
        for too long.
        """
        self.events.append((label, columns))

    def flush(self, timeTuple):
        """
        Commits all currently cached events to the Log.

        timeTuple - 2-tuple, the first component is the start time
                    and the second is the maximum latency. the event
                    should be guaranteed to occur between 
                    [start,start+latency]. This timestamp is assigned
                    to all events in the queue. 
        """
        log = Log.getInstance()
        for event in self.events:
            log.writeLine(timeTuple, event[0], event[1])
        self.events = []

