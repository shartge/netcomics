APPNAME	= netcomics
AP2NAME	= display_comics
AP3NAME = show_comics

MODULE1 = MyResponse.pm
MODULE2 = MyRequest.pm
MODULE3 = ExternalUserAgent.pm
MODULE4 = RLI.pm

RCFILE	= netcomicsrc
VERSION	= 0.13.1
PKGVERSION = 1

#The 4 most commonly changed paths.  All occurrances of these in the
#scripts, documentation, and the RPM spec will be changed if you set
#these to something different
PERL	= /usr/bin/perl
PERLSITE = /usr/lib/perl5
PERLTK	= $(PERL)
BUILDROOT = 
PREFIX	= $(BUILDROOT)/usr
TMPBASE	= $(BUILDROOT)/var/spool
SYSRCDIR = $(BUILDROOT)/etc

RM	= rm -f
FIND	= find
MKDIR	= mkdir -p
CD      = cd
POD2MAN = pod2man --center="Web Utilities" --release="netcomics-$(VERSION)"
POD2HTML= pod2html
INSTALL	= install
ETAGS	= etags
CT	= cleartool

BININSTALLFLAGS	= -m 755
LIBINSTALLFLAGS	= -m 644

BINDIR  = $(PREFIX)/bin
MANROOT	= $(PREFIX)/man
LIBBASE	= $(PREFIX)/share
LIBDIR	= $(LIBBASE)/$(APPNAME)
MKDIRFLAGS	= -m 755
TMPDIR	= $(TMPBASE)/$(APPNAME)
TMPMKDIRFLAGS	= -m 777
HTMLDIR	= $(LIBDIR)/html_tmpl
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
DEBFILE	= ../$(APPNAME)_$(VERSION)-$(PKGVERSION)_all.deb
TARBZ2FILE	= $(APPNAME)-$(VERSION).tar.bz2
TARGZFILE	= $(APPNAME)-$(VERSION).tar.gz


APPNAME	= netcomics
AP2NAME	= display_comics
AP3NAME = show_comics
RCFILE	= netcomicsrc
VERSION	= 0.13
PKGVERSION = 1

#The 4 most commonly changed paths.  All occurrances of these in the
#scripts, documentation, and the RPM spec will be changed if you set
#these to something different
PERL	= /usr/bin/perl
PERLTK	= $(PERL)
BUILDROOT =
PREFIX	= $(BUILDROOT)/usr
TMPBASE	= $(BUILDROOT)/var/spool
SYSRCDIR = $(BUILDROOT)/etc

RM	= rm -f
FIND	= find
MKDIR	= mkdir -p
CD      = cd
POD2MAN = pod2man --center="Web Utilities" --release="netcomics-$(VERSION)"
POD2HTML= pod2html
INSTALL	= install
ETAGS	= etags
CT	= cleartool

BININSTALLFLAGS	= -m 755
LIBINSTALLFLAGS	= -m 644

BINDIR  = $(PREFIX)/bin
MANROOT	= $(PREFIX)/man
LIBBASE	= $(PREFIX)/share
LIBDIR	= $(LIBBASE)/$(APPNAME)
MKDIRFLAGS	= -m 755
TMPDIR	= $(TMPBASE)/$(APPNAME)
TMPMKDIRFLAGS	= -m 777
HTMLDIR	= $(LIBDIR)/html_tmpl
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
DEBFILE	= ../$(APPNAME)_$(VERSION)-$(PKGVERSION)_all.deb
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
	lib/bastich \
	lib/bayside \
	lib/bigpanda \
	lib/boatanchor \
	lib/boxjam \
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
	lib/fatjesus \
	lib/fce \
	lib/fika \
	lib/fordummies \
	lib/foxtrot \
	lib/frankandernest \
	lib/gaming_u \
	lib/garfield \
	lib/gilthorp \
	lib/gpf \
	lib/greystoneinn \
	lib/greytown \
	lib/heaven_and_earth \
	lib/helen \
	lib/janesworld \
	lib/jerkcity \
	lib/k_chronicles \
	lib/kevin-n-kell \
	lib/kingfeatures \
	lib/laughseeds \
	lib/lcd \
	lib/lily_wong \
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
	lib/rogues \
	lib/roommates \
	lib/sempai \
	lib/soaprope \
	lib/sourcewars \
	lib/shermans_lagoon \
	lib/shoe \
	lib/sinfest \
	lib/sketch \
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
	lib/youdamn

