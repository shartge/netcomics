#-*-mode: Perl; tab-width: 4 -*-
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Library General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

package Netcomics::Config;

use POSIX;
use strict;

my $script_name = "netcomics";

require Exporter;
use vars qw(@EXPORT @ISA);
@ISA = qw(Exporter);
@EXPORT = qw/$date_fmt @libdirs $html_tmpl_dir $comics_dir $system_rc
	$verbose $extra_verbose $delete_files @selected_comics
	$do_list_comics $make_webpage $remake_webpage $proxy_url
	$days_of_comics $days_prior @dates $start_date $end_date
	$given_options $user_specified_comics $user_unspecified_comics
	$external_cmd $dont_download $use_filecmd $prefer_color
	$reset_libdir $real_date $always_download $max_attempts
	$show_tasks $separate_comics $single_rli_file $netcomics_rli_file
	$rc_file %comics %groups
	$webpage_on_stdout $skip_bad_comics $sort_by_date $webpage_title
	$webpage_index_title $comics_per_page $link_color $vlink_color
	$index_link_color $index_vlink_color $background $webpage_index
	$webpage_filename_tmpl $webpage_index_filename/; 

#all the config options & their defaults.

# Rule: Only declare a variable global with "use vars" if it can potentially
# need to be overridden by running code with "require".  For instance, most
# global variables that need to be declared with "use vars" are ones that
# can be set in the user's netcomicsrc file. Any variable that is set with
# a command line option should also be declared with "use vars".
#
# Don't forget to add the variable to the netcomicsrc file if it makes sense!

use vars('$date_fmt'); $date_fmt = "%Y%m%d"; #date format in filenames

#default options values
use vars ('@libdirs'); @libdirs = ("/usr/share/netcomics");
use vars ('$html_tmpl_dir'); $html_tmpl_dir = "$libdirs[0]/html_tmpl";
use vars ('$comics_dir'); $comics_dir = "/var/spool/netcomics";
use vars ('$system_rc'); $system_rc = "/etc/netcomicsrc";
use vars ('$verbose'); $verbose = 0; #default to not verbose
use vars ('$extra_verbose'); $extra_verbose = 0; #default to not extra verbose
use vars ('$delete_files'); $delete_files = 0;
use vars ('@selected_comics'); @selected_comics = ();
use vars ('$do_list_comics'); $do_list_comics = 0;
use vars ('$make_webpage'); $make_webpage = 0; #def to not create the webpage
use vars ('$remake_webpage'); $remake_webpage = 0;
use vars ('$proxy_url'); $proxy_url = undef;
#number of days of comics to get, going backwards.
use vars ('$days_of_comics'); $days_of_comics = undef; 
use vars ('$days_prior'); $days_prior = undef; #number of days prior to start at
use vars ('@dates'); @dates = (); #dates of comics to get
use vars qw($start_date $end_date); ($start_date,$end_date) = (undef,undef);
#used in case there were any failures to help reconstruct the command line 
#options to use.
use vars ('$given_options'); $given_options = ""; 
use vars ('$user_specified_comics'); $user_specified_comics = 0;
use vars ('$user_unspecified_comics'); $user_unspecified_comics = 0;
use vars ('$external_cmd'); $external_cmd = undef;
use vars ('$dont_download'); $dont_download = 0;
use vars ('$use_filecmd'); $use_filecmd = 0;
use vars ('$prefer_color'); $prefer_color = 1;
use vars ('$reset_libdir'); $reset_libdir = 0;
use vars ('$real_date'); $real_date = 0;
use vars ('$always_download'); $always_download = 0;
use vars ('$max_attempts'); $max_attempts = 3;
use vars ('$show_tasks'); $show_tasks = 0;
use vars ('$single_rli_file'); $single_rli_file = 0;
use vars ('$netcomics_rli_file'); $netcomics_rli_file = ".netcomics.rli";
use vars ('$separate_comics'); $separate_comics = 0;

#Options set through an rc file
use vars ('$rc_file'); $rc_file = "$ENV{'HOME'}/.netcomicsrc";
use vars qw(%comics %groups);

