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

package Netcomics::HTML::Page;

use strict;
use POSIX;
use Netcomics::Util qw/image_size image_type/;
use Netcomics::HTML::Theme;
use Netcomics::Config qw/$html_theme $comics_dir $verbose $extra_verbose
    $make_webpage $remake_webpage $separate_comics $webpage_indexname_tmpl
	$webpage_on_stdout $skip_bad_comics $webpage_title $dont_download
	$webpage_index_title $comics_per_page $link_color $vlink_color
	$index_link_color $index_vlink_color $background $webpage_index
	$webpage_filename_tmpl $webpage_templates $webpage_index_filename
    $webpage_datefmt $webpage_absolute_paths $comics_per_index_page
/;

require Exporter;
use vars qw($VERSION);
$VERSION = do {require Netcomics::Config; $Netcomics::Config::VERSION;};

sub new {
	my $class = shift;

	print STDERR "setting attributes...\n" if $extra_verbose;

	# Set up the properties of the page to be outputed.
	my $self = {
				# These are default values. You can feel free to override
				# them by passing them to the $self->new function.
				'rli_dataset' => { },
				'comics_set' => [ ],
				'datestr' => strftime($webpage_datefmt, gmtime(time())),
				'ctime' => ctime(time()),
				'ltime' => 	[localtime(time)],
				'theme' => undef,
				'index' => undef,
				'group_number' => 1,
				'num_groups' => 1,
				'link_to_local_archives' => 0,
				'webpage_filename_tmpl' => $webpage_filename_tmpl,
				'theme_dir' => ".",
				'include_subdir' => 0,

				# Pass these fields if you want proper pages generated...
				'first_comic' => 1,
				'last_comic' => 10,
				'total_comics' => 10,
				'filename' => stripout($webpage_filename_tmpl,'<NUM>'),
				@_
			   };

	if (! defined($self->{'theme'})) {
		print STDERR "No theme specified.  Using the defualt.\n"
			if $extra_verbose;
		$self->{'theme'} = eval "Netcomics::HTML::Themes::$html_theme->new";
	}

	print STDERR "Creating with template $self->{'theme'}->{'name'}.\n"
		if $extra_verbose;

	# Bless object and return it.
	bless $self, $class;

	return $self;
}

