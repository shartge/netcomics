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

package Netcomics::ExternalUserAgent;
use Netcomics::MyResponse;
use strict;

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
	return Netcomics::MyResponse->new($retval, $content);
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
