package MyRequest;

sub new {
	my ($class,$url) = @_;
	my $self = bless {
	    'method' => 'GET',
	    'url' => $url,
	    'referer' => undef
	    }, $class;
	$self;
}

sub method {
	my $self = shift;
	$self->{'method'};
}

sub url {
	my $self = shift;
	$self->{'url'};
}

sub referer {
	my $self = shift;
	if (@_ == 0) {
	    return $self->{'referer'};
	} elsif (@_ == 1) {
	    $self->{'referer'} = shift;
	} else {
	    die("Too many arguments to MyRequest::referer(@_)");
	}
}

1;
