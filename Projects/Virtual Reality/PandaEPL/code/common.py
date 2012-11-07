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



# Most clients will import PandaEPL using this file,
# e.g. from pandaepl.common import *

# Load commonly used PandaEPL features.
from pandaepl.AmbientLight import AmbientLight
from pandaepl.Avatar import Avatar
from pandaepl.Camera import Camera
from pandaepl.Conf import Conf
from pandaepl.DirectionalLight import DirectionalLight
from pandaepl.Exceptions import *
from pandaepl.Experiment import Experiment
from pandaepl.ExpFog import ExpFog
from pandaepl.Image import Image
from pandaepl.Instructions import Instructions
from pandaepl.LinearFog import LinearFog
from pandaepl.Log import Log
from pandaepl.LogQueue import LogQueue
from pandaepl.Model import Model
from pandaepl.MovingObject import MovingObject
from pandaepl.Options import Options
from pandaepl.PointLight import PointLight
from pandaepl.SpotLight import SpotLight
from pandaepl.Task import Task
from pandaepl.TempObject import TempObject
from pandaepl.Text import Text
from pandaepl.Tuples import *
from pandaepl.VideoLogQueue import VideoLogQueue as VLQ
from pandaepl.Vr import Vr
from pandaepl.ptime import *

# Suppress default Panda3D window, load window
# options.
from pandac.PandaModules import loadPrcFileData, WindowProperties
log = Log.getInstance()
options  = Options.getInstance().get()
optCmd   = "window-type none\n"
optCmd  += "auto-flip 0\n"
optCmd  += "win-size "+str(options.resW)+" "+str(options.resH)+"\n"
optCmd  += "fullscreen "+str(int(not options.noFS))+"\n"
optCmd  += "show-frame-rate-meter "+str(int(options.showFps))+"\n"
optCmd  += "framebuffer-multisample 1\n"
timestamp, returnVal = timedCall(loadPrcFileData, "", optCmd)

log.addType("COMMON_WIN_PROPERTIES", [('resW',int), ('resH',int), \
                                      ('fullscreen',bool), ('showFps',bool)])
log.writeLine(timestamp, "COMMON_WIN_PROPERTIES", [options.resW, options.resH, \
                                                   not options.noFS, options.showFps])

del loadPrcFileData
del options
del log

# Start up Panda3D, setup our camera, and open 
# a window.
import direct.directbase.DirectStart
base.cam     = Camera.getDefaultCamera().retrNodePath()
base.camNode = Camera.getDefaultCamera().retrNodePath().node()
base.camLens = Camera.getDefaultCamera().retrNodePath().node().getLens()
base.openDefaultWindow(startDirect=False, props=WindowProperties.getDefault(), keepCamera=True)
del WindowProperties

# Modules that need to be loaded after Panda3D has been initialized.
from pandaepl.SimpleSound import SimpleSound

# Calibrate the Joystick.
from Joystick import Joystick
Joystick.getInstance().calibrate()
del Joystick

