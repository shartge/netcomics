#!/usr/bin/perl -w
#
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

use ExtUtils::MakeMaker;
use strict;

my @pl_with_pod = qw(
netcomics
comicpage
show_comics
);

my @pl_to_install = (@pl_with_pod, "display_comics");

my @pm_to_install = qw(
Config.pm
ExternalUserAgent.pm
Factory.pm
GtkComics.pm
HTML.pm
HTML/Page.pm
HTML/Set.pm
HTML/Themes/Default.pm
MyRequest.pm
MyResponse.pm
Util.pm
RLI.pm
);

my @pm_with_pod = qw(
Config
);

my @glade_files = qw(
Comicpage/comicpage.glade
);

my @html_templates = qw(
);

my @etc_files = qw(
netcomicsrc
);

my @modules = qw(
after_y2k
an
angry_flower
bad_boys
badlands
bruno
callahan
cartoonweb
comicspage
comicspage_ed
comiczone
creators_syndicate
curiosities
doemain
doodie
doonesbury
dork_tower
down_earth
dragon
dr_fun
dysentery
fairgame
falling_dream
farcus
fika
frankandernest
freefall
gaming_u
gilthorp
helen
inktank
jerkcity
joyoftech
k_chronicles
keenspace
keenspot
kevin-n-kell
kingfeatures
laughseeds
lcd
lily_wong
littlegamers
madam-n-eve
megatokyo
mercury
mom
mrlowe
nando
newshounds
norm
offthemark
penny_arcade
pvp
red_meat
rocky
sempai
sourcewars
shermans_lagoon
shoe
sluggy_freelance
small_grey
small_world
spaz_labs
spex
spooner
story_minute
stuff_this
this_modern_world
toonville
touche
toytrunk
triangle_robert
tucson
ucomics
unitedmedia
user_friendly
wait_bob
wfc
);

my @old_modules = qw(
alice
angst
avalon
banditbruno
bastich
bayside
bigpanda
boatanchor
bobbins
boxjam
calvin-n-hobbes
ccs
clan_cats
chuck_show
ctoons
dilbert
elf_life
everythingjake
exploitation
fatjesus
fce
forbez
fordummies
foxtrot
garfield
glasbergen
goats
gpf
greystoneinn
greytown
heaven_and_earth
helpdesk
janesworld
lostfound
melonpool
nukees
ozy_millie
psmueller
reallife
road_waffles
rogues
roomies
roommates
sinfest
sketch
soaprope
suburban
superosity
tom_the_dancing_bug
uexpress
wandering
whenigrowup
wiley
worldviews
youdamn
);

package MY;

# Determine things that should *not* be installed
sub libscan {
    my($self, $path) = @_;
    return '' if $path =~ m/.in$/;
    return '' if $path =~ m:\bCVS/:;
    return '' if $path =~ m/~$/;
    return '' if $path =~ m/.cvsignore$/;
    $path;
}

# Pass section & version number to pod2man
sub manifypods {
    my $self = shift;
    my $ver = $self->{VERSION} || "";
    local($_) = $self->SUPER::manifypods(@_);
    s/pod2man\s*$/pod2man --center="Web Utilities" --release="netcomics-$ver\/m"/;
    $_;
}

#make it so installed directly under site_lib.
sub constants {
    my $self = shift;
    local($_) = $self->SUPER::constants(@_);

	#Before perl 5.005_03, $(PREFIX) isn't included in the installman*dirs,
	#forcing you to set their values on the make command line when you
	#simply want to change PREFIX.
	if (/^PREFIX\s*=\s*(.*)/m) {
		#Only replace if we successfully find PREFIX first.
		my $prefix = $1;
		my $replace_prefix = '$(PREFIX)';
		s/^(INSTALL\w+\s*=\s*)$prefix/$1$replace_prefix/gm;
	} else {
		print STDERR "Warning: couldn't find PREFIX defined in constants.\n";
	}

	#The following would force installation under site_perl itself and
	#not under a subdir of it named with perl's version.  However,
	#instead of forcing the change here, installsitelib is changed in
	#netcomics.spec & debian/*.  The INSTALL file describes how to
	#do it on the make commandline, too.
    #s/^(INSTALLSITELIB.*site_perl).*/$1/m;

    $_;
}

