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
#
# $Id$
#

use Netcomics::HTML::Theme;

package Netcomics::HTML::Themes::CleanRound;
use vars '@ISA'; @ISA = ("Netcomics::HTML::Themes::Default");
use strict;

require Exporter;
use vars qw($VERSION);
$VERSION = sprintf("%d.%02d", q$Revision$ =~ /(\d+)\.(\d+)/);

my (%html,%imgs,%prefs);

$html{'links'} = <<END_LINKS;
<TABLE WIDTH=100%>
  <TR>
    <TD ALIGN=left><A HREF="<FILE=PREV>"><img border=0 src="<THEME_DIR>/prev.gif"></A></TD>
    <TD ALIGN=right><A HREF="<FILE=NEXT>"><img border=0 src="<THEME_DIR>/next.gif"></A></TD>
  </TR>
</TABLE>
END_LINKS

# To use the corners als real images is neccessary, or some browsers
# will render the left and right side with a wrong width in some
# situations.
#
# Putting the corners into the background-attribute as well does not
# work in those situations.
#
# This is no problem, since the corners are never needed to be stretched
# only the horizontal and vertical bars need to be handeled this way.

$html{'body'} = <<END_BODY;
  <tr><td>
      <center>
      <table cellspacing=0 cellpadding=0 border=0>
        <tr>
          <td><img src="<THEME_DIR>/top_l.gif" width="20" height="20"></td>
          <td background="<THEME_DIR>/top.gif" height="20">&nbsp;</td>
          <td><img src="<THEME_DIR>/top_r.gif" width="20" height="20" ></td>
        </tr>
        <tr>
          <td background="<THEME_DIR>/left.gif" width="20">&nbsp;</td>
          <td <WIDTH> bgcolor="#f7f7f7" align=center><font face="Arial,Helvetica" size=+1 color=black><b><a name="<COMIC_ID>"><COMIC_NAME></a></b></font></td>
          <td background="<THEME_DIR>/right.gif" width="20">&nbsp;</td>
        </tr>
        <tr>
	  <td background="<THEME_DIR>/left.gif" width="20">&nbsp;</td>
	  <td bgcolor="#f7f7f7" height="10">&nbsp;</td>
	  <td background="<THEME_DIR>/right.gif" width="20">&nbsp;</td>
        </tr>
        <tr>
          <td background="<THEME_DIR>/left.gif" width="20">&nbsp;</td>
          <td><ELEMENT></td>
          <td background="<THEME_DIR>/right.gif" width="20">&nbsp;</td>
        </tr>
        <tr>
          <td><img src="<THEME_DIR>/bot_l.gif" width="20" height="20"></td>
          <td background="<THEME_DIR>/bot.gif" height="20">&nbsp;</td>
          <td><img src="<THEME_DIR>/bot_r.gif" width="20" height="20"></td>
        </tr>
      </table>
      <CAPTION>
      </center>
  </td></tr>
END_BODY

$html{'tail'} = <<END_TAIL;

<HR>
<FONT SIZE=-1><CENTER>This page was created by the CleanRound theme on <CTIME>.</CENTER></FONT>
</BODY>
</HTML>
END_TAIL

$html{'links_index'} = <<END_LINKS_INDEX;
<TR><TD>
  <TABLE WIDTH=100%>
    <TR>
      <TD ALIGN=left><A HREF="<FILE=PREV>"><img border=0 src="<THEME_DIR>/prev.gif"></A></TD>
      <TD ALIGN=center><A HREF="<FILE=INDEX>"><img border=0 src="<THEME_DIR>/index.gif"></A></TD>
      <TD ALIGN=right><A HREF="<FILE=NEXT>"><img border=0 src="<THEME_DIR>/next.gif"></A></TD>
    </TR>
  </TABLE>
</TD></TR>
END_LINKS_INDEX

$imgs{'bot.gif'} = <<END_MIME;
R0lGODlhFAAUAKEAAAAAAL+/v/f39////yH+G05ldGNvbWljcyBjbGVhbiByb3VuZCB0aGVt
ZQAh+QQBCgADACwAAAAAFAAUAAACHpSPqcvtD6OctNqLXdi8ez+E4kiW5omm6sq27gubBQA7
END_MIME

$imgs{'bot_l.gif'} = <<END_MIME;
R0lGODlhFAAUAKEAAAAAAL+/v/f39////yH+G05ldGNvbWljcyBjbGVhbiByb3VuZCB0aGVt
ZQAh+QQBCgADACwAAAAAFAAUAAACLZxvIcstiJRz8MjJasJNj8t5ICaOlMgt3mdma9A+K2vO
FowH9s73/g8MCoeQAgA7
END_MIME

