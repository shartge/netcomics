#-*- tab-width: 4 -*-
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

package Netcomics::Util;

use POSIX;
use strict;
use Carp;
use Netcomics::Config;

require Exporter;
use vars qw(@EXPORT @ISA $tz $imgsize_loaded);
@ISA = qw(Exporter);
@EXPORT = qw(
			 requireDataDumper
			 load_modules
			 parse_name
			 date_from_filename
			 file_write
			 file_read
			 image_size
			 library_sort
			 libdate_sort
			 mkgmtime
			 samedate
			 status_message
			 syscmd
			 );

#mkgmtime var (taken from Time::Local)
{
	my(@epoch) = localtime(0);
	my($tzmin) = $epoch[2] * 60 + $epoch[1];    # minutes east of GMT
	if ($tzmin > 0) {
		$tzmin = 24 * 60 - $tzmin;              # minutes west of GMT
		$tzmin -= 24 * 60 if $epoch[5] == 70;   # account for the date line
	}
	$tz = (0 - $tzmin/60);
}

sub requireDataDumper {
	my $data_dumper_installed = 0;
    $@ = 1;
    eval {
		$@ = 0;
		require Data::Dumper;
    };
    if ($@) {
		#Data::Dumper not installed.
		print "Warning: Data::Dumper not installed.\n" .
			"Will not be able to store extra comic information.\n"
				if $verbose;
    } else {
		$data_dumper_installed = 1;
		#setup Data::Dumper stuff.
		#$Data::Dumper::Purity = 1;
    }
    return $data_dumper_installed;
};

#load_modules(namespace,dirs) arguments:
# Namespace in which to load modules
# Directories to find modules
#returns a reference to a copy of the hof hash which was also loaded
#into that namespace.
sub load_modules {
	my $namespace = shift;
	my @libdirs = @_;
	push(@INC,@libdirs);
	foreach my $libdir (@libdirs) {
		if (opendir(DIR, $libdir)) {
			my @modules = grep { /[^~]$/ && -f "$libdir/$_" } readdir(DIR);
			closedir DIR;
			print "Loading modules in $libdir: " if $extra_verbose;

			my $module;
			foreach $module (@modules) {
				next if $module =~ /\.pm$/;
				print "$module " if $extra_verbose;
				eval "package $namespace; require \"$libdir/$module\""
					if (-r "$libdir/$module");
			}
			print "\n" if $extra_verbose;
		} else {
			print STDERR "$libdir is not accessible. Skipping it.\n";
		}
	}
	my %hofc;
	eval "%hofc = %${namespace}::hof";
	return \%hofc;
}

sub parse_name {
	$_ = shift();
	$_ =~ s/_/ /g; #remove underscores
	if (/(.+?)-(\d+)(-(\d+))?\.(\w+)/) {
		return($1,$2,$5,$4);
	} elsif (/^([^\.\d]+)$/) {
		#apparently no date or file type in the name (lack of period or digit)
		print STDERR "error determining filetype for: $_\n"
			if $extra_verbose;
		return($1,undef);
	} else {
		print STDERR "error processing filename: $_\n"
			if $extra_verbose;
		return (undef,undef);
	}
}

sub date_from_filename {
	$_ = shift;
	if (/.*-(\d?\d?\d\d)(\d\d)(\d\d)(-\d+)?\.\w+/) {
		my ($year,$month,$day) = ($1,$2,$3);
		if ($year > 1900) {
			$year -= 1900;
		} elsif ($year < 38) {
			$year += 100;
		}
		return mkgmtime(0,0,0,$day,--$month,$year);
	} else {
		return undef;
	}
}

sub file_write {
	my $file = shift(@_);
	my $mode = shift(@_);
	my $exists = -f $file;
	open(F, ">$file") || die "Could not open \"$file\". $!";
	binmode(F);
	print(F @_);
	close(F);
	unless ($exists) {
		chmod($mode, $file) || die "Could not set \"$file\"'s permissions. $!";
	}
}

