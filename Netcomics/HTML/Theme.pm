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

package Netcomics::HTML::Theme;

use MIME::Base64;
use strict;

use vars '@html_keys';
@html_keys =qw(head links pre_body body body_el caption post_body tail
			   links_index links_element);
use vars '@imgs_keys';
@imgs_keys = qw(top_l top top_r bot_l bot bot_r left right prev index next);

=head2 new($name, $r_imgs, $r_html)

Create a new HTML::Theme object with the specified name (which should
match the theme package name), a reference to a hash of images, and a
a reference to a hash of html.  Use of images in themes is not yet
supported, but the html hash keys should be that in the @html_keys
list.

=cut

sub new {
	my ($class, $name, $r_imgs, $r_html) = @_;

	my $self = bless {
				'name' => $name,
				'html' => $r_html,
				'imgs' => $r_imgs,
			   }, $class;

	return $self;
}

sub generate_images {
	my $self = shift;
	my $target_directory = shift;

	my $images = $self->{'imgs'};

	foreach (keys(%$images)) {
		print "Saving image $_...\n";
		my $decoded = decode_base64($images->{$_});
		open(F,">$target_directory/$_") || die "could not open file: $!\n";
		print F $decoded;
		close(F);
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