OLDMODULES = \
	banditbruno \
	bobbins \
	calvin-n-hobbes \
	ctoons \
	dilbert \
	glasbergen \
	goats \
	roomies \
	uexpress \
	worldviews 

PROGRAMMODULES = \
	Netcomics/MyResponse.pm \
	Netcomics/MyRequest.pm \
	Netcomics/ExternalUserAgent.pm \
	Netcomics/RLI.pm 

HTMLTEMPLATES = \
	head.html tail.html links.html links_index.html index_body_el.html\
	body_el1.html body_el2.html body_el3.html body_el4.html\
	body_el5.html body_el6.html body_el7.html body_el8.html

ALLFILES = Makefile README LICENSE-GPL ChangeLog INSTALL NEWS $(RPMSPEC) \
	$(APPNAME) $(AP2NAME) $(AP3NAME) doc/old_Comic_Module-HOWTO.html \
	doc/netcomics.lsm doc/Modify_Webpage_Creation-HOWTO.html \
	doc/Comic_Module-HOWTO.html contrib/comics_update $(MODULES)

#specify the following on the command line so that you can force
#installation under a different prefix without it remaking everything
NOREMAKE = 0

all: remake_check bin doc etc

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
		[ $(HTMLDIR) != /usr/share/netcomics/html_tmpl ] || \
		[ $(APPNAME) != netcomics ] \
	      ) && ( [ $(NOREMAKE) != 1 ] && [ $(MAKE) != clearmake ] ) ); then\
		echo "Having documentation & scripts reproduced in doc & bin.";\
		$(RM) bin/$(APPNAME) bin/$(AP2NAME) bin/$(AP3NAME) \
			doc/$(APPNAME).pod doc/$(AP3NAME).pod; \
	fi

distclean:: clean

#emacs produced backup files
clean::
	$(FIND) . \( -name "*~" -o -name ".#*" \) -exec $(RM) {} \;

#Application targets & their associated phony targets
install:: all
	$(MKDIR) $(TMPMKDIRFLAGS) $(TMPDIR)
	$(MKDIR) $(MKDIRFLAGS) $(BINDIR)
	$(MKDIR) $(PERLSITE)/Netcomics
	$(INSTALL) $(BININSTALLFLAGS) bin/$(APPNAME) $(BINDIR)/$(APPNAME)
	$(INSTALL) $(BININSTALLFLAGS) bin/$(AP2NAME) $(BINDIR)/$(AP2NAME)
	$(INSTALL) $(BININSTALLFLAGS) bin/$(AP3NAME) $(BINDIR)/$(AP3NAME)
	$(INSTALL) $(LIBINSTALLFLAGS) Netcomics/$(MODULE1) $(PERLSITE)/Netcomics/$(MODULE1)
	$(INSTALL) $(LIBINSTALLFLAGS) Netcomics/$(MODULE2) $(PERLSITE)/Netcomics/$(MODULE2)
	$(INSTALL) $(LIBINSTALLFLAGS) Netcomics/$(MODULE3) $(PERLSITE)/Netcomics/$(MODULE3)
	$(INSTALL) $(LIBINSTALLFLAGS) Netcomics/$(MODULE4) $(PERLSITE)/Netcomics/$(MODULE4)
	
bin/$(AP2NAME): $(AP2NAME)
	$(PERL) -pe s%/usr/bin/perl%$(PERL)%gm $(AP2NAME) \
	| $(PERL) -pe s%/var/spool/netcomics%$(TMPDIR)%gm > $@

bin/$(AP3NAME): $(AP3NAME)
	$(PERL) -pe s%/usr/bin/perl%$(PERLTK)%gm $(AP3NAME) \
	| $(PERL) -pe s%/var/spool/netcomics%$(TMPDIR)%gm > $@

