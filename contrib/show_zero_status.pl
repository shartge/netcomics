#!/usr/bin/perl -w
# netcomics/contrib/show_zero_status.pl

# This script goes through the directory given as an argument (or default of
# $HOME/comics/), and list all that have zero status.
#
# This is usefull when you have (literally, in my case) 3,000 rli files that
# need trimming to speed up start time.

use strict;
use Data::Dumper;

my $home = $ENV{'HOME'};
my $comic_dir = shift(@ARGV) || "$home/comics/";

print $comic_dir."\n";

foreach(glob("$comic_dir.*.rli"))
{
	open(DATA,$_) or next;
	my $code ;
	{
		local $/;
		$code = <DATA>;
	}
#	print $code;
	my %rli;
	eval $code;
	if ($@) {
		die "Error loading rli status file: '$_':\n$@.";
	} elsif (keys(%rli) == 0) {
		print STDERR "Loading rli status file, $_, " .
			"resulted in an empty rli\n";
	} 
#	print Data::Dumper->Dump([%rli],[qw(*rli)]);
	print "$_ $rli{'status'}\n" if $rli{'status'} == 0;
}

