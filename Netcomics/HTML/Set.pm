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
	print "comics = @comics" if $verbose;
	my $num_comics = @comics;
	if ($num_comics == 0) {
		print "\nNot creating a new webpage.\n" if $verbose;
		return;
	}

	print "\n" if $verbose;
	unless ($self->{'webpage_on_stdout'}) {
		print "Deleting old webpages (".$self->{'output_dir'} . 
				"/<index.html,comic*.html>).\n" if $verbose;
		chdir $self->{'output_dir'};
		unlink <index.html>;
		unlink <comic*.html>;
	}

	if ($verbose) {
		print "Creating the webpage";
		print "s" if defined($comics_per_page);
		print ".\n";
	}

	#create a sorted list of the comics
	my @sorted_comics = sort({libdate_sort($a, $b, $rlis{$a}{'time'},
										   $rlis{$b}{'time'}, $sort_by_date);} 
							 @comics);
	print "sorted comics: @sorted_comics\n" if $extra_verbose;


	#determine number of groups of comics, and number of comics on each page
	$comics_per_page = $num_comics
			unless defined($comics_per_page); 
	my $num_groups = $num_comics / $comics_per_page;
	$num_groups =~ s/^(\d+)\.?\d*$/$1/;
	my $comics_on_last = $num_comics % $comics_per_page;
	$num_groups++ if $comics_on_last > 0;
	print "number of groups    = $num_groups\n" .
		"comics per page     = $comics_per_page\n" .
			"comics on last page = $comics_on_last\n"
				if $extra_verbose;

	# Process the index.
	my $index;
	if ($webpage_index) {
		#index head global info
		$index = $self->{'theme'}->{'head'};
		$index =~ s/<PAGETITLE>/$webpage_title/g;
		$index =~ s/<NUM=FIRST>/1/g;
		$index =~ s/<NUM=(LAST|TOTAL)>/$num_comics/g;
		$index =~ s/<PAGETITLE>/$webpage_title/g;
		$index =~ s/<LINK_COLOR>/$link_color/g;
		$index =~ s/<VLINK_COLOR>/$vlink_color/g;
		$index =~ s/<BACKGROUND>/$background/g;

		# Code that let's you use custom date strigs.
		my $date = strftime("%b %d, %Y",gmtime(time()));
		$index =~ s/<DATE>/$date/g;
		my @ltime = localtime(time);
		while ($index =~ /<DATE FORMAT="([^\"]*)">/) {
			my $datestr = strftime($1,@ltime); 
			$index =~ s/<DATE FORMAT="([^\"]*)">/$datestr/;
		}
	}

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

		print "trying object...\n";
		print "first = $first, last = $last\n";
		(my $filename = $webpage_filename_tmpl) =~ s/<NUM>/$group_num/g;
		#print Data::Dumper->Dump([\%rlis],[qw(*%rlis)]);
		#print keys(%rlis);

		#print @sorted_comics[($first-1)..($last-1)];

		my @comics_to_pass = @sorted_comics[($first-1)..($last-1)];

		# Create our HTML Page object.
		my $HTML_Page = Netcomics::HTML::Page->new
			('webpage_title' => "$webpage_title",
			 'num_groups' => $num_groups,
			 'group_num' => $group_num,
			 'first_comic' => $first,
			 'last_comic' => $last,
			 'total_comics' => $num_comics,
			 'filename' => $filename,
			 'rli_dataset' => \%rlis,
			 'comics_set' => [@comics_to_pass],
			 'include_subdir' => $self->{'include_subdir'}
			);

		print "Object created...\n";

		my %returned = %{$HTML_Page->generate};

		my $page = "$returned{'head'}$returned{'links'}$returned{'body'}" .
		"$returned{'links'}$returned{'tail_tmpl'}";

		$tail = $returned{'tail_tmpl'};

		$index .= $returned{'index'};

		unless ($webpage_on_stdout) {
			file_write("$self->{'output_dir'}/$filename",0664,"$page");
		} else {
			print "$page";
		}
	}
	if ($webpage_index && ! $webpage_on_stdout) {
		file_write("$self->{'output_dir'}/$webpage_index_filename",
				   0664, "$index$tail");
	}
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
			print "Skipping $comic in operation.\n" if $verbose;
			next;
		}
		$rlis{$comic} = $rli;
	}
	return(%rlis);
}

1;
