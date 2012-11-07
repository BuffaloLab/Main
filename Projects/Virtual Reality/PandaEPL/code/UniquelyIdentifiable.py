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

from Exceptions   import *
from Identifiable import Identifiable
from weakref      import WeakValueDictionary

class UniquelyIdentifiable(Identifiable):
    """
    An object with a unique identifier.
    """

    # All UniquelyIdentifiable IDs, dictionary keys are the ids
    # and values are references to the objects.
    globalIds = WeakValueDictionary()

    def __init__(self, identifier):
        """
        Creates a UniquelyIdentifiable object.

        identifier - A unique string identifier for this object.
        """
        if UniquelyIdentifiable.globalIds.has_key(identifier):
            raise IdentifierException, "An object with the identifier '"+identifier+\
                                        "' already exists."

        UniquelyIdentifiable.globalIds[identifier] = self
        Identifiable.__init__(self, identifier)

    def __del__(self):
        """
        Destroys the object.
        """
        # We used to delete the member from globalIds here, but 
        # now that it's weakly referenced, we don't have to do
        # anything.
        pass

