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

#class attributes
my $inform_maintainer = "Please inform the maintainer of netcomics:\n" .
    "Ben Hochstedler <hochstrb\@cs.rose-hulman.edu>.\n";
my $files_mode = 0644;
my $themes_loaded = 0;

# Load the templates into this namespace.
sub load_themes {
	load_modules("main", @html_theme_dirs)
		unless $themes_loaded;
	$themes_loaded = 1;
}

=head2

list_themes($do_print)

Returns a list of HTML Themes and also prints them out if $do_print is 1.

=cut

sub list_themes {
	my $do_print = shift;
	load_themes();
	my @modules = grep(s/.*::([^:]+)::$/$1/,
					   processSyms("main::", "Netcomics::HTML::Theme"));
	if (defined($do_print) && $do_print) {
		print "HTML Themes:\n" if $verbose;
		my $list_sep = $"; #save the list separator
		$" = "\n"; #change the list separator
		print "@modules\n";
		$" = $list_sep; #restore the list separator"
	}

	return @modules;
}

=head2 load_theme($theme_name)

Returns a theme object for the given theme name.

=cut

sub load_theme {
	my $theme_name = shift;
	load_themes();
	my $theme = eval "Netcomics::HTML::Themes::$theme_name->new";
	if (! defined($theme)) {
		my @themes = list_themes();
		die "The specified theme does not exist: $theme_name.\n" .
			"Valid themes: @themes\n";
	} else {
		print "Creating with HTML template $theme->{'name'}.\n" if $verbose;
	}
	return $theme;
}

sub create_basic_page_set {
	my $self = shift;
	my @rli = @_;
	my $template = load_theme($html_theme);
	my $HTMLpage = Netcomics::HTML::Set->new(
											 'theme' => $template
											);
	$HTMLpage->create_set_of_pages(@rli);
}

sub create_toplevel_page_set {
	my $self = shift;
	my @rli = @_;
	load_themes();
	my $template = load_theme($html_theme);
	my $HTMLpage = Netcomics::HTML::Set->new(
											 'theme' => $template,
											 'link_to_local_archives' => 1,
											);
	$HTMLpage->create_set_of_pages(@rli);
}

sub create_archive_webpages {
	my $self = shift;
	my @rli = @_;

	my $template = load_theme($html_theme);

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
	load_themes();
	my $template = load_theme($html_theme);

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
		('output_dir' => "$comics_dir",
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