sub macro {
	my $self = shift;
	return "
TO_INST_PL = @pl_to_install

MODULES = @modules

OLDMODULES = @old_modules

" . '
RCFILE = netcomicsrc
PKGVERSION = 1cvs

#install paths
TMPBASE	= /var/spool
TMPDIR	= $(TMPBASE)/$(NAME)
MY_INST_SUBDIR = Netcomics
MOD_INST_DIR = $(MY_INST_SUBDIR)/Comic
ETC_INST_DIR = $(MY_INST_SUBDIR)/etc
HTML_INST_DIR = $(MY_INST_SUBDIR)/HTML/Themes

POD2HTML= pod2html
ETAGS	= etags
CVS	= cvs
BZIP2 = bzip2
GZIP = $(COMPRESS)
CHOWN = chown
RPM = rpm
RPMBUILDFLAGS = -ba
SRCDIR	= /usr/src
RHDIR	= $(SRCDIR)/redhat
RHSPECS	= $(RHDIR)/SPECS
RHSRCS	= $(RHDIR)/SOURCES
RHRPMS	= $(RHDIR)/RPMS
RPMSPEC	= $(NAME).spec
RPMFILE	= $(DISTVNAME)-$(PKGVERSION).noarch.rpm
DEBFILE	= $(DISTVNAME)_$(PKGVERSION)_all.deb
DEBFILELINK	= $(DISTVNAME)-$(PKGVERSION)_all.deb
TARBZ2FILE	= ../$(DISTVNAME).tar.bz2
TARGZFILE	= ../$(DISTVNAME).tar$(SUFFIX)
ZIPFILE 	= ../$(DISTVNAME).zip

#Use this macro for creating any template file.
SUBPATHS = \
	echo "Generating $@ from $<"; \
	$(PERL) -pe s%/usr/bin%$(INSTALLBIN)%gm $< \
	| $(PERL) -pe s%$(INSTALLBIN)/perl%$(PERL)%gm \
	| $(PERL) -pe s%/var/spool/netcomics%$(TMPDIR)%gm \
	| $(PERL) -pe s%/usr/lib/perl5/site_perl%$(INSTALLSITELIB)%gm \
	| $(PERL) -pe s%/usr/share/perl5/Netcomics/HTML/Themes%$(INSTALLSITELIB)/$(HTML_INST_DIR)%gm \
    | $(PERL) -pe s%/usr/share/perl5/Netcomics/Comicpage%$(INSTALLSITELIB)/Netcomics/Comicpage%gm \
	| $(PERL) -pe s%/usr/share/perl5/Netcomics/Comic%$(INSTALLSITELIB)/$(MOD_INST_DIR)%gm \
	| $(PERL) -pe s%netcomics%$(NAME)%gm \
	| $(PERL) -pe s%/usr/share/perl5/Netcomics/etc%$(INSTALLSITELIB)/$(ETC_INST_DIR)%gm \
	| $(PERL) -pe "s/\@OLDMODULES\@/$(OLDMODULES)/gm" \
	| $(PERL) -pe "s/\@VERSION\@/$(VERSION)/gm" \
	| $(PERL) -pe "s/\@PKGVERSION\@/$(PKGVERSION)/gm" \
	> $@

POD2HTMLRULES = cd doc; $(POD2HTML) --infile=../$< --outfile=../$@

clean::
	cd doc; $(RM_F) pod2html-itemcache pod2html-dircache

MODPODRULES = \
	echo Extracting pod text from $?; \
	cat $? \
	| perl -ne \
	\'$$p += /^=head/; \
		$$p = 0 if /^=cut/; \
		print($$_) if $$p;\' \
	> $@

';
}

