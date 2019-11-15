include ../common.mk

BINARIES := bin/mkswapfile

SERVICES_IN := $(wildcard systemd/*.service.in)
SERVICES := $(patsubst %.in,%,$(SERVICES_IN))
SWAPS := $(wildcard systemd/*.swap)
UNITS := $(SERVICES) $(SWAPS)

all: $(SERVICES)

install: all
	install -d $(DESTDIR)$(sbindir)
	install -m 0755 $(BINARIES) $(DESTDIR)$(sbindir)
	install -d $(DESTDIR)$(systemdunitsdir)
	install -m 0644 $(UNITS) $(DESTDIR)$(systemdunitsdir)
	$(call enable-systemd-units,$(DESTDIR)$(systemdunitsdir),$(notdir $(UNITS)))