bin:: bin/$(AP2NAME) bin/$(AP3NAME)

distclean::
	$(RM) bin/$(AP2NAME)
	$(RM) bin/$(AP3NAME)

bin/$(APPNAME): Makefile $(APPNAME)
	$(PERL) -pe s%/usr/bin%$(BINDIR)%gm $(APPNAME) \
	| $(PERL) -pe s%$(BINDIR)/perl%$(PERL)%gm \
	| $(PERL) -pe s%/var/spool/netcomics%$(TMPDIR)%gm \
	| $(PERL) -pe s%/usr/share/netcomics/html_tmpl%$(HTMLDIR)%gm \
	| $(PERL) -pe s%/usr/share/netcomics%$(LIBDIR)%gm \
	| $(PERL) -pe s%netcomics%$(APPNAME)%gm \
	| $(PERL) -pe s%/etc%$(SYSRCDIR)%gm > bin/$(APPNAME)

bin:: bin/$(APPNAME)

distclean::
	$(RM) bin/$(APPNAME)

etc/$(RCFILE): Makefile $(RCFILE)
	$(PERL) -pe s%/usr/bin%$(BINDIR)%gm $(RCFILE) \
	| $(PERL) -pe s%$(BINDIR)/perl%$(PERL)%gm \
	| $(PERL) -pe s%/var/spool/netcomics%$(TMPDIR)%gm \
	| $(PERL) -pe s%/usr/share/netcomics/html_tmpl%$(HTMLDIR)%gm \
	| $(PERL) -pe s%/usr/share/netcomics%$(LIBDIR)%gm \
	| $(PERL) -pe s%netcomics%$(APPNAME)%gm \
	| $(PERL) -pe s%/etc%$(SYSRCDIR)%gm > etc/$(RCFILE)

etc:: etc/$(RCFILE)

install::
	$(MKDIR) $(MKDIRFLAGS) $(SYSRCDIR)
	$(INSTALL) $(LIBINSTALLFLAGS) etc/$(RCFILE) $(SYSRCDIR)/$(RCFILE)

distclean::
	$(RM) etc/$(RCFILE)

#TAGS for use in emacs
TAGS: $(APPNAME) $(AP2NAME) $(AP3NAME)
	$(ETAGS) $(APPNAME) $(AP2NAME) $(AP3NAME)

devel:: TAGS

distclean::
	$(RM) TAGS


#Documentation targets & their associated phony targets
doc/$(APPNAME).pod: bin/$(APPNAME)
	@echo Extracting pod text from $?
	@cat $? \
	| perl -ne \
	'$$p += /^=head/; \
		$$p = 0 if /^=cut/; \
		print($$_) if $$p;' \
	> $@

doc/$(AP3NAME).pod: bin/$(AP3NAME)
	@echo Extracting pod text from $?
	@cat $? \
	| perl -ne \
	'$$p += /^=head/; \
		$$p = 0 if /^=cut/; \
		print($$_) if $$p;' \
	> $@

distclean::
	$(RM) doc/$(APPNAME).pod
	$(RM) doc/$(AP3NAME).pod

doc/$(APPNAME).1: doc/$(APPNAME).pod
	@$(RM) $@
	@$(CD) doc;\
	echo "$(POD2MAN) --section=1 $(APPNAME).pod > $(APPNAME).1";\
	$(POD2MAN) --section=1 $(APPNAME).pod > $(APPNAME).1

doc/$(AP3NAME).1: doc/$(AP3NAME).pod
	@$(RM) $@
	@$(CD) doc;\
	echo "$(POD2MAN) --section=1 $(AP3NAME).pod > $(AP3NAME).1";\
	$(POD2MAN) --section=1 $(AP3NAME).pod > $(AP3NAME).1

distclean::
	$(RM) doc/$(APPNAME).1
	$(RM) doc/$(AP3NAME).1

install::
	$(MKDIR) $(MKDIRFLAGS) $(MANDIR1)
	$(INSTALL) $(LIBINSTALLFLAGS) doc/$(APPNAME).1 $(MANDIR1)
	$(INSTALL) $(LIBINSTALLFLAGS) doc/$(AP3NAME).1 $(MANDIR1)

