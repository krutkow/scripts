#!/bin/sh

# Kristin Rutkowski
# calls the backup script incr_bak.pl 


location=$1

usage () {
  echo "\nUsage:\n"
  echo "    path/to/backup.sh <location> \n"
  echo "Where <location> = 'hhome', 'work', or 'seth'"
  echo ""
}


intro () {
  echo "backing up $location ..."
}


## home ##
backup_home () {
  intro
  ls -1 /Applications/ > /Users/kristin2/Documents/applications.list
  /Users/kristinrutkowskiwork/Documents/scripts/incr_bak.pl --source /Users/kristin2/Sites/         --dest /Volumes/MyPassport1TB/home/Sites/ --keep 2
  /Users/kristinrutkowskiwork/Documents/scripts/incr_bak.pl --source /Users/kristin2/Music/iTunes/  --dest /Volumes/MyPassport1TB/home/Music/iTunes/ --keep 2
  /Users/kristinrutkowskiwork/Documents/scripts/incr_bak.pl --source /Users/kristin2/Documents/     --dest /Volumes/MyPassport1TB/home/Documents/ --keep 2
  /Users/kristinrutkowskiwork/Documents/scripts/incr_bak.pl --source /Users/kristin2/Pictures/      --dest /Volumes/MyPassport1TB/home/Pictures/ --keep 2

  /Users/kristinrutkowskiwork/Documents/scripts/incr_bak.pl --source /Users/Shared/                 --dest /Volumes/MyPassport1TB/Shared/ --keep 2
}


## work ##
backup_work () {
  intro
  /Users/kristinrutkowskiwork/Documents/scripts/incr_bak.pl --source /Users/kristinrutkowskiwork/Documents/ --dest /Volumes/MyPassport1TB/work/Documents/ --keep 2
  /Users/kristinrutkowskiwork/Documents/scripts/incr_bak.pl --source /Users/kristinrutkowskiwork/Desktop/   --dest /Volumes/MyPassport1TB/work/Desktop/ --keep 2
  
  /Users/kristinrutkowskiwork/Documents/scripts/incr_bak.pl --source /Users/Shared/                 --dest /Volumes/MyPassport1TB/Shared/ --keep 2
}


## seth ##
backup_seth () {
  intro
  /Users/kristinrutkowskiwork/Documents/scripts/incr_bak.pl --source /Users/sethlangianese/Documents/ --dest /Volumes/MyPassport1TB/Seth/MacBook/Documents/ --keep 2
  /Users/kristinrutkowskiwork/Documents/scripts/incr_bak.pl --source /Users/sethlangianese/Desktop/   --dest /Volumes/MyPassport1TB/Seth/MacBook/Desktop/ --keep 2
  /Users/kristinrutkowskiwork/Documents/scripts/incr_bak.pl --source /Users/sethlangianese/Music/     --dest /Volumes/MyPassport1TB/Seth/MacBook/Music/ --keep 2
  /Users/kristinrutkowskiwork/Documents/scripts/incr_bak.pl --source /Users/sethlangianese/Pictures/  --dest /Volumes/MyPassport1TB/Seth/MacBook/Pictures/ --keep 2
}


case $location in
  hhome ) backup_home ;;
   work ) backup_work ;;
   seth ) backup_seth ;;
   *    ) usage
esac

