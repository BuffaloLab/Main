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

from Log              import Log
from direct.task.Task import Task as Panda3D_Task
from Exceptions       import *
from Experiment       import Experiment
from Options          import Options
from ptime            import *
import random
import time

class EEG:
    """
    Sync-pulsing via ActiveWire.
    """

    singletonInstance = None

    eegLog = Log()
    eegLog.addType("UP", [], False)
    eegLog.addType("DN", [], False)
    eegLog.addType("TRAIN_UP", [], False)
    eegLog.addType("TRAIN_DN", [], False)

    # Length of the pulse in msec.
    pulseDuration = 10

    def __init__(self):
        """
        Creates an EEG object. Client scripts should treat
        EEG as a singleton and get references to it using
        getInstance() instead of creating a new instance.
        """
        from eeg.activewire.awCard import awCard
        self.awCard = awCard()

        # When the last sync pulse ended.
        self.syncPulseOffTime = mstime()

        # When the sync pulse was turned on, None if it's off.
        self.syncPulseOnTime = None

        # Time between previous sync pulse ending and the 
        # next one starting. This varies between 750ms and
        # 1250ms for each pulse, to aid in the alignment
        # of behavioral and eeg data.
        self.syncPulseInterval = 1000

        # Listen for Experiment-level events.
        Experiment.getInstance().registerObserver(self.expEvent)

        # Listen for VR events.
        from Vr import Vr
        Vr.getInstance().registerObserver(self.vrEvent)

    def pulse(self, prefix=""):
        """
        Sends a pulse, blocking between the on and off state, 
        and logs it. If a sync-pulse is being sent, it's 
        interrupted.

        prefix    - string, identifier for the pulse,
                    used for logging
        """
        if self.syncPulseOnTime != None:
            self.__syncPulse(False)

        self.__pulse(True,prefix)
        time.sleep(EEG.pulseDuration/1000.0)
        self.__pulse(False,prefix)
            
    def pulseTrain(self, n, identifier):
        """
        Sends n pulses with prefix TRAIN in a row. See pulse(..).
        """
        EEG.eegLog.addType(identifier, [])
        EEG.eegLog.writeLine((mstime(), 0), identifier, [])
        for i in range(n):
            self.pulse("TRAIN")

    def getInstance(cls):
        """
        Returns a reference to (the one and only) EEG instance.
        Use this instead of instantiating a copy directly.
        """
        if EEG.singletonInstance == None:
            EEG.singletonInstance = EEG()
        return EEG.singletonInstance
    
    getInstance = classmethod(getInstance)

    def eegTask(self, pandaTaskInfo):
        """
        A Panda3D task that handles sync-pulsing in a non-blocking way.
        """
        # If sync-pulse is on, see if we have to turn it off.
        if self.syncPulseOnTime != None and \
           mstime() >= self.syncPulseOnTime + EEG.pulseDuration:
            self.__syncPulse(False)

        # If sync-pulse is not on, see if it's time to send another.
        if self.syncPulseOnTime == None and \
           mstime() >= self.syncPulseOffTime + self.syncPulseInterval:
            self.__syncPulse(True)

        return Panda3D_Task.cont

    def expEvent(self, eventName, **dargs):
        """
        Listens for Experiment events. Generally called by 
        the Experiment class and should not be used by 
        PandaEPL client code directly.
        """
        if eventName == "setSessionNum":
            EEG.eegLog.setLogFile(Experiment.getInstance().getSesDirectory()+"/eeg.eeglog")
            EEG.eegLog.setTypeFile(Experiment.getInstance().getSesDirectory()+"/eegFormat.pkl")

    def vrEvent(self, eventName, **dargs):
        """
        Listens for VR events. Generally called by 
        the VR class and should not be used by 
        PandaEPL client code directly.
        """
        if eventName == "loopStarted":
            # Register a Panda3D task that will handle sync-pulsing.
            if not Options.getInstance().get().noEEG:
              base.taskMgr.add(self.eegTask, "PandaEPL_eegTask", -1)

    def __pulse(self, on, prefix=""):
        """
        Turns the pulse on or off and returns the time
        at which the state changed occurred.

        on     - boolean      
        prefix - string, identifier for the pulse,
                 used for logging
        """
        if prefix != "":
            prefix = prefix + "_"

        if on:
            timestamp, returnVal = timedCall(self.awCard.allOn)
            EEG.eegLog.writeLine(timestamp, prefix+"UP", [])
        else:
            timestamp, returnVal = timedCall(self.awCard.allOff)
            EEG.eegLog.writeLine(timestamp, prefix+"DN", [])

        return timestamp[0]

    def __syncPulse(self, on):
        """
        Same as __pulse(..), but keeps track of variables
        used by the sync-pulsing task.

        on     - boolean
        """
        if on:
            self.syncPulseOnTime   = self.__pulse(True)
        else:
            self.syncPulseOffTime  = self.__pulse(False)
            self.syncPulseOnTime   = None
            self.syncPulseInterval = random.uniform(750,1250)

