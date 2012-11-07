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

from Log                 import Log
from VrObject            import VrObject
from Vr                  import Vr
from Tuples              import *
from ptime               import *
from math                import sin,cos,radians
from pandac.PandaModules import CollisionNode, CollisionSphere

class MovingObject(VrObject):
    """
    An object which moves and can collide
    with other objects.
    """

    Log.getInstance().addType("MOVINGOBJECT_COLLISIONRADIUS", \
                                [('identifier',basestring), ('value',Log.number)])
    Log.getInstance().addType("MOVINGOBJECT_TRIGGERSCOLLISIONS", \
                                [('identifier',basestring), ('value',bool)])
    Log.getInstance().addType("MOVINGOBJECT_LINEARACCEL", \
                                [('identifier',basestring), ('value',Log.number)])
    Log.getInstance().addType("MOVINGOBJECT_LINEARSPEED", \
                                [('identifier',basestring), ('value',Log.number)])
    Log.getInstance().addType("MOVINGOBJECT_MAXBACKWARDSPEED", \
                                [('identifier',basestring), ('value',Log.number)])
    Log.getInstance().addType("MOVINGOBJECT_MAXFORWARDSPEED", \
                                [('identifier',basestring), ('value',Log.number)])
    Log.getInstance().addType("MOVINGOBJECT_MAXTURNINGSPEED", \
                                [('identifier',basestring), ('value',Log.number)])
    Log.getInstance().addType("MOVINGOBJECT_TURNINGACCEL", \
                                [('identifier',basestring), ('value',Log.number)])
    Log.getInstance().addType("MOVINGOBJECT_TURNINGSPEED", \
                                [('identifier',basestring), ('value',Log.number)])

    def __init__(self, identifier, nodePath, fromCollision):
        """
        Creates a MovingObject.

        A MovingObject SHOULD NOT BE CREATED DIRECTLY BY
        A CLIENT SCRIPT. Create a specific type of MovingObject
        instead, e.g. Avatar. 

        identifier    - string, a unique identifier for this object
        nodePath      - A Panda3D NodePath object.
        fromCollision - boolean, whether this object can collide with others
                        and trigger collision events.
        """
        VrObject.__init__(self, identifier, nodePath)

        # Collision.
        self.fromCollision = False
        self.setFromCollision(fromCollision)
        self.setCollisionRadius(0)

        # Linear.
        self.setMaxForwardSpeed(0)
        self.setMaxBackwardSpeed(0)
        self.setLinearSpeed(0)
        self.setLinearAccel(0)

        # Turning.
        self.setMaxTurningSpeed(0)
        self.setTurningSpeed(0)
        self.setTurningAccel(0)

    def __del__(self):
        """
        Destroys the object.
        """
        VrObject.__del__(self)

    def direction(self):
        """
        Returns a normalized vector in the 
        player's heading direction (i.e. around
        the z-axis).
        """
        objectAngle = radians(self.getH()+90)
        return Vec3(cos(objectAngle), sin(objectAngle), 0)

    def handleRepelCollision(collisionInfoList):
        """
        A useful generic collision callback that doesn't
        allow the colliding objects to go into one another.
        """
        fromObj = collisionInfoList[0].getFrom()
        fromObj.setLinearSpeed(0)
        fromObj.setPos(fromObj.getOldPos())

    handleRepelCollision = staticmethod(handleRepelCollision)

    def handleSlideCollision(collisionInfoList):
        """
        A useful generic collison callback that slides
        one object along the other.
        """	
        fromObj = collisionInfoList[0].getFrom()
	cNormal = collisionInfoList[0].getSurfaceNormal()
        dt      = collisionInfoList[0].getLastTime()
	
	if fromObj.getLinearSpeed() > 0:
		dir = 1
	else:
		dir = -1

        if len(collisionInfoList) > 1:
		cNormal2 = collisionInfoList[1].getSurfaceNormal()
		if dir * cNormal.dot(fromObj.direction()) < 0 and dir * cNormal2.dot(fromObj.direction()) < 0:
			MovingObject.handleRepelCollision(collisionInfoList)
			return
		elif dir * cNormal.dot(fromObj.direction()) > 0 and dir * cNormal2.dot(fromObj.direction()) < 0:
			cNormal = collisionInfoList[1].getSurfaceNormal()

	vel     = fromObj.direction() - (cNormal * cNormal.dot(fromObj.direction()))
        vel.normalize()

        slowFactor = 5.0
        if fromObj.getLinearSpeed() > fromObj.getMaxForwardSpeed()/slowFactor:
            fromObj.setLinearSpeed(fromObj.getMaxForwardSpeed()/slowFactor)
        elif fromObj.getLinearSpeed() < fromObj.getMaxBackwardSpeed()/slowFactor:
            fromObj.setLinearSpeed(fromObj.getMaxBackwardSpeed()/slowFactor)

        fromObj.setPos(fromObj.getOldPos() + vel*dt*fromObj.getLinearSpeed())

    handleSlideCollision = staticmethod(handleSlideCollision)

    def move(self, dt):
        """
        Moves the object based on its current direction, speed, 
        and the given dt. dt is in seconds.
        """
        self.setH(self.getH() + dt*self.getTurningSpeed())
        self.setPos(self.getPos() + self.direction()*dt*self.getLinearSpeed())

    def retrColNodePath(self):
        """
        Used internally by PandaEPL, client scripts should not 
        rely on this function.

        Returns the underlying Panda3D NodePath for the collision node.
        """
        return self.collisionNp

    def getCollisionIdentifier(self):
        """
        Returns a unique identifier for the collision sphere
        around this object.
        """
        return self.getIdentifier() + "Collision"
    
    def getCollisionRadius(self):
        """
        Returns the radius of the collision sphere for this object
        in VR units.
        """
        if not self.fromCollision:
            raise AttributeError, "getCollisionRadius() not valid on objects with fromCollision off"
        return self.collisionNp.node().modifySolid(0).getRadius()

    def getLinearAccel(self):
        """
        Returns the forward/backward acceleration
        of the player in VR units/s^2.
        """
        return self.linearAccel

    def getLinearSpeed(self):
        """
        Returns the current speed of the player
        in VR units/s.
        """
        return self.linearSpeed

    def getMaxBackwardSpeed(self):
        """
        Returns the maxmimum backward speed of 
        the player in VR units/s.
        """
        return self.maxBackwardSpeed

    def getMaxForwardSpeed(self):
        """
        Returns the maximum forward speed of
        the player in VR units/s.
        """
        return self.maxForwardSpeed

    def getMaxTurningSpeed(self):
        """
        Returns the maximum absolute turning 
        speed of the player in degrees/s.
        """
        return self.maxTurningSpeed

    def getTurningAccel(self):
        """
        Returns the turning acceleration of the 
        player in degrees/s^2.
        """
        return self.turningAccel

    def getTurningSpeed(self):
        """
        Returns the current turning speed of the 
        player in degrees/s.
        """
        return self.turningSpeed

    def isFromCollision(self):
        """
        Returns a boolean specifying whether this object can collide
        with others and trigger collision events.
        """
        return self.fromCollision

    def setCollisionRadius(self, newCollisionRadius=None):
        """
        Sets the radius of the collision sphere for this
        object in VR units. If None, this value defaults
        to the smallest radius encompassing all geometry.
        """
        if not self.fromCollision:
            raise AttributeError, "setCollisionRadius(..) not valid on objects with fromCollision off"

        if newCollisionRadius == None:
            newCollisionRadius = self.retrNodePath().getBounds().getRadius()
        self.collisionNp.node().modifySolid(0).setRadius(newCollisionRadius)

        Log.getInstance().writeLine((mstime(), 0), "MOVINGOBJECT_COLLISIONRADIUS", \
                                    [self.getIdentifier(), newCollisionRadius])

    def setFromCollision(self, newFromCollision):
        """
        Sets whether this object can collide with others and
        trigger collision events.
        """
        vr = Vr.getInstance()

        # If from collision has now been disabled and it's been
        # previously enabled, destroy the collision sphere around
        # this object and unregister it.
        if not newFromCollision and self.fromCollision:
            vr.unregisterFromObject(self)
            self.collisionNp.removeNode()
            self.collisionNp = None

        # If from collision has been enabled and it's been
        # previously disabled, create a collision sphere around
        # this object and register it with the environment.
        if newFromCollision and not self.fromCollision:
            self.collisionNp = self.nodePath.attachNewNode(CollisionNode(self.getCollisionIdentifier()))
            self.collisionNp.node().addSolid(CollisionSphere(0, 0, 0, 0))
            vr.registerFromObject(self)

        self.fromCollision = newFromCollision
        Log.getInstance().writeLine((mstime(), 0), "MOVINGOBJECT_TRIGGERSCOLLISIONS", \
                                    [self.getIdentifier(), newFromCollision])

    def setLinearAccel(self, newLinearAccel):
        """
        Sets the forward/backward acceleration
        of the player in VR units/s^2.
        """
        self.linearAccel = newLinearAccel
        Log.getInstance().writeLine((mstime(), 0), "MOVINGOBJECT_LINEARACCEL", \
                                    [self.getIdentifier(), newLinearAccel])

    def setLinearSpeed(self, newLinearSpeed):
        """
        Sets the current speed of the player
        in VR units/s.
        """
        if newLinearSpeed > self.getMaxForwardSpeed():
            newLinearSpeed = self.getMaxForwardSpeed()
        elif newLinearSpeed < self.getMaxBackwardSpeed():
            newLinearSpeed = self.getMaxBackwardSpeed()

        self.linearSpeed = newLinearSpeed
        Log.getInstance().writeLine((mstime(), 0), "MOVINGOBJECT_LINEARSPEED", \
                                    [self.getIdentifier(), newLinearSpeed])

    def setMaxBackwardSpeed(self, newMaxBackwardSpeed):
        """
        Sets the maximum backward speed of the
        player in VR units/s.
        """
        self.maxBackwardSpeed = newMaxBackwardSpeed
        Log.getInstance().writeLine((mstime(), 0), "MOVINGOBJECT_MAXBACKWARDSPEED", \
                                    [self.getIdentifier(), newMaxBackwardSpeed])

    def setMaxForwardSpeed(self, newMaxForwardSpeed):
        """
        Sets the maximum forward speed of the
        player in VR units/s.
        """
        self.maxForwardSpeed = newMaxForwardSpeed
        Log.getInstance().writeLine((mstime(), 0), "MOVINGOBJECT_MAXFORWARDSPEED", \
                                    [self.getIdentifier(), newMaxForwardSpeed])

    def setMaxTurningSpeed(self, newMaxTurningSpeed):
        """
        Sets the maximum absolute turning 
        speed of the player in degrees/s.
        """
        self.maxTurningSpeed = newMaxTurningSpeed
        Log.getInstance().writeLine((mstime(), 0), "MOVINGOBJECT_MAXTURNINGSPEED", \
                                    [self.getIdentifier(), newMaxTurningSpeed])

    def setTurningAccel(self, newTurningAccel):
        """
        Sets the turning acceleration of the 
        player in degrees/s^2.
        """
        self.turningAccel = newTurningAccel
        Log.getInstance().writeLine((mstime(), 0), "MOVINGOBJECT_TURNINGACCEL", \
                                    [self.getIdentifier(), newTurningAccel])

    def setTurningSpeed(self, newTurningSpeed):
        """
        Sets the current turning speed of the
        player in degrees/s.
        """
        if newTurningSpeed > self.getMaxTurningSpeed():
            newTurningSpeed = self.getMaxTurningSpeed()
        elif newTurningSpeed < -self.getMaxTurningSpeed():
            newTurningSpeed = -self.getMaxTurningSpeed()

        self.turningSpeed = newTurningSpeed
        Log.getInstance().writeLine((mstime(), 0), "MOVINGOBJECT_TURNINGSPEED", \
                                    [self.getIdentifier(), newTurningSpeed])

