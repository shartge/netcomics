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

use Netcomics::HTML::Theme;

package Netcomics::HTML::Themes::Default;
use vars '@ISA'; @ISA = ("Netcomics::HTML::Theme");
use strict;

require Exporter;
use vars qw($VERSION);
$VERSION = sprintf("%d.%02d", q$Revision$ =~ /(\d+)\.(\d+)/);

my (%html,%imgs,%prefs);

$html{'head'} = <<END_HEAD;
<HTML>

<HEAD>
  <TITLE><PAGETITLE> (<NUM=FIRST>-<NUM=LAST> of <NUM=TOTAL>)</TITLE>
</HEAD>

<BODY <LINK_COLOR> <VLINK_COLOR> <BACKGROUND>>
<CENTER>
  <H1><PAGETITLE> (<NUM=FIRST>-<NUM=LAST> of <NUM=TOTAL>)</H1>
</CENTER>

END_HEAD

$html{'links'} = <<END_LINKS;
<TABLE WIDTH=100%>
  <TR>
    <TD ALIGN=left><A HREF="<FILE=PREV>">Previous <NUM> Comics</A></TD>
    <TD ALIGN=right><A HREF="<FILE=NEXT>">Next <NUM> Comics</A></TD>
  </TR>
</TABLE>
END_LINKS
$html{'pre_body'} = <<END_PRE_BODY;
<TABLE WIDTH=100%>
END_PRE_BODY

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

$html{'body_el_embed'} = <<END_BODY_ELEMENT_EMBED;
<embed src="<COMIC_FILE>" <SIZE> align="absmiddle" salign="l" play="true" loop="true" quality="autohigh" swLiveConnect="False"></embed>
END_BODY_ELEMENT_EMBED

$html{'caption'} = <<END_CAPTION;
<TR><TD><CENTER><CAPTION_DATA></CENTER></TD></TR>
END_CAPTION

$html{'post_body'} = <<END_POST_BODY;
</TABLE>
END_POST_BODY

$html{'tail'} = <<END_TAIL;

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

# Setup default colors...
$prefs{'vlink_color'} = "VLINK=#FF99FF";
$prefs{'link_color'}  = "LINK=#9999FF";

sub new {
	my ($class, $name, $r_imgs, $r_html, $r_prefs) = @_;
	$name = "Default" unless defined $name;
	my %html_c = %html;
	my %imgs_c = %imgs;
	my %prefs_c = %prefs;
	if (defined($r_html)) {
		#only copy the html templates that get used
		foreach (@Netcomics::HTML::Theme::html_keys) {
			$html_c{$_} = $r_html->{$_} if defined $r_html->{$_};
		}
	}
	if (defined($r_imgs)) {
		foreach (keys(%$r_imgs)) { #copy all images
			$imgs_c{$_} = $r_imgs->{$_};
		}
	}
	if (defined($r_prefs)) {
		foreach (keys(%$r_prefs)) { #copy all prefs
			$prefs_c{$_} = $r_prefs->{$_};
		}
	}
    return $class->SUPER::new($name, \%imgs_c, \%html_c, \%prefs_c);
}

1;

