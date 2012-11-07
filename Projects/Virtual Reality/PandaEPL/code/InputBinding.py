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

class InputBinding:
    """
    Represents a key-event binding (see InputDevice.bind(..)).
    """

    def __init__(self, eventName, keys, repeat):
        """
        Creates an InputBinding object.

        This class is used internally by PandaEPL and
        SHOULD NOT BE USED DIRECTLY BY CLIENT SCRIPTS.

        eventName - string, the name of the event.
        keys      - strings, a list of keys that must be
                    pressed (in combination) to generate
                    this event.
        repeat    - boolean, whether holding the keys down
                    will generate multiple events.
        """
        self.eventName = eventName
        self.keys      = keys
        self.repeat    = repeat

