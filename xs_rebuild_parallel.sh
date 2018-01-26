#!/bin/bash

# should be run in heasoft/Xspec/BUILD_DIR

gnome-terminal -x bash -c ". $HEADAS/headas-init.sh; 
	cd ../src/XSUser; hmake;
  cd ../XSModel/Model/MixFunction; hmake"
gnome-terminal -x bash -c ". $HEADAS/headas-init.sh; 
	cd ../src/XSModel; hmake;"
gnome-terminal -x bash -c ". $HEADAS/headas-init.sh; 
	cd ../src/XSFit; hmake;
  cd FitMethod/Minuit; hmake; 
  cd minuit2/src; hmake; 
  cd ../../../../../../Integral; hmake; 
  cd ../src/tools; hmake; 
  cd ../main; hmake xspec.o;
  cd ../XSUser/Python/xspec; hmake"
./hmake
