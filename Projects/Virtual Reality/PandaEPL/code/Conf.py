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

import os
import sys
from Exceptions import *
from Log        import Log
from Observable import Observable
from Options    import Options
from ptime      import *

# Make these available inside config files.
from Tuples     import *
from Keyboard   import Keyboard
from Joystick   import Joystick

class Conf(Observable):
    """
    Global configuration handler.
    """

    singletonInstance = None
    Log.getInstance().addType("CONF_LOAD", [('configFile',str), ('sconfigFile',basestring)])

    def __init__(self):
        """
        Creates a Conf object. Client scripts should treat
        Conf as a singleton and get reference to it using
        getInstance() instead of creating a new instance.
        """
        Observable.__init__(self)

        # Filenames
        self.configFile  = None
        self.sconfigFile = None

        # The actualy configuration dictionary.
        self.config      = {}

        # Whether a configuration has been loaded yet.
        self.loaded      = False

    def getInstance(cls):
        """
        Returns a reference to (the one and only) Conf instance.
        Use this instead of instantiating a copy directly.
        """
        if Conf.singletonInstance == None:
            Conf.singletonInstance = Conf()
        return Conf.singletonInstance

    getInstance = classmethod(getInstance)

    def load(self, configFile, sconfigFile=None):
        """
        Loads the given configuration and subject configuration
        files.
        """
        self.configFile  = configFile
        self.sconfigFile = sconfigFile

        oldConfig   = self.config
        self.config = {}
        execfile(configFile, globals(), self.config)
        if sconfigFile != None:
            execfile(sconfigFile, globals(), self.config)

        self.loaded = True
        Log.getInstance().writeLine((mstime(), 0), "CONF_LOAD", [configFile, sconfigFile])
        self.notify("configChanged", oldConfig=oldConfig)

    def loadDefault(self):
        """
        Loads the configuration and subject configuration
        files specified on the command line. If no
        configuration file is specified, './config.py' is
        assumed.
        """
        options = Options.getInstance().get()
        if not os.access(options.config, os.F_OK):
            options.error("Configuration file '"+options.config+"' was not found.")
        if options.sconfig != None and not os.access(options.sconfig, os.F_OK):
            options.error("Subject configuration file '"+options.sconfig+"' was not found.")

        self.load(options.config, options.sconfig)

    def registerObserver(self, observer):
        """
        Adds the given callback to the list of entities
        that receive calls made by notify.
        """
        Observable.registerObserver(self, observer)
        if self.isLoaded():
            observer("configChanged", oldConfig={})

    def getConfig(self):
        """
        Returns a dictionary with the currently loaded
        configuration values.
        """
        return self.config

    def getConfigFile(self):
        """
        Returns the path to the configuration file
        specified with load(..).
        """
        return self.configFile

    def getSconfigFile(self):
        """
        Returns the path to the subject configuration file
        specified with load(..).
        """
        return self.sconfigFile

    def isLoaded(self):
        """
        Returns a boolean specifying whether a configuration
        has been loaded.
        """
        return self.loaded

