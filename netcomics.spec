Name: netcomics
Version: 0.13
Release: 1
Summary: A perl script that downloads today's comics from the Web
Copyright: GPL
Group: Applications/Networking
URL: http://netcomics.sourceforge.net/
Source: http://download.sourceforge.net/netcomics/netcomics-%{version}.tar.bz2
Prefix: /usr
Packager: Ben Hochstedler <hochstrb@cs.rose-hulman.edu>
BuildArchitectures: noarch
BuildRoot: /tmp/%{name}-%{version}-root
Requires: netcomics-data

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
Requires: netcomics

%description data
This is the modular library of perl scripts that provide netcomics the
information it needs to download comic strips from the Web.

%changelog
* Tue Aug 25 2000 Ben Hochstedler <hochstrb@cs.rose-hulman.edu> 0.13-1
- Added info about new referer and download avoidance capabilities.
- Added the comics: Whenigrowup, Dr. Fun, Sinfest, Sempai, Everything Jake,
  Can of the Cats.
- Added Astronomy Picture of the Day.
* Sun Apr 23 2000 Ben Hochstedler <hochstrb@cs.rose-hulman.edu> 0.12-1
- Added the comics: 9 Chickweed Lane, Absurd Notion, Against The Grain,
  Alice, Avalon, Badlands, Bobos Progress, Boonies, Broom-Hilda, Buckets,
  Cats With Hands, Chase Villens, Dilbert Classics, Down To Earth, Dr Katz,
  Dragon Tails, Eek and Meek, Fair Game, Fat Cats, Gibberish, Gil Thorp,
  Hound's Home, Ick, Janes World, The Japanese Beetle, K Rat, Kudzu, Lola,
  Loose Parts, Mary Worth, Meatloaf Night, Mickey Mouse, The New Breed,
  Out of Fika, Outtake, PC and Pixel, PS Mueller, Penny Arcade, Phantom,
  Player Versus Player, Pretzel Logic, Quigmans, Random Shots, Rex Morgan,
  Ripleys Believe It Or Not, Real Life, Roomies, Rubes, Small Grey,
  Small World, Spex and Wally, Staggering Heights, Suburban Jungle, Sylvia,
  Tarzan, Thats Life, Top Of This World, Toy Trunk Railroad, Wahm.com Mom,
  Waiting For Bob, WildLife, You Damn Kid.
- Fixed Y2K bugs
* Tue Nov 30 1999 Ben Hochstedler <hochstrb@cs.rose-hulman.edu> 0.11-1
- Changed /usr/lib/netcomics to /usr/share/netcomics.
- Added TODO.
- Added the comics: After Y2K, Dysentery, Cartoon Web, Bound & Gagged,
  Fred Basset, Herb & Jaamal, Middletons, Pluggers, Motley's Crew,
  Zorro, Liberty Meadows, Teenage Ninja Turtles, Ballard Street, Miss
  Peach, Wee Pals, Raw Material, Agnes, Dr Katz, Outtake, Pcpixel, 9
  Chickweed Lane, Broom-Hilda, Kudzu, Lola, Quigmans, Rubes, Boonies,
  Juilet Jones, Judge Parker, Mark Trail, Henry, Prince Val, New
  Format, Theydoit, Walnut Cove, Tiger, Ripkirby, Hazel, Katzenjammer
  Kids, Mandrake, Pops Place, Popeye, Small Society, Steve Roper,
  Moose Miller, Needhelp, Dick Tracy, Brenda Star, Orphan Annie,
  Gasoline Alley, Soap On A Rope, and World Views
- Added editorial cartoons by: Walt Handelsman,  Bill Day, Chan Lowe,
  Steve Sack, Mike Peters, Dana Summers, Jeff Macnelly, Jack Ohman,
  Don Wright, Dick Locher, Wayne Stayskal
- Removed Goats for copyright issues.
* Sat Sep 4 1999 Ben Hochstedler <hochstrb@cs.rose-hulman.edu> 0.10-3
- Changed new contrib files to use /usr/bin/perl.
* Sat Sep 4 1999 Ben Hochstedler <hochstrb@cs.rose-hulman.edu> 0.10-2
- Update Makefile to have temporary files created by pod2html removed.
- Added contrib scripts for dealing with time conversions.
* Sat Sep 4 1999 Ben Hochstedler <hochstrb@cs.rose-hulman.edu> 0.10-1
- Use of gmtime() instead of localtime() for code that downloads comics.
- New fields: title, type, author, main, & archives; name depricated.
- Created webpages now get links included to the comic's site.
- Seperated modules into their own RPM.
- new comics: Bliss, The Boondocks, Citizen Dog, The Fusco Brothers,
  Overboard, Tank McNamara, Real Life Adventures, Tradin' Paint,
  Animal Crackers, Bottom Liners, Strange Brew, For Heaven's Sake,
  Heathcliff, & Color Blind.
