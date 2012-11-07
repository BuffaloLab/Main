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

from Log                  import Log
from ModelBase            import ModelBase
from MovingObject         import MovingObject
from UniquelyIdentifiable import UniquelyIdentifiable
from VideoLogQueue        import VideoLogQueue as VLQ
from ptime                import *

class MovingModel(ModelBase, MovingObject, UniquelyIdentifiable):
    """
    An object converted and loaded from a 
    3D modeling package which also moves
    and collides with other objects.
    """

    Log.getInstance().addType("MOVINGMODEL_INIT", [('identifier',basestring), ('filename',basestring)])
    Log.getInstance().addType("MOVINGMODEL_CREATED", [('identifier',basestring)])

    def __init__(self, identifier, model, location, fromCollision):
        """
        Loads a model into the current environment.

        identifier    - string, a unique identifier for this model
        model         - string, model filename
        location      - Point3, where the model goes
        fromCollision - boolean, whether this object can collide with others
                        and trigger collision events.
        """
        Log.getInstance().writeLine((mstime(), 0), "MOVINGMODEL_INIT", \
                                    [identifier, model])
        UniquelyIdentifiable.__init__(self, identifier)

        nodePath = base.loader.loadModel(model)
        ModelBase.__init__(self, identifier, nodePath, location)
        MovingObject.__init__(self, identifier, nodePath, fromCollision)
        VLQ.getInstance().writeLine("MOVINGMODEL_CREATED", [identifier])
        
    def __del__(self):
        """
        Destroys the object.
        """
        ModelBase.__del__(self)
        MovingObject.__del__(self)
        UniquelyIdentifiable.__del__(self)