sub file_read {
	local $/;
	my $file = shift;
	open(F, "<$file") || die "Could not open \"$file\". $!";
	binmode(F);
	$/ = undef; #input record separator
	my $text = <F>;
	close(F);
	return $text;
}

#returns the size of the image as is put into an HTML <img> tag.
sub image_size {
	my ($file) = shift;
	#when run for the first time, try to import Image::Size.
	if (! defined $imgsize_loaded) {
		$@ = 0;
		eval {require Image::Size; Image::Size->import('html_imgsize');};
		if ($@) {
			print "\nWarning: Image::Size not installed. Using the file " .
				"command instead.\n\n" if $verbose;
			$imgsize_loaded = 0;
		} else {
			$imgsize_loaded = 1;
		}
	}
	return html_imgsize($file) if $imgsize_loaded && ! $use_filecmd;

	$_ = `file $file`;
	if ($? == 0 && /(\d+) x (\d+)/) {
		return "WIDTH=$1 HEIGHT=$2";
	} else {
		return undef;
	}
}

sub library_sort {
	my ($a,$b) = @_;
	(my $thea = $a) =~ s/^\s*(a|an|the)[\s_]+//i;
	(my $theb = $b) =~ s/^\s*(a|an|the)[\s_]+//i;
	return $thea cmp $theb;
}

sub libdate_sort {
	my ($a,$b,$ad,$bd,$sort_by_date) = @_;
	if ($ad == $bd || ! $sort_by_date) {
		return library_sort($a,$b);
	} else {
		return $bd <=> $ad;
	}
}

sub mkgmtime {
	return mktime(@_) + (3600*$tz);
}

=head2 in_future($day_to_download, $days_behind)

Compares the the variable $days_to_download against the time reported by the
time command. Returns 1 if the date has happened yet. in_future() compensates
the "today" date by $days_behind.

=cut

sub in_future {
	my ($day_to_download, $days_behind) = @_;
	my $today_time = (time - (86400*$days_behind));
	if ($today_time < $day_to_download) {
		return 0;
	} else {
		return 1;
	}
}

sub status_message {
	#note this table is stolen from HTTP::Status
	my %StatusCode = 
		(100 => 'Continue',
		 101 => 'Switching Protocols',
		 200 => 'OK',
		 201 => 'Created',
		 202 => 'Accepted',
		 203 => 'Non-Authoritative Information',
		 204 => 'No Content',
		 205 => 'Reset Content',
		 206 => 'Partial Content',
		 300 => 'Multiple Choices',
		 301 => 'Moved Permanently',
		 302 => 'Moved Temporarily',
		 303 => 'See Other',
		 304 => 'Not Modified',
		 305 => 'Use Proxy',
		 400 => 'Bad Request',
		 401 => 'Unauthorized',
		 402 => 'Payment Required',
		 403 => 'Forbidden',
		 404 => 'Not Found',
		 405 => 'Method Not Allowed',
		 406 => 'Not Acceptable',
		 407 => 'Proxy Authentication Required',
		 408 => 'Request Timeout',
		 409 => 'Conflict',
		 410 => 'Gone',
		 411 => 'Length Required',
		 412 => 'Precondition Failed',
		 413 => 'Request Entity Too Large',
		 414 => 'Request-URI Too Large',
		 415 => 'Unsupported Media Type',
		 500 => 'Internal Server Error',
		 501 => 'Not Implemented',
		 502 => 'Bad Gateway',
		 503 => 'Service Unavailable',
		 504 => 'Gateway Timeout',
		 505 => 'HTTP Version Not Supported',
		 );
	$_ = $StatusCode{shift(@_)};
	return (defined($_)? $_ : "(unknown HTTP response code)");
}

sub syscmd {
	my $cmd = shift(@_);
	print "$cmd\n";
	return system($cmd);
}

#are the given two times during the same date?
sub samedate {
	my $t1 = strftime("%Y%m%d",gmtime($_[0]));
	my $t2 = strftime("%Y%m%d",gmtime($_[1]));
	return ($t1 == $t2);
}
1;
