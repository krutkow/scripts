#! /bin/bash

# 20170913
# Kristin Rutkowski
# based on script written by Craig Gordon

# Script to more fully clean a built heasoft directory.  The 'hmake clean' 
# command cleans the build, but doesn't remove the x86 installed 
# directories.  If there are files dated older than the installed files 
# (but if they're the actual desired files), rebuilding will not install them.
# removing these install directories should fix that.
#


INSTALL_DIR=x86_64
INSTALL_DIR=x86_64-apple-darwin18.7.0
dirsArray=($(find . -maxdepth 1 -type d))
origDir=$(pwd)

echo "Running in directory $origDir"

# make sure we're in a heasoft dir
# ideally we're in the main heasoft directory
if [[ $origDir != *"heasoft"* ]]; then
  echo "You're not in a heasoft directory.  Exiting."
  exit 0
fi

# get length of an array
numDirs=${#dirsArray[@]}

# loop through dirs, rm the install dir
for (( i=0; i<${numDirs}; i++ ));
do
  dirToDelete=$origDir/${dirsArray[$i]}/$INSTALL_DIR
  echo "  curr loop = ${dirsArray[$i]}"
  echo "  dirToDelete = $dirToDelete"
  if [ -d "$dirToDelete"* ] ; then
    echo "removing $dirToDelete*"
    rm -rf "$dirToDelete"*
  fi
  dirToDelete=$origDir/${dirsArray[$i]}/BLD/$INSTALL_DIR
  if [ -d "$dirToDelete"* ] ; then
    echo "removing $dirToDelete*"
    rm -rf "$dirToDelete"*
  fi
done