#Webpage options
use vars ('$webpage_on_stdout'); $webpage_on_stdout = 0;
use vars ('$skip_bad_comics'); $skip_bad_comics = 0;
use vars ('$sort_by_date'); $sort_by_date = 0;
use vars ('$webpage_title'); 
$webpage_title = "Today's Comics From The Web on <DATE>";
use vars ('$webpage_index_title'); 
$webpage_index_title = "Index for " . $webpage_title;
use vars ('$comics_per_page'); $comics_per_page = undef;
use vars ('$link_color'); $link_color = "LINK=#9999FF";
use vars ('$vlink_color'); $vlink_color = "VLINK=#FF99FF";
use vars ('$index_link_color'); $index_link_color = "";
use vars ('$index_vlink_color'); $index_vlink_color = "";
use vars ('$background'); $background = "";
use vars ('$webpage_index'); $webpage_index = 1;
use vars ('$webpage_filename_tmpl'); 
$webpage_filename_tmpl = "comics<NUM>.html";
use vars ('$webpage_index_filename'); $webpage_index_filename = "index.html";

#pass in a reference to a config object (not yet implemented)
#or the name of the script.
sub new {
	my ($class,$init) = @_;
	my $scriptName = $script_name;
	$_ = ref($init);
	if (/SCALAR/) {
		$scriptName = $init;
	}
	#else ;instantiation with a Config object currently not supported.

	my $self = {
		'script_name' => $scriptName,
		'usage' => \&usage,
	};
	bless $self, $class;
	return $self;
}

sub setUsageProc {
	my $self = shift;
	my $proc = shift;
	$self->{'usage'} = $proc;
}
 
