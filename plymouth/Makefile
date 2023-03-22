include ../common.mk

SDDM_SERVICE := $(wildcard sddm.service.d/*)

all:

install: all
	install -d $(DESTDIR)$(systemdunitsdir)/sddm.service.d
	install -m 0644 $(SDDM_SERVICE) $(DESTDIR)$(systemdunitsdir)/sddm.service.d
