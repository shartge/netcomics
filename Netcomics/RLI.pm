package RLI;

sub new {
	my ($this,$time,$color) = @_;
	my $class = ref($this) || $this;
	my $self = {};
	bless $self, $class;
	$self->{'behind'} = 0; #default 0 days behind
	#default is 0 to indicate we're only interested in static information.
	$self->{'time'} = defined($time) ? $time : 0;
	#default is to prefer color.
	$self->{'$color'} = defined($color) ? $color : 1;
	#subclasses must define this method.
	return $self->init();
}

#subclasses call this method to quickly & easily add static attributes.
#Argument: hash reference
sub add_attributes {
	my $method = "RLI::add_attributes()";
	my $self = shift;
	croak("$method: argument must be a reference to a hash.")
		if @_ != 1 || ! (ref($_[0]) eq 'HASH');
	my $attrs = shift;
	for (keys(%$attrs)) {

		if (/(time|color|page|exprs)/) {
			croak("$method: static vars may not include $_.");
		} 
		else {
			$self->{$_} = $attrs->{$_};
		}
	}
	return $self;
}

#setting color on/off will automatically have the RLI reinitialize itself.
sub color {
	my $self = shift;
	if (@_) {
		$self->init(shift);
		return $self;
	} else {
		return $self->{'color'};
	}
}

#setting the time will automatically have the RLI reinitialize itself.
sub time {
	my $self = shift;
	if (@_) {
		$self->init(shift);
		return $self;
	} else {
		return $self->{'time'};
	}
}

sub behind {
	my $self = shift;
	return $self->{'behind'};
}

1;
