# Copyright (C) 2003-2005 Michael J. Kahana
# Authors: Ian Schleifer, Per Sederberg, Aaron Geller, Josh Jacobs
# URL: http://memory.psych.upenn.edu/programming/pyepl
#
# Distributed under the terms of the GNU Lesser General Public License
# (LGPL). See the license.txt that came with this file.

PLATFORM = $(shell uname)
INCLUDEPY=$(shell python -c "import distutils.sysconfig;print distutils.sysconfig.get_config_var('INCLUDEPY')")

ifeq ($(PLATFORM), Darwin)
all: _awCard.so

INCLUDEPY=$(shell python -c "import distutils.sysconfig;print distutils.sysconfig.get_config_var('INCLUDEPY')")
LIBPY=$(shell python -c "import distutils.sysconfig;print distutils.sysconfig.get_config_var('LIBPL')")
PYTHON_INC = $(INCLUDEPY)
PYTHON_LIB = $(LIBPY)
FLAGS1 = -Wno-long-double -DHAVE_CONFIG_H
FLAGS2 = -bundle -undefined suppress -flat_namespace -lpthread
FLAGS3 = -fno-strict-aliasing -Wno-long-double -no-cpp-precomp	\
-mno-fused-madd -fno-common -dynamic -DNDEBUG -O2 -Wall	

_awCard.so: awCard.o awCard.i 
	swig -c++ -python awCard.i
	g++ $(FLAGS1) -I$(PYTHON_INC) -L$(PYTHON_LIB) -c awCard_wrap.cxx 
	g++ $(FLAGS2) awCard.o awCard_wrap.o -o $@ -law 

awCard.o: awCard.cpp awCard.h 
	g++ $(FLAGS3) -I$(PYTHON_INC) -c $*.cpp -o $@

awctest: awCard.cpp awCard.h
	g++ -g -o $@ awCard.cpp -law

clean:
	rm *.o *.so *.cxx

endif
