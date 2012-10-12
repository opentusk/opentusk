# Makefile for various po files.

# Add more languages here!  Beware that this is a makefile snippet and
# you have to adhere to make syntax.
LINGUAS = fr

# Textdomain for our package.
TEXTDOMAIN = tusk
COPYRIGHT_HOLDER =  jpb
MSGID_BUGS_ADDRESS =  jpb

srcdir = .
libdir = ../lib
TUSK_ROOT = "/usr/local/tusk/current
#CATALOGS = $(addsuffix .po, LINGUAS)
CATALOGS = $(LINGUAS)
MO_FILES = $(addsuffix .mo, $(LINGUAS))

MSGMERGE = msgmerge
MSGFMT   = msgfmt
XGETTEXT = xgettext
CATOBJEXT = .po
LOCALE_DIR = $(libdir)/LocaleData

TD = $(strip $(TEXTDOMAIN))


POTFILES = $(srcdir)/POTFILES.in \
#	$(shell cat $(srcdir)/POTFILES.in) 
#POTFILES = $(shell find $(TUSK_ROOT)/lib $(TUSK_ROOT)/code -type f | grep -vE "(\.git|\/log|mason_cache|\.mo) )
#POTFILES =  $(shell for file in `find $(TUSK_ROOT)/lib $(TUSK_ROOT)/code -type f`;do echo $$file; done)
#POTFILES =  $(shell find /usr/local/tusk/current/lib  /usr/local/tusk/current/code -type f |grep -vE "(\.git|\/log|\/CVS|mason_cache|\.mo)" > potfiles.in)


default: help

all: $(TD).pot update-po update-mo install

help:
	@echo "Available targets:"
	@echo "  pot               - remake master catalog"
	@echo "  update-po         - merge po files"
	@echo "  update-mo         - regenerate mo files"
	@echo "  install           - install mo files"
	@echo "  configure         - creates $(libdir)/LocaleData"
	@echo "  scan              - scans soure files builds $(POTFILES)"
	@echo "  clean             - removes mo and editor temp file"
	@echo "  real-clean        - does a 'clean' and deletes *.po *.pot"
	@echo "  all               - all of the above"

pot: $(TD).pot 

scan:

	@if [ -e  $(POTFILES) ] ; then  rm  $(POTFILES); fi
	@echo "doing find $(POTFILES)"	
#	$(shell find /usr/local/tusk/current/lib  /usr/local/tusk/current/code -type f |grep -vE "(\.git|\/log|\/CVS|mason_cache|\.mo)" > $(POTFILES))
	@find /usr/local/tusk/current/lib/  /usr/local/tusk/current/code/ -type f |grep -v CVS> $(POTFILES)

	
test:
	cat potfiles.in
configure:
	@if test -d "$LOCALE_DIR" ; then \
		echo "I already have a $(LOCALE_DIR) skipping." ; \
	else \
		echo "mkdir -p $(LOCALE_DIR)" \
		mkdir -p $(LOCALE_DIR) ; \
	fi ; 
real-clean:
	rm -f  *~ *.bak *.mo *.pot *.po *.in $(MO_FILES) */*/*.mo
clean:
	rm -f *~ *.bak *.mo

# FIXME: The parameter --from-code is only needed if your sources contain
# any 8 bit data (even in comments).  UTF-8 is only a guess here, but it
# will at least accept any 8 bit data.
#
# The parameter "--language=perl" is not strictly needed because the
# source language of all our files will be auto-detected by xgettext
# by their filename extension.  You should even avoid this parameter
# if you want to extract strings from multiple source languages.
$(TD).pot: $(POTFILES)
	$(XGETTEXT) --output=$(srcdir)/$(TD).pox --from-code=utf-8 \
		--add-comments=TRANSLATORS: --files-from=$(srcdir)/POTFILES.in \
		--from-code=utf-8 \
		--copyright-holder="$(COPYRIGHT_HOLDER)" \
		--msgid-bugs-address="$(MSGID_BUGS_ADDRESS)" \
		--keyword=__ --keyword=__x \
		--language=python && \
	rm -f $@ && mv $(TD).pox $@

install: $(MO_FILES)
	cd $(srcdir); \
	targetdir='$(LOCALE_DIR)'; \
	languages='$(LINGUAS)'; \
	for lang in $$languages; do \
		mkdir -p "$$targetdir/$$lang/LC_MESSAGES" || exit 1; \
		dest="$$targetdir/$$lang/LC_MESSAGES/$(TD).mo"; \
		cat="$$lang.mo"; \
		echo "installing $$cat as $$dest"; \
		cp -f $$cat $$dest && chmod 644 $$dest || exit 1; \
	done

update-mo: $(MO_FILES)

update-po:
	$(MAKE) $(TD).pot
	cd $(srcdir); \
        catalogs='$(CATALOGS)'; \
        for cat in $$catalogs; do \
          cat=`basename $$cat`; \
          lang=`echo $$cat | sed 's/\$(CATOBJEXT)$$//'`; \
          mv $$lang.po $$lang.old.po; \
          echo "$$lang:"; \
          if $(MSGMERGE) $$lang.old.po $(TD).pot -o $$lang.po; then \
            rm -f $$lang.old.po; \
          else \
            echo "msgmerge for $$cat failed!"; \
            rm -f $$lang.po; \
            mv $$lang.old.po $$lang.po; \
          fi; \
        done

.SUFFIXES:
.SUFFIXES: .po .mo

.po.mo:
	$(MSGFMT) --check --statistics --verbose -o $@ $<

