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

package Netcomics::HTML::Themes::Default;

use MIME::Base64;

my @html_keys = qw(head links body body_el tail links_index links_element);
my @imgs_keys =
	qw(top_l top top_r bot_l bot bot_r left right prev index next);

my (%html,%imgs);

$html{'head'} = <<END_HEAD;
<HTML>

<HEAD>
  <TITLE><PAGETITLE> (<NUM=FIRST>-<NUM=LAST> of <NUM=TOTAL>)</TITLE>
</HEAD>

<BODY <LINK_COLOR> <VLINK_COLOR> <BACKGROUND>>
<CENTER>
  <H1><PAGETITLE> (<NUM=FIRST>-<NUM=LAST> of <NUM=TOTAL>)</H1>
</CENTER>

<TABLE WIDTH=100%>
END_HEAD

$html{'links'} = <<END_LINKS;
<TR><TD>
  <TABLE WIDTH=100%>
    <TR>
      <TD ALIGN=left><A HREF="<FILE=PREV>">Previous <NUM> Comics</A></TD>
      <TD ALIGN=right><A HREF="<FILE=NEXT>">Next <NUM> Comics</A></TD>
    </TR>
  </TABLE>
</TD></TR>
END_LINKS

$html{'body'} = <<END_BODY;
  <TR><TD ALIGN=CENTER>
    <TABLE CELLSPACING=0 CELLPADDING=0 BORDER=0><TR>
      <TD BGCOLOR=black ALIGN=CENTER><FONT FACE="Arial,Helvetica" SIZE=+1 COLOR=white><B><A NAME="<COMIC_ID>"><COMIC_NAME></A></B></FONT>
      </TD>
    </TR>
    <TR><TD><ELEMENT></TD></TR>
    <CAPTION>
    </TABLE>
  </TD></TR>
END_BODY

$html{'body_el'} = <<END_BODY_ELEMENT;
<A HREF="<COMIC_FILE>"><IMG BORDER=0 SRC="<COMIC_FILE>" <SIZE>></A>
END_BODY_ELEMENT

$html{'tail'} = <<END_TAIL;
</TABLE>

<HR>
<FONT SIZE=-1><CENTER>This page was created on <CTIME>.</CENTER></FONT>
</BODY>
</HTML>
END_TAIL

$html{'links_index'} = <<END_LINKS_INDEX;
<TR><TD>
  <TABLE WIDTH=100%>
    <TR>
      <TD ALIGN=left><A HREF="<FILE=PREV>">Previous <NUM> Comics</A></TD>
      <TD ALIGN=center><A HREF="<FILE=INDEX>">Index</A></TD>
      <TD ALIGN=right><A HREF="<FILE=NEXT>">Next <NUM> Comics</A></TD>
    </TR>
  </TABLE>
</TD></TR>
END_LINKS_INDEX

$html{'index_element'} = <<END_INDEX_ELEMENT;
  <TR>
    <TD><A HREF="<FILE=CURRENT>#<COMIC_ID>"><COMIC_NAME></A></TD>
    <TD ALIGN=right><COMIC_DATE></TD>
    <TD><COMIC_AUTHOR></TD>
    <TD><COMIC_STATUS></TD>
    <TD ALIGN=right><A HREF="<FILE=CURRENT>"><PAGE=CURRENT></A></TD>
  </TR>
END_INDEX_ELEMENT

sub new {
	#takes these optional arguments: imgs hash ref & an html hash ref
	my ($class, $name, $r_imgs, $r_html) = @_;

	my $self = bless {
				'name' => $name || "Default",
				'html' => \%html,
				'imgs' => \%imgs,
			   }, $class;

	#only copy only standard-named keys because that's all that Page.pm
	#cares about.
	if (defined($r_html)) {
		foreach my $key (@html_keys) {
			$self->{'html'}{$key} = $r_html->{$key} if defined $r_html->{$key};
		}
	}
	if (defined($r_imgs)) {
		foreach my $key (keys(%$r_imgs)) {
			$self->{'imgs'}{$key} = $r_imgs->{$key};
		}
	}
	#print "CREATED KEYS:".keys(%$self->{'imgs'});
	
	return bless $self, $class;
}

sub generate_images {
	my $self = shift;
	my $target_directory = shift;

	my %images = %{$self->{'imgs'}};

	foreach (keys(%images)) {
		print "Saving image $_...\n";
		my $decoded = decode_base64($images{$_});
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