sub post_constants {
	my $self = shift;
	my $gentext = "";
	foreach (@pm_with_pod) {
	  $gentext .= "doc/$_.pod: Netcomics/$_.pm\n\t" .
		  '@$(MODPODRULES)' . "\n\n";
	}
	return $gentext . '
TAGS: $(TO_INST_PM) $(TO_INST_PL) $(MODULES)
	$(ETAGS) $(TO_INST_PM) $(TO_INST_PL) $(MODULES)

devel::TAGS

clean::
	$(RM_F) TAGS

all:: $(TO_INST_PL:%=bin/%)

bin/%: %
	@$(MKPATH) bin
	@$(SUBPATHS)

clean::
	$(RM_F) $(TO_INST_PL:%=bin/%)

#The pod extension is removed so that it does not show up in the manpage header
doc/%: doc/%.pod
	@$(SUBPATHS)

all:: $(MAN1PODS:%=%.html) $(MAN3PODS:Netcomics/%.pm=doc/%.html)

doc/%.html: doc/%
	$(POD2HTMLRULES) --title="Netcomics: $(<:doc/%=%)"

clean::
	$(RM_F) pod2html-*cache \
		$(MAN1PODS:%=%.html) $(MAN1PODS) \
		$(MAN3PODS:Netcomics/%.pm=doc/%.pod) \
		$(MAN3PODS:Netcomics/%.pm=doc/%) \
		$(MAN3PODS:Netcomics/%.pm=doc/%.html)

#create the spool directory
install::
	@$(MKPATH) $(TMPDIR)

#generate the Config perl module with the install paths used.
Netcomics/Config.pm: Netcomics/Config.pm.in
	@$(SUBPATHS)

clean::
	$(RM_F) Netcomics/Config.pm

#Check for old modules.
install::
	@oldmods=""; \
	for file in $(OLDMODULES); do \
		if [ -f $(INSTALLSITELIB)/$(MOD_INST_DIR)/$$file ]; then \
			oldmods=$${oldmods}\ $$file; \
		fi; \
	done; \
	if test "x$$oldmods" != "x"; then \
		echo ""; \
		echo "Warning!  You have old modules that should be\
			deleted: $$oldmods."; \
		echo "Run the following commands to remove them:"; \
		echo "cd $(INSTALLSITELIB)/$(MOD_INST_DIR); $(RM_F) $$oldmods"; \
	fi

bz2dist: $(DISTVNAME).tar.bz2

$(DISTVNAME).tar.bz2 : distdir
	$(PREOP)
	$(TO_UNIX)
	$(TAR) $(TARFLAGS) $(DISTVNAME).tar $(DISTVNAME)
	$(RM_RF) $(DISTVNAME)
	$(BZIP2) $(DISTVNAME).tar
	$(POSTOP)

$(TARBZ2FILE): $(TARBZ2FILE:../%=%)
	$(MV) $< $@

$(TARGZFILE): $(TARBZ2FILE:../%=%)
	$(MV) $< $@

$(ZIPFILE): $(TARBZ2FILE:../%=%)
	$(MV) $< $@

distclean::
	@$(RM_F) $(TARBZ2FILE:../%=%) $(TARGZFILE:../%=%) $(ZIPFILE:../%=%)

#Make an RPM
$(RHSPECS)/$(RPMSPEC): $(RPMSPEC)
	@$(SUBPATHS)

$(RHSRCS)/$(TARBZ2FILE:../%=%): $(TARBZ2FILE)
	cp $< $@

$(RHRPMS)/noarch/$(RPMFILE): $(RHSPECS)/$(RPMSPEC) \
		$(RHSRCS)/$(TARBZ2FILE:../%=%)
	cd $(RHSPECS); $(RPM) $(RPMBUILDFLAGS) $(RPMSPEC)

#Make a Debian package
../$(DEBFILE): $(DEBFILES:%=debian/%) $(TARGZFILE)
	cd ..; \
	$(GZIP) -d -c $(TARGZFILE) | $(TAR) xvf - ; \
	cd $(DISTVNAME); \
	su -c "$(MAKE) -f debian/rules binary; \
		   $(CHOWN) $$LOGNAME $@; $(RM_RF) ../$(DISTVNAME)"

distclean::
	#$(RM) bin/*
	$(RM_RF) debian/netcomics
	$(RM_RF) debian/netcomics-modules
	$(RM_RF) debian/netcomics-comicpage
	$(RM_RF) debian/tmp
	$(RM) debian/files debian/*.debhelper debian/*substvars
	$(RM_RF) comic_page/
	$(RM_RF) comicpage.glade.bak comicpage.glade2perl.xml
	$(RM_RF) build-stamp configure-stamp


#This link is made to remind you that you need to upload the file
#with this name to metalab.unc.edu, not the one the debian packager creates.
../$(DEBFILELINK): ../$(DEBFILE)
	@$(RM_F) $@
	$(LN) -s $(DEBFILE) $@

#Maintanence targets
preparchive: distclean
	$(PERL) Makefile.PL

archives: preparchive
	$(MAKE) $(TARBZ2FILE)
	$(MAKE) $(TARGZFILE)
	$(MAKE) $(ZIPFILE)

rpm:
	$(MAKE) INSTALLSITELIB=/usr/lib/perl5/site_perl $(RHRPMS)/noarch/$(RPMFILE)

deb:
	dpkg-buildpackage -rfakeroot

tag: label
label:
	ver=`echo $(VERSION) | sed \'s/\./_/g\'`; \
	cd ..; $(CVS) tag V$$ver

#example on how to change where things are installed
install_home:
	$(MAKE) clean
	$(PERL) Makefile.PL
	$(MAKE) install PREFIX=$(HOME) INSTALLMAN3DIR=$(HOME)/man/man3 \
		TMPDIR=$(HOME)/www/comics

.PHONY: archives rpm dist deb preparchive tag label install_home

';
}


package main;

my %opts =
	('NAME' => 'netcomics',
	 'VERSION' => "0.14",
	 'PM' => {(map {("Netcomics/$_" =>
				   '$(INST_LIBDIR)/$(MY_INST_SUBDIR)/' . $_)} @pm_to_install),
			  (map {("$_" =>
				   '$(INST_LIBDIR)/$(MY_INST_SUBDIR)/' . $_)} @glade_files),
#			  (map {("html_tmpl/$_" =>
#					'$(INST_LIBDIR)/$(HTML_INST_DIR)/' . $_)} @html_templates),
			  (map {("lib/$_" =>
					 '$(INST_LIBDIR)/$(MOD_INST_DIR)/' . $_)} @modules),
			  (map {("$_" =>
					 '$(INST_LIBDIR)/$(ETC_INST_DIR)/' . $_)} @etc_files),
			 },
	 'MAN3PODS' => {map {("Netcomics/$_.pm" =>
						  '$(INST_MAN3DIR)/Netcomics::' . $_ . '.$(MAN3EXT)')}
					@pm_with_pod},
	 'EXE_FILES' => [map {("bin/$_")} @pl_to_install],
	 'MAN1PODS' => {map {("doc/$_" =>
						  '$(INST_MAN1DIR)/' . $_ . '.$(MAN1EXT)')}
					@pl_with_pod},
#	 'INSTPRIVLIB' => ?
#	 'PPM_INSTALL_SCRIPT' => 'postinstall', # find old comic modules
#	 'clean' => {'FILES' => '$(EXE_FILES)'},
	);

if ($ExtUtils::MakeMaker::VERSION >= 5.43) {
	$opts{'AUTHOR'} = "Ben Hochstedler <hochstrb\@cs.rose-hulman.edu> " .
		"Elliot Glaysher <glaysher\@umich.edu>";
	$opts{'ABSTRACT'} =
		"A set of tools that automates downloading & viewing comics from " .
			"the Web";
}

WriteMakefile(%opts);


# Local Variables:
# tab-width: 4
# cperl-indent-level: 4
# cperl-continued-brace-offset: -4
# cperl-continued-statement-offset: 4
# cperl-label-offset: -4
# perl-indent-level: 4
# perl-continued-brace-offset: -4
# perl-continued-statement-offset: 4
# perl-label-offset: -4
# End:
