#-*- tab-width: 4 -*-
#---------------------------------------------------------------------
# This module creates the interface for Comic Page.
#---------------------------------------------------------------------
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
#
#---------------------------------------------------------------------
package Netcomics::GtkComics;

use strict;
use Gnome;
use Gtk::GladeXML;
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
my $main = new Gtk::GladeXML("Comicpage/comicpage.glade");
$main->signal_autoconnect_from_package('Netcomics::GtkComics');

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
my $list = $main->get_widget('clist1');
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

# Create temporary groups.
foreach (keys(%procs)) {
	$groups{"All"} .= " $_";
}
$groups{"single_panes"} = "boffo fw fdcotd curios";
$groups{"animated"} = "doodie";

my @menu_list;
my $value = 0;
my $top_menu = new Gtk::Menu;
my $opt_list = $main->get_widget('optmenu_groups');
$opt_list->set_menu( $top_menu );
foreach (keys(%groups)) {
	my $newmenuitem = new Gtk::MenuItem("$_");
	$top_menu->append($newmenuitem);
	$newmenuitem->signal_connect( 'activate', \&change_group, $value  );
	$newmenuitem->show;
	$value++;
	push(@menu_list, $_);
}

my $i;
for ($i = 0; $i < $#unified_comic_array; $i++) {
	$list->append( @{$unified_comic_array[ $i ]} );
}

# Set up status bar.
my $info = $main->get_widget('appbar1');
$info->set_status("Welcome!");
$info->set_progress(1);

# Set up signal handelers.
#$forms->{'window_comic_page'}{'calendar_date_comic_selection'}->signal_connect( 'day_selected', \&Display_comic );
#$main->get_widget('clist1')->signal_connect( 'select_row', \&comic_selected_from_list );
#$forms->{'window_comic_page'}{'optionmenu1'}->signal_connect( 'released', \&change_group );

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
	   ["Elliot Glaysher <nuriko.chan\@home.com>" ,
	   "Ben Hochstedler <hochstrb\@cs.rose-hulman.edu>"], 
	   "Comic Page is a program that will create a composite image of your favorite online comics. It will also do archiving of these comics if you so wish it to."
	  );

	# Set properties and show.
	$ab->set_title("About"."Comic Page" );
	$ab->position('mouse' );
	$ab->set_policy(1, 1, 0 );
	$ab->set_modal(1 );
	$ab->show;
}

sub change_group {
	shift;
	my $value = shift;
	my $group_name = $menu_list[$value];
	my $comics = $groups{$group_name};
	my @comics = split(/ /,$comics);

	my (@unified_comic_array, @true_comic_name);
	foreach my $name (@comics) {
		push(@true_comic_name, $procs{$name});
	}
	@true_comic_name = sort(@true_comic_name);
	foreach (@true_comic_name) {
		my $tmpref = [ "$_" ];
		push(@unified_comic_array, $tmpref);
	}
	my $i;

	# Clear data and add new array.
	my $list = $main->get_widget('clist1');
	$list->clear();
	$list->set_selection_mode( 'single' );
	for ($i = 0; $i < $#unified_comic_array + 1; $i++) {
		$list->append( @{$unified_comic_array[ $i ]} );
	}
}

sub comic_selected_from_list {
	my $clist = shift;
	shift;
	my $row = shift;

	# Get the proc name of the comic.
	my $name = $clist->get_text( $row, 0 );
	$proc = $name_lookup{$name};

	# Do a days behind lookup, get the localtime formatted @ for time - the
	# days behind, and then set the $calendar's date. (Display_comic is called
	# automatically.
	my $calendar = $main->get_widget('calendar_date_comic_selection');
	my $days_behind = $date_lookup{$proc};
	my @date = localtime((time - (86400*$days_behind)));
	$calendar->select_month( $date[4], ($date[5] + 1900) );
	$calendar->select_day( ($date[3] ) );

	return;
}

sub Display_comic {
	# Setup variables.
	my $calendar;
	$calendar = $main->get_widget('calendar_date_comic_selection');
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
		my $display_area = $main->get_widget('pixmap1');
		$display_area->load_file($filename);
		$display_area->show();
		if ($rli->{'caption'}) {
			$info->set_status("$rli->{'caption'}");
		} else {
			$info->set_status("Displayed: $filename");
		}
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

1;
