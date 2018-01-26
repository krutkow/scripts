#!/bin/bash

# should be run in heasoft/BUILD_DIR

# first parallel terminal
gnome-terminal -x bash -c ". $HEADAS/headas-init.sh; 
	cd ../src/XSUser; hmake;
  cd ../XSModel/Model/MixFunction; hmake"

# second parallel terminal
gnome-terminal -x bash -c ". $HEADAS/headas-init.sh; 
	cd ../src/XSModel; hmake;"


# thnird parallel terminal
gnome-terminal -x bash -c ". $HEADAS/headas-init.sh; 
	cd ../src/XSFit; hmake;
  cd FitMethod/Minuit; hmake; 
  cd minuit2/src; hmake; 
  cd ../../../../../../Integral; hmake; 
  cd ../src/tools; hmake; 
  cd ../main; hmake xspec.o;
  cd ../XSUser/Python/xspec; hmake"

# this runs in the original terminal.  The others must finish before this finishes.
# +++ ???
./hmake
