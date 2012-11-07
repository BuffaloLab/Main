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
from ptime                import *

class Task(UniquelyIdentifiable):
    """
    Represents a callback that runs at a specified
    interval.
    """

    Log.getInstance().addType("TASK_INIT", \
                              [('identifier',basestring), ('callback',basestring)])
    Log.getInstance().addType("TASK_CREATED", [('identifier',basestring)])
    Log.getInstance().addType("TASK_INTERVAL", \
                              [('identifier',basestring), ('value',Log.number)])
    Log.getInstance().addType("TASK_LASTRUN", \
                              [('identifier',basestring), ('value',Log.number)])

    def __init__(self, identifier, callback, interval=None, startNow=True):
        """
        Creates a Task object.

        identifier - string, a unique identifier for this task
        callback   - the function to call, the function should
                     accept one argument (a TaskInfo object)
                     and return True (or None) if the task should 
                     run again, False otherwise. 
        interval   - float, how often to call the callback, in 
                     ms. The function will be called after
                     -at least- this amount of time has elapsed
                     and -before- rendering the next frame. 
                     The user should not count on the calls being
                     made at exact and even intervals. If None,
                     fires before every frame is drawn.
        startNow   - If True, the task will run for the first time 
                     on the next frame after it's created. If False,
                     we'll wait 'interval' time for the first run.
        """
        Log.getInstance().writeLine((mstime(), 0), "TASK_INIT", \
                                    [identifier, callback.__name__])
        UniquelyIdentifiable.__init__(self, identifier)

        self.callback = callback
        self.setInterval(interval)
        if startNow:
            self.setLastRun(None)
        else:
            self.setLastRun(mstime())

        Log.getInstance().writeLine((mstime(), 0), "TASK_CREATED", [identifier])

    def __del__(self):
        """
        Destroys the object.
        """
        UniquelyIdentifiable.__del__(self)

    def getCallback(self):
        """
        Returns the function called.
        """
        return self.callback

    def getInterval(self):
        """
        Returns the interval at which the callback is
        called, in seconds.
        """
        return self.interval

    def getLastRun(self):
        """
        Returns the time (on a logical clock) the task
        was last executed.
        """
        return self.lastRun

    def setInterval(self, newInterval):
        """
        Sets the interval at which the callback is
        called, in seconds.
        """
        self.interval = newInterval
        Log.getInstance().writeLine((mstime(), 0), "TASK_INTERVAL", \
                                    [self.getIdentifier(), newInterval])

    def setLastRun(self, newLastRun):
        """
        Sets the time (on a logical clock) the task
        was last executed. This is called by the
        PandaEPL task manager and should not be
        used by client scripts.
        """
        self.lastRun = newLastRun
        Log.getInstance().writeLine((mstime(), 0), "TASK_LASTRUN", \
                                    [self.getIdentifier(), newLastRun])

