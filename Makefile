APPNAME	= netcomics
AP2NAME	= display_comics
AP3NAME = show_comics

MODULE1 = MyResponse.pm
MODULE2 = MyRequest.pm
MODULE3 = ExternalUserAgent.pm
MODULE4 = RLI.pm

RCFILE	= netcomicsrc
VERSION	= 0.14
PKGVERSION = 1

#The 4 most commonly changed paths.  All occurrances of these in the
#scripts, documentation, and the RPM spec will be changed if you set
#these to something different
PERL	= /usr/bin/perl
PERLTK	= $(PERL)
BUILDROOT = 
PREFIX	= $(BUILDROOT)/usr
TMPBASE	= $(BUILDROOT)/var/spool
SYSRCDIR = $(BUIDLROOT)/etc
PERLLIBROOT = $(BUILDROOT)/usr/lib/perl5
PERLINSTDIR = $(PERLLIBROOT)/site_perl/Netcomics
TMPBUILDDIR = $(BUIDLROOT)/tmp/$(APPNAME)

RM	= rm -f
FIND	= find
MKDIR	= mkdir -p
CD      = cd
POD2MAN = pod2man --center="Web Utilities" --release="netcomics-$(VERSION)"
POD2HTML= pod2html
INSTALL	= install
ETAGS	= etags
CVS	= cvs
CHOWN	= chown
LN	= ln
CHMOD	= chmod
MV	= mv
CP	= cp
RMDIR	= rm -rf

LIBPERMS = 644
BININSTALLFLAGS	= -m 755
LIBINSTALLFLAGS	= -m $(LIBPERMS)

BINDIR  = $(PREFIX)/bin
MANROOT	= $(PREFIX)/man
LIBBASE	= $(PREFIX)/share
LIBDIR	= $(LIBBASE)/$(APPNAME)
MKDIRFLAGS	= -m 755
TMPDIR	= $(TMPBASE)/$(APPNAME)
TMPMKDIRFLAGS	= -m 777
HTMLTMPLDIR = html_tmpl
HTMLDIR	= $(LIBDIR)/$(HTMLTMPLDIR)
MANDIR1	= $(MANROOT)/man1

BZIP2	= bzip2
GZIP	= gzip
TAR	= tar
TARFILES= "ls -d $(APPNAME)-$(VERSION)/* | \
	$(PERL) -pe 's/.*(lost\+found|dist).*//gm'"
RPM	= rpm
RPMBUILDFLAGS	= -ba

SRCDIR	= /usr/src
RHDIR	= $(SRCDIR)/redhat
RHSPECS	= $(RHDIR)/SPECS
RHSRCS	= $(RHDIR)/SOURCES
RHRPMS	= $(RHDIR)/RPMS
RPMSPEC	= $(APPNAME).spec
RPMFILE	= $(APPNAME)-$(VERSION)-$(PKGVERSION).noarch.rpm
DEBFILE	= $(APPNAME)_$(VERSION)-$(PKGVERSION)_all.deb
DEBFILELINK	= $(APPNAME)-$(VERSION)-$(PKGVERSION)_all.deb
TARBZ2FILE	= $(APPNAME)-$(VERSION).tar.bz2
TARGZFILE	= $(APPNAME)-$(VERSION).tar.gz

