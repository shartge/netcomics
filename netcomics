#!/usr/bin/perl -w
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

#This script requires the following CPAN packages:
#libwww-perl, HTML-Parser, Image-Size
#
#To add your own comic lib modules, first visit the comic strip resource at:
#http://comics.kurle.com/resource/
#to find the comic you want.

$0 =~ s,.*/,,;  # use basename only

use POSIX;
use strict;
use Carp;
BEGIN {my $d="/usr/lib/perl5/site_perl"; push(@INC,$d) if ! grep(/^$d$/,@INC);}
use Netcomics::MyResponse;
use Netcomics::MyRequest;
use Netcomics::ExternalUserAgent;
use Netcomics::RLI;
use Netcomics::HTML;
use Netcomics::Factory;
use Netcomics::Config;
use Netcomics::Util;

# Global Variables
my $script_name = "netcomics";

my $conf = Netcomics::Config->new($script_name);
$conf->processARGV(@ARGV);

$| = 1; #autoflush on STDERR & STDOUT

#Persistent storage of rli info depends on Data::Dumper
my $data_dumper_installed = requireDataDumper();

my $factory = Netcomics::Factory->new($conf);
$factory->setup;

$factory->list_comics(), exit(0) if ($do_list_comics);

#get_comics returns a list of comics which is used to help determine
#if a comic in the directory was just downloaded or not.
#dump_rli(\@rli) if $single_rli_file;
my @rli = $factory->get_comics();
my @comics = $factory->files_retrieved();
my @existing_rli_files = $factory->existing_rli_files();
my $get_current = $factory->get_current();
if ($remake_webpage) {
	print "Scanning $comics_dir for comics with no associated status file.\n"
		if $extra_verbose;
	opendir(DIR,$comics_dir) || die "could not open $comics_dir: $!";
	my @files = readdir(DIR);
	closedir(DIR);
	#sort so that if there's a multifile comic and regular comic associated
	#with the same comic-date, that the multi-file comics can be processed
	#first.
	@files = sort(grep(/(xpm|gif|jpe?g|tiff?|png)$/,@files));

  RMW:
	while (@files) {
		my $file = shift(@files);
		#although we could check to see if the file is in @comics or
		#@existing_rli_files right away, we have to first check through
		#all of the files associated with this one if it is a multi-file comic
		my ($title,$date,$type,$num) = parse_name($file);
		my $name = "$title-$date";
		my $rli = {'title' => $title,
				   'name' => $name,
				   'time' => date_from_filename($file),
				   'status' => 1,
				   'type' => $type,
				   'file' => [$file]
				   };
		if (defined($num)) {
			#this is part of a multi-file comic
			#recreate the file array because the one we're looking
			#at may not be image #1.
			$rli->{'file'}->[$num - 1] = $file;
			my @multifiles = grep(/^$name(-\d+)?\.\w+$/,@files);
			@files = grep(!/^$name(-\d+)?\.\w+$/,@files);
			for (@multifiles) {
				my $file = $_;
				#make sure that none of the files in the multi-file comic
				#have an rli status file
				if (grep(/^$file$/,@comics) ||
					grep(/^$file$/,@existing_rli_files)) {
					print STDERR "Warning: $name has some stale file(s).\n"
						if $verbose;
					next RMW;
				}
				#add this file to the $rli's file list
				my ($title,$date,$type,$num) = parse_name($file);
				$rli->{'file'}->[$num - 1] = $file;
			}
		}
		next if grep(/^$file$/,@comics) ||
			grep(/^$file$/,@existing_rli_files); #skip this file 
		#no associated rli status file, generate our own rli hash for the file.
		print STDERR "Warning: $name has no status file; some " .
			"info about it may be lost.\n" if $verbose;
		push(@rli,$rli);
	}
}

#check to see if any comics were downloaded or are downloadable
#simply to give a message to the user if verbose.
if ($verbose) {
	my $good = 0;
	foreach (@rli) {
		$good = 1, last if $_->{'status'};
	}
	unless ($good) {
		my $m = $dont_download ? "are downloadable" : "were downloaded";
		print "\nNo comics $m.\n";
	}
}

print STDERR "Selected Comics !! : @selected_comics \n" if $extra_verbose;

if ($make_webpage) {
	# Load all possible alternative themes modules.
	load_modules("Netcomics::HTML::Themes", @html_theme_dirs);

	# Create the webpage.
	unless ($separate_comics) {
		Netcomics::HTML->create_basic_page_set(@rli);
	} else {
		Netcomics::HTML->create_archive_webpages(@rli);
		Netcomics::HTML->create_toplevel_page_set(@rli);
	}
} else {
    my $user_specified_no_comics = 
	($user_specified_comics && ! @selected_comics) ? 1 : 0;
    #print filenames or urls.
	foreach (@rli) {
		my $rli = $_;
		if ($rli->{'status'} =~ /[12]/) {
			my $time = $rli->{'time'};
			if ($get_current) {
				if (defined($rli->{'behind'})) {
					#get what the current specified date was from days behind
					$time +=  $rli->{'behind'}*3600*24;
				} elsif (defined($factory->days_behind($rli->{'proc'}))) {
					#backwards compatibility for rlis created with code that
					#didn't save the days behind in the rli.
					$time += $factory->days_behind($rli->{'proc'})*3600*24;
				} else {
					#this must be an old rli file not created with code
					#that saved the days behind info in the rli.
					$time = "";
				}
			}
			if (!$user_specified_comics || $user_specified_no_comics ||
				(grep(/^$rli->{'proc'}$/, @selected_comics) &&
				 grep(/$time/, @dates))) {
				print "$rli->{'title'} (" . 
					strftime("%a, %x",gmtime($rli->{'time'})) . "):\n" 
						if $verbose;
				#dont_download is set when user requests urls only
				if ($dont_download) {
					print join("\n",@{$rli->{'url'}})
						if defined $rli->{'url'};
				} else {
					print join("\n",map {"$comics_dir/$_"} @{$rli->{'file'}})
						if defined $rli->{'file'};
				}
				print "\n";
			}
		}
	}
}
#END of main


# Local Variables:
# tab-width: 4
# cperl-indent-level: 4
# cperl-continued-brace-offset: -4
# cperl-continued-statement-offset: 4
# cperl-label-offset: -4
# perl-indent-level: 4
# perl-continued-brace-offset: -4
# perl-continued-statement-offset: 4
# perl-label-offset: -4
# End:
