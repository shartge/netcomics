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

package Netcomics::MyRequest;
use strict;

require Exporter;
use vars qw($VERSION);
$VERSION = do {require Netcomics::Config; $Netcomics::Config::VERSION;};

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
