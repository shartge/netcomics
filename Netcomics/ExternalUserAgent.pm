package ExternalUserAgent;

sub new {
	my ($class,$init) = @_;
	if (ref $init) {
	    die "Error!  handling references unimplmemented.\n";
	}
	my $self = bless {
	    'cmd' => 'wget -q -O - --header="Referer: %R" ',
	    'verbose' => 0,
	    'extra_verbose' => 0,
	    'proxy' => undef
	    }, $class;
	$self;
}

sub setCmd {
	my ($self,$cmd) = @_;
	die "Error: External command must be a scalar.\n"
	    if (! defined($cmd) || ref($cmd));
	my $old = $self->{'cmd'};
	$self->{'cmd'} = $cmd;
	return $old;
}

sub setVerbosity {
	my ($self,$verbosity) = @_;
	die "Error: verbosity must be a scalar.\n"
	    if (! defined($verbosity) || ref($verbosity));
	$self->{'verbose'} = ($verbosity > 0) ? 1 : 0;
	$self->{'extra_verbose'} = ($verbosity > 1) ? 1 : 0;
}

sub proxy {
	my ($self,$protocols,$proxy) = @_;
	#protocols is ignored
	if (@_ == 1) {
	    return $self->{'proxy'};
	} elsif (@_ == 3) {
	    $self->{'proxy'} = $proxy;
	} else {
	    shift;
	    die("Wrong number of arguments to UA::proxy(@_)");
	}
}

sub request {
	my ($self,$request) = @_;
	my ($method,$url) = ($request->method,$request->url);
	die "Error: HTTP request type $method uknown or unimplemented.\n"
	    unless ($method =~ /^GET$/);
	my $cmdline = $self->{'cmd'};
	my $referer = $request->referer;
	$cmdline =~ s/%[Rr]/$referer/ if defined $referer;
	$cmdline =~ s/%[Pp]/$self->{'proxy'}/ if defined $self->proxy;
	if ($cmdline =~ /%[Uu]/) {
	    $cmdline =~ s/%[Uu]/$url/;
	} else {
	    $cmdline .= " $url";
	}
	print "Running: '$cmdline'." if $self->{'extra_verbose'};
	my $content = `$cmdline`;
	my $retval = $?;
	print " ret=$retval\n" if $self->{'extra_verbose'};
	return MyResponse->new($retval, $content);
}

1;