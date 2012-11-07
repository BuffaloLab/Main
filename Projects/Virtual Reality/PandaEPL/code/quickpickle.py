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

import cPickle

def quickPickle(fname,obj):
    """
    save the given object (obj) to a file (fname)
    in binary format, using the cPickle module.  if
    the file already exists, overwrite it
    """
    fd = file(fname, 'w')
    try:
        cPickle.dump(obj,fd)
    finally:
        fd.close()

def quickUnpickle(fname):
    """
    load an object from the given pickled file (fname)
    """
    fd = file(fname)
    obj = cPickle.load(fd)
    fd.close()
    return obj

