#!/usr/bin/perl -w
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

=head1 NAME

netcomics - retrieve comics from the Internet

=head1 SYNOPSIS

B<netcomics> [B<-abBDhiIlLosuvv>] [B<-c,-C> I<"comic ids">] [B<-p> I<proxy>] [ B<-R> retries]
  [B<-S,-T,-E> I<date> [B<-A>]] [B<-n,-N> I<days>] [B<-d,-m,-t> I<dir>] [B<-f> I<date_fmt>]
  [B<-g> [I<program>]] [B<-nD>] [B<-r> I<rc_file>] [B<-P>] [B<-W,-w>[=I<n>]] [B<-nw>]

=head1 DESCRIPTION

The I<netcomics> program will download today's comic strips from
the Web, and place them in a spool directory where they can be
retrieved for display.  Because each website that carries comic
strips chooses how old of strips to show, the comic strips downloaded
will actually be from different dates.  Most common will be comic
strips that are 1 week, 2 weeks, and 3 weeks old. Also, each website
is not updated at the same time, nor are any of them updated at a
consistent time during the day.  Therefore, when running netcomics
as a cron job in the early morning, you may need to rerun it by hand
a little later in the day to get the comics that it couldn't find.
I<netcomics> will automatically determine what comics need to be retried
to be downloaded (max retries defaulted to 3).

I<netcomics> also supports retrieving specific dates of comics.  A
"Starting Date" may be specified with B<-S>.  An "Ending Date" may be
specified with B<-E>.  And a specific date may be specified with
B<-T>.  All dates are given in the M-D-[YY]YY format.  If a start date
is given without an end date, B<-n> may be used to specify the number
of days of comics to retrieve starting at the specified start date.
If an end date is given without a start date, B<-n> will specify the
number of days of comics to retrieve counting backwards from the end
date.  If a start date is given without B<-n> or B<-E>, then the end
date is assumed to be today's date.  If the option given to B<-E>,
B<-S>, or B<-T> is just an integer, that integer is interpreted as
the number of days prior to the current day (specify specific dates
relatively).

Another way to specify the dates to download comics, is to use B<-N>
in conjunction with B<-n>.  The argument to B<-N> is the number of
days prior to the current day to retrieve comics.  Note that this does
not specify an actual date.  It rather indicates the number of days
ago a comic was made available, rather than the actual date of the
comic.  To see how far behind the date of each comic is from the date
it actually gets released, use B<-l>.  So if today is Wednesday, and you
specify B<-N 2>, I<netcomics> will download the comics that were made
available on Monday.  This is useful for running netcomics in a
timezone that is way ahead of the timezones the comics' websites are
located.

I<netcomics> was created for the purpose of giving your weary mind a 
little relief from your hectic workday, so another script
called I<show_comics> has been provided to periodically popup the 
retrieved comic strips throughout the workday.  Another script called
I<display_comics> has also been provided, but it is only an example
script of what can be done for displaying comics on many users
computers on a network.

B<Important:>  The further east your timezone is from the US, the later 
in the day you'll have to run I<netcomics>.  As a reference, I suggest
those whose timezone is GMT to wait to run the script at 12:30pm if
they want to get all the comics at a time that's pretty likely to have
had all of the 
s updated.  Use B<-N> if you want to run the
script early in the morning and are having problems getting comics to
download. Also, just because a comic failed to download doesn't mean
that the module for that comic is broken--it may mean the website
just hasn't been updated yet.

I<netcomics> can also create an set of HTML files, in the
directory you have the comics placed.   If a number is given with
B<-W> or B<-w>, it will be used to determine the number of comics to
be placed in each html file.  Each file is named "comic#.html", and an
"index.html" file is created with a table of pointers into these files.

I<netcomics> can also maintain archives of comics for you with the use
of the B<-P> feature. Using this will separate all comics of a single
title into their own separate directories. Using the B<-P> also effects
the behaviour of the generation of HTML pages: for each comic, a different
set of HTML pages is generated. It is a better idea to set the variable
$seperate_comics to 1 in your netcomicsrc file so this option is not
intermittently used.

B<Disclaimer:> Do not put the comics up on the Internet!  You should
only use them for your own use.  Also, do not redistribute the comics
downloaded by I<netcomics> in any other way unless you receive written
authorization from each comic's publisher and/or author.

=head1 OPTIONS

=over 4

=item B<-a>

Always download even if the comic strip about to be downloaded exists in
the spool directory.  When netcomics starts up, it scans the download directory
and reads in all the status information files for each comic strip in the
directory (use B<-D> to have netcomics clear the directory when it starts).
By default, netcomics will skip downloading comics you specify to download
if they are in the directory and they have a good status indicator.  By
specifying this option, netcomics will skip this step and clobber the
previously downloaded comics.

