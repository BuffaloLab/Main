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

from Exceptions  import *
from quickpickle import *
from sys         import *
from string      import *
import os

class LogEntryType:
    """
    See Log.addType(...).
    """
    def __init__(self, label, columns, onlyWriteChanges):
        self.label            = label
        self.columns          = columns
        self.onlyWriteChanges = onlyWriteChanges

    def __eq__(self, other):
        return (self.label == other.label and \
                self.columns == other.columns)

    def __ne__(self, other):
        return (self.label != other.label or \
                self.columns != other.columns)

        
class Log:

    number = (float,int,long)
    encType = "utf-8"
    singletonInstance = None
    
    def __init__(self):
        """
        Create a new Log object.
        """
        self.fd = None

        # Caches log events if a log location has not yet
        # been specified (and so we don't know where to
        # write logs event). When a location is specified,
        # 'fd' is set and the cache is dumped.
        self.logCache = u''

        # Dictionary of log events. See addType(..).
        self.formatDict = dict()

        # The last line written, stored by label. Keeps duplicates out.
        self.lastLine = dict()

        # Location of log format data. Format data is cached
        # until this location is specified, at which point
        # it's dumped to the specified file and updated
        # on every call to addType(..).
        self.formatPickleName = None

        # From Exceptions.py, solved a circular initialization issue.
        # This really belongs in Exception.py, however, and should be
        # moved when there's time to look into this issue again. 
        self.addType("EXCEPTION_RAISED", [('type',basestring), ('message',basestring)])

    def __del__(self):
        """
        Release current file handle, if any.
        """
        if self.fd != None:
            self.fd.flush()
            self.fd.close()
        
    def getInstance(cls):
        """
        Returns a reference to the default Log instance.
        """
        if Log.singletonInstance == None:
            Log.singletonInstance = Log()

        return Log.singletonInstance

    getInstance = classmethod(getInstance)

    def setLogFile(self, newLogFile):
        """
        Specifies where the logger should write events.
        If the file exists, it will be appended to.
        If there's anything in the cache, it will be dumped
        here.
        """
        if self.fd != None:
            self.fd.close()
        self.fd = open(newLogFile, "a")
        
        self.fd.write(self.logCache.encode(Log.encType))
        self.fd.flush()
        self.logCache = u''
        self.lastLine = dict()

    def setTypeFile(self, newTypeFile):
        """
        Specifies where the logger should write type
        information. If the file exists, it will first be
        loaded and the types there will be merged with 
        the ones in memory. If any are incomptaible 
        (i.e. two event labels with the same name but 
        a different column configuration), a LogException 
        is thrown.
        """
        if os.access(newTypeFile, os.F_OK): 
            oldFormatDict = quickUnpickle(newTypeFile)
            for label in oldFormatDict.keys():
                if self.formatDict.has_key(label) and \
                   oldFormatDict[label] != self.formatDict[label]:
                    raise LogException, "Attempted to load type file "+newTypeFile+", which has a "+\
                                        "different configuration for log events of type "+\
                                        "\""+label+"\"."
                self.addType(label, oldFormatDict[label].columns, oldFormatDict[label].onlyWriteChanges)

        self.formatPickleName = newTypeFile
        quickPickle(self.formatPickleName,self.formatDict)

    def writeLine(self, timeTuple, label, columns):
        """
        Adds a line to the current log file. 

        timeTuple - 2-tuple, the first component is the start time
                    and the second is the maximum latency. the event
                    should be guaranteed to occur between 
                    [start,start+latency].
        label     - string, the name of the event to log, must have been 
                    previously registered with a call to addType(..). 
        columns   - list of values associated with the event as specified 
                    in the addType(..) call.
        """
        # Make sure label has previously been registered with addType(..).
        if not label in self.formatDict.keys():
            raise LogException, 'Log error: unknown type ('+str(label)+')'

        # Make sure the number of columns registered is the same as the
        # number of columns passed in.
        if len(columns) != len(self.formatDict[label].columns):
            raise LogException, 'Log error: argument list has incorrect length for label '+str(label)
        
        # Build the log line value by value, making sure each is of the 
        # registered type.
        nextLine = unicode(timeTuple[0])+u'\t'+unicode(timeTuple[1])+u'\t'+unicode(label)
        lineData = ''
        for i in range(0,len(columns)):
            if isinstance(columns[i], self.formatDict[label].columns[i][1]) or \
               columns[i] == None:
                # If not already a unicode object, decode 
                # using system default encoding.
                columnTmp = columns[i]
                if not isinstance(columnTmp, unicode):
                    columnTmp = unicode(columnTmp)
                # Append column info.
                column = u'\t'+columnTmp.replace(u'\n',u' ')
                nextLine += column
                lineData += column
            else:
                raise LogException, 'Log error: format mismatch ('+label+\
                                    '['+self.formatDict[label].columns[i][0]+'] '+\
                                    'entered as '+str(type(columns[i]))+')'


        # If not a duplicate entry, write the log line to the current file, 
        # or the cache if a location hasn't been specified.
        if not self.formatDict[label].onlyWriteChanges or not self.lastLine.has_key(label) or self.lastLine[label] != lineData:
            if self.fd==None:
                self.logCache += nextLine+u'\n'
            else:
                self.fd.write((nextLine+u'\n').encode(Log.encType))
                self.fd.flush()
        
            self.lastLine[label] = lineData

    def addType(self, label, columns, onlyWriteChanges=True):
        """
        Register a new type of event with the logger.
        
        label            - string, identifier for the new event
        columns          - list, a list of pairs identifying the fields 
                           associated with the new event. The first element
                           of each pair is a string identifier for the field,
                           and the second element is its data type. See doc/LOGS
        onlyWriteChanges - When True, calls to writeLine(..) with this label will 
                           only be effective if the value of the columns has changed 
                           since the last call.
       
                           In the following case, LINE1 will be logged once: 
                           foo.writeLine(..,label,LINE1)
                           foo.writeLine(..,label,LINE1)

                           In this case, however, LINE1 will be logged twice (with LINE2
                           in the middle):

                           foo.writeLine(..,label,LINE1)
                           foo.writeLine(..,label,LINE2)
                           foo.writeLine(..,label,LINE1)
        """
        # If this label has already been registered, make sure the passed
        # types are the same as before. If they're not, tell the user.
        if self.formatDict.has_key(label):
            if self.formatDict[label].columns != columns:
                raise LogException, 'Log error: label "'+label+'" already registerd with a '+\
                                    'different column configuration.'
            else:
                return

        self.formatDict[label] = LogEntryType(label, columns, onlyWriteChanges)

        # If a location has been specified, save the updated events.
        # Otherwise, they'll be dumped as soon as a location is set.
        if self.formatPickleName!=None:
            quickPickle(self.formatPickleName,self.formatDict)

    def getTypes(self):
        """
        Return a dictionary of event types known to the logger.
        The dictionary is indexed by event label and each element
        is a LogEntryType.
        """
        return self.formatDict

