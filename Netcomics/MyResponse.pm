#-*-mode: Perl; tab-width: 4 -*-
package MyResponse;

sub new {
	my ($class,$code,$content) = @_;
	my $self = bless {
	    'content' => $content,
	    'code' => $code
	    }, $class;
	$self;
}

sub code {
	my $self = shift;
	$self->{'code'};
}

sub is_success {
	my $self = shift;
	$self->{'code'} ? 0 : 1;
}

sub content {
	my $self = shift;
	$self->{'content'};
}

1;