However, if used with B<-c>, the behavior is different.  Netcomics by default
will only download the comics you specify with B<-c>.  If B<-c> isn't provided,
netcomics will download everything.  If both B<-a> and B<-c> are provided,
it will process both the comics you specify (even if they were already
successfully downloaded) and the ones that weren't successfully downloaded.
Note that only the tries counter is ignored for the specified comics in this
case.  See B<-nR> for changing the maximum number of retries.

=item B<-A>

Consider I<today> is the day specified with the B<-S>, B<-T> or B<-E> options.
Will recalculate dates decalage accordingly.
This option only makes sense when used with the B<-S>, B<-T> or B<-E> options.

=item B<-b>

Get black & white comics if their is a choice between that and color.

=item B<-B>

Don't get black & white comics if their is a choice between that and color.
Use this option to override the setting in the rc file.

=item B<-c> I<'comic_ids'>

Get the supplied comics (ids are separated by white spaces).
This option may be repeated, and may not be used in conjunction with B<-C>.

=item B<-C> I<'comic_ids'>

Don't get the supplied comics (ids are separated by white spaces).
This option may be repeated, and may not be used in conjunction with B<-c>.

=item B<-d> I<dir>

Put comics into directory. Default is /var/spool/netcomics.

=item B<-D>

Delete files in directory before retrieving.

=item B<-E> [I<date> | I<days>]

Specify an ending date, or the date that is the specified number of
days prior to today, with which to define the range of days of comics
to retrieve.  Must be used in combination with one of B<-S> or B<-n>.
The date is of the form: M-D-Y.

=item B<-f> I<date_fmt>

Specify the date format used when naming files.  Default is C<'%y%m%d'>.

=item B<-g> [I<program>]

Specify a program to use to perform HTTP requests.  The 
program must write the retrieved content of the URL on its stdout.
The macro %R is replaced with the URL of the referer, %P is replaced
with the proxy URL (if supplied), and %U is replaced with
the URL to retrieve.  If %U is not found, the URL is appended (with a
space). Macros are case insensitive.

Note that you don't have to specify the program on the command line
if you want to use the default command which is:

   'wget -q -O - --header="Referer: %R"'.

You'll probably just want to set $external_cmd in your rc file.

=item B<-G>

Puts all rli information into one .rli file, named I<.netcomics.rli>
by default. Like B<-P>, it is a good idea to set $single_rli_file in
your netcomicsrc file instead of using this from the command line.

=item B<-h>

Show usage. Comics will not be downloaded.

=item B<-i>

Don't create an index for the webpages.

=item B<-I>

Create an index for the webpages. Specify this to override the setting 
in the rc file if need be.

=item B<-l>

List supported comics & their identifiers, sorted by name alphabetically.
Comics will not be downloaded.

=item B<-L>

Sort comics in webpages by date and when using B<-l>, by days behind.

=item B<-m> I<dir>

Add dir to the locations of comic modules. Default is /usr/share/netcomics.
This option may be repeated to add multiple directories.

=item B<-M> I<dir>

Use only the list of locations of comic modules specified on the command line.

=item B<-n> I<days>

Retrieve this number of days of comics, going backwards. Default is 1.
This option may be used in conjunction with B<-N>.

=item B<-N> I<days>

Start retrieving comics this many days before the currently available date.
If you use B<-l> to show the comic id's, the 3rd column indicates the number
of days behind a comic is available.  By default, if B<-E> or B<-S> are
not specified, then netcomics will retrieve each comic, understanding that
the latest available is that many days ago (according to the number shown
in the 3rd column).  Use this option to push the number of days ago back 
even further.  Default is 0. This option may be used in conjunction with 
B<-n>, but not with B<-S> or B<-E>.

=item B<-o>

Write the webpage on standard out. Cannot specify the number of comics
per page for B<-W> or B<-w> if you use this option.

=item B<-p> I<url>

Specify a URL to use as a proxy.  Both HTTP and FTP are supported.
If you use wget, specify http_proxy = URL or ftp_proxy = URL in your
.wgetrc file.

=item B<-P>

Turns on comic separation mode, which puts comics into their own 
subdirectories. This is useful for maintaining an archive of comics.
It is a better idea to set the $separate_comics variable to 1 in the
netcomicsrc file so that this feature is not intermittently used.

=item B<-Q>

Supresses the final error message that prints out the command to rerun
to attempt to try to retreive the comics that failed to download.

