include ../common.mk

SERVICES := $(wildcard systemd/*.service)

all:

install: all
	install -d $(DESTDIR)$(systemdunitsdir)
	install -m 0644 $(SERVICES) $(DESTDIR)$(systemdunitsdir)/
	$(call enable-systemd-units,$(DESTDIR)$(systemdunitsdir),$(notdir $(SERVICES)))