doc:: doc/$(APPNAME).1

doc:: doc/$(AP3NAME).1

doc/$(APPNAME).html: doc/$(APPNAME).pod
	@$(RM) $@
	$(POD2HTML) $? > $@
	$(RM) pod2html-itemcache pod2html-dircache

doc/$(AP3NAME).html: doc/$(AP3NAME).pod
	@$(RM) $@
	$(POD2HTML) $? > $@
	$(RM) pod2html-itemcache pod2html-dircache

distclean::
	$(RM) doc/$(APPNAME).html
	$(RM) doc/$(AP3NAME).html

clean::
	$(RM) pod2html-*cache

doc::	doc/$(APPNAME).html

doc::	doc/$(AP3NAME).html

install:: install_mods install_html


install_mods:
	$(MKDIR) $(MKDIRFLAGS) $(LIBDIR)
	$(INSTALL) $(LIBINSTALLFLAGS) $(MODULES) $(LIBDIR);

install_html:
	$(MKDIR) $(MKDIRFLAGS) $(HTMLDIR)
	cd html_tmpl; \
	$(INSTALL) $(LIBINSTALLFLAGS) $(HTMLTEMPLATES) $(HTMLDIR)

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
$(RHSPECS)/$(RPMSPEC): Makefile $(RPMSPEC)
	$(PERL) -pe s%/usr/bin%$(BINDIR)%gm $(RPMSPEC) \
	| $(PERL) -pe s%$(BINDIR)/perl%$(PERL)%gm \
	| $(PERL) -pe s%/var/spool/netcomics%$(TMPDIR)%gm \
	| $(PERL) -pe s%/usr/share/netcomics%$(LIBDIR)%gm \
	| $(PERL) -pe s%/usr/man%$(MANROOT)%gm \
	| $(PERL) -pe s%netcomics%$(APPNAME)%gm > $(RHSPECS)/$(RPMSPEC)

$(RHSOURCES)/$(TARGZFILE): ../$(TARGZFILE)
	$(INSTALL) $(LIBINSTALLFLAGS) ../$(TARGZFILE) $(RHSRCS)

$(RHSOURCES)/$(TARBZ2FILE): ../$(TARBZ2FILE)
	$(INSTALL) $(LIBINSTALLFLAGS) ../$(TARBZ2FILE) $(RHSRCS)

$(RHRPMS)/noarch/$(RPMFILE): $(RHSPECS)/$(RPMSPEC) $(RHSOURCES)/$(TARBZ2FILE)
	cd $(RHSPECS); $(RPM) $(RPMBUILDFLAGS) $(RPMSPEC)

$(DEBFILE): debian/rules ../$(TARGZFILE)
	cd ..; \
	$(GZIP) -d -c $(TARGZFILE) | $(TAR) xvf - ; \
	cd $(APPNAME)-$(VERSION); \
	$(MAKE) -f debian/rules binary; \
	cd ..; \
	$(RM) -r $(APPNAME)-$(VERSION)

#Maintanence targets
preparchive: distclean all
	$(RM) .cmake.state

archives: preparchive ../$(TARBZ2FILE) ../$(TARGZFILE)

rpm:	$(RHRPMS)/noarch/$(RPMFILE)

deb:	$(DEBFILE)

dist:	archives rpm deb
	echo "Don't forget to clearmake label when you're done."

label:
	$(CT) mklbtype -nc V$(VERSION)
	$(CT) mklabel -recurse V$(VERSION) .

install_local:
	$(MAKE) install PREFIX=/usr/local

install_home:
	$(MAKE) install PREFIX=$(HOME) \
		TMPDIR=$(HOME)/comics SYSRCDIR=$(HOME)/etc

install_for_ben:
	@perl=`which perl`; tkperl=`which tkperl`; \
	$(MAKE) install PREFIX=$(HOME) \
		TMPDIR=$(HOME)/www/comics PERL=$$perl \
		PERLTK=$$tkperl SYSRCDIR=$(HOME)/etc

.PHONY: all doc install clean distclean archives rpm dist install_for_ben \
devel bin deb install_html install_mods