=item B<-nQ>

Disable suppression of final error message (override rc file setting).

=item B<-q>

Show what comics would be downloaded.  Don't actually do anything.

=item B<-r> I<rc filename>

Specify an alternate name for the user-specific rc file

=item B<-R> I<retries>

Specify the maximum number of retries for downloading comics not specified
to be downloaded, inbetween invocations of netcomics.
If you don't have the download directory cleared out, netcomics will
pick up information on comics it's tried to download previously.  Specify
1 to this option if you don't want netcomics to retry to download comics
you don't specify for it to download.  Specify 0 for an infinite number of
retries.

=item B<-nR>

Specify there is no maximum number of retries.  This will cause netcomics
to keep trying to download comics that haven't been successfully downloaded
no matter how many unsuccessful attempts there were.  This is the same
thing as B<-R 0>.

=item B<-s>

Don't skip bad comics when creating the web page.  This will potentially
cause the web page to be loaded into a browser more slowly, but it will
make it evident exactly which websites don't return proper HTTP errors.

=item B<-S> [I<date> | I<days>]

Specify a starting date, or the date that is the specified number of
days prior to today, with which to define the range of days of
comics to retrieve.  May be used in combination with of B<-E> or
B<-n>. The date is of the form: M-D-Y.

=item B<-t> I<dir>

Specify the location of html template files. Default is 
/usr/share/netcomics/html_tmpl.

=item B<-T> [I<date> | I<days>]

Specify a specific date, or the date that is the specified number of
days prior to today, of comics to retrieve.  This option my be
repeated. The date is of the form: M-D-Y.

=item B<-u>

Don't download comics, but print URLs on stdout, or if creating a
webpage, make the images implemented using the URLs.  Note that this
option can be used with B<-a> (always download).  This option doesn't keep
everything from being downloaded--just the final URL.  B<-a> simply turns
off netcomics' tendency to needlessly redownload comics already "downloaded"
(whether it be fully downloaded or only to the point of having a URL to
the comic strip).

Another important note is that some websites try to prevent downloading
of comics from programs like this by requiring the "referer" of the
HTTP Get operation to be of a particular website.  For those websites that
impose this policy, using this option will result in comics that won't
download when browsing the webpage netcomics produces because the referer
your browser will specify when doing the HTTP Get operation for those
comics won't be the right one.

=item B<-v>

Be a little verbose.

=item B<-vv>

Be extra verbose

=item B<-w>[=n]

Create an html file, index.html, for the comics downloaded. Optionally,
n specifies the number of comics to have in each page, where subsequent
html files are named comic#.html.

=item B<-nw>

Do not create a webpage. Use this option to override the rc file setting,
make_webpage, if need be.  When no webpage is created, filenames of the
selected comics will be printed.  If the B<-u> option is used, URLs will
be printed instead.  Use B<-v> also to include the comic tiles before the
filenames or URLs.

=item B<-wt> I<title>

Specify a title for the web page rather than the default
("Today's Comics From the Web on E<lt>DATEE<gt>").  This is useful
for when you download specific comics, and want the title of the
web page to reflect the actual contents.

=item B<-W>[=n]

Recreate the html file, index.html, from the comics that are in the
directory, as well as any new comics downloaded.  Optionally,
n specifies the number of comics to have in each page, where subsequent
html files are named comic#.html.

=back

=head1 EXAMPLES

=over 3

=item 1. Run as a cronjob.

Run as a cron job at 7:30am, Monday through Friday, removing
the previous day's comics beforehand, and creating a web page.
And for Monday, also retrieve Saturday & Sunday's comics.

   30 07  *  *  2-5  /usr/bin/netcomics -D -w
   30 07  *  *  1    /usr/bin/netcomics -n 3 -D -w


=item 2. Run as a cronjob, not so many on Monday.

Same as before, except, for Monday, get Saturday's & Sunday's
comics, and for Tuesday, get Monday & Tuesday's.  This is so there
isn't such an overload of comics on Monday.

   30 07  *  *  1    /usr/bin/netcomics -N 1 -n 2 -D -w
   30 07  *  *  2    /usr/bin/netcomics -n 2 -D -w
   30 07  *  *  3-5  /usr/bin/netcomics -D -w

=item 3. Run as a cronjob, email yourself the URLs.

   30 07  *  *  *    /usr/bin/netcomics -uv | mailx -s "today's comics" $LOGNAME

=item 4. Select comics, separate directory, different date format in webpage.

