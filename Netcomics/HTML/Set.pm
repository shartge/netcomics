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

package Netcomics::HTML::Set;

use strict;
use Netcomics::Config;
use Netcomics::HTML::Themes::Default;
use Netcomics::Util;
use Netcomics::HTML::Page;
use POSIX;

my $inform_maintainer = "Please inform the maintainer of netcomics:\n" .
    "Ben Hochstedler <hochstrb\@cs.rose-hulman.edu>.\n";

sub new {
	my $class = shift;

	my $HTML_Theme = new Netcomics::HTML::Themes::Default;

	my $self = {
				# The important stuff; properties, etc.
				'output_dir' => $comics_dir,
				'webpage_on_stdout' => $webpage_on_stdout,
				'include_subdir' => 1,
				'link_to_local_archives' => 0,
				'webpage_filename_tmpl' => $webpage_filename_tmpl,

				# The templates:
				'theme' => $HTML_Theme,

				# Override previous settings.
				@_
			   };

	# Bless object and return it.
	bless $self, $class;

	return $self;
}

sub create_set_of_pages {
	my $self = shift();
	my @rli = @_;

	#create a hash into the rli's
	my %rlis = ();

	%rlis = check_rlis(@rli);
	my @comics = keys(%rlis);
	print STDERR "comics = @comics" if $verbose;
	my $num_comics = @comics;
	if ($num_comics == 0) {
		print STDERR "\nNot creating a new webpage.\n" if $verbose;
		return;
	}

	print STDERR "\n" if $verbose;
	unless ($self->{'webpage_on_stdout'}) {
		print STDERR "Deleting old webpages (".$self->{'output_dir'} .
				"/<index.html,comic*.html>).\n" if $verbose;
		chdir $self->{'output_dir'};
		unlink <index*.html>;
		unlink <comic*.html>;
	}

	if ($verbose) {
		print STDERR "Creating the webpage";
		print STDERR "s" if defined($comics_per_page);
		print STDERR ".\n";
	}

	#create a sorted list of the comics
	my @sorted_comics = sort({libdate_sort($a, $b, $rlis{$a}{'time'},
										   $rlis{$b}{'time'}, $sort_by_date);} 
							 @comics);
	print STDERR "sorted comics: @sorted_comics\n" if $extra_verbose;


	#determine number of groups of comics, and number of comics on each page
	$comics_per_page = $num_comics
			unless defined($comics_per_page); 
	my $num_groups = $num_comics / $comics_per_page;
	$num_groups =~ s/^(\d+)\.?\d*$/$1/;
	my $comics_on_last = $num_comics % $comics_per_page;
	$num_groups++ if $comics_on_last > 0;
	print STDERR "number of groups    = $num_groups\n" .
		"comics per page     = $comics_per_page\n" .
			"comics on last page = $comics_on_last\n"
				if $extra_verbose;

	my @index_entries;
	my $tail;

	for my $group_num (1..$num_groups) {
		my $singlepage;
		if ($num_groups >= 2) {
			$singlepage = 0;
		} else {
			$singlepage = 1;
		}

		# Generate the first and last comic numbers in @sorted_comics.
		my $first = ($group_num - 1) * $comics_per_page + 1;
		my $last  = $first + $comics_per_page - 1;
		$last = $first + $comics_on_last - 1 
	    if ($group_num == $num_groups && $comics_on_last > 0);

		print STDERR "trying object...\n" if $extra_verbose;
		print STDERR "first = $first, last = $last\n" if $extra_verbose;
		(my $filename = $self->{'webpage_filename_tmpl'}) 
			=~ s/<NUM>/$group_num/g;

		#print Data::Dumper->Dump([\%rlis],[qw(*%rlis)]);
		#print keys(%rlis);

		#print @sorted_comics[($first-1)..($last-1)];

		my @comics_to_pass = @sorted_comics[($first-1)..($last-1)];

		# Create our HTML Page object.
		my $HTML_Page = Netcomics::HTML::Page->new
			('webpage_title' => "$webpage_title",
			 'num_groups' => $num_groups,
			 'group_number' => $group_num,
			 'first_comic' => $first,
			 'last_comic' => $last,
			 'total_comics' => $num_comics,
			 'filename' => $filename,
			 'link_to_local_archives' => $self->{'link_to_local_archives'},
			 'rli_dataset' => \%rlis,
			 'comics_set' => [@comics_to_pass],
			 'include_subdir' => $self->{'include_subdir'},
			 'webpage_filename_tmpl' => $self->{'webpage_filename_tmpl'},
			 'theme' => $self->{'theme'}
			);

		print STDERR "Object created...\n" if $extra_verbose;

		my %returned = %{$HTML_Page->generate};

		my $page = "$returned{'head'}$returned{'links'}$self->{'theme'}->{'html'}{'pre_body'}$returned{'body'}$self->{'theme'}->{'html'}{'post_body'}" .
		"$returned{'links'}$returned{'tail_tmpl'}";

		$tail = $returned{'tail_tmpl'};

		push(@index_entries, @{$returned{'index'}});

		unless ($webpage_on_stdout) {
			file_write("$self->{'output_dir'}/$filename",0664,"$page");
		} else {
			print STDERR "$page";
		}
	}

	# Yes, pretty much this whole section of code is ripped from above.
	# Sue me.
	if ($webpage_index && ! $webpage_on_stdout) {

		# Determine number of index pages for comics. Yes this was ripped from
		# above, yes this should be a sub. So sue me.
		$comics_per_index_page = $num_comics
			unless defined($comics_per_index_page); 
		my $num_groups = $num_comics / $comics_per_index_page;
		$num_groups =~ s/^(\d+)\.?\d*$/$1/;
		my $comics_on_last = $num_comics % $comics_per_index_page;
		$num_groups++ if $comics_on_last > 0;

		for my $group_num (1..$num_groups) {
			my $singlepage;
			if ($num_groups >= 2) {
				$singlepage = 0;
			} else {
				$singlepage = 1;
			}

			# Generate the first and last comic numbers in @sorted_comics.
			my $first = ($group_num - 1) * $comics_per_index_page + 1;
			my $last  = $first + $comics_per_index_page - 1;
			$last = $first + $comics_on_last - 1 
				if ($group_num == $num_groups && $comics_on_last > 0);

			# Create what's going to be the index.
			my $index;
			my $index_head;
			#index head global info
			$index_head = $self->{'theme'}->{'html'}{'head'};
			$index_head =~ s/<PAGETITLE>/$webpage_title/g;
			$index_head =~ s/<NUM=FIRST>/$first/g;
			$index_head =~ s/<NUM=LAST>/$last/g;
			$index_head =~ s/<NUM=TOTAL>/$num_comics/g;
			$index_head =~ s/<PAGETITLE>/$webpage_title/g;
			$index_head =~ s/<LINK_COLOR>/$link_color/g;
			$index_head =~ s/<VLINK_COLOR>/$vlink_color/g;
			$index_head =~ s/<BACKGROUND>/$background/g;

			# Code that let's you use custom date strigs.
			my $date = strftime("%b %d, %Y",gmtime(time()));
			$index_head =~ s/<DATE>/$date/g;
			my @ltime = localtime(time);
			while ($index_head =~ /<DATE FORMAT="([^\"]*)">/) {
				my $datestr = strftime($1,@ltime); 
				$index_head =~ s/<DATE FORMAT="([^\"]*)">/$datestr/;
			}

			# Now create the header with links to previous page, next page, and
			# up if we have multiple groups. Otherwise leave $links blank.
			my ($nextfile,$prevfile) = ($webpage_indexname_tmpl) x 2;
			my $nextgroup = ($group_num == $num_groups) ? 1 : $group_num + 1;
			my $prevgroup = $group_num - 1;
			if ($group_num == 1) {
				$prevgroup = $num_groups;
			}

			$nextgroup = 1 if $nextfile =~ s/<NUM>/$nextgroup/g;
			$prevfile =~ s/<NUM>/$prevgroup/g;

			my $links = "";
			if ($num_groups > 1) {
				$links = $self->{'theme'}->{'html'}{'links'};
				$links =~ s/<FILE=PREV>/$prevfile/g;
				$links =~ s/<FILE=NEXT>/$nextfile/g;
				$links =~ s/<NUM>/$comics_per_index_page/g;
			}

			for my $comic_number ($first .. $last ) {
				$index .= $index_entries[$comic_number - 1];
			}

			my $filename;
			unless($num_groups == 1) {
				($filename = $webpage_indexname_tmpl ) 
					=~ s/<NUM>/$group_num/g;
				file_write("$self->{'output_dir'}/$filename",
						   0664, "$index_head$links$self->{'theme'}->{'html'}{'pre_body'}$index$self->{'theme'}->{'html'}{'post_body'}$links$tail");
			}
			else {
				($filename = $webpage_indexname_tmpl ) 
					=~ s/<NUM>//g;
				file_write("$self->{'output_dir'}/$filename",
						   0664, "$index_head$self->{'theme'}->{'html'}{'pre_body'}$index$self->{'theme'}->{'html'}{'post_body'}$tail");
			}
		}
	}
	$self->{'theme'}->generate_images($self->{'output_dir'});
}

sub check_rlis {
	my @rli = @_;
	my %rlis = ();

	foreach (@rli) {
		my $rli = $_;

		next if (!$remake_webpage && defined($rli->{'reloaded'}));
		my $comic = $rli->{'name'};
		$_ = $rli->{'status'};
		if (! defined($_)) {
			print STDERR "$comic has an undefined status. Skipping.\n" 
				if $verbose;
			next;
		} elsif (/[03]/) {
			#didn't download (if a backup was tried (3), there's another
			#rli for the backup).
			next;
		} elsif (/1/) {
			print STDERR "No file for $comic. $inform_maintainer",next
				unless defined $rli->{'file'};
			$rli->{'stat'} = "local";
		} elsif (/2/) {
			print STDERR "No url for $comic. $inform_maintainer",next
				unless defined $rli->{'url'};
			$rli->{'file'} = $rli->{'url'};
			$rli->{'stat'} = "remote";
		} else {
			print STDERR "Unsupported status ($_) for $comic. " .
				$inform_maintainer;
			print STDERR "Skipping $comic in operation.\n" if $verbose;
			next;
		}
		$rlis{$comic} = $rli;
	}
	return(%rlis);
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
