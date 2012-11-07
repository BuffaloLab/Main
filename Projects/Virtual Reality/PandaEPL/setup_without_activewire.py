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

from distutils.core import setup
from distutils.sysconfig import get_config_var
import os
import sys

if len(sys.argv)>1 and sys.argv[1]=="install":
    INSTALL = True
else:
    INSTALL = False

if INSTALL:
    site_packages_dir = os.path.join(get_config_var('BINLIBDEST'), 'site-packages')

    setup(name="pandaepl",
          version="0.9",
          description="Panda3D-based Experiment Programming Library",
          package_dir={'pandaepl': "code"},
          packages=['pandaepl'],
          author="Alec Solway"
         )

