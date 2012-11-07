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

from Conf        import Conf
from Log         import Log
from Observable  import Observable
from Options     import Options
from Exceptions  import *
from quickpickle import *
import shutil
import os
import sys

class Experiment(Observable):
    """
    The entry point to an experiment.
    """
    singletonInstance = None

    def __init__(self):
        """
        Creates an Experiment object.
        """
        Observable.__init__(self)

        # If the data directory doesn't exist, create it.
        DATA_DIR = "./data"
        if not os.access(DATA_DIR, os.F_OK):
            os.mkdir(DATA_DIR, 0755)

        # Get experiment data directory.
        options = Options.getInstance().get()
        if options.subjId==None:
            Options.getInstance().error("Please specify a subject ID with '-s'.")
        self.expDir = DATA_DIR + "/" + options.subjId

        # If the experiment data directory doesn't exist, create it.
        if not os.access(self.expDir, os.F_OK):
            os.mkdir(self.expDir, 0755)
        
        # File that holds experiment state.
        self.expStateFilename = self.expDir + "/expState.pkl"

        # Experiment state dictionary.
        # If this is not the first time the experiment is run,
        # load it. 
        self.expState = None
        if os.access(self.expStateFilename, os.F_OK):
            self.expState = quickUnpickle(self.expStateFilename)
        # Otherwise, initialize a new one.
        else:
            self.expState = dict()
            self.expState['userState'] = dict()

        # Whether a session number has been set. This must be
        # done before starting a session.
        self.sessionNumSet = False

        # Whether the experiment has been started yet.
        self.started = False

    def getInstance(cls):
        """
        Returns a reference to (the one and only) Experiment
        instance. Use this isntead of instantiating a copy
        directly.
        """
        if Experiment.singletonInstance == None:
            Experiment.singletonInstance = Experiment()
        return Experiment.singletonInstance

    getInstance = classmethod(getInstance)

    def registerObserver(self, observer):
        """
        Adds the given callback to the list of entities
        that receive calls made by notify.
        """
        Observable.registerObserver(self, observer)
        if self.sessionNumSet:
            observer("setSessionNum")

    def start(self):
        """
        Starts running the experiment.
        """
        if not self.sessionNumSet:
            raise SessionException, "A session number must be set with " +\
                                    "Experiment.setSessionNum(..) before " +\
                                    "starting the experiment."

        self.started = True
        from Vr import Vr
        if not Options.getInstance().get().noEEG:
            from EEG import EEG
            EEG.getInstance().pulseTrain(10, "EXPSTART_TRAIN")
        Vr.getInstance().loop()

    def stop(self):
        """
        Stops the experiment and exits.
        """
        if not Options.getInstance().get().noEEG:
            from EEG import EEG
            EEG.getInstance().pulseTrain(5, "EXPEND_TRAIN")
        sys.exit()

    def getExpDirectory(self):
        """
        Returns a path to the experiment data directory.
        """
        return self.expDir

    def getSesDirectory(self):
        """
        Returns a path to the session data directory.
        """
        return self.expDir + "/session_" + str(self.getSessionNum())

    def getSessionNum(self):
        """
        Returns the current session number.
        """
        return self.expState['sessionNum']

    def getState(self):
        """
        Returns a dictionary of user-defined state values.
        """
        return self.expState['userState']

    def isStarted(self):
        """
        Whether the experiment has been started yet.
        """
        return self.started

    def setSessionNum(self, newSessionNum):
        """
        Starts a new session of the experiment.
        """
        self.sessionNumSet = True

        # Set new session number.
        self.expState['sessionNum'] = newSessionNum

        # Save new experiment state.
        quickPickle(self.expStateFilename, self.expState)

        # Make new session directory if it doesn't exist.
        if not os.access(self.getSesDirectory(), os.F_OK):
            os.mkdir(self.getSesDirectory(), 0755)

        # Tell the logger about the new session information.
        log = Log.getInstance()
        log.setLogFile(self.getSesDirectory()+"/log.txt")
        log.setTypeFile(self.getSesDirectory()+"/logFormat.pkl")

        # See if we can find saved config files (we're 
        # continuing this session). If so, load them.
        if os.access(self.getSesDirectory()+"/config.py", os.F_OK):
            if os.access(self.getSesDirectory()+"/sconfig.py", os.F_OK):
                sconfigFile = self.getSesDirectory()+"/sconfig.py"
            else:
                sconfigFile = None
            Conf.getInstance().load(self.getSesDirectory()+"/config.py", sconfigFile)
        # Otherwise move current conf files to new session directory.
        else:
            conf = Conf.getInstance()
            conf.loadDefault()
            shutil.copy(conf.getConfigFile(), self.getSesDirectory()+"/config.py")
            if conf.getSconfigFile() != None:
                shutil.copy(conf.getSconfigFile(), self.getSesDirectory()+"/sconfig.py")
             
        self.notify("setSessionNum")
 
    def setState(self, newState):
        """
        Sets the dictionary of user-defined state values.
        """
        if not isinstance(newState, dict):
            raise TypeError, "newState must be a dictionary."
        self.expState['userState'] = newState
        quickPickle(self.expStateFilename, self.expState)

