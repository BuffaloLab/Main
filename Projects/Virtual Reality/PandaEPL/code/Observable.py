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

from WeakCallableProxy import WeakCallableProxy

class Observable:
    """
    An object of this type generates events
    that others can register and listen for.
    """

    def __init__(self):
        """
        Creates an Observable object.
        """
        self.observers = []

    def notify(self, eventName, **dargs):
        """
        Notifies all observers of the given event.
        Each observer is called with the event name
        and a dictionary of arbitrary values (i.e. **dargs).
        """
        removeList = []
        for observer in self.observers:
            # If the object doesn't exist anymore, 
            # mark the reference for deletion.
            if observer.isDead():
                removeList.append(observer)
            else:
                observer(eventName, **dargs)

        # Delete all marked references.
        for observer in removeList:
            self.observers.remove(observer)

    def registerObserver(self, observer):
        """
        Adds the given callback to the list of entities
        that receive calls made by notify.
        """
        observer = WeakCallableProxy(observer)

        if self.observers.count(observer) == 0:
            self.observers.append(observer)

    def unregisterObserver(self, observer):
        """
        Removes the given callback from the list of entities
        that receive calls made by notify.
        """
        observer = WeakCallableProxy(observer)

        if self.observers.has_key(observer):
            self.observers.remove(observer)   