sub generate {
	my $self = shift;

	print STDERR "Creating $self->{'filename'} ($self->{'first_comic'} to " . 
		"$self->{'last_comic'} of $self->{'total_comics'})\n"
			if $extra_verbose && !$webpage_on_stdout;

	#replace group-global info
	my $body ="";
	my @index;

	# Okay, now let's create the header and substitute information
	# in.
	my $head = $self->{'theme'}->{'html'}{'head'};
	$head =~ s/<NUM=FIRST>/$self->{'first_comic'}/g;
	$head =~ s/<NUM=LAST>/$self->{'last_comic'}/g;
	$head =~ s/<NUM=TOTAL>/$self->{'total_comics'}/g;
	$head =~ s/<LINK_COLOR>/$link_color/g;
	$head =~ s/<VLINK_COLOR>/$vlink_color/g;
	$head =~ s/<BACKGROUND>/$background/g;

	# Code that let's you use custom date strigs.
	$head =~ s/<DATE>/$self->{'datestr'}/g;
	while ($head =~ /<DATE FORMAT="([^\"]*)">/) {
		my $datestr = strftime($1,@{$self->{'ltime'}});
		$head =~ s/<DATE FORMAT="([^\"]*)">/$datestr/;
	}

	# 
	my ($nextfile,$prevfile) = ($self->{'webpage_filename_tmpl'}) x 2;
	my $nextgroup = ($self->{'group_number'} == $self->{'num_groups'})? 1 : $self->{'group_number'} + 1;
	my $prevgroup = $self->{'group_number'} - 1;
	if ($self->{'group_number'} == 1) {
		$prevgroup = $self->{'num_groups'};
	}

	$nextgroup = 1 if $nextfile =~ s/<NUM>/$nextgroup/g;
	$prevfile =~ s/<NUM>/$prevgroup/g;


	# Now create the header with links to previous page, next page, and up
	# if we have multiple groups. Otherwise leave $links blank.
	my $links = "";
	if ($self->{'num_groups'} > 1) {
		my $links_tmpl_type = $webpage_index ? 'links_index' : 'links';
		$links = $self->{'theme'}->{'html'}{$links_tmpl_type};
		$links =~ s/<FILE=PREV>/$prevfile/g;
		$links =~ s/<FILE=NEXT>/$nextfile/g;
		$links =~ s/<NUM>/$comics_per_page/g;
	}

	#Create a top & bottom links.  The link to the index can be different
	#between the top & bottom if the number of comics per index is different
	#than the number of comics per page.
	my ($links_top, $links_bottom) = ($links) x 2;
	my $index_filename = $self->index_for_comic($self->{'first_comic'});
	$links_top =~ s/<FILE=INDEX>/$index_filename/g;
	$index_filename = $self->index_for_comic($self->{'last_comic'});
	$links_bottom =~ s/<FILE=INDEX>/$index_filename/g;


	# Make the index body.
	my $index_body_el_tmpl;
	if ($webpage_index) {
		$index_body_el_tmpl = $self->{'theme'}->{'html'}{'index_element'};
		$index_body_el_tmpl =~ s/<FILE=CURRENT>/$self->{'filename'}/g;
		$index_body_el_tmpl =~ s/<PAGE=CURRENT>/$self->{'group_number'}/g;
	}
	#print Data::Dumper->Dump([$self],[qw(*self)]);
	foreach my $comic (@{$self->{'comics_set'}}) {
		my $rli = $self->{'rli_dataset'}{$comic};
		#print Data::Dumper->Dump([$rli],[qw(*rli)]);
		my @gmtime = gmtime($rli->{'time'});
		my $comic_id = $rli->{'name'};
		my @image = @{$rli->{'file'}};

		# Setup title string (It's the title, author, date...)
		my $title;
		if (defined($_ = $rli->{'main'})) {
			#link to the base URL of the site
			$title = "<A HREF=\"$_\">$rli->{'title'}</A>";
		} else {
			$title = $rli->{'title'};
		}
		$title .= " by " . $rli->{'author'} if defined $rli->{'author'};
		my $date = strftime("%a, %h %d, %Y",@gmtime);
		if (defined($_ = $rli->{'url'}[0])) {
			#link to the comic at the site
			$title .= " <A HREF=\"$_\">($date)</A>";
		} else {
			$title .= " ($date)";
		}

		# Archive Information
		my $archivelink = $rli->{'archives'};
		if ($self->{'link_to_local_archives'}) {
			# link to local archives

			# If we're making indexies, then link to index, else link
			# to the first page of comics.
			my $fname;
			if ($webpage_index) {
				$fname = $index_filename;
			} else {
				($fname = $self->{'webpage_filename_tmpl'}) =~ s/<NUM>/1/;
			}
			$archivelink = "$rli->{'subdir'}/$fname";
		} else {
			#link to the site's archives
			$archivelink = $rli->{'archives'};
		}
		if (defined($archivelink)) {
			#link to the site's archives
			$title .= " <A HREF=\"$archivelink\"><FONT FACE=\"times\">" .
				"<I>(archives)</I></FONT></A>";
		}
		print STDERR "$rli->{'title'} ($date)" if $extra_verbose;

		# If we have a caption, we had better display it.
		my $caption = "";
		if (defined $rli->{'caption'}) {
			$caption = $self->{'theme'}->{'html'}{'caption'};
			$caption =~ s/<CAPTION_DATA>/$rli->{'caption'}/g;
		}

		#global body element fields
		my $body_el = $self->{'theme'}->{'html'}{'body'};
		$body_el =~ s/<COMIC_NAME>/$title/g;
		$body_el =~ s/<CAPTION>/$caption/;
		$body_el =~ s/<COMIC_ID>/$comic_id/g;

		my ($width,$height) = (0,0); #cumulative height, max width.

		my $comic_images;
		for ($[..$#image) {
			my $num = $_ + 1;
			my $image = $image[$_];
			next unless defined $image;
			my $size = undef;
			my $body_element = image_type($rli->{'type'}) ?
				$self->{'theme'}->{'html'}{'body_el'} :
				$self->{'theme'}->{'html'}{'body_el_embed'};
			$body_element = $self->{'theme'}->{'html'}{'body_el'}
				if ! defined $body_element;

			#get the size from the file if it exists (status of 1)
			if ($rli->{'status'} == 1) {
				my $fullfilepath = "$comics_dir/" .
					(defined($rli->{'subdir'})? "$rli->{'subdir'}/" : "") .
						$image;
				$size = image_size($fullfilepath);
			}
			if (! defined($size) && defined($rli->{'size'})) {
				if (ref($rli->{'size'}) ne "ARRAY") {
					# If this code is executed, something is REALLY wrong :-P
					print STDERR "$rli->{'title'}: size is not an array:" .
						"\"$size\".  Please inform the comic maintainer.\n"
							if $verbose;
				} else {
					#get the size from the specified default since this
					#is either a URL or the size couldn't be determined
					$size = "WIDTH=" . $rli->{'size'}[0] .
						" HEIGHT=" . $rli->{'size'}[1];
				}
			}

			#catch all for size
			unless (defined($size)) {
				if ($skip_bad_comics && $rli->{'status'} == 1) {
					next;
				} else {
					$size = "";
				}
			}

			#width & height are used individually for themes w/ images
			if (defined($size)) {
				if ($size =~ /WIDTH="?(\d+)"?/i) {
					#maximum width
					$width = $1 > $width ? $1 : $width;
				}
				if ($size =~ /HEIGHT="?(\d+)"?/i) {
					#cumulative height
					$height += $1;
				}
			}

			print STDERR " $num: $image" if $extra_verbose;

			# Check for various variables and compensate for how they
			# affect the $image variable.
			unless ($dont_download) {
				$image = $self->path_for_file($image,
											  $rli->{'subdir'},
											  $comics_dir);
			}

			# Substitue in the values and add tack it on to $comic_images
			$body_element =~ s/<COMIC_FILE>/$image/g;
			$body_element =~ s/<SIZE>/$size/; 
			$comic_images .= $body_element;
		}

		$body_el =~ s/<ELEMENT>/$comic_images/;
		$body_el =~ s/<WIDTH>/WIDTH=$width/g;
		$body_el =~ s/<HEIGHT>/HEIGHT=$height/g;

		$body .= $body_el;
		if ($webpage_index) {
			my $author = defined($rli->{'author'})? $rli->{'author'} : 
				"(author unknown)";
			$_ = $index_body_el_tmpl;
			s/<COMIC_DATE>/$date/g;
			s/<COMIC_NAME>/$rli->{'title'}/g;
			s/<COMIC_AUTHOR>/$author/g;
			s/<COMIC_STATUS>/$rli->{'stat'}/g;
			s/<FILE=CURRENT>/$self->{'filename'}/g;
			s/<PAGE=CURRENT>/$self->{'group_number'}/g;
			s/<COMIC_ID>/$comic_id/g;
			push(@index, $_);
		}
		print STDERR "\n" if $extra_verbose;
	}

	#Other stuff that all we need to change in them are the
	#common elements.
	my $tail = $self->{'theme'}->{'html'}{'tail'};
	my $pre_body = $self->{'theme'}->{'html'}{'pre_body'};
	my $post_body = $self->{'theme'}->{'html'}{'post_body'};

	#get the correct theme dir.
	my $theme_dir = $self->path_for_file($self->{'theme_dir'},
										 undef,
										 $self->{'output_dir'});

	# Catch all for common elements.
	foreach (\$head, \$links_top, \$pre_body, \$body, \$post_body,
			 \$links_bottom, \$tail) {
		$$_ =~ s/<PAGETITLE>/$webpage_title/g;
		$$_ =~ s/<CTIME>/$self->{'ctime'}/g;
		$$_ =~ s/<DATE>/$self->{'datestr'}/g;
		$$_ =~ s/<THEME_DIR>/$theme_dir/g;
	}

	return({'head' => $head,
			'links_top' => $links_top,
			'pre_body' => $pre_body,
			'body' => $body,
			'post_body' => $post_body,
			'links_bottom' => $links_bottom,
			'tail' => $tail,
			'index' => \@index
		   });
}

sub stripout {
	$_ = $_[0];
	s/$_[1]//g;
}

#returns the filename for the index of the comic number.
sub index_for_comic {
	my $self = shift;
	my $cnum = shift;

	return $webpage_index_filename
		 if ! defined $comics_per_index_page || $comics_per_index_page < 1 ||
			 $comics_per_index_page >= $self->{'total_comics'};

	my $group_num = $cnum / $comics_per_index_page;
	$group_num =~ s/^(\d+)\.?\d*$/$1/;
	$group_num++; #change to 1-based
	my $filename = $webpage_indexname_tmpl;
	$filename =~ s/<NUM>/$group_num/g;

	return $filename;
}

#returns the URL for the given file, taking into account user settings.
#absodir is $comics_dir for comics, $self->{'output_dir'} for html stuff
sub path_for_file {
	my ($self, $file, $subdir, $absodir) = @_;

	if ($webpage_absolute_paths) {
		if (defined($subdir)) {
			$file = $absodir."/".$subdir."/".$file;
		} else {
			$file = $absodir."/".$file;
		}
	} else {
		if ($self->{'include_subdir'} && defined($subdir)) {
			$file = $subdir."/".$file;
		} else {
			# Do nothing. $file is correct.
		}
	}
	return $file;
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
