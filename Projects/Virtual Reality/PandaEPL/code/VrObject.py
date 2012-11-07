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

from Identifiable        import Identifiable
from Log                 import Log
from Tuples              import *
from VideoLogQueue       import VideoLogQueue as VLQ
from pandac.PandaModules import TransparencyAttrib

class VrObject(Identifiable):
    """
    The base class for all objects that exist in the VR world.
    """

    Log.getInstance().addType("VROBJECT_REMOVE", [('identifier',basestring)])
    Log.getInstance().addType("VROBJECT_COLLISIONCALLBACK", \
                                [('identifier',basestring), ('callback',basestring)])
    Log.getInstance().addType("VROBJECT_FOGOFF", [('identifier',basestring)])
    Log.getInstance().addType("VROBJECT_FOGON", \
                                [('identifier',basestring), ('fogIdentifier',basestring)])
    Log.getInstance().addType("VROBJECT_HEADING", \
                                [('identifier',basestring), ('value',Log.number)])
    Log.getInstance().addType("VROBJECT_HPR", \
                                [('identifier',basestring), ('value',VBase3)])
    Log.getInstance().addType("VROBJECT_PITCH", \
                                [('identifier',basestring), ('value',Log.number)])
    Log.getInstance().addType("VROBJECT_POS", \
                                [('identifier',basestring), ('value',VBase3)])
    Log.getInstance().addType("VROBJECT_ROLL", \
                                [('identifier',basestring), ('value',Log.number)])
    Log.getInstance().addType("VROBJECT_SCALE", \
                                [('identifier',basestring), ('value',VBase3)])
    Log.getInstance().addType("VROBJECT_STASHED", \
                                [('identifier',basestring), ('value',bool)])
    Log.getInstance().addType("VROBJECT_STICKSTOSCREEN", \
                                [('identifier',basestring), ('value',bool)])
    Log.getInstance().addType("VROBJECT_TRANSPARENCY", \
                                [('identifier',basestring), ('value',bool)])
    Log.getInstance().addType("VROBJECT_VISIBLE", \
                                [('identifier',basestring), ('value',bool)])

    def __init__(self, identifier, nodePath, callback=None):
        """
        Creates the object from a Panda3D NodePath.

        A VRObject SHOULD NOT BE CREATED DIRECTLY BY
        A CLIENT SCRIPT.

        Clients should use the library to create a specific type
        of VRObject (Model, Light, Text, etc).

        identifier - A unique string identifier for this object.
        nodePath   - A Panda3D NodePath object.
        callback   - A function to call when this object collides with
                     a MovingObject.
        """
        Identifiable.__init__(self, identifier)

        self.nodePath       = nodePath
        self.oldPos         = None
        self.sticksToScreen = None
        self.setSticksToScreen(False)
        self.setVisible(True)
        self.setCollisionCallback(callback)

        # Set internal Panda3D node names to the same identifer
        # as the top-level PandaEPL object.
        self.nodePath.node().setName(identifier)
        for np in self.nodePath.findAllMatches("**").asList():
            np.setName(identifier)

        # Pre-load textures, other internal Panda3D initializations.
        if base.win != None:
          nodePath.prepareScene(base.win.getGsg())

    def __del__(self):
        """
        Destroys the object.
        """
        self.nodePath.removeNode()
        VLQ.getInstance().writeLine("VROBJECT_REMOVE", [self.getIdentifier()])

    def retrNodePath(self):
        """
        Used internally by PandaEPL, client scripts should not 
        rely on this function.

        Returns the underlying Panda3D NodePath.
        """
        return self.nodePath

    def getCollisionCallback(self):
        """
        Returns the function that's called when the object collides
        with a MovingObject or None if not set.
        """
        return self.collisionCallback

    def getH(self):
        """
        Returns the object's heading, in degrees.
        """
        return self.nodePath.getH()

    def getHpr(self):
        """
        Returns a Point3 containing the object's
        heading, pitch, and roll.
        """
        return self.nodePath.getHpr()

    def getOldPos(self):
        """
        Returns the object's position before the last
        call to setPos(..).
        """
        return self.oldPos

    def getP(self):
        """
        Returns the object's pitch, in degrees.
        """
        return self.nodePath.getP()

    def getPos(self):
        """
        Returns a Point3 containg the object's position.
        """
        return self.nodePath.getPos(base.render2d)

    def getR(self):
        """
        Returns the object's roll, in degrees.
        """
        return self.nodePath.getR()

    def getScale(self):
        """
        Returns the object's scale components (Point3).
        """
        return self.nodePath.getScale()

    def isTransparency(self):
        """
        Returns a boolean specifying whether transparency
        is enabled.
        """
        return self.nodePath.hasTransparency()

    def isStashed(self):
        """
        Returns a boolean specifying whether the object
        is stashed. See setStashed(..).
        """
        return self.nodePath.isStashed()

    def isSticksToScreen(self):
        """
        Returns False if the object is in the 3D world, True if its in front.
        """
        return self.sticksToScreen

    def isVisible(self):
        """
        Returns a boolean specifying whether the object is visible.
        """
        return self.visible

    def setCollisionCallback(self, newCollisionCallback):
        """
        Sets the function that's called when the object collides
        with a MovingObject, could be None. It will receive a list
        of CollisionInfo objects, one for each geom-geom level
        collision between it and the MovingObject.
        NOTE: To simplify model creation, collision detection
        is still performed against any collision solids in the
        model even if this value is set to None. However, no 
        events are then fired.
        """
        # Tell the vr environment about the callback
        # and log the event.
        from Vr import Vr
        vr = Vr.getInstance()
        if newCollisionCallback == None:
            vr.unregisterIntoObject(self)
            callbackName = "None"
        else:
            vr.registerIntoObject(self)
            callbackName = newCollisionCallback.__name__

        self.collisionCallback = newCollisionCallback
        VLQ.getInstance().writeLine("VROBJECT_COLLISIONCALLBACK", \
                                    [self.getIdentifier(), callbackName])

    def setFog(self, fog):
        """
        Sets the given Fog object to act on this
        this VrObject. If None, any existing fog
        effect is removed.
        """
        if fog==None:
            self.nodePath.clearFog()
            VLQ.getInstance().writeLine("VROBJECT_FOGOFF", [self.getIdentifier()])
        else:
            self.nodePath.setFog(fog.retrNodePath().node())
            VLQ.getInstance().writeLine("VROBJECT_FOGON", [self.getIdentifier(), 
                                                           fog.getIdentifier()])

    def setH(self, newH):
        """
        Sets the object's heading, in degrees.
        """
        self.nodePath.setH(newH)
        VLQ.getInstance().writeLine("VROBJECT_HEADING", \
                                    [self.getIdentifier(), newH])

    def setHpr(self, newHpr):
        """
        Sets the object's heading, pitch and roll, in degrees.
        newHpr - Point3
        """
        self.nodePath.setHpr(newHpr)
        VLQ.getInstance().writeLine("VROBJECT_HPR", \
                                    [self.getIdentifier(), newHpr])
    def setP(self, newP):
        """
        Sets the object's pitch, in degrees.
        """
        self.nodePath.setP(newP)
        VLQ.getInstance().writeLine("VROBJECT_PITCH", \
                                    [self.getIdentifier(), newP])
    def setPos(self, newPos):
        """
        Sets the object's position (Point3).
        """
        self.oldPos = self.nodePath.getPos()
        self.nodePath.setPos(base.render2d, newPos)
        VLQ.getInstance().writeLine("VROBJECT_POS", \
                                    [self.getIdentifier(), newPos])

    def setPosHpr(self, newPos, newHpr):
        """
        Sets the object's position (Point3) and Hpr (Point3) 
        in one shot. See setPos(..) and setHpr(..).
        """
        self.setPos(newPos)
        self.setHpr(newHpr)

    def setR(self, newR):
        """
        Sets the object's roll, in degrees.
        """
        self.nodePath.setR(newR)
        VLQ.getInstance().writeLine("VROBJECT_ROLL", \
                                    [self.getIdentifier(), newR])

    def setScale(self, newScale):
        """
        Sets the object's scale components (Point3).
        If given a single value, all three components
        are set to that same value.
        """
        self.nodePath.setScale(newScale)
        if isinstance(newScale, Point3):
            scaleToLog = newScale
        else:
            scaleToLog = Point3(newScale, newScale, newScale)
        VLQ.getInstance().writeLine("VROBJECT_SCALE", \
                                    [self.getIdentifier(), scaleToLog])

    def setStashed(self, newStashed):
        """
        If True, the object is completely removed from
        the environment, but not destroyed. This is 
        different from being invisible, because invisible
        objects still participate in collision detection
        (for instance), whereas stashed objects do not.
        """
        if newStashed and not self.nodePath.isStashed():
            self.nodePath.stash()
            VLQ.getInstance().writeLine("VROBJECT_STASHED", \
                                        [self.getIdentifier(), True])
        elif not newStashed and self.nodePath.isStashed():
            self.nodePath.unstash()
            VLQ.getInstance().writeLine("VROBJECT_STASHED", \
                                        [self.getIdentifier(), False])

    def setSticksToScreen(self, newSticks):
        """
        False if the object is in the 3D world, True if its in front.
        """
        # Panda3D automatically unstashes a node after it's
        # re-parented. We don't want/need this feature.
        oldStashed = self.nodePath.isStashed()

        if newSticks and (self.sticksToScreen==None or not self.sticksToScreen):
            self.nodePath.reparentTo(base.aspect2d)
            VLQ.getInstance().writeLine("VROBJECT_STICKSTOSCREEN", \
                                        [self.getIdentifier(), True])
        elif not newSticks and (self.sticksToScreen==None or self.sticksToScreen):
            self.nodePath.reparentTo(base.render)
            VLQ.getInstance().writeLine("VROBJECT_STICKSTOSCREEN", \
                                        [self.getIdentifier(), False])

        self.sticksToScreen = newSticks
        if oldStashed and not self.nodePath.isStashed():
            self.nodePath.stash()

    def setTransparency(self, newTransparency):
        """
        Sets transparency on or off (boolean).
        """
        if newTransparency and not self.nodePath.hasTransparency():
            self.nodePath.setTransparency(TransparencyAttrib.MAlpha)
            VLQ.getInstance().writeLine("VROBJECT_TRANSPARENCY", \
                                        [self.getIdentifier(), True])
        elif not newTransparency and self.nodePath.hasTransparency():
            self.nodePath.clearTransparency()
            VLQ.getInstance().writeLine("VROBJECT_TRANSPARENCY", \
                                        [self.getIdentifier(), False])

    def setVisible(self, newVisible):
        """
        Sets object's visibility (boolean).
        """
        if newVisible and self.nodePath.isHidden():
            self.nodePath.show()
            VLQ.getInstance().writeLine("VROBJECT_VISIBLE", \
                                        [self.getIdentifier(), True])
        elif not newVisible and not self.nodePath.isHidden():
            self.nodePath.hide()
            VLQ.getInstance().writeLine("VROBJECT_VISIBLE", \
                                        [self.getIdentifier(), False])
        self.visible = newVisible

