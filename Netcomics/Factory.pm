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

package Netcomics::Factory;

use POSIX;
use strict;
use Carp;
use Netcomics::Config;
use Netcomics::MyResponse;
use Netcomics::MyRequest;
use Netcomics::Util;
use Netcomics::ExternalUserAgent;

use vars qw(%rli @rli); #only used for importing modules & .rli files.
use vars qw(%hof);

#class attributes
my $files_mode = 0644;
my $default_filetype = "gif"; #only used if module didn't supply one.
my $data_dumper_installed;

#pass in a Factory instance (not currently supported)
#or a Config instance.
sub new {
	my ($class,$init) = @_;
	my $conf = undef;
	if (ref($init)) {
		if ($init->isa("Netcomics::Config")) {
			$conf = $init;
		}
		#else; instantiation with a Factory object currently not supported.
	}
	if (!defined($conf)) {
		croak "Error: a Netcomics::Config object must be supplied when" .
			"creating a new Factory.";
	}
	my $self = {
		'rli_procs' => {}, #hash of hashes of indexes into @rli.
		'hof' => {},
		'rli' => [],
		'dates' => \@dates,
		'existing_rli_files' => [],
		'files_retrieved' => [],
		'conf' => $conf,
		'get_current' => undef, #accomodate the time for the rli hash function?
	};

	bless $self, $class;

	# Load comic modules.
	load_modules("Netcomics::Factory",@libdirs)
		if keys(%hof) == 0;
	#check later in setup() to make sure that there were no errors.

	# We need Data::Dumper for the next part.
	$data_dumper_installed = requireDataDumper;

	return $self;
}

