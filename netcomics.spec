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

%changelog
* Sun Jul  8 2001 Ben Hochstedler <hochstrb@cs.rose-hulman.edu> 0.14-1
- Added a netcomics requires for netcomics-data >= 0.14.
- Updated for the change in Makefile -> Makefile.PL
- Trimmed changelog to only include changes to the spec.
* Fri Jul  6 2001 Ben Hochstedler <hochstrb@cs.rose-hulman.edu> 0.13.2-1
- updated version
* Mon May 21 2001 Ben Hochstedler <hochstrb@cs.rose-hulman.edu> 0.14-1
- Added /usr/lib/perl5 files & comicpage manpage.
* Fri Apr 27 2001 Ben Hochstedler <hochstrb@cs.rose-hulman.edu> 0.14-1
- Added conf file /etc/netcomicsrc. Made Version, Release, & OLDMODULES
  to be replaced by the Makefile.
* Sun Feb 18 2001 Ben Hochstedler <hochstrb@cs.rose-hulman.edu> 0.13.1-1
- added gzip of manpages, doc files for data pkg, & check for old modules.
* Tue Aug 25 2000 Ben Hochstedler <hochstrb@cs.rose-hulman.edu> 0.13-1
- Added Astronomy Picture of the Day.
* Tue Nov 30 1999 Ben Hochstedler <hochstrb@cs.rose-hulman.edu> 0.11-1
- Changed /usr/lib/netcomics to /usr/share/netcomics.
- Added TODO.
* Sat Sep 4 1999 Ben Hochstedler <hochstrb@cs.rose-hulman.edu> 0.10-1
- Separated modules into their own RPM.
* Wed Aug 4 1999 Ben Hochstedler <hochstrb@cs.rose-hulman.edu> 0.9.1-1
- Made distribution a little more GNU compliant.
* Wed Jun 16 1999 Ben Hochstedler <hochstrb@cs.rose-hulman.edu> 0.8-1
- Added a new display script: show_comics.  Removed dependancies on perl 
  CPAN modules! Added support for specifying the program to use to fetch URLs.
  Added support for comic Stuff This, and made other various updates.
- For RPM spec: added BuildRoot
* Mon Apr 5 1999 Ben Hochstedler <hochstrb@cs.rose-hulman.edu> 0.6-1
- Added contrib/comics_update, updated post install info text
* Wed Mar 3 1999 Ben Hochstedler <hochstrb@cs.rose-hulman.edu> 0.5-1
- Added template as document & moved html files to doc directory
* Wed Feb 17 1999 Ben Hochstedler <hochstrb@cs.rose-hulman.edu> 0.3-1
- fixed typo in the post-install message & added Howto file
* Tue Feb 16 1999 Ben Hochstedler <hochstrb@cs.rose-hulman.edu> 0.2-2
- added manpage
* Mon Feb 15 1999 Ben Hochstedler <hochstrb@cs.rose-hulman.edu> 0.2-1
- added comiczone comics, and a CHANGES file
* Sun Feb 14 1999 Ben Hochstedler <hochstrb@cs.rose-hulman.edu> 0.1-1
- initial version

# Provide perl-specific find-{provides,requires}.
%define __find_provides /usr/lib/rpm/find-provides.perl
%define __find_requires /usr/lib/rpm/find-requires.perl

#specify these without the install prefix
%define installsitelib lib/perl5/site_perl

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

gzip -9nvf `find $RPM_BUILD_ROOT/usr -name '*.[1-9]' -print`

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
There are 32 new comics supported by this release.
See the NEWS file for a list of those new comics.
END

%files
%defattr(-,root,root)
%doc ChangeLog AUTHORS NEWS README TODO LICENSE-GPL doc/*.html doc/netcomics.lsm lib/template contrib/comics_update contrib/localtime contrib/local2gmtime contrib/mktime netcomicsrc doc/design.dia
/usr/bin/netcomics
/usr/bin/show_comics
/usr/bin/comicpage
%dir /usr/%{installsitelib}/Netcomics
/usr/%{installsitelib}/Netcomics/*.pm
/usr/%{installsitelib}/Netcomics/Comicpage
%dir /etc
%attr(-,root,man) /usr/man/man1/*
%attr(-,root,man) /usr/lib/perl5/man/man3/Netcomics::Config.3.gz
%config /usr/bin/display_comics
%config /etc/netcomicsrc
%attr(-,root,users) %dir /var/spool/netcomics
%attr(-,root,users) %dir /usr/%{installsitelib}/Netcomics/Comic


%files data
%defattr(-,root,root)
%doc ChangeLog AUTHORS NEWS README TODO LICENSE-GPL doc/Modify_Webpage_Creation-HOWTO.html lib/template doc/Comic_Module-HOWTO.html potd/astronomy
/usr/%{installsitelib}/Netcomics/Comic
/usr/%{installsitelib}/Netcomics/html_tmpl
