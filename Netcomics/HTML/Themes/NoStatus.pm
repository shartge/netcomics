
package Netcomics::HTML::Themes::NoStatus;
use vars '@ISA'; @ISA = ("Netcomics::HTML::Themes::Default");
use strict;

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
