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

from pandac.PandaModules  import Camera as Panda3D_Camera, NodePath, PerspectiveLens
from Conf                 import Conf
from Log                  import Log
from Options              import Options
from UniquelyIdentifiable import UniquelyIdentifiable
from VideoLogQueue        import VideoLogQueue as VLQ
from VrObject             import VrObject
from ptime                import *

class Camera(VrObject, UniquelyIdentifiable):
    """
    A viewport into the Vr environment.
    """

    defaultInstance = None

    Log.getInstance().addType("CAMERA_INIT", [('identifier',basestring)])
    Log.getInstance().addType("CAMERA_CREATED", [('identifier',basestring)])
    Log.getInstance().addType("CAMERA_FOV", [('identifier',basestring), \
                              ('horzFov',Log.number), ('vertFov',Log.number)])
    Log.getInstance().addType("CAMERA_ASPECTRATIO", [('identifier',basestring), \
                              ('aspectRatio',Log.number)]) 

    def __init__(self, identifier, horzFov, vertFov=None, aspectRatio=None):
        """
        Creates a Camera object.

        identifier  - string, a unique identifier for this object
        horzFov     - Horizontal field of view.
        vertFov     - Vertical field of view. If None, this will
                      automatically be set to maintain the aspect 
                      ratio.
        aspectRatio - The ratio of the height to the width of the image.
                      If None, this will automatically be set to the
                      aspect ratio of the main window.
        """
        Log.getInstance().writeLine((mstime(), 0), "CAMERA_INIT", [identifier])        
        UniquelyIdentifiable.__init__(self, identifier)

        # Create underlying Panda3D camera.
        camera = Panda3D_Camera(identifier)
        camera.setLens(PerspectiveLens())

        # Initialize base properties.
        VrObject.__init__(self, identifier, NodePath(camera))

        # Initialize properties.
        self.setAspectRatio(aspectRatio)
        self.setFov(horzFov, vertFov)

        VLQ.getInstance().writeLine("CAMERA_CREATED", [identifier])

    def __del__(self):
        """
        Destroys the object.
        """
        VrObject.__del__(self)
        UniquelyIdentifiable.__del__(self)

    def configEvent(cls, eventName, **dargs):
        """
        Updates the default camera with the current 
        configuration values. Generally called by the 
        Conf class and should not be used by PandaEPL 
        client code directly.
        """
        config = Conf.getInstance().getConfig()

        if eventName == "configChanged":
            if config.has_key('vFOV'):
                Camera.defaultInstance.setFov(config['FOV'], config['vFOV'])
            else:
                Camera.defaultInstance.setFov(config['FOV'])

    configEvent = classmethod(configEvent)

    def getDefaultCamera(cls):
        """
        Returns the default camera used in the VR
        environment. If you're not doing anything
        out of the ordinary, use this instead of
        creating a new camera.
        """
        if Camera.defaultInstance == None:
            Camera.defaultInstance = Camera("PandaEPL_defaultCamera", 0)

            # Set aspect ratio.
            options = Options.getInstance().get()
            Camera.defaultInstance.setAspectRatio(float(options.resW)/float(options.resH))

            # Listen for configuration changes.
            Conf.getInstance().registerObserver(Camera.configEvent)

        return Camera.defaultInstance
       
    getDefaultCamera = classmethod(getDefaultCamera)
 
    def getAspectRatio(self):
        """
        Returns the aspect ratio.
        """
        return self.retrNodePath().node().getLens().getAspectRatio()

    def getFov(self):
        """
        Returns the horizontal and vertical field of 
        view in a Vec2.
        """
        return self.retrNodePath().node().getLens().getFov()

    def setAspectRatio(self, newAspectRatio):
        """
        Sets the aspect ratio. If called with None,
        resets the aspect ratio to that of the main window.
        """
        if newAspectRatio == None:
            self.retrNodePath().node().getLens().setAspectRatio(base.getAspectRatio())
        else:
            self.retrNodePath().node().getLens().setAspectRatio(newAspectRatio)

        VLQ.getInstance().writeLine("CAMERA_ASPECTRATIO", [self.getIdentifier(), newAspectRatio])

    def setFov(self, newHorzFov, newVertFov=None):
        """
        Sets the camera's field of view.
        See the class constructor for details.
        """
        if newVertFov == None:
            self.retrNodePath().node().getLens().setFov(newHorzFov)
            VLQ.getInstance().writeLine("CAMERA_FOV", [self.getIdentifier(), newHorzFov, \
                                         self.retrNodePath().node().getLens().getVfov()])
        else:
            self.retrNodePath().node().getLens().setFov(newHorzFov, newVertFov)
            VLQ.getInstance().writeLine("CAMERA_FOV", [self.getIdentifier(), newHorzFov, newVertFov])

