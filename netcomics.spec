Name: netcomics
Version: @VERSION@
Release: @PKGVERSION@
Summary: A perl script that downloads today's comics from the Web
Copyright: GPL
Group: Applications/Networking
URL: http://netcomics.sourceforge.net/
Source: http://download.sourceforge.net/netcomics/netcomics-%{version}.tar.bz2
Prefixes: /usr,/var
Packager: Ben Hochstedler <hochstrb@cs.rose-hulman.edu>
BuildArchitectures: noarch
BuildRoot: /tmp/%{name}-%{version}-root
Requires: netcomics-data >= 0.14

%description
netcomics is a perl script that can retrieve comic strips from the Web
that are continuously being updated each day. netcomics utilizes a
modular set of library perl scripts that provide it information on
where to find each specific comic strip.  It is most often run as a
cron job, along with a provided script, show_comics, to display it
on your workstation. It also can create webpages with the comics.

%package data
Summary: Comic modules that instruct netcomics on how to obtain comic strips.
Group: Applications/Networking
Requires: netcomics >= 0.14
Prefix: /usr

%description data
This is the modular library of perl scripts that provide netcomics the
information it needs to download comic strips from the Web.

# Provide perl-specific find-{provides,requires}.
%define __find_provides /usr/lib/rpm/find-provides.perl
%define __find_requires /usr/lib/rpm/find-requires.perl

#specify these without the install prefix
%define installsitelib lib/perl5/site_perl

#doc files that can be compressed
%define gzdocs ChangeLog AUTHORS NEWS README TODO LICENSE-GPL

%prep
%setup -q

%build
perl Makefile.PL
make INSTALLSITELIB=/usr/%{installsitelib}

%install
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/usr/$installsitelib
make PREFIX=$RPM_BUILD_ROOT/usr TMPBASE=$RPM_BUILD_ROOT/var/spool \
     INSTALLSITELIB=$RPM_BUILD_ROOT/usr/%{installsitelib} install

gzip -9nvf `find $RPM_BUILD_ROOT/usr -name '*.[1-9]' -print` \
     %{gzdocs}

%clean
rm -rf $RPM_BUILD_ROOT

%post
#get the first prefix
pfx=`echo $RPM_INSTALL_PREFIX | perl -pe 's/,.*//'`
cat <<END
FYI: Netcomics is now an official CPAN module.  The comic modules are no
longer stored under $pfx/share/netcomics, but under $pfx/%{installsitelib}.
END

%post data
LIBDIR=$RPM_INSTALL_PREFIX/%{installsitelib}/Netcomics/Comic
#The following is replaced by the list in the Makefile
OLDMODULES="@OLDMODULES@"
oldmods=""
cd $LIBDIR
for file in $OLDMODULES; do
    if [ -f $file ]; then
        oldmods="$oldmods $file"
	#making them unreadible makes it so netcomics won't load them.
	chmod a-r $file
    fi
done
if test "x$oldmods" != "x"; then
   cat <<END
Warning!  There may be some old modules installed that need to be
deleted.  If you are updating this package, chances are they have
already been removed.  However, run the following commands to make
sure they are removed:
END
    echo "  cd $LIBDIR; rm -f $oldmods"
fi
cat <<END
See the NEWS file for a list of the new comics & features.
END

%files
%defattr(-,root,root)
%doc *.gz doc/*.html doc/netcomics.lsm lib/template contrib/comics_update contrib/localtime contrib/local2gmtime contrib/mktime netcomicsrc doc/design.dia
/usr/bin/netcomics
/usr/bin/show_comics
/usr/bin/comicpage
%dir /usr/%{installsitelib}/Netcomics
/usr/%{installsitelib}/Netcomics/*.pm
/usr/%{installsitelib}/Netcomics/Comicpage
%dir /usr/share/perl5/Netcomics/etc
%attr(-,root,man) /usr/man/man1/*
%attr(-,root,man) /usr/lib/perl5/man/man3/Netcomics::Config.3.gz
%config /usr/bin/display_comics
%config /usr/share/perl5/Netcomics/etc/netcomicsrc
%attr(-,root,users) %dir /var/spool/netcomics
%attr(-,root,users) %dir /usr/%{installsitelib}/Netcomics/Comic


%files data
%defattr(-,root,root)
%doc *.gz doc/Modify_Webpage_Creation-HOWTO.html lib/template doc/Comic_Module-HOWTO.html potd/astronomy
/usr/%{installsitelib}/Netcomics/Comic
/usr/%{installsitelib}/Netcomics/HTML/Themes

%define date    %(echo `LC_ALL="C" date +"%a %b %d %Y"`)
%changelog
* %{date} Ben Hochstedler <hochstrb@cs.rose-hulman.edu> %{version}-%{release}

$Log$
Revision 1.17  2002-03-31 16:25:21  hochstrb
updated message displayed after install of data module

Revision 1.16  2001/09/19 15:32:58  hochstrb
updated install paths & added better proxy handling

Revision 1.15  2001/09/05 14:06:33  hochstrb
Completed the changes for html_tmpl -> HTML/Themes/Default.pm

Revision 1.14  2001/07/19 17:04:34  hochstrb
Added gzip of some doc files; reworked changelog to be RCS generated

Revision 1.13  2001/07/19 14:59:08  hochstrb
- merged OO branch into head

Revision 1.12  2001/07/18 18:03:39  hochstrb
- fixed %post data to report the old modules *may* need to be deleted.

Revision 1.7.8.7  2001/07/19 12:04:36  hochstrb
- merged HEAD into OO branch

Revision 1.11  2001/07/18 16:15:22  hochstrb
- changes in preparation for 0.13.2

Revision 1.10  2001/07/17 20:18:54  hochstrb
- updated for preperation to release 0.13.2

Revision 1.7.8.6  2001/07/08 15:14:48  hochstrb
- Updated to work with new Makefile.PL for CPAN.

Revision 1.7.8.5  2001/05/22 14:24:08  hochstrb
- Further updates to make all files in the distribution handled properly

Revision 1.7.8.4  2001/05/21 19:26:32  hochstrb
- further changes for doc files & updated the rpm spec.

Revision 1.7.8.3  2001/04/27 12:02:02  hochstrb
- Added macros that get replaced when netcomics.spec is installed.

Revision 1.7.8.2  2001/03/04 16:28:17  hochstrb
- merged main.

Revision 1.9  2001/02/18 15:33:06  hochstrb
- Updated for V0.13.1 release.

Revision 1.7.8.1  2001/02/15 16:03:36  hochstrb
- Merged main

Revision 1.8  2001/02/13 00:21:07  hochstrb
- Updated for 0.13.1

Revision 1.7  2000/08/25 16:18:10  hochstrb
- branches:  1.7.8;
Added info on new comics

Revision 1.6  2000/08/25 12:40:38  hochstrb
- Added reference to new comic: Gaming U

Revision 1.5  2000/08/25 12:38:01  hochstrb
- Updated in preperation for 0.13

Revision 1.4  2000/08/16 12:43:56  hochstrb
- Added utilization of rli status files for download avoidance &
  tracking attempts 

Revision 1.3  2000/07/26 15:40:23  hochstrb
- Added referer and external command macros capabilities

Revision 1.2  2000/07/20 13:37:10  hochstrb
- Changed location of download site and homepage.

Revision 1.1  2000/04/23 16:26:25  hochstrb
- Initial revision

Revision 1.1.1.1  2000/04/23 16:26:25  hochstrb
- Import of netcomics sources from clearcase.