MODULES = lib/after_y2k \
	lib/alice \
	lib/an \
	lib/angry_flower \
	lib/angst \
	lib/avalon \
	lib/bad_boys \
	lib/badlands \
	lib/bayside \
	lib/bigpanda \
	lib/boatanchor \
	lib/bruno \
	lib/callahan \
	lib/cartoonweb \
	lib/ccs \
	lib/chuck_show \
	lib/clan_cats \
	lib/comicspage \
	lib/comicspage_ed \
	lib/comiczone \
	lib/creators_syndicate \
	lib/curiosities \
	lib/doemain \
	lib/doodie \
	lib/doonesbury \
	lib/dork_tower \
	lib/down_earth \
	lib/dr_fun \
	lib/dysentery \
	lib/elf_life \
	lib/everythingjake \
	lib/exploitation \
	lib/falling_dream \
	lib/farcus \
	lib/fika \
	lib/forbez \
	lib/fordummies \
	lib/foxtrot \
	lib/frankandernest \
	lib/freefall \
	lib/gaming_u \
	lib/gilthorp \
	lib/gpf \
	lib/greystoneinn \
	lib/greytown \
	lib/helen \
	lib/helpdesk \
	lib/janesworld \
	lib/jerkcity \
	lib/joyoftech \
	lib/k_chronicles \
	lib/keenspace \
	lib/kevin-n-kell \
	lib/kingfeatures \
	lib/laughseeds \
	lib/lcd \
	lib/lily_wong \
	lib/lostfound \
	lib/madam-n-eve \
	lib/megatokyo \
	lib/melonpool \
	lib/mercury \
	lib/mom \
	lib/nando \
	lib/newshounds \
	lib/norm \
	lib/nukees \
	lib/offthemark \
	lib/ozy_millie \
	lib/penny_arcade \
	lib/psmueller \
	lib/pvp \
	lib/reallife \
	lib/red_meat \
	lib/road_waffles \
	lib/rocky \
	lib/roommates \
	lib/sempai \
	lib/soaprope \
	lib/sourcewars \
	lib/shermans_lagoon \
	lib/shoe \
	lib/sinfest \
	lib/sluggy_freelance \
	lib/small_grey \
	lib/small_world \
	lib/spaz_labs \
	lib/spex \
	lib/spooner \
	lib/story_minute \
	lib/stuff_this \
	lib/suburban \
	lib/superosity \
	lib/this_modern_world \
	lib/tom_the_dancing_bug \
	lib/toonville \
	lib/touche \
	lib/toytrunk \
	lib/triangle_robert \
	lib/tucson \
	lib/ucomics \
	lib/unitedmedia \
	lib/user_friendly \
	lib/wait_bob \
	lib/wandering \
	lib/wfc \
	lib/whenigrowup \
	lib/wiley \
	lib/youdamn \

OLDMODULES = \
	banditbruno \
	bastich \
	bobbins \
	boxjam \
	calvin-n-hobbes \
	ctoons \
	dilbert \
	fatjesus \
	fce \
	garfield \
	glasbergen \
	goats \
	heaven_and_earth \
	rogues \
	roomies \
	sketch \
	uexpress \
	worldviews \

PERLMODULES = \
	Config.pm \
	ExternalUserAgent.pm \
	Factory.pm \
	HTML.pm \
	MyResponse.pm \
	MyRequest.pm \
	RLI.pm \
	Util.pm \

HTMLTEMPLATES = \
	head.html tail.html links.html links_index.html index_body_el.html\
	body_el1.html body_el2.html body_el3.html body_el4.html\
	body_el5.html body_el6.html body_el7.html body_el8.html

DEBFILES = changelog conffiles control copyright cron.daily dirs docs rules

ALLFILES = Makefile README LICENSE-GPL ChangeLog INSTALL NEWS $(RPMSPEC) \
	$(APPNAME) $(AP2NAME) $(AP3NAME) doc/old_Comic_Module-HOWTO.html \
	doc/netcomics.lsm doc/Modify_Webpage_Creation-HOWTO.html \
	doc/Comic_Module-HOWTO.html contrib/comics_update $(MODULES) \
	$(HTMLTEMPLATES:%=$(HTMLTMPLDIR)/%) $(PERLMODULES:%=Netcomics/%) \
	$(DEBFILES:%=debian/%)

#specify the following on the command line so that you can force
#installation under a different prefix without it remaking everything
NOREMAKE = 0

all: remake_check bin doc etc modules