sub processARGV {
    my $self = shift;
    my @ARGV = @_;

	#needed for mkgmtime.
	#can't be used at top of this file because it uses this package.
	require Netcomics::Util;

	my $smushopt = 0;

	#TODO: preload options that specify verbosity here
	my $i = 0;
	foreach (@ARGV) {
		last if ++$i == @ARGV;
		#rc filename
		if (/^-\w*r$/) {
			if (@ARGV > 0) {
				$rc_file = $ARGV[$i]
				} else {
					print STDERR "Need a filename for an argument to -r. " .
						"Use -h for usage.\n";
					exit 1;
				}
			if (! -f $rc_file) {
				print STDERR "Specified rc file doesn't exist: '$rc_file'\n";
				exit 1;
			} elsif (! -r $rc_file) {
				print STDERR "Can't read specified rc file: '$rc_file'\n";
				exit 1;
			}
			last;
		}
	}


	#First load the system rc file, then the user rc file
	$self->load_rcfile($system_rc,$rc_file);

	my @newlibdirs = ();
	my $did_c_already = 0;

	#parse command line options
	while (@ARGV) {
		$_ = shift(@ARGV);

		#Get specific comics or don't get a specific comics
		if (/-(c)$/i) {
			if (@ARGV > 0) {
				my @ids = split(' ',shift(@ARGV));
				unless ($did_c_already) {
					if ($1 eq 'c') {
						$user_specified_comics = 1;
						@selected_comics = @ids;
					} else {
						$user_unspecified_comics = 1;
						@selected_comics = @ids;
					}
				} else {
					if ($1 eq 'c') {
						$user_specified_comics = 1;
						push(@selected_comics, @ids);
					} else {
						$user_unspecified_comics = 1;
						push(@selected_comics, @ids);
					}
				}
				$did_c_already = 1;
			} else {
				print STDERR "Need a space-delimitted list of comic id's.";
				print STDERR "  Use -h for usage.\n";
				exit 1;
			}
			if ($user_unspecified_comics && $user_specified_comics) {
				print STDERR 
					"Can only use one of -c and -C. Use -h for usage.\n";
				exit 1;
			}
		}
		
		#Put @rli into one large file.
		elsif (/-G/) {
			$single_rli_file = 1;
			$smushopt = 1;
		}
	
		#List supported comics
		elsif (/-l/) {
			$do_list_comics++;
			$smushopt = 1;
		}
		
		#set the directory
		elsif (/-d$/) {
			if (@ARGV > 0) {
				$comics_dir = shift(@ARGV);
				$given_options .= " -d $comics_dir";
			} else {
				print STDERR "Need a directory name. Use -h for usage.\n";
				exit 1;
			}
		}
		
		#verbosity
		elsif (/-v/) {
			if ($verbose) {
				$extra_verbose = 1;
				if ($given_options =~ /^(.*)-v([^v].*)$/) {
					$given_options = $1 . $2;
				}
				$given_options .= " -vv";
			} else {
				$verbose = 1;
				$given_options .= " -v";
			}
			$smushopt = 1;
		}
	
		# Seperate comics into their own directories
		elsif (/-P/) {
			$separate_comics = 1;
			$smushopt = 1;
			$given_options .= " -P";
		}
		
		#Delete the files
		elsif (/-D/) {
			$delete_files = 1;
			$smushopt = 1;
		}

		#Don't delete the files
		elsif (/-nD/) {
			$delete_files = 0;
			$given_options .= " -nD";
		}

		#webpage title
		elsif (/-wt$/) {
			if (@ARGV > 0) {
				$webpage_title = shift(@ARGV);
				$given_options .= " -wt '$webpage_title'";
			} else {
				print STDERR "Need a string for an argument to -wt. " .
					"Use -h for usage.\n";
				exit 1;
			}
		}

		#webpage on standard out
		elsif (/-o/) {
			$webpage_on_stdout = 1;
			$given_options .= " -o";
			$smushopt = 1;
		}

		#don't create a webpage
		elsif (/-nw$/) {
			$make_webpage = 0;	
			$remake_webpage = 0;
			$given_options .= " -nw";
		}

		#Create webpage?
		elsif (/-(w)(=.+)?/i) {
			if (defined($2)) {
				if ($2 =~ /^=(\d+)$/) {
					$comics_per_page = $1;
				} else {
					print STDERR "Number of comics per page for -W & -w must " .
						"be a positive integer.\n";
					exit 1;
				}
			} else {
				$smushopt = 1;
			}
			$make_webpage = 1;
			$remake_webpage = ($1 =~ /W/)? 1 : 0;
		}

		#Use a Proxy?
		elsif (/-p$/) {
			if (@ARGV > 0) {
				$proxy_url = shift(@ARGV);
				$given_options .= " -p $proxy_url";
			} else {
				print STDERR "Need a URL to use as the proxy. " .
					"Use -h for usage.\n";
				exit 1;
			}
		}

		#Number of days of comics to get, going backwards
		elsif (/-n$/) {
			if (@ARGV > 0) {
				$days_of_comics = shift(@ARGV);
			} else {
				print STDERR "Need a number for an argument to -n. " .
					"Use -h for usage.\n";
				exit 1;
			}
		}

		#HTML Template Directory
		elsif (/-t$/) {
			if (@ARGV > 0) {
				$html_tmpl_dir = shift(@ARGV);
				$given_options .= " -t $html_tmpl_dir";
			} else {
				print STDERR "Need a directory for an argument to -t. " .
					"Use -h for usage.\n";
				exit 1;
			}
		}

		#Comic Module Directory
		elsif (/-m$/) {
			if (@ARGV > 0) {
				my $dir = shift(@ARGV);
				unshift(@newlibdirs,$dir);
				$given_options .= " -m $dir";
			} else {
				print STDERR "Need a directory for an argument to -m. " .
					"Use -h for usage.\n";
				exit 1;
			}
		}

		#clear out libdirs
		elsif (/-M$/) {
			@libdirs = ();
			$given_options .= " -M";
			$smushopt = 1;
		}

		# Real date day
		elsif (/-A$/) {
			$real_date = 1;
			$given_options .= " -A";
			$smushopt = 1;
		}

		#Specified date
		elsif (/-([STE])$/) {
			my $type = $1;
			my $good = 0;
			
			if (@ARGV > 0) {
				my $ds = shift(@ARGV);
				my $ts = undef;
				if ($ds =~ /([0-1]?[0-9])-([0-3]?[0-9])-(19|20)?([0-9][0-9])/) {
					my $year = defined($4) ? $4 : $3;
					$year += 100 if $year < 70;
					$ts = mkgmtime(0,0,12,$2,$1-1,$year);
				} elsif ($ds =~ /^([+-]?\d+)$/) {
					$ts = time - ($1 * 24*3600);
				}
				if (defined($ts)) {
					$given_options .= " -$type $ds";
					$good = 1;
					$_ = $type;
					if (/T/) {
						push(@dates,$ts);
					} elsif (/S/) {
						$start_date = $ts;
					} elsif (/E/) {
						$end_date = $ts;
					}
				}
			}
			
			unless ($good) {
				print STDERR "Need a date for an argument to -$type. " .
					"It has the form: MM-DD-[YY]YY\nOr it is the " .
						"number of days prior to day to specify the date.\n";
				exit 1;
			}
		}

		#skip bad comics
		elsif (/-s/) {
			$skip_bad_comics = 1;
			$given_options .= " -s";
			$smushopt = 1;
		}

		#date format used when naming files
		elsif (/-f$/) {
			if (@ARGV > 0) {
				$date_fmt = shift(@ARGV);
				$given_options .= " -f '$date_fmt'";
			} else {
				print STDERR "Need a date format for an argument to -f. " .
					"Use -h for usage.\n";
				exit 1;
			}
		}

		#Number of days of comics to get, going backwards
		elsif (/-N$/) {
			if (@ARGV > 0) {
				$days_prior = shift(@ARGV);
				$given_options .= " -N $days_prior";
			} else {
				print STDERR "Need a number for an argument to -N. " .
					"Use -h for usage.\n";
				exit 1;
			}
		}

		#external program to use instead of LWP
		elsif (/-g(=(.+))?([^=]+)?$/) {
			$given_options .= " -g";
			if (defined($2)) {
				$external_cmd = $2;
			} elsif (! defined($3) && @ARGV > 0 && $ARGV[0] !~ /^-/) {
				$external_cmd = shift(@ARGV);
			} else {
				$smushopt = 1;
			}
			$given_options .= " '$external_cmd'" if defined $external_cmd;
		}

		#print URLs or put them in the webpage?
		elsif (/-u/) {
			$dont_download = 1;
			$given_options .= " -u";
			$smushopt = 1;
		}

		#get b/w if possible
		elsif (/-(b)/i) {
			$prefer_color = ($1 =~ /B/)? 1 : 0;
			$given_options .= " -$1";
			$smushopt = 1;
		}

		#sort by date
		elsif (/-L/) {
			$sort_by_date = 1;
			$smushopt = 1;
			$given_options .= " -L";
		}

		#no index for webpaegs
		elsif (/-(i)/i) {
			$webpage_index = ($1 =~ /I/)? 1 : 0;
			$smushopt = 1;
			$given_options .= " -$1";
		}

		#rc filename
		elsif (/-r$/) {
			#already did the work of checking to make sure its good
			shift(@ARGV);
			$given_options .= " -r '$rc_file'";
		}

		#always download
		elsif (/-a$/) {
			$always_download = 1;
			$smushopt = 1;
			#don't add to given options 
		}

		#maximum retries
		elsif (/-(n?R)$/) {
			my $good = 0;
			if ($1 eq 'nR') {
				$good = 1;
				$max_attempts = 0;
			} elsif (@ARGV > 0) {
				$max_attempts = shift(@ARGV);
				$good = 1 if $max_attempts =~ /^\d+$/;
			}
			if (! $good) {
				print STDERR "You must specify a number, 0 or greater, " .
					"with -R. Use -h for usage.\n";
				exit 1;
			}
		}

		#show tasks
		elsif (/-q$/) {
			$show_tasks = 1;
			$smushopt = 1;
			$given_options .= " -q";
		}

		#Usage
		else {
			print STDERR "Unknown option: $_.\n" unless /-h/;
			&{$self->{'usage'}}();
		}

		#Allow for smushed-together options
		if ($smushopt) {
			$smushopt = 0;
			if (/-.(.+)/) {
				unshift(@ARGV,"-$1");
				print "Pushing -$1 onto command line arguments.\n" 
					if $extra_verbose;
			}
		}
	}

	#tack on user-given directories.
	unshift(@libdirs,@newlibdirs);

	#check to make sure proper sets of options were provided
	if (defined($end_date)) {
		if ($start_date > $end_date) {
			print STDERR "The starting date must be before the ending date. ";
			print STDERR "Use -h for usage.\n";
			exit 1;
		} elsif (defined($days_of_comics)) {
			print STDERR "The number of days of comics to retrieve may not be ";
			print STDERR "specified when the starting and\nending dates are. ";
			print STDERR "Use -h for usage.\n";
			exit 1;
		}
	}
	if (defined($days_prior) && (defined($end_date) || defined($start_date))) {
		print STDERR "-N may not be specified with -S or -E.  " .
			"Use -h for usage.\n";
		exit 1;
	} elsif (! defined($days_prior)) {
		$days_prior = 0;
	}
	if (defined($comics_per_page) && $webpage_on_stdout) {
		print STDERR "-o may not be specified with -W= or -w=.  " .
			"Use -h for usage.\n";
		exit 1;
	}
	if ( ($real_date == 1) && ! defined($start_date) && (scalar @dates == 0) ) {
		print STDERR "-A may only be used with -S, -E or -T.  " .
			"Use -h for usage.\n";
		exit 1;
	}

}

