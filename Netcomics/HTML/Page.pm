package Netcomics::HTML::Page;

use strict;
use Netcomics::Config;
use Netcomics::Util;
use POSIX;
use Netcomics::HTML::Themes::Default;

sub new {
	my $class = shift;

	print "setting attributes...\n";

	# Set up the properties of the page to be outputed.
	my $self = {
				# These are default values. You can feel free to override
				# them by passing them to the $self->new function.
				'rli_dataset' => { },
				'comics_set' => [ ],
				'datestr' => strftime("%b %d, %Y",gmtime(time())),
				'ctime' => ctime(time()),
				'theme' => new Netcomics::HTML::Themes::Default,
				'index' => undef,
				'group_number' => 1,
				'num_groups' => 1,

				# Pass these fields if you want proper pages generated...
				'first_comic' => 1,
				'last_comic' => 10,
				'total_comics' => 10,
				'filename' => "comics.html",
				@_
			   };

	print "attributes set...\n";

	# Bless object and return it.
	bless $self, $class;

	return $self;
}

sub generate {
	my $self = shift;

	print "Creating $self->{'filename'} ($self->{'first_comic'} to $self->{'last_comic'} of $self->{'total_comics'})\n" 
		if $extra_verbose && !$webpage_on_stdout;

	#replace group-global info
	my $body ="";
	my $index = "";

	# Okay, now let's create the header and substitute information
	# in.
	my $head = $self->{'theme'}->{'head'};
	$head =~ s/<PAGETITLE>/$webpage_title/g;
	$head =~ s/<CTIME>/$self->{'ctime'}/g;
	$head =~ s/<DATE>/$self->{'datestr'}/g;
	$head =~ s/<NUM=FIRST>/$self->{'first_comic'}/g;
	$head =~ s/<NUM=LAST>/$self->{'last_comic'}/g;
	$head =~ s/<NUM=TOTAL>/$self->{'total_comics'}/g;
	$head =~ s/<LINK_COLOR>/$link_color/g;
	$head =~ s/<VLINK_COLOR>/$vlink_color/g;
	$head =~ s/<BACKGROUND>/$background/g;

	# Code that let's you use custom date strigs.
	$head =~ s/<DATE>/$self->{'datestr'}/g;
	my @ltime = localtime(time);
	while ($head =~ /<DATE FORMAT="([^\"]*)">/) {
		my $datestr = strftime($1,@ltime); 
		$head =~ s/<DATE FORMAT="([^\"]*)">/$datestr/;
	}

	# 
	my ($nextfile,$prevfile) = ($webpage_filename_tmpl) x 2;
	my $nextgroup = ($self->{'group_num'} == $self->{'num_groups'})? 1 : $self->{'group_num'} + 1;
	my $prevgroup = $self->{'group_num'} - 1;
	if ($self->{'group_num'} == 1) {
		$prevgroup = $self->{'num_groups'};
	}
	$nextgroup = 1 if $nextfile =~ s/<NUM>/$nextgroup/g;
	$prevfile =~ s/<NUM>/$prevgroup/g;

	# Now create the header with links to previous page, next page, and up
	# if we have multiple groups. Otherwise leave $links blank.
	my $links = "";
	if ($self->{'num_groups'} > 1) {
		$links = $self->{'theme'}->{'links'};
		$links =~ s/<FILE=PREV>/$prevfile/g;
		$links =~ s/<FILE=NEXT>/$nextfile/g;
		$links =~ s/<NUM>/$comics_per_page/g;
	}

	# Make the index body.
	my $index_body_el_tmpl;
	if ($webpage_index) {
		$index_body_el_tmpl = $self->{'theme'}->{'index_element'};
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
		if (defined($_ = $rli->{'archives'})) {
			#link to the site's archives
			$title .= " <A HREF=\"$_\"><FONT FACE=\"times\">" .
				"<I>(archives)</I></FONT></A>";
		}
		print "$rli->{'title'} ($date)" if $extra_verbose;

		# If we have a caption, we had better display it.
		my $caption = "";
		$caption = "<TR><TD><CENTER>" . $rli->{'caption'} . 
			"</CENTER></TD></TR>" if defined $rli->{'caption'};

		#global body element fields
		my $body_el = $self->{'theme'}->{'body'};
		$body_el =~ s/<COMIC_NAME>/$title/g;
		$body_el =~ s/<CAPTION>/$caption/; 
		$body_el =~ s/<COMIC_ID>/$comic_id/g;
		
		###############################
		# Start massive code overhaul.
		my $comic_images;
		for ($[..$#image) {
			my $num = $_ + 1;
			my $image = $image[$_];
			next unless defined $image;
			my $size = undef;
			my $body_element = $self->{'theme'}->{'body_el'};

			#get the size from the file (status==1)
			$size = image_size( ($comics_dir . "/$image") ) 
				if $rli->{'status'} == 1;
			if (! defined($size) && defined($rli->{'size'})) {
				my $size = $rli->{'size'};
				if (ref($size) ne "ARRAY") {
					# If this code is executed, something is REALLY wrong :-P
					print STDERR "$rli->{'title'}: size is not an array:" .
						"\"$size\".  Please inform the comic maintainer.\n"
							if $verbose;
				} else {
					#get the size from the specified default since this
					#is either a URL or the size couldn't be determined
					$size = "WIDTH=" . $size->[0] .
						" HEIGHT=" . $size->[1];
				}
			}
			#my $width = (defined($size) && $size =~ /(WIDTH=\d+)/) ? 
			#	$1 : "";
			#catch all for size
			unless (defined($size)) {
				if ($skip_bad_comics && $rli->{'status'} == 1) {
					next;
				} else {
					$size = "";
				}
			}

			print " $num: $image" if $extra_verbose;

			# Check for various variables and compensate for how they
			# effect the $image variable.
			if ($webpage_absolute_paths) {
				if ($separate_comics) {
					$image = $comics_dir."/".$rli->{'subdir'}."/".$image;
				} else {
					$image = $comics_dir."/".$image;
				}
			} else {
				if ($separate_comics) {
					if ($self->{'include_subdir'}) {
						$image = $rli->{'subdir'}."/".$image;
					} else {
						# Do nothing. $image is correct.
					}
				} else {
					# Do nothing. $imge is correct.
				}
			}

			# Substitue in the values and add tack it on to $comic_images...
			$body_element =~ s/<COMIC_FILE>/$image/g;
			$body_element =~ s/<SIZE>/$size/; 
			$comic_images .= $body_element;
		}
		# End Massive Code Overhaul
		###########################

		$body_el =~ s/<ELEMENT>/$comic_images/;

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
			s/<PAGE=CURRENT>/$self->{'group_num'}/g;
			s/<COMIC_ID>/$comic_id/g;
			$index .= $_;
		}
		print "\n" if $extra_verbose;
	}

	# Create it for the sole purpose of returning it.
	my $tail_tmpl = $self->{'theme'}->{'tail'};

	# Catch all for common elements.
	foreach (\$body, \$links, \$index, \$tail_tmpl) {
		$$_ =~ s/<PAGETITLE>/$webpage_title/g;
		$$_ =~ s/<CTIME>/$self->{'ctime'}/g;
		$$_ =~ s/<DATE>/$self->{'datestr'}/g;
	}

	return({'head' => "$head",
			'links' => "$links",
			'body' => "$body",
			'tail_tmpl' => "$tail_tmpl",
			'index' => "$index"
		   });
}

1;

