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

package Netcomics::HTML::Themes::OldSchool;
use vars '@ISA'; @ISA = ("Netcomics::HTML::Themes::Default");
use strict;

require Exporter;
use vars qw($VERSION);
$VERSION = sprintf("%d.%02d", q$Revision$ =~ /(\d+)\.(\d+)/);

my (%html,%imgs);

$html{'head'} = <<END_HEAD;
<HTML>
<HEAD>
  <TITLE>Netcomics: <NUM=FIRST>-<NUM=LAST> of <NUM=TOTAL> (<CTIME>)</TITLE>
</HEAD>
<BODY <LINK_COLOR> <VLINK_COLOR> <BACKGROUND>>

END_HEAD

$html{'links'} = <<END_LINKS;
<A HREF="<FILE=PREV>">&lt; &lt; &lt; &lt;</A>
&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;
<A HREF="<FILE=NEXT>">&gt; &gt; &gt; &gt;</A>
<P>
END_LINKS
    
$html{'links_index'} = $html{'links'};

    
$html{'pre_body'} = '<TABLE>';

$html{'body'} = <<END_BODY;
<ELEMENT>
<P>
END_BODY

$html{'body_el'} = <<END_BODY_ELEMENT;
<A HREF="<COMIC_FILE>"><IMG BORDER=0 SRC="<COMIC_FILE>" <SIZE>></A>
END_BODY_ELEMENT

$html{'caption'} = <<END_CAPTION;
<BR><CAPTION_DATA>
END_CAPTION

$html{'post_body'} = '</TABLE>';

$html{'tail'} = <<END_TAIL;

<P>
<FONT SIZE=-1><CTIME></FONT>
</BODY>
</HTML>
END_TAIL

sub new {
    my $class = shift;
    return $class->SUPER::new("Old School",\%imgs,\%html);
}

1;

