include ../common.mk

BINARIES := $(wildcard bin/*)
SDDM_SERVICE := $(wildcard sddm.service.d/*)

all:

install: all
	install -d $(DESTDIR)$(sbindir)
	install -m 0755 $(BINARIES) $(DESTDIR)$(sbindir)
	for i in $(shell bin/steamos-logger --log-level); do \
		ln -sf steamos-logger $(DESTDIR)$(sbindir)/steamos-$$i; \
	done
	install -d $(DESTDIR)$(systemdunitsdir)/sddm.service.d
	install -m 0644 $(SDDM_SERVICE) $(DESTDIR)$(systemdunitsdir)/sddm.service.d