* Wed Aug 4 1999 Ben Hochstedler <hochstrb@cs.rose-hulman.edu> 0.9.1-1
- Fixed bugs in the Flash Gordon, Dilbert, and Comiczone modules.
- Changed html template loading error handling.
- Made distribution a little more GNU compliant.
* Fri Jul 30 1999 Ben Hochstedler <hochstrb@cs.rose-hulman.edu> 0.9-1
- Functionality added: backup scheme, default size, open display check
  in show_comics, put URLs in webpage if can't download.
- Fixed bugs in command line processing (including inverting the
  functionality of -s)
- Updated many comics and added The Amazing Spiderman, Family
  Circus, Apartment 3-G, Between Friends, Boners Ark, Bringing Up
  Father, Buckles, Claire and Weber, Crock, Curtis, Dennis The Menace,
  Dinette Set, The Family Circus, Flash Gordon, and Free For All.
* Wed Jun 16 1999 Ben Hochstedler <hochstrb@cs.rose-hulman.edu> 0.8-1
- Added a new display script: show_comics.  Removed dependancies on perl 
  CPAN modules! Added support for specifying the program to use to fetch URLs.
  Added support for comic Stuff This, and made other various updates.
- For RPM spec: added BuildRoot
* Wed Jun 2 1999 Ben Hochstedler <hochstrb@cs.rose-hulman.edu> 0.7-1
- new comics: Bizzaro, Off The Mark, Today's Comic,
  For Dummies Cartoon of the Day, Curiosities, The Falling Dream, Laugh Seeds,
  Melonpool, Mr. Chuck Show, Ozy & Millie, Bruno the Bandit
- fixed command line options parsing bugs
- updated comics to reflect changes to websites
* Mon Apr 5 1999 Ben Hochstedler <hochstrb@cs.rose-hulman.edu> 0.6-1
- Added contrib/comics_update, updated post install info text
* Wed Mar 3 1999 Ben Hochstedler <hochstrb@cs.rose-hulman.edu> 0.5-1
- Added template as document & moved html files to doc directory
* Fri Feb 19 1999 Ben Hochstedler <hochstrb@cs.rose-hulman.edu> 0.4-1
- added dependency for perl-Image-Size, html templates & webpage creation HOWTO
* Wed Feb 17 1999 Ben Hochstedler <hochstrb@cs.rose-hulman.edu> 0.3-1
- fixed typo in the post-install message & added Howto file
* Tue Feb 16 1999 Ben Hochstedler <hochstrb@cs.rose-hulman.edu> 0.2-3
- added perl-HTML-Parser dependency
* Tue Feb 16 1999 Ben Hochstedler <hochstrb@cs.rose-hulman.edu> 0.2-2
- added manpage
* Mon Feb 15 1999 Ben Hochstedler <hochstrb@cs.rose-hulman.edu> 0.2-1
- added comiczone comics, and a CHANGES file
* Sun Feb 14 1999 Ben Hochstedler <hochstrb@cs.rose-hulman.edu> 0.1-1
- initial version

%prep
%setup -q

%build
make

%install
rm -rf $RPM_BUILD_ROOT

#To change where netcomics is placed, use something like this
#from the command line (not from within here unless you update all occurances
#of them inside this file.  That would be a waste of time, however, because
#that will automatically be done for you if you do this from the command line):
#   make PREFIX=/usr/local TMPBASE=/usr/local SYSRCDIR=/usr/local/etc \
#        PERL=/usr/local/bin/perl dist

make BUILDROOT=$RPM_BUILD_ROOT NOREMAKE=1 install

%clean
rm -rf $RPM_BUILD_ROOT

%preun
rm -f /var/spool/netcomics/*

%post
cat <<END
FYI:
* The external command now supports macros for referer, proxy, and
  url.  Please see the entry for -g in the manpage because you may want
  to adjust your setting of this option.
* Netcomics now has download avoidance and retry capabilities.  To
  retry downloading comics, you can simply rerun netcomics with the
  same options instead of using the command given on stdout at the end
  of the download sequence.  See the manpage for details on -q -a -R.
END

%files
%defattr(-,root,root)
%doc ChangeLog NEWS README TODO LICENSE-GPL doc/Modify_Webpage_Creation-HOWTO.html doc/netcomics.html doc/netcomics.lsm lib/template contrib/comics_update contrib/localtime contrib/local2gmtime contrib/mktime doc/Comic_Module-HOWTO.html doc/old_Comic_Module-HOWTO.html potd/astronomy
/usr/bin/netcomics
/usr/bin/show_comics
%attr(-,root,man) /usr/man/man1/netcomics.1
%attr(-,root,man) /usr/man/man1/show_comics.1
%config /usr/bin/display_comics
%attr(-,root,users) %dir /var/spool/netcomics
%attr(-,root,users) %dir /usr/share/netcomics

%files data
%defattr(-,root,root)
/usr/share/netcomics
