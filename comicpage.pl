#!/usr/bin/perl -w
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

use strict;
use Gnome;
use POSIX;
use Exporter;
use Netcomics::GtkComics;
use Netcomics::Config;
use Netcomics::Factory;
use Netcomics::Util;
use Data::Dumper;

$| = 1;
my $NAME = "ComicPage";

init Gnome $NAME;
set_locale Gtk;

my $false = 0;
my $true = 1;
my $proc;

# Create the GUI.
my $forms = &Netcomics::GtkComics::create_main_window;

print "Creating Netcomics object\n";
# Create the $factory object, and get the @comic_names .
my $script_name = "ComicPage";
my $conf = Netcomics::Config->new($script_name);
$conf->load_rcfile($system_rc,$rc_file);

$verbose = 1;
$extra_verbose = 1;

my $data_dumper_installed = requireDataDumper();

my $factory = Netcomics::Factory->new($conf);
my ($names_r,$max_flen,$max_nlen) = $factory->comic_names;
my %names = %$names_r;
my @names = sort({libdate_sort($a,$b,$names{$b}[1],$names{$a}[1],
									 $sort_by_date);} keys(%names));


print "Sorting...\n";
my $list = $forms->{'window_comic_page'}{'list1'};
$list->set_selection_mode( 'single' );
my @unified_comic_array;
my (%name_lookup, %date_lookup, %procs);
foreach my $name (@names) {
	my ($f, $d) = @{$names{$name}};
	my $tmpref = [ "$name" ];
	$name_lookup{$name} = "$f";
	$date_lookup{$f} = "$d";
	$procs{$f} = $name;
	push(@unified_comic_array, $tmpref);
}

my $i;
for ($i = 0; $i < $#unified_comic_array; $i++) {
	$list->append( @{$unified_comic_array[ $i ]} );
}

# Set up status bar.
my $info = $forms->{'window_comic_page'}{'appbar1'};
$info->set_status("Welcome!");
$info->set_progress(1);

# Set up signal handelers.
$forms->{'window_comic_page'}{'window_comic_page'}->signal_connect( 'delete_event', \&shut_me_down );
$forms->{'window_comic_page'}{'window_comic_page'}->signal_connect( 'destroy_event', \&shut_me_down );
$forms->{'window_comic_page'}{'menu_file_exit'}->signal_connect( 'activate', \&shut_me_down );
$forms->{'window_comic_page'}{'menu_help_about'}->signal_connect( 'activate', \&about_Form );
$forms->{'window_comic_page'}{'calendar_date_comic_selection'}->signal_connect( 'day_selected', \&Display_comic );
$forms->{'window_comic_page'}{'list1'}->signal_connect( 'select_row', \&comic_selected_from_list );


# Show the window.
$forms->{'window_comic_page'}{'window_comic_page'}->show();

# Call &on_calendar1_day_selected to pull up today's comic.
#&Display_comic;

# Enter main Gtk loop.
main Gtk;

sub about_Form {
	my $name = $0;

	# Create a Gnome::About '$ab'
	my $ab = new Gnome::About
	  (
	   "Comic Page", 
	   "0.01", 
	   "(C) GNU GPL, Elliot Glaysher, Mon Jan 22, 2001", 
	   "Elliot Glaysher <nuriko.chan\@home.com> \n" .
	   "Ben Hochstedler <hochstrb\@cs.rose-hulman.edu>", 
	   "Comic Page is a program that will create a composite image of your favorite online comics. It will also do archiving of these comics if you so wish it to."
	  );

	# Set properties and show.
	$ab->set_title("About"."Comic Page" );
	$ab->position('mouse' );
	$ab->set_policy(1, 1, 0 );
	$ab->set_modal(1 );
	$ab->show;
}

sub comic_selected_from_list {
	my ( $clist, $row, $column, $event, @data ) = @_;
	my $calendar;
	my $name;
	$calendar = $forms->{'window_comic_page'}{'calendar_date_comic_selection'};

	# Get the proc name of the comic.
	$name = $clist->get_text( $row, 0 );
	$proc = $name_lookup{$name};

	# Do a days behind lookup, get the localtime formatted @ for time - the
	# days behind, and then set the $calendar's date. (Display_comic is called
	# automatically.
	my $days_behind = $date_lookup{$proc};
	my @date = localtime((time - (86400*$days_behind)));
	$calendar->select_month( $date[4], ($date[5] + 1900) );
	$calendar->select_day( ($date[3] ) );

	return;
}

sub Display_comic {
	# Setup variables.
	my $calendar;
	$calendar = $forms->{'window_comic_page'}{'calendar_date_comic_selection'};
	(my $year, my $month, my $day) = $calendar->get_date();
	my $day_to_download = mkgmtime(0,0,12,$day,$month,$year-1900);
	my $comic_name = $procs{$proc};
	my $days_behind = $date_lookup{$proc};

	$info->set_progress(0);
	print "$year:$month:$day\n" if $verbose;

	# Check to see if the day's happened yet.
	unless (Netcomics::Util::in_future($day_to_download, $days_behind)) {
		$info->set_status("This day has not happened yet.");
		return;
	}

	# Pass responsibility off to $factory to get the comic.
	$info->set_progress(.10);
	$info->set_status("Please wait while downloading $comic_name...");
	my ($rli,$i) = $factory->get_comic($proc, $day_to_download);

	$info->set_progress(.70);
	if ($extra_verbose) {
		print Data::Dumper->Dump([$rli],[qw(*rli)]);
	}

	if (defined($rli) && $rli->{'status'} == 1) {
		# Display the comic since it downloaded succesfully.
		my $filename = "$comics_dir/$rli->{'file'}[0]";
		print "Going to display: $filename \n" if $extra_verbose;
		$forms->{'window_comic_page'}{'pixmap1'}->load_file($filename);
		$forms->{'window_comic_page'}{'pixmap1'}->show();
		$info->set_status("Displayed: $filename");
	} else {
		# Error, as it didn't download.
		$info->set_status(strftime("Could not download $comic_name for %x",
								   gmtime($day_to_download)));
	}
	$info->set_progress(1);
}

sub shut_me_down {
	Gtk->exit( 0 );
	return $false;
}