Grab Dilbert & Foxtrot comics from the past 30 days, place them in /tmp,
and create a web page with a specific title (<DATE> gets replaced with the
name of the month).

   netcomics -c "dilbert ft" -n 30 -d /tmp -w -wt 'Dilbert & \
   Foxtrot Comics From the Month of <DATE FORMAT="%b">'

=item 5. Date range, start to finish, plus an extra date.

Specify the date range of comics to retrieve to be from Feb 3, 1999
to Feb 6, 1999, and also get comics on March 3, 1998.

   netcomics -S 2-3-99 -E 2-6-99 -T 3-3-98

=item 6. Date range, specify end & number of date, exclude some comics.

Specify the date range of comics to retrieve to be from Jan 6, 1999
and the 5 days before it.  Get all the comics except Jerkcity and Doodie

   netcomics -E 1-6-99 -n 6 -C jc -C doodie

=item 7. Specify number of days of comics, a number of days ago.

Specify the date range of comics to retrieve to be all those that came
available three, four, and five days ago.

   netcomics -N 3 -n 3

=item 8. Specify number of days of comics, a number of days ago.

Specify the date range of comics to retrieve to be all those that are
dated three, four, and five days ago.  This example is given to show
the difference between B<-E> & B<-S>  (when given a number) and -N. All
comics downloaded will have the same 3 dates, while in the previous 
example, the comics will have varying dates that are determined by
the 3rd column in the output of -l. Note that since many comics aren't
available until 2 weeks have past, many of them will not download
with this example.

   netcomics -E 3 -n 3

            or

   netcomics -E 3 -S 5

See B<-A> for a more elegant way of downloading comics released in the
past.

=item 9. Use wget.

Use wget instead of libwww-perl (makes it so you don't have to install
libwww-perl).

   netcomics -g

=item 10. Print webpage with URLs to stdout.

Do not actually download the comics.  Output the webpage (which will point
to the comics on the websites they actually are released from) to stdout.

   netcomics -uwo

=item 11. Pretend today's date is a different one.

Download the Calvin & Hobbes, Alice and Dragon Tails as if the day the
download was done was May 1st 2000.
 
   netcomics -T 5-1-00 -A -c "ch alice dt"
 
This will download Dragon Tails for May 1st 2000 since the strip is available
the same day, but will download the May 1st 1989 Calvin & Hobbes' strip
since it is 4018 days back, as well as the April 17th 2000 strip for Alice 
since it is 14 days back.

This behaviour also applies for the B<-E> and B<-S> options.

=item 12. Forcibly try to download those that failed.

Have netcomics retry downloading comics it didn't successfully download,
regardless of the number of times they've been retried (also remaking the
webpage).

   netcomics -c "" -R 0 -W

=item 13. Forcibly redownload everything.

Have netcomics ignore all previously downloaded (and not-yet downloaded) comics
and redownload everything.  Note that this was netcomics' default behaviour
prior to version 0.13. Also note this has the affect of resetting all comics'
retry counter to 1.

   netcomics -a

=item 14. List the supported comics.

List all the supported comics, including their IDs that are used with the B<-c>
option, and how old they are before being released on the website from which
they are downloaded.

   netcomics -l

=item 15. Override rc file options.

With a ~/.netcomicsrc file having $delete_files = 1 and $remake_webpage = 1
or $make_webpage = 1, tell netcomics to not delete the previously downloaded
comics and to not create or recreate the webpage.

   netcomics -nD -nw

=item 16. Create your own archives of comics.

Tells netcomics to download Kevin & Kell and User Friendly for the last fifteen
days, place them in separate directories, and then make a webpage with 10
entries on each page.

	netcomics -n 15 -W=10 -P -c "kk uf"

=back

=head1 FILES

=over 29

=item /usr/share/netcomics

Directory containing the modules that return RLIs.

=item /usr/share/netcomics/html_tmpl

Directory containing the HTML template files used to create the
web page.

=item /var/spool/netcomics

Default directory where comics and the web page are placed.

=item /usr/bin/display_comics

Example script that should be modified to be used to display the
downloaded comics.

=back

=head1 BUGS

=over 4

See the TODO file in the source distribution.

=back

=head1 SEE ALSO

show_comics(1)

=head1 AUTHOR

Ben Hochstedler <hochstrb@cs.rose-hulman.edu>
ICQ: B<15469308> AIM: B<hochstrb> Yahoo: B<hochstrb>

=cut

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

if ($make_webpage) {
	#Create the HTML object.
	my $HTMLpage = Netcomics::HTML->new("Webpage");

	# Create the webpage.
	unless ($separate_comics) {
		$HTMLpage->create_webpage(@rli);
	} else {
		$HTMLpage->create_webpage_set(\@rli, \@selected_comics);
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

