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

import datetime
import time

def microtime():
    """
    Returns the current time since epoch, accurate to the
    value returned by gettimeofday(), usually ~1microsecond.
    """
    now = datetime.datetime.now()
    return long(time.mktime(now.timetuple()) * 1000000 + now.microsecond)

def mstime():
    """
    Returns the current time since epoch.
    """
    return microtime()/1000

def timedCall(f, *targs, **dargs):
    """
    Calls f with the given arguments. Returns a 2-tuple,
    the first component is itself a 2-tuple containing 
    the call time and length (in ms) and the second component
    is the return value.
    """
    before = mstime()
    r = f(*targs, **dargs)
    after  = mstime()

    return ((before, after - before + 1), r)