#check to see if anything has changed, and have it remade if so.
#no worries if using clearmake
remake_check:
	@if ( ( [ $(PREFIX) != /usr ] || \
		[ $(PERL) != /usr/bin/perl ] || \
		[ $(PERLTK) != /usr/bin/perl ] || \
		[ $(BINDIR) != /usr/bin ] || \
		[ $(LIBBASE) != /usr/share ] || \
		[ $(LIBDIR) != /usr/share/netcomics ] || \
		[ $(TMPDIR) != /var/spool/netcomics ] || \
		[ $(HTMLDIR) != /usr/share/netcomics/$(HTMLTMPLDIR) ] || \
		[ $(APPNAME) != netcomics ] \
	      ) && ( [ $(NOREMAKE) != 1 ] && [ $(MAKE) != clearmake ] ) ); then\
		echo "Having documentation & scripts reproduced in doc & bin.";\
		$(MAKE) distclean; \
	fi

#Use this macro for creating any template file.
SUBPATHS = \
	echo "Generating $@ from $<"; \
	$(PERL) -pe s%/usr/bin%$(BINDIR)%gm $< \
	| $(PERL) -pe s%$(BINDIR)/perl%$(PERL)%gm \
	| $(PERL) -pe s%/var/spool/netcomics%$(TMPDIR)%gm \
	| $(PERL) -pe s%/usr/share/netcomics/$(HTMLTMPLDIR)%$(HTMLDIR)%gm \
	| $(PERL) -pe s%/usr/share/netcomics%$(LIBDIR)%gm \
	| $(PERL) -pe s%netcomics%$(APPNAME)%gm \
	| $(PERL) -pe s%/etc%$(SYSRCDIR)%gm \
	| $(PERL) -pe "s/\@OLDMODULES\@/$(OLDMODULES)/gm" \
	| $(PERL) -pe "s/\@VERSION\@/$(VERSION)/gm" \
	| $(PERL) -pe "s/\@PKGVERSION\@/$(PKGVERSION)/gm" \
	> $@


distclean:: clean

#emacs produced backup files
clean::
	$(FIND) . \( -name "*~" -o -name ".#*" \) -exec $(RM) {} \;
	rm *-stamp -f

#Application targets & their associated phony targets
install:: all
	$(MKDIR) $(TMPMKDIRFLAGS) $(TMPDIR)
	$(MKDIR) $(MKDIRFLAGS) $(BINDIR)
	$(INSTALL) $(BININSTALLFLAGS) bin/$(APPNAME) $(BINDIR)/$(APPNAME)
	$(INSTALL) $(BININSTALLFLAGS) bin/$(AP2NAME) $(BINDIR)/$(AP2NAME)
	$(INSTALL) $(BININSTALLFLAGS) bin/$(AP3NAME) $(BINDIR)/$(AP3NAME)

bin/$(AP2NAME): $(AP2NAME)
	@$(SUBPATHS)

bin/$(AP3NAME): $(AP3NAME)
	@$(SUBPATHS)

bin:: bin/$(AP2NAME) bin/$(AP3NAME)

distclean::
	$(RM) bin/$(AP2NAME)
	$(RM) bin/$(AP3NAME)

bin/$(APPNAME): $(APPNAME)
	@$(SUBPATHS)

bin:: bin/$(APPNAME)

