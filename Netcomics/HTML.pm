package HTML;

use Netcomics::RLI;
use POSIX;

sub new {
	my $this = @_;
#	my $class = ref($this) || $this;
	my $class = "HTML";
	my $self = {};
	bless $self, $class;
	#Webpage specific options, go see ./netcomics.
	$self->{'webpage_on_stdout'} = 0;
	$self->{'skip_bad_comics'} = 0;
	$self->{'sort_by_date'} = 0;
	$self->{'webpage_title'} = "Today's Comics From The Web on <DATE>";
	$self->{'webpage_index_title'} = "Index for " . $self->{'webpage_title'};
	$self->{'comics_per_page'} = undef;
	$self->{'link_color'} = "LINK=#9999FF";
	$self->{'vlink_color'} = "VLINK=#FF99FF";
	$self->{'index_link_color'} = "";
	$self->{'index_vlink_color'} = "";
	$self->{'background'} = "";
	$self->{'webpage_index'} = 1;
	$self->{'webpage_filename_tmpl'} = "comics<NUM>.html";
	$self->{'webpage_index_filename'} = "index.html";
	$self->{'webpage_on_stdout'} = 0;

	#Properties that HTML needs, but aren't part of the HTML subsystem
	#Per se, but are still necessary.
	$self->{'index'} = 1; 
	$self->{'templates'} = "/usr/share/netcomics/html_tmpl";
	$self->{'reamake_webpage'} = 0;
	$self->{'dont_download'} = 0;
	$self->{'comics_dir'} = "/var/spool/netcomics/";
	$self->{'verbose'} = 1;
	$self->{'extra_verbose'} = 1;
	$self->{'sort_by_date'} = 0;
	
	#subclasses must define this method.
	return $self;
}

