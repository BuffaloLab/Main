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

from optparse import OptionParser
import re

class Options(OptionParser):
    """
    Manages experiment command line options.
    """
    
    singletonInstance = None

    def __init__(self):
        """
        Creates an Options object.
        """
        OptionParser.__init__(self)

        self.add_option('--config', action="store", dest="config", help="Path to configuration file. (Default: ./config.py)",
                        default="./config.py")
        self.add_option('--sconfig', action="store", dest="sconfig", help="Path to subject configuration file."+\
                        " (Default: None)")
        self.add_option('-s', action="store", dest="subjId", help="Subject ID  (Required)")
        self.add_option('--js-zero-threshold', action="store", dest="js_zero_threshold", help="Value beyond which "+\
                        "a joystick axis is considered 'pressed'. Axis values are in the range [0, 1]. (Default: 0.2)",
                        default=0.2)
        self.add_option('--no-eeg', action="store_true", dest="noEEG", help="Disable sync-pulsing.",
                        default=False)
        self.add_option('--show-fps', action="store_true", dest="showFps", help="Display frames per second.",
                        default=False)
        self.add_option('--no-fs', action="store_true", dest="noFS", help="Run the experiment in a window (not fullscreen).",
                        default=False)
        self.add_option('--resolution', action="store", dest="resolution", help="Screen resolution in the"+\
                        " format: WxH. (Default: 800x600)", default="800x600")

        (self.parsedValues, positionalArgs) = self.parse_args()
        self.__postProcess()

    def __postProcess(self):
        """
        Performs post-processing of command line 
        options.
        """
        # Parse resolution.
        resolutionMatch = re.compile("(?P<resW>\d+)[Xx](?P<resH>\d+)").match(self.parsedValues.resolution)
        self.parsedValues.resW = int(resolutionMatch.group('resW'))
        self.parsedValues.resH = int(resolutionMatch.group('resH'))
    
    def getInstance(cls):
        """
        Returns a reference to (the one and only)
        Options instance. Use this instead of
        instantiating a copy directly.
        """
        if Options.singletonInstance == None:
            Options.singletonInstance = Options()
        return Options.singletonInstance

    getInstance = classmethod(getInstance)

    def get(self):
        """
        Returns an object with attributes matching
        the supported command line options. Parsing 
        is done when the object is first created, 
        this function returns a cached copy.
        """
        return self.parsedValues

