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

from ptime import *

class PandaEplException(Exception):
    """
    The base class for all PandaEPL exceptions.
    """
    pass

class ConfLoadException(PandaEplException):
    """
    Signals a configuration problem.
    """
    def __init__(self, message):
        Exception.__init__(self, message)
        from Log import Log
        Log.getInstance().writeLine((mstime(), 0), "EXCEPTION_RAISED", [self.__class__.__name__, message])

class MainLoopException(PandaEplException):
    """
    Signals a high-level main loop problem.
    """
    def __init__(self, message):
        Exception.__init__(self, message)
        from Log import Log
        Log.getInstance().writeLine((mstime(), 0), "EXCEPTION_RAISED", [self.__class__.__name__, message])

class LogException(PandaEplException):
    """
    Signals a logging problem.
    """
    def __init__(self, message):
        Exception.__init__(self, message)
        from Log import Log
        Log.getInstance().writeLine((mstime(), 0), "EXCEPTION_RAISED", [self.__class__.__name__, message])

class IdentifierException(PandaEplException):
    """
    Signals a problem with a UniquelyIdentifiable object,
    e.g. trying to create an object with an existing ID.
    """
    def __init__(self, message):
        Exception.__init__(self, message)
        from Log import Log
        Log.getInstance().writeLine((mstime(), 0), "EXCEPTION_RAISED", [self.__class__.__name__, message])

class SessionException(PandaEplException):
    """
    Signals a problem with the current session.
    """
    def __init__(self, message):
        Exception.__init__(self, message)
        from Log import Log
        Log.getInstance().writeLine((mstime(), 0), "EXCEPTION_RAISED", [self.__class__.__name__, message])

class eegException(PandaEplException):
    """
    Signals a problem with sync-pulsing.
    """
    def __init__(self, message):
        Exception.__init__(self, message)
        from Log import Log
        Log.getInstance().writeLine((mstime(), 0), "EXCEPTION_RAISED", [self.__class__.__name__, message])

class SoundException(PandaEplException):
    """
    Signals a problem with the sound subsystem.
    """
    def __init__(self, message):
        Exception.__init__(self, message)
        from Log import Log
        Log.getInstance().writeLine((mstime(), 0), "EXCEPTION_RAISED", [self.__class__.__name__, message])

