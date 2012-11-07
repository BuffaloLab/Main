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
    swig_targets = [os.path.join('eeg', 'activewire')]
    for target in swig_targets:
        res = os.system('make -C %s' % target)
        if res != 0:
            print ""
            print "!!! Compilation Error !!!"
            print "Make failed for target %s" % target
            print "Exiting...Please fix the above error and try again..."
            print ""
            sys.exit(res)

    site_packages_dir = os.path.join(get_config_var('BINLIBDEST'), 'site-packages')
    data_files = [(os.path.join(site_packages_dir, 'pandaepl', swig_targets[0]), ["eeg/activewire/_awCard.so"])]

    setup(name="pandaepl",
          version="0.9",
          description="Panda3D-based Experiment Programming Library",
          package_dir={'pandaepl': "code", 'pandaepl.eeg': "eeg"},
          packages=['pandaepl', 'pandaepl.eeg', 'pandaepl.eeg.activewire'],
          data_files = data_files,
          author="Alec Solway"
         )

