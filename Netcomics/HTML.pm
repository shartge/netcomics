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

package Netcomics::HTML;

use POSIX;
use strict;
use Carp;
use Netcomics::Util;
use Netcomics::Config;
use Netcomics::HTML::Set;

# Load the templates into this namespace.
load_modules("Netcomics::HTML::Themes", @html_theme_dirs);

#class attributes
my $inform_maintainer = "Please inform the maintainer of netcomics:\n" .
    "Ben Hochstedler <hochstrb\@cs.rose-hulman.edu>.\n";
my $files_mode = 0644;

sub create_basic_page_set {
	my $self = shift;
	my @rli = @_;
	my $template = eval "Netcomics::HTML::Themes::$html_theme->new";
	print "Creating with template $template->{'name'}.\n";
	my $HTMLpage = Netcomics::HTML::Set->new(
											 'theme' => $template
											);
	$HTMLpage->create_set_of_pages(@rli);
}

sub create_toplevel_page_set {
	my $self = shift;
	my @rli = @_;
	my $template = eval "Netcomics::HTML::Themes::$html_theme->new";
	print "Creating with template $template->{'name'}.\n";
	my $HTMLpage = Netcomics::HTML::Set->new(
											 'theme' => $template,
											 'link_to_local_archives' => 1,
											);
	$HTMLpage->create_set_of_pages(@rli);
}

sub create_archive_webpages {
	my $self = shift;
	my @rli = @_;

	my $template = eval "Netcomics::HTML::Themes::$html_theme->new";
	print "Creating with template $template->{'name'}.\n";

	# Create archive pages
	my @selected_comics;
	foreach (@rli) {
		my $proc = $_->{'proc'};
		push(@selected_comics, $proc) if not grep(/$proc/, @selected_comics);
	}

	foreach my $comic (@selected_comics) {
		my @rlis_to_pass;
		my $subdir = "";
		foreach my $rli (@rli) {
			#print "Trying to match $comic to $rli->{'proc'}\n";
			#print "Succes matching $comic to $rli->{'proc'}" if
			#grep(/$comic/, $rli->{'proc'});
			if (defined($rli->{'proc'})) {
				if (grep(/^$comic$/, $rli->{'proc'})) {
					push(@rlis_to_pass, $rli);
					$subdir = $rli->{'subdir'};
				}
			}
		}
		my $HTMLpage = Netcomics::HTML::Set->new
		('output_dir' => "$comics_dir/$subdir",
		 'theme' => $template,
		 'include_subdir' => 0
		);
		#print "Putting in directory $subdir\n";
		$HTMLpage->create_set_of_pages(@rlis_to_pass);
	}
}

sub create_today_page {
	my $self = shift;
	my @rli = @_;

	my $template = eval "Netcomics::HTML::Themes::$html_theme->new";
	print STDERR "Creating with template $template->{'name'}.\n" if $verbose;

	# Create archives for these comics.
	my %data = Netcomics::Util::rlis_hash(@rli);

	my @rlis_to_pass;
	foreach my $comic (keys(%data)) {
		my $subdir = "";

		my $comic_to_pass;
		my $highest = 0;
		foreach my $entry (@{$data{$comic}}) {
			if (($highest < $entry->{'time'} ) &&
				$entry->{'status'} != 0) {
				$highest = $entry->{'time'};
				$comic_to_pass = $entry;
			}
		}
		push(@rlis_to_pass, $comic_to_pass);
	}

	my $HTMLpage = Netcomics::HTML::Set->new
	('output_dir' => "$comics_dir",,
	 'theme' => $template,
	 'include_subdir' => 1,
	 'webpage_filename_tmpl' => "today<NUM>.html",
	 'link_to_local_archives' => 1
	);
	$HTMLpage->create_set_of_pages(@rlis_to_pass);
}

1;


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
