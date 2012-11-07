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

from Exceptions           import *
from Log                  import Log
from UniquelyIdentifiable import UniquelyIdentifiable
from ptime                import *
from direct.task.Task     import Task as Panda3D_Task 

hasTksound = True
try:
    import tkSnack
    import Tkinter
    import _tkinter
except ImportError:
    hasTksound = False

if not hasTksound:
    class SimpleSound:
        def __init__(self, identifier):
            raise SoundException, "Can't create a SimpleSound object, the "+\
                                  "tkSnack and/or Tkinter libraries are missing."
else:
    class SimpleSound(tkSnack.Sound, UniquelyIdentifiable):
        """
        Supports basic (e.g. non-3D) sound playback and recording.
        """
    
        # tkSnack needs Tk to run, even if we're not 
        # using it. Here we initialize things and hide
        # the default Tk window.
        tkRoot = Tkinter.Tk()
        tkRoot.withdraw()
        tkSnack.initializeSnack(tkRoot)

        # We create a task that gives Tcl/Tk a chance
        # to check for and dispatch any pending events.
        def tkEventsTask(taskInfo):
            while SimpleSound.tkRoot.dooneevent(_tkinter.ALL_EVENTS | _tkinter.DONT_WAIT):
                pass
            return Panda3D_Task.cont
        base.taskMgr.add(tkEventsTask, "PandaEPL_tkEventsTask", -10000) # Sound goes before pretty much anything.
        del tkEventsTask

        Log.getInstance().addType("SIMPLESOUND_INIT", [('identifier',basestring)])
        Log.getInstance().addType("SIMPLESOUND_CREATED", [('identifier',basestring)])
        Log.getInstance().addType("SIMPLESOUND_ASSOCFILE", [('identifier',basestring), ('file',basestring)])
        Log.getInstance().addType("SIMPLESOUND_LOADFILE", [('identifier',basestring), ('file',basestring)])
        Log.getInstance().addType("SIMPLESOUND_PLAY", [('identifier',basestring), ('blocking',bool)])
        Log.getInstance().addType("SIMPLESOUND_RECORD", [('identifier',basestring)])
        Log.getInstance().addType("SIMPLESOUND_STOP", [('identifier',basestring)])
        Log.getInstance().addType("SIMPLESOUND_WRITE", [('identifier',basestring), ('file',basestring)])

        def __init__(self, identifier):
            """
            Creates a SimpleSound object.

            identifier - string, a unique identifier for this object
            """
            Log.getInstance().writeLine((mstime(), 0), "SIMPLESOUND_INIT", \
                                    [identifier])
            UniquelyIdentifiable.__init__(self, identifier)
            tkSnack.Sound.__init__(self)
            self["frequency"] = 44100
            Log.getInstance().writeLine((mstime(), 0), "SIMPLESOUND_CREATED", \
                                        [identifier])

        def __del__(self):
            """
            Destroys the object.
            """
            UniquelyIdentifiable.__del__(self)

        def load(self, filename):
            """
            Loads the given file into memory.
            """
            timestamp, returnVal = timedCall(tkSnack.Sound.load, self, filename)
            Log.getInstance().writeLine(timestamp, "SIMPLESOUND_LOADFILE", \
                                        [self.getIdentifier(), filename])

        def play(self, blocking=True):
            """
            Plays the file set with setFile(..) or load(..).
            """
            timestamp, returnVal = timedCall(tkSnack.Sound.play, self, blocking=blocking)
            Log.getInstance().writeLine(timestamp, "SIMPLESOUND_PLAY", \
                                        [self.getIdentifier(), blocking])

        def record(self):
            """
            Starts recording.
            """
            timestamp, returnVal = timedCall(tkSnack.Sound.record, self)
            Log.getInstance().writeLine(timestamp, "SIMPLESOUND_RECORD", \
                                        [self.getIdentifier()])

        def stop(self):
            """
            Stops playback or recording.
            """
            timestamp, returnVal = timedCall(tkSnack.Sound.stop, self)
            Log.getInstance().writeLine(timestamp, "SIMPLESOUND_STOP", \
                                        [self.getIdentifier()])

        def write(self, filename):
            """
            Writes the contents in memory to the given file.
            """
            timestamp, returnVal = timedCall(tkSnack.Sound.write, self, filename)
            Log.getInstance().writeLine(timestamp, "SIMPLESOUND_WRITE", \
                                        [self.getIdentifier(), filename])

        def getFile(self):
            """
            Returns the sound file associated with the object.
            See setFile(..).
            """
            return self["file"]

        def setFile(self, newFilename):
            """
            Associates the given sound file with the object,
            but does not read it into memory right away. 
            This is useful, for instance, if you want to play
            a large file that may not fit into memory. When
            you call play(..), the file will be read a bit
            at a time. Of course, such operations are slower
            than in-memory operations and may result in choppiness.
            """
            # This goes against the general preference of using
            # attributes instead of getters and setters in Python
            # (i.e. we're wrapping a setter around an attribute!),
            # but this is done to keep things consistent with the rest
            # of the library, which is based on Panda3D and uses
            # getters and setters.
            self["file"] = newFilename
            Log.getInstance().writeLine((mstime(), 0), "SIMPLESOUND_ASSOCFILE", \
                                        [self.getIdentifier(), newFilename])