sub load_rcfile {
	my $self = shift;
	foreach (@_) {
		my $file = $_;
		if (-f $file && -r $file) {
		    $@=0;
		    eval {require $file;};
		    if ($@) {
				print STDERR "Error loading rcfile: '$file':\n$@.\n";
				exit 1;
		    }
		}
	}
}

sub usage {
	my $self = shift;

	print "$self->{'script_name'} : download comics from the Web.\n";
	print << "END";
�2001 Ben Hochstedler <hochstrb\@cs.rose-hulman.edu>
usage: netcomics [-abBDhiIlLosuvv] [-c,-C "comic ids"] [-p proxy] [-R retries]
	             [-S,-T,-E date [-A]] [-n,-N days] [-d,-m,-t dir] [-f date_fmt]
	             [-g [program]] [-nD] [-r rc_file] [-W,-w[=n]] [-nw]
   -a: if comics are specified, forcibly try to download them and also try
	   to download any comics that weren't successfully downloaded.
	   if comics aren't specified, forcibly (re)download all comics.
   -A: act as if the days specified with S, T or E were today
   -b: specify that you prefer the comics to be in black & white--not color
   -B: specify that you prefer the comics color (override rc file setting)
   -c: get the listed comics (ids are separated by white spaces)
   -C: don't get the listed comics (ids are separated by white spaces)
   -d: put comics into directory (default /var/spool/netcomics)
   -D: delete files in directory before retreiving
   -nD:don't delete files in directory (override rc file setting)
   -E: specify the ending date of a range of days of comics to retrieve
   -f: specify the date format used when naming files. default: '%y%m%d'
   -g: specify an external program to use instead of libwww-perl
   -h: show usage (doesn't download comics)
   -i: don't create an index for the webpages
   -I: create an index for the webpages (override rc file setting)
   -l: list supported comics & their identifiers (doesn't download comics)
   -L: sort comics by date in webpage, days behind when listing them
   -m: add dir to locations of comic modules (default /usr/share/netcomics)
   -M: only use directories for comics modules specified on the command line
   -n: retrieve this number of days of comics, going backwards. default is 1
   -N: retrieve this number of days prior to the currently available date
   -o: write the webpage on standard out
   -p: use the given url as the proxy
   -P: separate comics into their own subdirectories
   -q: show what comics would be downloaded; don't actually do anything.
   -r: specify the rc filename (default ~/.netcomicsrc)
   -R: specify the max attempts to download a comic between invocations
   -nR:specify there's no maximum number of attempts (same as -R 0).
   -s: skip bad comics when creating the webpage
   -S: specify a starting date of a range of days of comics to retrieve
   -t: location of html tmpl files (default /usr/share/netcomics/html_tmpl)
   -T: specify a specific date of comics to retrieve
   -u: don't download comics. print URLs on stdout, or if creating a
	   webpage, have the images be implemented using the URLs.
   -v: be a little verbose
   -vv:be extra verbose
   -w: create an html file, index.html, n comics per page
   -nw:don't create a webpage (override setting in rc file)
   -wt:specify a title for the webpage rather than the default
   -W: recreate webpage from all files in directory, n comics per page
END
	exit 0;
}

