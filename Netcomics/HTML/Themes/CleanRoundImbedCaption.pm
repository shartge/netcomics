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

package Netcomics::HTML::Themes::CleanRoundImbedCaption;
use vars '@ISA'; @ISA = ("Netcomics::HTML::Themes::CleanRound");
use strict;

require Exporter;
use vars qw($VERSION);
$VERSION = sprintf("%d.%02d", q$Revision$ =~ /(\d+)\.(\d+)/);

my (%html, %imgs);

$html{'caption'} = <<END_CAPTION;
        <tr valign=center>
          <td background="<THEME_DIR>/left.gif" width="20">&nbsp;</td>
  	  <td><center><CAPTION_DATA></center></td>
          <td background="<THEME_DIR>/right.gif" width="20">&nbsp;</td>
	</tr>
END_CAPTION

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
          <td <WIDTH> bgcolor=black align=center><font face="Arial,Helvetica" size=+1 color=white><b><a name="<COMIC_ID>"><COMIC_NAME></a></b></font></td>
          <td background="<THEME_DIR>/right.gif" width="20">&nbsp;</td>
        </tr>
        <tr>
          <td background="<THEME_DIR>/left.gif" width="20">&nbsp;</td>
          <td><ELEMENT></td>
          <td background="<THEME_DIR>/right.gif" width="20">&nbsp;</td>
        </tr>
        <CAPTION>
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

sub new {
	my ($class, $name, $r_imgs, $r_html) = @_;
	$name = "CleanRoundImbedCaption" unless defined $name;
	my %html_c = %html;
	my %imgs_c = %imgs;
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
    return $class->SUPER::new($name, \%imgs_c, \%html_c);
}

1;