distclean::
	$(RM) bin/$(APPNAME)
	$(RM) debian/netcomics -R
	$(RM) debian/netcomics-modules -R
	$(RM) debian/tmp -R
	$(RM) debian/files debian/*.debhelper debian/substvars
	$(RM) debian/*.1

etc/$(RCFILE): $(RCFILE)
	@$(SUBPATHS)

etc:: etc/$(RCFILE)

install::
	$(MKDIR) $(MKDIRFLAGS) $(BUILDROOT)/$(SYSRCDIR)
	$(INSTALL) $(LIBINSTALLFLAGS) etc/$(RCFILE) $(BUILDROOT)/$(SYSRCDIR)/$(RCFILE)

distclean::
	$(RM) etc/$(RCFILE)

#TAGS for use in emacs
TAGS: $(APPNAME) $(AP2NAME) $(AP3NAME)
	$(ETAGS) $(APPNAME) $(AP2NAME) $(AP3NAME)

devel:: TAGS

distclean::
	$(RM) TAGS


#Documentation targets & their associated phony targets

POD2MANRULES = \
	$(RM) $@; \
	$(SUBPATHS); \
	$(MKDIR) $(TMPBUILDDIR)/doc; \
	$(CP) $@ $(TMPBUILDDIR)/$<; \
	$(RM) $@; \
	echo "$(POD2MAN) --section=$$section $< > $@"; \
	$(POD2MAN) --section=$$section $(TMPBUILDDIR)/$< > $@; \
	$(RM) $(TMPBUILDDIR)/$<; \
	$(RMDIR) $(TMPBUILDDIR)/doc $(TMPBUILDDIR);

POD2HTMLRULES = \
	$(RM) $@; \
	$(SUBPATHS); \
	$(MKDIR) $(TMPBUILDDIR)/doc; \
	$(CP) $@ $(TMPBUILDDIR)/$<; \
	$(RM) $@; \
	echo "$(POD2HTML) $< > $@"; \
	$(POD2HTML) $(TMPBUILDDIR)/$< > $@; \
	$(RM) pod2html-itemcache pod2html-dircache $(TMPBUILDDIR)/$<; \
	$(RMDIR) $(TMPBUILDDIR)/doc $(TMPBUILDDIR);

%.1: %.pod
	@section=1; $(POD2MANRULES)

distclean::
	$(RM) doc/$(APPNAME).1
	$(RM) doc/$(AP3NAME).1

install::
	$(MKDIR) $(MKDIRFLAGS) $(MANDIR1)
	$(INSTALL) $(LIBINSTALLFLAGS) doc/$(APPNAME).1 $(MANDIR1)
	$(INSTALL) $(LIBINSTALLFLAGS) doc/$(AP3NAME).1 $(MANDIR1)

doc:: doc/$(APPNAME).1

doc:: doc/$(AP3NAME).1

%.html: %.pod
	@$(POD2HTMLRULES)

distclean::
	$(RM) doc/$(APPNAME).html
	$(RM) doc/$(AP3NAME).html

clean::
	$(RM) pod2html-*cache

doc::	doc/$(APPNAME).html

doc::	doc/$(AP3NAME).html

install:: install_mods install_html install_pms

install_mods:
	$(MKDIR) $(MKDIRFLAGS) $(LIBDIR)
	$(INSTALL) $(LIBINSTALLFLAGS) $(MODULES) $(LIBDIR);

install_html:
	$(MKDIR) $(MKDIRFLAGS) $(HTMLDIR)
	$(CD) $(HTMLTMPLDIR); \
	$(INSTALL) $(LIBINSTALLFLAGS) $(HTMLTEMPLATES) $(HTMLDIR)

install_pms: $(PERLMODULES:%=Netcomics/%)
	$(MKDIR) $(MKDIRFLAGS) $(PERLINSTDIR)
	$(CD) Netcomics; \
	$(INSTALL) $(LIBINSTALLFLAGS) $(PERLMODULES) $(PERLINSTDIR)

Netcomics/Config.pm: Netcomics/Config.pm.in
	@$(SUBPATHS)

distclean::
	$(RM) Netcomics/Config.pm

modules:: Netcomics/Config.pm

install::
	@oldmods=""; \
	for file in $(OLDMODULES); do \
		if [ -f $(LIBDIR)/$$file ]; then \
			oldmods=$${oldmods}\ $$file; \
		fi; \
	done; \
	if test "x$$oldmods" != "x"; then \
		echo ""; \
		echo "Warning!  You have old modules that should be\
			deleted: $$oldmods."; \
		echo "Run the following commands to remove them:"; \
		echo "cd $(LIBDIR); $(RM) $$oldmods"; \
	fi

#Distribution targets
../$(TARBZ2FILE): $(ALLFILES)
	rm -f ../$(APPNAME)-$(VERSION)
	ln -s $(APPNAME) ../$(APPNAME)-$(VERSION)
	cd ..; $(TAR) cf - `eval $(TARFILES)` | $(BZIP2) > $(TARBZ2FILE)
	rm ../$(APPNAME)-$(VERSION)

../$(TARGZFILE): $(ALLFILES)
	rm -f ../$(APPNAME)-$(VERSION)
	ln -s $(APPNAME) ../$(APPNAME)-$(VERSION)
	cd ..; $(TAR) cf - `eval $(TARFILES)` | $(GZIP) > $(TARGZFILE)
	rm ../$(APPNAME)-$(VERSION)

#Make an RPM
$(RHSPECS)/$(RPMSPEC): $(RPMSPEC)
	@$(SUBPATHS)

$(RHSOURCES)/$(TARGZFILE): ../$(TARGZFILE)
	$(INSTALL) $(LIBINSTALLFLAGS) ../$(TARGZFILE) $(RHSRCS)

$(RHSOURCES)/$(TARBZ2FILE): ../$(TARBZ2FILE)
	$(INSTALL) $(LIBINSTALLFLAGS) ../$(TARBZ2FILE) $(RHSRCS)

$(RHRPMS)/noarch/$(RPMFILE): $(RHSPECS)/$(RPMSPEC) $(RHSOURCES)/$(TARBZ2FILE)
	cd $(RHSPECS); $(RPM) $(RPMBUILDFLAGS) $(RPMSPEC)

../$(DEBFILE): $(DEBFILES:%=debian/%) ../$(TARGZFILE)
	cd ..; \
	$(GZIP) -d -c $(TARGZFILE) | $(TAR) xvf - ; \
	cd $(APPNAME)-$(VERSION); \
	su -c "$(MAKE) -f debian/rules binary; \
	$(CHOWN) $$LOGNAME $@; \
	cd ..; \
	$(RM) -r $(APPNAME)-$(VERSION)"

#This link is made to remind you that you need to upload the file
#with this name to metalab.unc.edu, not the one the debian packager creates.
../$(DEBFILELINK): ../$(DEBFILE)
	@$(RM) $@
	$(LN) -s $(DEBFILE) $@

#Maintanence targets
preparchive: distclean all

archives: preparchive ../$(TARBZ2FILE) ../$(TARGZFILE)

rpm:	$(RHRPMS)/noarch/$(RPMFILE)

#deb:	../$(DEBFILE) ../$(DEBFILELINK)
deb:
	dpkg-buildpackage -rfakeroot

dist:	archives rpm
	@echo "Now do the following:"
	@echo "* check in any changes still pending"
	@echo "* make tag"
	@echo "* sign the packages."

tag: label
label:
	ver=`echo $(VERSION) | sed 's/\./_/g'`; \
	cd ..; $(CVS) tag V$$ver

install_local:
	$(MAKE) install PREFIX=/usr/local PERLLIBROOT=/usr/local/lib/perl5

install_home:
	$(MAKE) PREFIX=$(HOME) PERLLIBROOT=$(HOME)/lib \
		TMPDIR=$(HOME)/comics SYSRCDIR=$(HOME)/etc install 

install_for_ben:
	perl=`which perl`; tkperl=`which tkperl`; \
	$(MAKE) PREFIX=$(HOME) PERLLIBROOT=$(HOME)/lib \
		TMPDIR=$(HOME)/www/comics SYSRCDIR=$(HOME)/etc \
		PERL=$$perl PERLTK=$$tkperl install

.PHONY: all doc install clean distclean archives rpm dist install_for_ben \
devel bin deb install_html install_mods install_pms