$imgs{'bot_r.gif'} = <<END_MIME;
R0lGODlhFAAUAKEAAAAAAL+/v/f39////yH+G05ldGNvbWljcyBjbGVhbiByb3VuZCB0aGVt
ZQAh+QQBCgADACwAAAAAFAAUAAACLpSPEsPNCZdrMMk5KrpTH+54Bkh5AfmYWFmdaxqh7Oe+
zInX9s73/g8MCodEYQEAOw==
END_MIME

$imgs{'index.gif'} = <<END_MIME;
R0lGODlhFAAUAKEAAL+/v/f39////////yH+G05ldGNvbWljcyBjbGVhbiByb3VuZCB0aGVt
ZQAh+QQBCgACACwAAAAAFAAUAAACOJR/AMhtEMJyDkZJmb04i811VRhOGkmaD4qaIMstyqyk
tNK8YqarVO9ZlYKfFBEYRHqUPGPSiSgAADs=
END_MIME

$imgs{'left.gif'} = <<END_MIME;
R0lGODlhFAAUAKEAAAAAAL+/v/f39////yH+G05ldGNvbWljcyBjbGVhbiByb3VuZCB0aGVt
CgAh+QQBCgADACwAAAAAFAAUAAACLZxvIcstiJRz8MjJasJNj8t5ICZymTZOpfmgbFullMuu
ph3St57HL07iBX2sAgA7
END_MIME

$imgs{'next.gif'} = <<END_MIME;
R0lGODlhHgAUAKEAAL+/v/f39////////yH+G05ldGNvbWljcyBjbGVhbiByb3VuZCB0aGVt
ZQAh+QQBCgACACwAAAAAHgAUAAACRJSPmaDtDtibMEiKDQg2581dXsV1R4Sm6gqWVwnH8hwa
9I13+S63PO/74RjCnYSFXMVEI4SP2Ty5oiQoVWO6KiJayKMAADs=
END_MIME

$imgs{'prev.gif'} = <<END_MIME;
R0lGODlhHgAUAKEAAL+/v/f39////////yH+G05ldGNvbWljcyBjbGVhbiByb3VuZCB0aGVt
ZQAh+QQBCgACACwAAAAAHgAUAAACR5R/gMvNoJyUIMSJU7C51311zgeK1IZC6sq2EYnG8jwL
MI3nd87Lew+0AYcow49YM/pcTBYCFjI9UtLJJ1pdVLDZJ7ebABcAADs=
END_MIME

$imgs{'right.gif'} = <<END_MIME;
R0lGODlhFAAUAKEAAAAAAL+/v/f39////yH+HE5ldGNvbWljcyBjbGVhbiByb3VuZCB0aGVt
ZQoAIfkEAQoAAwAsAAAAABQAFAAAAi6UjxLDzQmXazDJOSq6Ux/ueAZIieRjYqh3ZqkqKqrL
znF72y+Ww3v3CwVLNVUBADs=
END_MIME

$imgs{'top.gif'} = <<END_MIME;
R0lGODlhFAAUAKEAAAAAAL+/v/f39////yH+G05ldGNvbWljcyBjbGVhbiByb3VuZCB0aGVt
CgAh+QQBCgADACwAAAAAFAAUAAACHpyPqcvtD6OctK6As95b+A+G4kiW5omm6sq27gubBQA7
END_MIME

$imgs{'top_l.gif'} = <<END_MIME;
R0lGODlhFAAUAKEAAAAAAL+/v/f39////yH+G05ldGNvbWljcyBjbGVhbiByb3VuZCB0aGVt
ZQAh+QQBCgADACwAAAAAFAAUAAACK5yPqcvtD6OctFoTsg5Piw86GUgKzViGTJCSK9t+a6wq
MD3T5nLHOc7TCQoAOw==
END_MIME

$imgs{'top_r.gif'} = <<END_MIME;
R0lGODlhFAAUAKEAAAAAAL+/v/f39////yH+G05ldGNvbWljcyBjbGVhbiByb3VuZCB0aGVt
ZQAh+QQBCgADACwAAAAAFAAUAAACK5yPqcvtD6OctK6Ac4ii+/x4ooA5o1gyJ9qs37a4nyqT
tAwrtR3XebL7IQoAOw==
END_MIME

$prefs{'vlink_color'} = "VLINK=\"#606060\"";
$prefs{'link_color'}  = "LINK=\"#4c4c4c\"";

sub new {
	my ($class, $name, $r_imgs, $r_html, $r_prefs) = @_;
	$name = "CleanRound" unless defined $name;
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