sub create_webpage {
	my $self = shift();
	my @rli = @_;
	
	print "RLI (in page): @rli \n";

	my $files_mode = 0644;
	
	#create a hash into the rli's
	my %rlis = ();
	
	foreach (@rli) {
		my $rli = $_;
		print $rli."\n";
		next if (!$self->{'remake_webpage'} && defined($rli->{'reloaded'}));
		my $comic = $rli->{'name'};
		$_ = $rli->{'status'};
		if (! defined($_)) {
			print STDERR "$comic has an undefined status. Skipping.\n" 
				if $self->{'verbose'};
			next;
		} elsif (/[03]/) {
			#didn't download (if a backup was tried (3), there's another
			#rli for the backup).
			next;
		} elsif (/1/) {
			print "No file for $comic. $inform_maintainer",next
				unless defined $rli->{'file'};
			$rli->{'stat'} = "local";
		} elsif (/2/) {
			print "No url for $comic. $inform_maintainer",next
				unless defined $rli->{'url'};
			$rli->{'file'} = $rli->{'url'};
			$rli->{'stat'} = "remote";
		} else {
			print STDERR "Unsupported status ($_) for $comic. " .
				$inform_maintainer;
			print "Skipping $comic in webpage.\n" if $self->{'verbose'};
			next;
		}
		$rlis{$comic} = $rli;
	}
	my @comics = keys(%rlis);
	print "comics = @comics\n" if $self->{'verbose'};
	my $num_comics = @comics;
	if ($num_comics == 0) {
		print "\nNot creating a new webpage.\n" if $self->{'verbose'};
		return;
	}
	unless ($self->{'dont_download'} && !$self->{'remake_webpage'}) {
		$@ = 0;
		eval {
			require Image::Size;
			Image::Size->import('html_imgsize');
		};
		if ($@) {
			print "\nWarning: Image::Size not installed. Using the file " .
				"command instead.\n\n" if $self->{'verbose'};
			$use_filecmd = 1;
		}
	}
	print "\n" if $self->{'verbose'};
	unless ($self->{'webpage_on_stdout'}) {
		print "Deleting old webpages (".$self->{'comics_dir'}."/<index.html,comic*.html>).\n" 
			if $self->{'verbose'};
		chdir $self->{'comics_dir'};
		unlink <index.html>;
		unlink <comic*.html>;
	}

	if ($self->{'verbose'}) {
		print "Creating the webpage";
		print "s" if defined($self->{'comics_per_page'});
		print ".\n";
	}

	my $time = time();
	my $datestr = strftime("%b %d, %Y",gmtime($time));
	my $ctime = ctime($time);

	#create a sorted list of the comics
	my @sorted_comics;
	if ($self->{'sort_by_date'}) {
		@sorted_comics = 
			sort({libdate_sort($a,$b,$rlis{$a}{'time'},$rlis{$b}{'time'});} 
				 @comics);
	} else {
		@sorted_comics = sort(library_sort @comics);
	}
	print "sorted comics: @sorted_comics\n" if $self->{'extra_verbose'};

	#determine number of groups of comics, and number of comics on each page
	$self->{'comics_per_page'} = $num_comics unless defined($self->{'comics_per_page'}); 
	my $num_groups = $num_comics / $self->{'comics_per_page'};
	$num_groups =~ s/^(\d+)\.?\d*$/$1/;
	my $comics_on_last = $num_comics % $self->{'comics_per_page'};
	$num_groups++ if $comics_on_last > 0;
	print "number of groups    = $num_groups\n" .
		"comics per page     = $self->{'comics_per_page'}\n" .
			"comics on last page = $comics_on_last\n"
				if $self->{'extra_verbose'};

	#Load in the templates & do some initial filling in of info
	my @body_el_tmpl = ("");
	my $i = 1;
	while (-f "$self->{'templates'}/body_el$i.html") {
		$body_el_tmpl[$i] = file_read("$self->{'templates'}/body_el$i.html");
		$i++;
	}
	if ($#body_el_tmpl < 1) {
		die "Could not find the html body template files under the default " .
			"directory:\n$self->{'templates'}. Please use -t to specify the " .
				"correct location.";
	}
	my $head_tmpl=file_read("$self->{'templates'}/head.html");
	my $links_tmpl=file_read("$self->{'templates'}/links" . 
							 ($self->{'webpage_index'}? "_index" : "") . ".html");
	my $tail_tmpl=file_read("$self->{'templates'}/tail.html");
	my $index_body_el_tmpl_tmpl=file_read("$self->{'templates'}/index_body_el.html")
		if $self->{'webpage_index'};

	my $index;
	if ($self->{'webpage_index'}) {
		#index head global info
		$index = $head_tmpl;
		$index =~ s/<NUM=FIRST>/1/g;
		$index =~ s/<NUM=(LAST|TOTAL)>/$num_comics/g;
		$index =~ s/<PAGETITLE>/$self->{'webpage_title'}/g;
		$links_tmpl =~ s/<FILE=INDEX>/$self->{'webpage_index'}_filename/g;
	}
	#replace head & tail template globals
	$head_tmpl =~ s/<PAGETITLE>/$self->{'webpage_title'}/g;
	$tail_tmpl =~ s/<CTIME>/$ctime/g;

	@_ = (\$head_tmpl);
	push(@_,\$index) if $self->{'webpage_index'};
	foreach (@_) {
		$$_ =~ s/<DATE>/$datestr/g;
		my @ltime = localtime($time);
		while ($$_ =~ /<DATE FORMAT="([^\"]*)">/) {
			my $datestr = strftime($1,@ltime); 
			$$_ =~ s/<DATE FORMAT="([^\"]*)">/$datestr/;
		}
	}
	#replace comic webpage head template globals
	$head_tmpl =~ s/<LINK_COLOR>/$self->{'link_color'}/g;
	$head_tmpl =~ s/<VLINK_COLOR>/$self->{'vlink_color'}/g;
	$head_tmpl =~ s/<BACKGROUND>/$self->{'background'}/g;

	if ($self->{'webpage_index'}) {
		#replace index head globals
		$index =~ s/<LINK_COLOR>/$self->{'index_link_color'}/g;
		$index =~ s/<VLINK_COLOR>/$self->{'index_vlink_color'}/g;
		$index =~ s/<BACKGROUND>/$self->{'background'}/g;
	}

	$i = -1;
	my $first_file;
	while (++$i < $num_groups) {
		my $group = $i + 1;
		my $first = $i * $self->{'comics_per_page'} + 1;
		my $last  = $first + $self->{'comics_per_page'} - 1;
		$last = $first + $comics_on_last -1 
			if ($group == $num_groups && $comics_on_last > 0);
		(my $filename = $self->{'webpage_filename_tmpl'}) =~ s/<NUM>/$group/g;
		my ($nextfile,$prevfile) = ($self->{'webpage_filename_tmpl'}) x 2;
		my $nextgroup = ($group == $num_groups)? 1 : $group +1;
		my $prevgroup = $group -1;
		if ($group == 1) {
			$prevgroup = $num_groups;
			$first_file = $filename;
		}
		$nextgroup = 1 if $nextfile =~ s/<NUM>/$nextgroup/g;
		$prevfile =~ s/<NUM>/$prevgroup/g;

		print "\nCreating $filename ($first to $last of $num_comics)\n" 
			if $self->{'extra_verbose'} && !$webpage_on_stdout;

		#replace group-global info
		my $head = $head_tmpl;
		my $links = "";
		my $body ="";
		my $tail = $tail_tmpl;
		$head =~ s/<NUM=FIRST>/$first/g;
		$head =~ s/<NUM=LAST>/$last/g;
		$head =~ s/<NUM=TOTAL>/$num_comics/g;
		if ($num_groups > 1) {
			$links = $links_tmpl;
			$links =~ s/<FILE=PREV>/$prevfile/g;
			$links =~ s/<FILE=NEXT>/$nextfile/g;
			$links =~ s/<NUM>/$self->{'comics_per_page'}/g;
		}
		my $index_body_el_tmpl;
		if ($self->{'webpage_index'}) {
			$index_body_el_tmpl = $index_body_el_tmpl_tmpl;
			$index_body_el_tmpl =~ s/<FILE=CURRENT>/$filename/g;
			$index_body_el_tmpl =~ s/<PAGE=CURRENT>/$group/g;
		}

		my $comic;
		foreach $comic (@sorted_comics[($first-1)..($last-1)]) {
			my $rli = $rlis{$comic};
			my @gmtime = gmtime($rli->{'time'});
			my $comic_id = $rli->{'name'};
			my @image = @{$rli->{'file'}};
			die "\nComics made up of more than $#body_el_tmpl files are not" .
				" supported.\n$inform_maintainer" if @image > $#body_el_tmpl;
			my $body_el = $body_el_tmpl[@image];
			
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
			print "$rli->{'title'} ($date)" if $self->{'extra_verbose'};
			my $caption = "";
			$caption = "<TR><TD><CENTER>" . $rli->{'caption'} . 
				"</CENTER></TD></TR>" if defined $rli->{'caption'};

			#global body element fields
			$body_el =~ s/<COMIC_NAME>/$title/g;
			$body_el =~ s/<CAPTION>/$caption/; 
			$body_el =~ s/<COMIC_ID>/$comic_id/g;

			for ($[..$image) { ###??????
				my $num = $_ + 1;
				my $image = $image[$_];
				my $size = undef;
				#get the size from the file (status==1)
				$size = image_size( ($self->{'comics_dir'} . "/$image") ) 
					if $rli->{'status'} == 1;
				if (! defined($size) && defined($rli->{'size'})) {
					my $size = $rli->{'size'};
					if (ref($size) ne "ARRAY") {
						print STDERR "$rli->{'title'}: size is not an array:" .
							"\"$size\".  Please inform the comic maintainer.\n"
								if $self->{'verbose'};
					} else {
						#get the size from the specified default since this
						#is either a URL or the size couldn't be determined
						$size = "WIDTH=" . $size->[0] .
							" HEIGHT=" . $size->[1];
					}
				}
				my $width = (defined($size) && $size =~ /(WIDTH=\d+)/) ? 
					$1 : "";
				#catch all for size
				unless (defined($size)) {
					if ($self->{'skip_bad_comics'} && $rli->{'status'} == 1) {
						next;
					} else {
						$size = "";
					}
				}
				print " $num: $image" if $self->{'extra_verbose'};
				$body_el =~ s/<COMIC_FILE$num>/$image/g;
				#width should be global, but oh well.
				$body_el =~ s/<WIDTH>/$width/; 
	            #not global so multiimage sizes don't override each other
				$body_el =~ s/<SIZE>/$size/; 
			}
			$body .= $body_el;

			if ($self->{'webpage_index'}) {
				my $author = defined($rli->{'author'})? $rli->{'author'} : 
					"(author unknown)";
				$_ = $index_body_el_tmpl;
				s/<COMIC_DATE>/$date/g;
				s/<COMIC_NAME>/$rli->{'title'}/g;
				s/<COMIC_AUTHOR>/$author/g;
				s/<COMIC_STATUS>/$rli->{'stat'}/g;
				s/<FILE=CURRENT>/$filename/g;
				s/<PAGE=CURRENT>/$group/g;
				s/<COMIC_ID>/$comic_id/g;
				$index .= $_;
			}

			print "\n" if $self->{'extra_verbose'};
		}
		unless ($self->{'webpage_on_stdout'}) {
			file_write("$self->{'comics_dir'}/$filename",$files_mode,
					   "$head$links$body$links$tail");
			file_write("$self->{'comics_dir'}/$self->{'webpage_index'}_filename",$files_mode,
					   "$index$tail");
		} else {
			print "$head$links$body$links$tail";
		}
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

sub library_sort {
	(my $thea = $a) =~ s/^\s*(a|an|the)[\s_]+//i;
	(my $theb = $b) =~ s/^\s*(a|an|the)[\s_]+//i;
	return $thea cmp $theb;
}

sub image_size {
	my $file = shift;
	return html_imgsize($file) unless $use_filecmd;

	$_ = `file $file`;
	if ($? == 0 && /(\d+) x (\d+)/) {
		return "WIDTH=$1 HEIGHT=$2";
	} else {
		return undef;
	}
}

1;