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

package Netcomics::HTML::Themes::NoStatus;
use vars '@ISA'; @ISA = ("Netcomics::HTML::Themes::Default");
use strict;

require Exporter;
use vars qw($VERSION);
$VERSION = sprintf("%d.%02d", q$Revision$ =~ /(\d+)\.(\d+)/);

my (%html,%imgs);

$html{'index_element'} = <<END_INDEX_ELEMENT;
  <TR>
    <TD><A HREF="<FILE=CURRENT>#<COMIC_ID>"><COMIC_NAME></A></TD>
    <TD ALIGN=right><COMIC_DATE></TD>
    <TD><COMIC_AUTHOR></TD>
    <TD ALIGN=right><A HREF="<FILE=CURRENT>"><PAGE=CURRENT></A></TD>
  </TR>
END_INDEX_ELEMENT

$html{'tail'} = <<END;

<HR>
<FONT SIZE=-1><CENTER>Created using the NoStatus theme
on <CTIME>.</CENTER></FONT>
</BODY>
</HTML>
END


sub new {
    my $class = shift;
    return $class->SUPER::new("NoStatus",\%imgs,\%html);
}

1;
