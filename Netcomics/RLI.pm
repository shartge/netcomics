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

package Netcomics::RLI;
use strict;

require Exporter;
use vars qw($VERSION);
$VERSION = do {require Netcomics::Config; $Netcomics::Config::VERSION;};

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