sub load_RLI_files {
	my $self = shift;
	#Make sure the temp dir exists
	unless (-d $comics_dir) {
		if (! $show_tasks) {
			mkdir($comics_dir,0777) || die "could not create $comics_dir: $!";
		} elsif ($extra_verbose) {
			print "Would have created the directory: $comics_dir";
		}
	} elsif ($delete_files) {
		if (! $show_tasks) {
			chdir $comics_dir || die "could not cd to $comics_dir: $!";
			unlink <*.*>;
			unlink <.*.rli>;
		} elsif ($extra_verbose) {
			print "Would have cleaned the directory: $comics_dir";
		}
	} else {
		#load in the rlis in the directory to find out what comics
		print "Reading $comics_dir to get list of current comics\n" 
			if $extra_verbose;
		opendir(DIR,$comics_dir) || die "could not open $comics_dir: $!";
		my @files = readdir(DIR);
		closedir(DIR);
		@files = sort(grep(s/(\..+\.rli)$/$1/,@files));
		if (grep(/^$netcomics_rli_file$/, @files)) {
			$single_rli_file = 1; #make sure this is on even if not specified
			@files = ($netcomics_rli_file); #make it the only file to load.
		}
	RLI_TEST: foreach my $rli (load_rlis(@files)) {
			$rli->{'reloaded'} = 1, $self->add_to_rli_list($rli) 
				if defined $rli;
			#make sure important data is correct in the rli (i.e. its files)
			for (@{$rli->{'file'}}) {
				my $file = $_;
				my $test_dir = $separate_comics ?
					"$comics_dir/$rli->{'subdir'}" : "$comics_dir";

				if (-f "$test_dir/$file") {
					push(@{$self->{'existing_rli_files'}},$file);
				} elsif ($rli->{'status'} == 1) {
					#print Data::Dumper->Dump([$rli],[qw(*rli)]);

					# use only the final pathname
					my @stuff = split(/\//, $file);
					my $time = "@stuff";
					$time--;
					if (-f "$test_dir/$stuff[$#stuff]") {
						my @list_of_files = @{$rli->{'file'}};
						my @temporary_file_rebuild_array;
						foreach (@list_of_files) {
							my @stuff = split(/\//, $_);
							$_ = "$stuff[$#stuff]";
							push(@temporary_file_rebuild_array, $_)
						}
						$rli->{'file'} = [ ];
						foreach (@temporary_file_rebuild_array) {
							push(@{$rli->{'file'}}, $_);
						}
						next RLI_TEST;
					}

					# At this point, there's nothing we can do...
					print STDERR "Warning: $file is missing in $comics_dir\n"
						if $verbose;
					#make it so that this one will be retried.
					$rli->{'status'} = 0;
					$rli->{'tries'}-- if $rli->{'tries'};
				}
			}
		}
	}
	print "Rli's reloaded: " . @{$self->{'rli'}} . "\n" if $extra_verbose;
}

sub setup {
	my $self = shift;

	# first make sure the modules were successfully loaded.
	if (keys(%hof) == 0) {
		# Error if no modules found.
		die "There were no comic modules succesfully loaded.  " .
			"Please check the setting\nof \@libdirs in the system" .
				" and user rc file and on the command line:\n" .
					"\@libdirs = @libdirs\n" .
						"Also, check the installation of netcomics.\n";
	}
	%{$self->{'hof'}} = %hof;
	# Reset these values whether we need them or not.
	$self->{'files_retrieved'} = [];
	$self->{'get_current'} = undef;

	#make sure user specified existing functions
	#and set the %hof to those the user specified
	if ($user_specified_comics || $user_unspecified_comics) {
		my %new_hof = ();
		my @hof_keys = keys(%{$self->{'hof'}});
		@hof_keys = () unless @hof_keys;
		my $fun;
		foreach $fun (@selected_comics) {
			$fun = quotemeta($fun);
			my @hres = grep(/^$fun$/,@hof_keys);
			if (@hres > 0) {
				$new_hof{$fun} = $self->{'hof'}{$fun};
			}
		}
		if ($user_specified_comics) {
			%{$self->{'hof'}} = %new_hof;
		} else {
			#intersection
			foreach (keys %new_hof) {
				delete $self->{'hof'}{$_};
			}
		}
	}

	print Data::Dumper->Dump([$self->{'rli_procs'}],[qw(*$self->{'rli_procs'})])
	if $data_dumper_installed && $extra_verbose && $show_tasks;

	#
	#Do the work.
	#
	$self->build_date_array();
	if ($extra_verbose) {
		print "dates: ";
		my $date;
		foreach $date (@{$self->{'dates'}}) {
			print strftime("%m-%d-%y",gmtime($date));
			print " ";
		}
		print "\n";
	}
	$self->build_rli_array();

	#stop and print what will be done
	if ($show_tasks) {
		for (@{$self->{'rli'}}) {
			my $rli = $_;
			my $name = strftime("$rli->{'title'}-${date_fmt}",
								gmtime($rli->{'time'}));
			my $try = $rli->{'tries'};
			if ($self->skip_rli($rli)) {
				print "Skip ($try): $name ($rli->{'proc'})\n";
			} else {
				$try++;
				print "Get  ($try): $name ($rli->{'proc'})\n";
			}
		}
		exit(0);
	}

	return $self;
}


#Build up the list of resource locators
sub build_rli_array {
	my $self = shift;
	if ($self->{'get_current'}) {
		#accomodate the time for the rli hash functions
		$self->build_rli_array_helper("Adding hof & get_current RLI's");
	} else {
		$self->build_rli_array_helper("Adding hof & !get_current RLI's");
	}
	print "\n" if $extra_verbose;
	
	#now remove undefs from @rli
	my @newrli = grep {defined($_) } @{$self->{'rli'}};
	@{$self->{'rli'}} = @newrli;
}

sub build_rli_array_helper {
	my ($self,$msg) = @_;
	print "\n$msg: " if $extra_verbose;
	my ($days, $fun, $time, $rli);
	my $rlis = $self->{'rli'};
	while (($fun,$days) = each %{$self->{'hof'}}) {
		next if $self->{'get_current'} && ! defined $days;
		print " $fun" if $extra_verbose;
		foreach $time (@{$self->{'dates'}}) {
		    if ($self->{'get_current'}) {
				$rli = $self->run_rli_func($fun,$time,$fun,$days);
		    } else {
				$rli = $self->run_rli_func($fun,$time,$fun);
		    }
		    if (defined($rli)) {
				#reget the time (incase of $self->{'get_current'})
				my $time = $rli->{'time'};
				#Find an rli with that date & proc, and if it exists,
				#borrow some of its info and then delete it.
				my ($old_rli,$i) = $self->get_comic($fun, $time, 1);
				if (defined($old_rli)) {
					#use status info if user didn't specify always download,
					#or if the user did specify always download and the user
					#specified some comics and this isn't one of them &&
					#its status is 1.
					if (! $always_download || 
						($user_specified_comics && 
						 ! grep(/^$rli->{'proc'}$/,@selected_comics) &&
						 $rlis->[$i]->{'status'} == 1)) {
						#copy info from old one into new one, thus
						#if the module changed, more correct info would be
						#used.
						$rli->{'file'} = $rlis->[$i]->{'file'};
						$rli->{'status'} = $rlis->[$i]->{'status'};
						$rli->{'tries'} = $rlis->[$i]->{'tries'};
						#now, copy in only those fields which don't exist.
						foreach (keys(%{$rlis->[$i]})) {
							$rli->{$_} = $rlis->[$i]->{$_} if
								(! defined $rli->{$_} &&
								 defined $rlis->[$i]->{$_});
						}
					}
					#remove the old one
					$self->remove_from_rli_list($old_rli);
					print "*" if $extra_verbose;
				}
				#add the new one
				$self->add_to_rli_list($rli);
			}
		}
	}
}

#determine if this rli should be processed or skipped.
sub skip_rli {
	my $self = shift;
	my $rli = shift;
	#skip if the rli is undefined or
	# if the user specified comics, didn't specify always download & 
	#    didn't specify this comic
	# if it was successfully downloaded or
	# if the URL was successfully determined and we're still not downloading or
	# if it's reached the max number of retries
	if (! defined($rli) || 
		(@selected_comics && ! $always_download && 
		 (($user_specified_comics && ! grep(/^$rli->{'proc'}$/,
											@selected_comics)) || 
		  ($user_unspecified_comics &&
		   grep(/^$rli->{'proc'}$/, @selected_comics)))
		 ) ||
		(defined($rli->{'status'}) && 
		 ($rli->{'status'} == 1 ||
		  $rli->{'status'} == 2 && $dont_download)) ||
		(defined($rli->{'tries'}) && 
		 $max_attempts > 0 && 
		 $rli->{'tries'} >= $max_attempts)) {
		return 1;
	} else {
#	print Data::Dumper->Dump([$rli],[qw(*rli)]);
		return 0;
	}
}

#Engine for getting the comics.  
#Go through the list of RLI's and get the comic at each one.
sub get_comics {
	my $self = shift;
	my $rlis = $self->{'rli'};
	return () if @$rlis == 0;

	#use polymorphism to make it so that the user doesn't have to have 
	#libwww-perl installed, but can use a program like wget instead
	my $ua;
	my $new_request;
	if (defined($external_cmd)) {
		$@ = 1;
	} else {
		$@ = 0;
		eval {
			require LWP;
			require URI::URL;
			require LWP::UserAgent;
			require HTTP::Request;
			require HTTP::Response;
			require HTTP::Request::Common;
			$ua = LWP::UserAgent->new;
			$new_request = sub {
				my $request = new HTTP::Request 'GET', shift;
				return add_referer($request,shift(@_));
			};
#	    $ua->redirect(0);
		};
	}
	if ($@) {
		$new_request = sub {
			my $request = new Netcomics::MyRequest shift;
			return add_referer($request,shift(@_));
		};
		$ua = Netcomics::ExternalUserAgent->new;
		$ua->setVerbosity(($extra_verbose) ? 2 : $verbose);
		unless (defined($external_cmd)) {
			print "\nlibwww-perl and/or URI are not installed.\n" .
				" Trying to download comics with wget instead.\n"
					if $verbose;
		} else {
			print "\nUsing '$external_cmd' to download comics.\n" 
				if $extra_verbose;
			$ua->setCmd($external_cmd);
		}
	}

	if (defined $proxy_url) {
		print "using proxy, $proxy_url ...\n" if $extra_verbose;
		$ua->proxy(['http', 'ftp'], $proxy_url);
	}
	my $response = undef;
	my @images = (); #list of comics successfully downloaded
	my @bad_images = (); #list of comic ids that had problems
	my @rli_queue = @$rlis;
  RLI: 
	while (@rli_queue) {
		my $rli = pop(@rli_queue);
		my $proc = $rli->{'proc'};
		my $time = $rli->{'time'};
		my $name = undef;

		#first construct the name because this is also used by webpage creation
		if (defined($rli->{'title'})) {
			#todo: stick in here, using options to determine how to
			#name the file.
			$name = strftime("$rli->{'title'}-${date_fmt}",gmtime($time));
		} else { 
			print STDERR "Error: No name or title provided for the " .
				"comic identified by $proc. Not using $proc\n";
			next;
		}
		$name =~ s/\s/_/g;
		$rli->{'name'} = $name;
		next if $self->skip_rli($rli);
		my ($base,$page,$expr,$exprs,$func,$back,$mfeh,$referer) = (undef)x8;
	  SETUPDATA:
		$base = $rli->{'base'} if exists $rli->{'base'};
		$page = $rli->{'page'} if exists $rli->{'page'};
		$expr = $rli->{'expr'} if exists $rli->{'expr'};
		$exprs = $rli->{'exprs'} if exists $rli->{'exprs'};
		$func = $rli->{'func'} if exists $rli->{'func'};
		$back = $rli->{'back'} if exists $rli->{'back'};
		$referer = $rli->{'referer'} if exists $rli->{'referer'};
		
		if ($separate_comics) {
			$rli->{'subdir'} = $rli->{'title'};
			$rli->{'subdir'} =~ s/\s/_/g;
			if (! -e "$comics_dir/$rli->{'subdir'}" ) {
				print "Creating directory $rli->{'subdir'}\n" if $verbose;
				mkdir("$comics_dir/$rli->{'subdir'}", 0755);
			}
		}
		
		if (!defined($rli->{'type'})) {
			$rli->{'type'} = $default_filetype;
			print STDERR "$proc: warning, no file type was supplied, " .
				"defaulting to $default_filetype\n" if $extra_verbose;
		}
		
		$rli->{'status'} = 0;
		
		unless (defined($base)) {
			print STDERR "Error: No base URL provided for the comic " .
				"identified by $proc. Not using $proc.\n";
			next;
		}
		print "$comics_dir/$name\n"
			if $verbose && ! $extra_verbose && ! $dont_download; 
		
		#handle backwards compatibility
		if (defined($exprs) && defined($expr)) {
			print STDERR "Both exprs & expr are defined in the rli returned";
			print STDERR " by $proc.  Please use only one. Skipping\n";
			next;
		}
		if (defined($page) || defined($exprs)) {
			#build up the exprs array
			$exprs = [$expr] if defined($expr) && defined($page);
			#make sure page is defined
			$page = "" if defined($exprs) && ! defined($page);
			#handle the multi-field expression hash or regular array of exprs
			if (defined($exprs)) {
				$_ = ref($exprs);
				if (/HASH/) {
					#advanced multi-field expression hash
					$mfeh = $exprs;
					if (defined($exprs = $mfeh->{'comic'})) {
						print "$name: Using comic in mfeh as exprs\n" 
							if $extra_verbose;
						delete($mfeh->{'comic'});
						undef $mfeh if keys(%$mfeh) == 0;
					} else {
						#print STDERR "$name: must provide field 'comic' in " .
						#    "'exprs' hash. Skipping $proc\n";
						#next;
					}
				} elsif (/ARRAY/) {
					#good
				} else {
					print STDERR "$name: exprs must either be an array or " .
						"a hash. Skipping $proc\n";
					next;
				}
			}

		} elsif (defined($expr)) {
			#set page to $expr
			$page = $expr;
		} elsif (defined($func)) {
			#good.
		} else {
			print STDERR "func, exprs, page, nor expr are defined in the rli ";
			print STDERR "returned by $proc. Please use at least one of them.";
			print STDERR " Skipping\n";
			next;
		}

		#set the download status:
		#0: didn't download--can't even use URL
		#1: successfully downloaded
		#2: didn't download, but URL is available
		#3: didn't download--using backup

		my $request;
		my $i = 0; #number of the URL gotten
		if (defined($page)) {
			my $url = "$base$page";
			print "$name($i): $url\n" if $extra_verbose;
			#don't download if this is the last URL & $dont_download is set
			if (!defined($func) && !defined($exprs) && $dont_download) {
				$rli->{'status'} = 2;
			} else {
				$request = &$new_request($url);
				$request->referer($referer) if defined $referer;
				$response = $ua->request($request);
				unless ($response->is_success) {
					my $code = $response->code;
					print STDERR "Response: $code " .
						status_message($code) . "\n"
							if $extra_verbose;
					if (defined($back) && 
						$self->add_back($back,$time,$proc,$rli,\@rli_queue,
										$rlis, "$name($i): " .
										"fetching '$url' failed.")) {
						goto FINISH_RLI;
					}
					print STDERR 
						"failure fetching '$url' for $name ($i).\n";
					push(@bad_images,$proc) 
						unless grep {/^$proc$/} @bad_images;
					if (!$skip_bad_comics && !defined($func) && 
						!defined($exprs)) {
						#use the URL instead
						print "using the URL instead for $name ($i).\n"
							if $verbose;
						$rli->{'status'} = 2;
					} else {
						goto FINISH_RLI;
					}
				}
			}
			$i++;

			my $exp = "";
			my $j = 0;
			foreach $exp (@$exprs) {
				#get the location of the image in the html page just returned.
				my $text = $response->content;
				#match on the content as if it were a single line (/$exp/s)
				$_ = $text;
				unless (eval(/$exp/s)) {
					if (defined($back) && 
						$self->add_back($back,$time,$proc,$rli,\@rli_queue,
										$rlis, "$name($i): " .
										"match for '$exp' in $url failed")){
						goto FINISH_RLI;
					}
					print STDERR "failed to match against '$exp' ($i) for ";
					print STDERR "$name in $url.\n";
					push(@bad_images,$proc) 
						unless grep {/^$proc$/} @bad_images;
					goto FINISH_RLI;
				}
				$url = "$base$1";
				
				#handle the multi-field expression hash
				foreach (keys(%$mfeh)) {
					my $field = $_;
					my $expr;
					next unless defined ($expr = $mfeh->{$field}[$j]);
					$_ = $text;
					if (eval(/$expr/s)) {
						$rli->{$field} = $1;
						print "$name($i).$field: expr = '$expr'; success.\n"
							if $extra_verbose;
					} else {
						print "$name($i).$field: search with /$expr/ failed.\n"
							if $verbose;
					}
				}


				#get the next URL
				print "$name($i): expr = '$exp'; URL = $url\n" 
					if $extra_verbose;
				#don't download if this is the last URL & $dont_download is set
				if (++$j == @$exprs && !defined($func) && $dont_download) {
					$rli->{'status'} = 2;
				} else {
					$request = &$new_request($url);
					$request->referer($referer) if defined $referer;
					$response = $ua->request($request);
					unless ($response->is_success) {
						my $code = $response->code;
						print STDERR "Response: $code " .
							status_message($code) . "\n"
								if $extra_verbose;
						if (defined($back) && 
							$self->add_back($back,$time,$proc,$rli,\@rli_queue,
											$rlis, "$name($i): " .
											"fetching '$url' failed.")) {
							goto FINISH_RLI;
						}
						print STDERR 
							"failure fetching '$url' for $name ($i).\n";
						push(@bad_images,$proc) 
							unless grep {/^$proc$/} @bad_images;
						if (!$skip_bad_comics && !defined($func) && 
							$j == @$exprs) {
							#use the URL instead
							print "using the URL instead for $name ($i).\n"
								if $verbose;
							$rli->{'status'} = 2;
						} else {
							goto FINISH_RLI;
						}
					}
					$i++; #simply keep track for debugging purposes
				}
			}
			$rli->{'url'}=[$url] unless defined $func || defined $rli->{'url'};
		}

		#handle function returning relative URLs
		if (defined($func)) {
			print "$name: applying function\n" if $extra_verbose;

			#run the function, giving it the last response downloaded if any
			my @relurls;
			if (defined($page)) {
				@relurls = &$func($response->content);
			} else {
				print "Warning: running func without supplying any content.\n"
					if $verbose;
				@relurls = &$func();
			}		
			
			if (@relurls == 0 || (@relurls == 1 && ! defined($relurls[0]))) {
				if (defined($back) && 
					$self->add_back($back, $time, $proc, $rli, \@rli_queue,
									$rlis, "$name($i): " .
									"function returned no relative urls.")){
					goto FINISH_RLI;
				}
				print "$name($i): function returned no relative urls.\n" 
					if $extra_verbose;
				goto FINISH_RLI;
			}
			
			my $j = 0;
		  RELURL:	    
			while (@relurls) {
				my $litem = pop(@relurls);
				$_ = ref($litem);
				if ($litem eq "DUMMY") {
					next RLI;
				}
				if (/HASH/) {
					#special rli fields to be added (like with mfeh)
					#instead of relative URLs.
					if ($j > 0) {
						#either rli fields or rel urls--both not allowed
						print STDERR "$name($i): bug found.  Both relative" .
							"URLs and RLI fields are not allowed to be " .
								"returned by functions.\n";
						next RLI;
					}
					$j--;
					my $key;
					foreach $key (keys(%$litem)) {
						print "$name($i): adding field '$key' => " .
							"'$litem->{$key}'\n" 
								if $extra_verbose && defined $litem->{$key};
						$rli->{$key} = $litem->{$key};
					}
					next RELURL;
				} elsif (/ARRAY/) {
					#push these back onto relurls
					push @relurls, @$litem;
					print STDERR "$name($i): adding contents of array ref " .
						"back onto relurls.\n";
					next RELURL;
				} elsif (! /^$/) {
					print STDERR "$name($i): list element of type $_ " .
						"returned by function is not yet supported.\n";
					next RELURL;
				}

				if ($j < 0) {
					#either rli fields or rel urls--both not allowed
					print STDERR "$name($i): bug found.  Both relative" .
						"URLs and RLI fields are not allowed to be " .
							"returned by functions.\n";
					next RLI;
				}

				my $url = "$base$litem";
				$j++; #used to append to the file name
				
				my $mname = $name;
				$mname ="${name}-$j";

				print "$mname: $url\n" if $extra_verbose;
				if ($dont_download) {
					$rli->{'status'} = 2;
				} else {
					$request = &$new_request($url,$referer);
					$response = $ua->request($request);
					unless ($response->is_success) {
						my $code = $response->code;
						print STDERR "Response: $code " .
							status_message($code) . "\n"
								if $extra_verbose;
						if (defined($back) && 
							$self->add_back($back,$time,$proc,$rli,\@rli_queue,
											$rlis, "$name($i): " .
											"fetching '$url' failed.")) {
							goto FINISH_RLI;
						}
						print STDERR 
							"failure fetching '$url' for $mname ($i).\n";
						push(@bad_images,$proc) 
							unless grep {/^$proc$/} @bad_images;
						if (!$skip_bad_comics) {
							#use the URL instead
							print "using the URL instead for $name ($i).\n"
								if $verbose;
							$rli->{'status'} = 2;
						} else {
							goto FINISH_RLI;
						}
					} else {
						$mname .= ".$rli->{'type'}";
						if ($separate_comics) {
							file_write("$comics_dir/$rli->{'subdir'}/$mname",
									   $files_mode, $response->content);
						} else {
							file_write("$comics_dir/$mname",$files_mode,
									   $response->content);
						}
						push(@images,$mname);
						$rli->{'file'} = [] unless defined $rli->{'file'};
						$rli->{'file'}->[@{$rli->{'file'}}] = $mname;
					}
				}
				$rli->{'url'} = [] unless defined $rli->{'url'};
				$rli->{'url'}->[@{$rli->{'url'}}] = $url;
				$i++; #simply keep track for debugging purposes
			}
			if ($j < 0) {
				#assume the @relurl returned contained a hash which added
				#fields to the rli which now need to be reprocessed.
				goto SETUPDATA;
			}
		} else  {
			#complete the fields for the rli.
			#first tack on the file type (it may have been changed thru 'exprs')
			$name .= "." . $rli->{'type'};

			unless ($dont_download || $rli->{'status'} == 2) {
				#save the image to its file if it was successfully downloaded.
				if ($separate_comics) {
					$rli->{'file'} = [ "$name" ];
					file_write("$comics_dir/$rli->{'subdir'}/$name",
							   $files_mode, $response->content);
				} else {
					$rli->{'file'} = [ "$name" ];
					file_write("$comics_dir/$name",
							   $files_mode, $response->content);
				}
				push(@images,$name);
			}
		}
		#Eliminate the need to put mulitple status sets to 1 in the code
		#by assuming that if it was bad, jumped to FINISH_RLI or status set
		#to 2.  If another status state is added, this may have to change.
		$rli->{'status'} = 1 if $rli->{'status'} == 0;
	  FINISH_RLI:
		$rli->{'tries'} = 0 unless defined $rli->{'tries'};
		$rli->{'tries'}++;
		$self->dump_rli($rli) unless $rli->{'status'} == 3;
	}
	
	print "\nImages retrieved and placed in $comics_dir:\n@images\n" 
		if $extra_verbose && !$dont_download;
    if (@bad_images > 0 && ! $suppress_rerun_command) {
		print STDERR 
			"To try retrieving the images that failed, run this command:\n" .
				"$self->{'conf'}{'script_name'} -nR";
		if (! $data_dumper_installed) {
			print STDERR " -c \"@bad_images\"";
			print STDERR " -n $days_of_comics" if ++$days_of_comics > 1;
		}
		print STDERR "$given_options\n";
		print STDERR <<END;
Please, before sending in a bug report on a comic that doesn't download,
try over a period of several days (or weeks, depending on the problem) to
see if it just happened to be that the website maintainer for that comic
didn't update the comic promptly.
END
	}
	@{$self->{'files_retrieved'}} = @images;
	return @$rlis;
}

#these 3 functions only return useful info after get_comics has been run
sub files_retrieved {
	my $self = shift;
	return @{$self->{'files_retrieved'}};
}

sub existing_rli_files {
	my $self = shift;
	return @{$self->{'existing_rli_files'}};
}

sub get_current {
	my $self = shift;
	return $self->{'get_current'};
}

sub days_behind {
	my ($self, $proc) = @_;
	return $self->{'hof'}{$proc};
}

#Return an rli ref and an index into $self->{'rli'} for the specified comic
#and date.
#If a third option, dont_download, is true it will simply return the rli &
#index if it exists without doing anything else.  Else, it will attempt to
#download it by first running clear_date_settings, changing the settings
#for getting the comic, and running get_comics().
sub get_comic {
	my $self = shift;
	my ($comic,$date,$dont_download) = @_;
	$dont_download = 0 unless defined $dont_download;

	#determine if this comic's been downloaded before
	while (1) {
		if (defined($self->{'rli_procs'}{$comic})) {
			foreach my $time (keys(%{$self->{'rli_procs'}{$comic}})) {
				if (samedate($date, $time)) {
					my $rlis_ndx = $self->{'rli_procs'}{$comic}{$time};
					my $rli = $self->{'rli'}[$rlis_ndx];
					return ($rli,$rlis_ndx)
						if $dont_download || $self->skip_rli($rli);
				}
			}
		}
		return undef if $dont_download;

		#Since we weren't told not to download it, let's try getting that
		#comic for the specified date!
		$self->{'conf'}->clear_date_settings();
		@selected_comics = ($comic);
		$user_specified_comics = 1;
		push(@{$self->{'dates'}},$date);

		$self->setup();

		# Let's get the comics!
		my @rli = $self->get_comics();

		$dont_download = 1;
	}
}


#persistently store an rli hash, or a bunch of hashes.
sub dump_rli {
	my $self = shift;
    my $rli = shift;
    if ($data_dumper_installed) {
		my @rli; #create an array to go through the rlis
		my $reftype = ref($rli);
        if ($reftype eq "ARRAY") {
            @rli = @$rli;
		} else {
			push(@rli, $rli);
		}
		foreach (@rli) {
			delete $_->{'reloaded'};
			#Delete no-longer needed fields for completely download comics
			if ($_->{'status'} == 1) {
				delete $_->{'base'};
				delete $_->{'page'};
				delete $_->{'exprs'};
			}
		}
        if ($reftype eq "ARRAY") {
			file_write($comics_dir . '/' . $netcomics_rli_file,
					   $files_mode,Data::Dumper->Dump([\@rli],[qw(*rli)]));
        } else {
            file_write($comics_dir . '/' . rli_filename($rli->{'name'}),
                       $files_mode,Data::Dumper->Dump([$rli],[qw(*rli)]));
        }
    }
}

#add the rli to the list of rlis.
sub add_to_rli_list {
	my ($self,$rli) = @_;
	my $proc = $rli->{'proc'};
	my $time = $rli->{'time'};
	my $i = @{$self->{'rli'}};
	$self->{'rli'}[$i] = $rli;
	#save the array index.
	$self->{'rli_procs'}->{$proc} = {} 
		if ! defined($self->{'rli_procs'}->{$proc});
	$self->{'rli_procs'}->{$proc}->{$time} = $i;
}

sub remove_from_rli_list {
	my $self = shift;
	foreach my $rliref (@_) {
		my $proc = $rliref->{'proc'};
		my $time = $rliref->{'time'};
		my ($rli, $i) = $self->get_comic($proc, $time, 1);
		if (defined($rli)) {
			if ($rli ne $rliref) {
				die "Bug in netcomics: rli to remove does not match the one" .
					" found.";
			}
			$self->{'rli'}[$i] = undef;
			delete $self->{'rli_procs'}->{$proc}->{$time};
		}
	}
}

#Returns a hash ref of the comics & days behind indexed by name.
#Each value is an array, 1st element comic id, 2nd element # of days behind.
#It also returns the maximum comic id length and the maximum comic name length.
sub comic_names {
	my $self = shift;
	my $today = time;
	my ($max_flen,$max_nlen) = (0,0);
	my %names; #indexed by the comic name (not function) to make sorting easy
	while (my ($f,$d) = each %hof) {
		my $i = -1;
		my $rh = undef;
		my $days = (defined $d) ? $d : 0;
		while ($i++ <= 21) {
			#try to get a real name from the rli function 21 times
			my $time = $today - (($days + $i) * 24*3600);
			last if defined($rh = $self->run_rli_func($f,$time,$f));
		}
		my $name;
		unless (defined($name = $rh->{'title'})) {
			($name,$_) = parse_name($rh->{'name'}) if defined($rh->{'name'});
			$name = $f unless defined $name;
		}
		$names{$name} = [$f,(defined $d ? $d : -1)];
		my $len = length($f);
		$max_flen = $len if $len > $max_flen;
		$len = length($name);
		$max_nlen = $len if $len > $max_nlen;
	}
	return (\%names, $max_flen, $max_nlen);
}

sub list_comics {
	my $self = shift;
	my $make_webpage = ($do_list_comics > 1)? 1 : 0;
	print STDERR "Listing comics.\n" if $extra_verbose;
	my ($names_r,$max_flen,$max_nlen) = $self->comic_names;
	my %names = %$names_r;
	my @names = sort({libdate_sort($a,$b,$names{$b}[1],$names{$a}[1],
								   $sort_by_date);} keys(%names));
	my $title = 'Comic Name';
	my $lines = '----------';
	$names{$title} = ["id","days behind"];
	$names{$lines} = ["--","-----------"];

	print "<HTML><TITLE>Supported Comics</TITLE>\n</HEAD>\n<BODY>\n<TABLE>\n" 
		if $make_webpage;

	my $name;
	foreach $name ($title,$lines,@names) {
		my ($f,$d) = @{$names{$name}};
		print "<TR><TD>" if $make_webpage;
		print "$f";
		my $len = $max_flen + 1 - length($f);
		if ($make_webpage) {
			print "</TD><TD>";
		} else {
			print " " x $len;
		}
		print "$name";
		$len = $max_nlen + 1 - length($name);
		if ($make_webpage) {
			print "</TD><TD>";
		} else {
			print " " x $len;
		}
		if ($d eq "-1") {
			print "N/A\n";
		} else {
			print "$d\n";
		}
		print "</TD></TR>\n" if $make_webpage;
	}
    print "</TABLE>\n</BODY>\n</HTML>\n" if $make_webpage;
}

sub add_back {
	my ($self,$back,$time,$proc,$rli,$rli_queue,$rli_list,$errmsg) = @_;
	if (defined($_ = $self->run_rli_func($back,$time,$proc))) {
		print $errmsg . ", using backup.\n" if $verbose;
		$rli->{'status'} = 3;
		push(@$rli_queue,$_);
		push(@$rli_list,$_);
		return 1;
	}
	return 0;
}

sub run_rli_func {
	my ($self,$fun,$time,$fun_name,$days) = @_;
	$time -= $days * 24*3600 if defined $days;

    my $days_behind = $self->{'hof'}{$fun};
	# Real date day
	if ($real_date == 1) {
		# Adapt time for this comic "as if" today was ...
		$time -= $days_behind * 24*3600;
	}

	#get the info from the RLI
	if (ref($fun) =~ /(SUB|CODE)/) {
		$_ = &$fun($time,$prefer_color);
	} else {
		$_ = eval "$fun($time,$prefer_color)";
	}
	#remember which RLI that was & save the time
	if (defined($_)) {
		if (ref($_) eq "HASH") {
		    $_->{'time'} = $time;
		    $_->{'proc'} = $fun_name;
			$_->{'behind'} = $days_behind;
		    if (defined($comics{$fun})) {
				#copy in user-defined keys
				my $field;
				foreach $field (keys(%{$comics{$fun}})) {
				    $_->{$field} = $comics{$fun}{$field};
				}
	    	}
		} else {
		    print STDERR "$fun: returned unsupported reference type: " .
				ref($fun) . ".\n";
		    $_ = undef;
		}
	}
	return $_;
}

#Build the array of dates of comics to get
sub build_date_array {
	my $self = shift;
	$days_of_comics = undef 
		if defined($days_of_comics) && $days_of_comics == 0;
	if (defined($days_of_comics)) {
		#incase user specified it with a minus sign.
		$days_of_comics = abs($days_of_comics);
		$days_of_comics--; #adjust for 0-base
	}
	my $now = time;
	{
		#adjust the time so it is of this morning just after midnight.
		my @ltime = gmtime($now);
		$now -= $ltime[0] + ($ltime[1] + $ltime[2]*60)*60;
	}

	$self->{'get_current'} = 0; #use hof
	#Determine the start & end dates
	if (! defined($end_date) && ! defined($days_of_comics) &&
		defined($start_date)) {
		#-S, no -E, no -n
		$end_date = $now + (get_max_hof($self->{'hof'}) * 24*3600);
	} elsif (defined($end_date) && defined($days_of_comics) &&
			 ! defined($start_date)) {
		#no -S, -E, -n
		$start_date = $end_date - ($days_of_comics * 24*3600);
	} elsif (! defined($end_date) && defined($days_of_comics) &&
			 defined($start_date)) {
		#-S, no -E, -n
		$end_date = $start_date + ($days_of_comics * 24*3600);
	} elsif (! defined($end_date) && defined($days_of_comics) && 
			 ! defined($start_date)) {
		#no -S, no -E, -n
		$self->{'get_current'} = 1;
		$end_date = $now - ($days_prior * 24*3600);
		$start_date = $end_date - ($days_of_comics * 24*3600);
	} elsif (! defined($end_date) && ! defined($days_of_comics) && 
			 ! defined($start_date)) {
		#no -S, no -E, no -n
		#we don't need to do anything special
		#add today's date (minus days prior) to the date array, and return.
		if (@{$self->{'dates'}} == 0) {
		    push(@{$self->{'dates'}},($now - ($days_prior * 24*3600)));
		    $self->{'get_current'} = 1;
		}
		return;
	}

	{   #Build up the date array
		my $time_c = $start_date;
		my @e_day = gmtime($end_date);
		my @c_day = gmtime($time_c);
		my $e_day = strftime("%Y%m%d",@e_day);
		my $c_day = strftime("%Y%m%d",@c_day);
		while ($c_day <= $e_day) {
		    push(@{$self->{'dates'}},$time_c);
		    $time_c += 24*3600;
		    @c_day = gmtime($time_c);
		    $c_day = strftime("%Y%m%d",@c_day);
		}
	}
}

#functions that don't require access to attributes

#return the name of an rli stat file given the rli's name (Rli_Name-YYYYMMDD)
sub rli_filename {
	return '.' . shift(@_) . '.rli';
}

sub add_referer {
	my ($request,$referer) = @_;
	if (! defined($referer)) {
		$referer = $request->url;
		$referer =~ s/([^:]+:\/*[^\/]+)\/.*/$1/ if defined $referer;
	}
	$request->referer($referer) if defined $referer;
	return $request;
}


#return a list of persistenantly stored rli hashes.
sub load_rlis {
	my @rli_files = @_;
	my @loaded_rlis = ();
	foreach (@rli_files) {
		my $file = $comics_dir . '/' . $_;
		local(@rli,%rli);
		if (-f $file && -r $file) {
			$@=0;
			eval {require $file;};
			if ($@) {
				warn "Warning: Failed to load file (skipping it):\n$@.\n";
				next;
			} elsif (@rli == 0 && keys(%rli) == 0) {
				print STDERR "Loading rli status file, $file, " .
					"resulted in an empty rli\n";
			} 
			#copy the whole reloaded list of rlis
			if (@rli) {
				push(@loaded_rlis, @rli);
			}
			#or copy the single rli reloaded
			if (keys(%rli)) {
				push(@loaded_rlis, \%rli);
			}
		} elsif ($extra_verbose) {
			print STDERR "Error: No rli status file $_, found!\n";
		}
	}
	#Make sure necessary fields are there
	foreach (@loaded_rlis) {
		$_->{'tries'} = 1 if ! defined $_->{'tries'};
	}
	return @loaded_rlis;
}

sub get_max_hof {
	my $hof = shift;
	my ($tmp, $max_hof);

	return 0 if ($real_date == 0);

	foreach $tmp (keys %$hof) {
		$max_hof = $hof->{$tmp} if ($hof->{$tmp} > $max_hof);
	}

	return $max_hof;
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
