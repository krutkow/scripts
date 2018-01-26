!/usr/bin/perl

####!/usr1/local/bin/perl

# incr_bak.pl - Make incremental backups of a directory using some hard
#               link voodoo to make each snapshot transparent to the user.
#               It should use only a minimal amount of space more than
#               the sum of the base backup and subsequent changes.
#
#               Invoke it with no flags to see how to make things go.
#
# jb----- 20100422
#
# jb----- 20100430
#  Added exclude option
#
# jb----- 20130711
#  Added rename option
#  Some cleanup



use strict;
use warnings;

use Getopt::Long;
use File::Path;

# a consistent rsync across platforms
#my $rsync = "/usr1/local/bin/rsync_v307-sl44ok";
my $rsync = "/usr/bin/rsync";

my $src;
my $dst;
my $keep;
my $rename;
my $exclude;
my $options = GetOptions (	'source|src|s=s'           => \$src,
														'destination|dest|dst|d=s' => \$dst,
														'keep|k=s'                 => \$keep,
														'rename|r=s'               => \$rename,
														'exclude|x=s'              => \$exclude );

sub usage {
	print <<EOT;

USAGE:
  incr_bak.pl -s|--src|--source SOURCE -d|--dst|--dest DEST \
              -k|--keep BACKUPS-TO-KEEP [--exclude|-x STRING] \
              [-r|--rename RENAMED-TARGET]

  Where:
   -s is the directory where backups are coming from.
      e.g. /local/data/moa/jb-----
   -d is the parent directory of the copy.
      e.g. /local/data/backups/ YOU NEED A TRAILING SLASH!
   -k is the number of old incremental backups you would like to
      retain. Hard links are used so negligible space is used unless data
      changes a lot.
   -x is a string you want to match to exclude from backups, like
      someone's scratch space. See rsync's man page for details.
   -r renames to the target - useful for backing up directories
      with identical names


  An example:
  incr_bak.pl -r daily-src -s /local/data/moa/jb-----/src -d /local/data/backup/ -k 8

  -x and -r are optional. The rest are not.

EOT
	exit;
} 


# invoke rsync to do some hard link magic to back files up incrementally, transparently
sub do_sync {
	my ( $src, $dst, $sync_name, $rsync ) = @_;

	if ( ! -d $dst )
	{
		print "==== $dst doesn't exist - making it\n";
		mkdir $dst;
	}
	mkdir "$dst/$sync_name.INCOMPLETE";

	my $exit_status;
	if ( defined $exclude )
	{
		$exit_status = system("$rsync --exclude=\"lost+found\" --exclude=\"$exclude\" --archive --partial --delete --stats --link-dest=$dst/$sync_name.0/ $src/ $dst/$sync_name.INCOMPLETE/");
	} else
	{
		$exit_status = system("$rsync --exclude=\"lost+found\" --archive --partial --delete --stats --link-dest=$dst/$sync_name.0/ $src/ $dst/$sync_name.INCOMPLETE/");
	}

# Do this instead to see what it WOULD do:
	#my $exit_status = system("$rsync --dry-run -v --archive --partial --delete --stats --link-dest=$dst/$sync_name.0/ $src/$sync_name/ $dst/$sync_name.INCOMPLETE/");

	# Yay for shell calling '0' true
	( $exit_status == 0 )
		and return 1
		or  return $exit_status / 256;
}

# increment each backup's trailing number, then chop off the oldest.
# this will not work for stuff that's older than $keep + 1 which
# is probably a Good Thing
sub do_rotate {
	my ( $dst, $sync_name, $keep ) = @_;

	# same as rm -r
	rmtree "$dst/$sync_name.$keep"
		and print "removed $dst/$sync_name.$keep\n";
		#or  print "failed to remove $dst/$sync_name.$keep\n";

	my $i;
	my $j;
	for ( $i = $keep - 1; $i >= 0; $i-- )
	{
		$j = $i + 1;
		rename "$dst/$sync_name.$i", "$dst/$sync_name.$j"
			and print "rotated $dst/$sync_name.$i to $dst/$sync_name.$j\n";
			#or  print "failed to rotate $dst/$sync_name.$i to $dst/$sync_name.$j\n";
	}
}


# Display usage info if we find a bewildered user
# (all command-line params must be defined)
defined $src &&
defined $dst &&
defined $keep
	or usage();

# we clobber and do an "rmtree" (aka rm -r) later on, so let's cover our bases
( $dst =~ m{(bak|back|backup|backups)} )
	or die "!!!! $dst does not look like a safe destination. I'm quitting
because I can do some real damage. Try syncing to something that has
\"backup\" or similar in its name.\n";

# This gives this script a lower priority, in case the user's doing something.
# Probably makes little difference, as it's disk i/o.
system("renice 19 $$ >/dev/null");

# Rsync is ugly with trailing slashes - let's remove them now
# and add them when we want them.
$src =~ s{/$}{};
$dst =~ s{/$}{};

# uhm, let's not
#if ( defined $rename ) {
#	$dst .= "/" . $rename;
#} else {
#	if ( $src =~ m{/([^/]+)$} ) {
#		$dst .= "/" . $1 }
#}

# Rsync won't do what we want here - putting a subdir into a superdir.
# ... whatever that means; I just made that up. s/underscores/toothpicks/g
#### $sync_name is really FOOBAR in src /local/data/FOOBAR
my $sync_name;
if ( defined $rename ) {
	$sync_name = $rename;
} else {
	$sync_name = $src;
	$sync_name =~ s{^.*/}{};
}

# NO NO NO!
# Since we're adding $sync name to whatever we're doing, we'll strip it!
# OK this could totally have been combined with what we did before and
# and sounds really stupid, but I think this makes things a little clearer.
#$src =~ s{^(.*)/.*$}{$1};

# Officially things are now one big CF

#here's a good time to debug if ya wanna
#die "src = $src\ndst = $dst\nsync_name = $sync_name\n";

# Actually sync the data
my $sync_status;
print "==== Syncing from $src to $dst/ ...\n";
$sync_status = do_sync($src, $dst, $sync_name, $rsync)
	and print "==== Data sunk.\n"
	or  die "!!!! FAILED -- (rsync status $sync_status) I'm leaving the partial backup in\n
		$dst/$sync_name.INCOMPLETE and not touching anything else.\n";

# Increment the backups' names and chop the old one off the tail
do_rotate($dst, $sync_name, $keep);

# We keep the backup in blah.INCOMPLETE in case of failure, so it's obvious that
# it may be incomplete.
# In most cases we won't have to rmtree this, but it won't hurt (famous last words)
rmtree "$dst/$sync_name.0";
rename "$dst/$sync_name.INCOMPLETE", "$dst/$sync_name.0";

# equivalent to 'touch' in the shell - we want some idea of when
# the backup was made when we 'ls' or 'stat' it
my $now = time;
utime $now, $now, "$dst/$sync_name.0";
#open my $DST, "< $dst/$sync_name.0";
#close DST;

# ...and some creature comforts (a symlink to the newest sync)
( -l "$dst/$sync_name" )
	and system "rm -f $dst/$sync_name";
system "ln -sf $dst/$sync_name.0 $dst/$sync_name";
