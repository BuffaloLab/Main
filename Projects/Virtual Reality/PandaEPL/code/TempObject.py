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

from Task   import Task
from Tuples import *
from Vr     import Vr
from ptime import *

class TempObject:
    """
    Creates a short-lived VrObject. Especially 
    useful for flashing Text and Image objects.
    """

    def __init__(self, vrObject, minTime, screenColor=Point4(0,0,0,0.5),callback=None):
        """
        Creates a TempObject.

        vrObject   -  VrObject
        minTime    -  float, minimum number of seconds until
                      the given object is destroyed. The actual
                      time may be slightly more, depending on the
                      frame rate.
        screenColor - Point4, the color to blank the screen to when 
                      displaying the object. If None, the screen will 
                      not be blanked. The default value is a 
                      semi-transparent black.
        callback    - callback to run after TempObject is destroyed 
        """
        self.vrObject = vrObject

        vr = Vr.getInstance()
        vr.setIntermission(True)
        if screenColor!=None:
            vr.blankScreen(screenColor)
        vrObject.setStashed(False)
        vr.addTask(Task(vrObject.getIdentifier()+"_temp", self.destroy, minTime, startNow=False))
	self.callback = callback
    
    def destroy(self, taskInfo):
        """
        Destroys the associated VrObject. This is called 
        automatically by PandaEPL at the appropriate time
        and should generally not be called directly by
        client scripts.
        """
        del self.vrObject
        vr = Vr.getInstance()
        vr.blankScreenOff()
        vr.setIntermission(False)

        if self.callback:
            timestamp, callbackVal = timedCall(self.callback) 
   
        return False
        
