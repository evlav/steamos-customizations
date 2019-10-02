include ../common.mk

BINARIES := $(wildcard bin/*)
DKMS_CONFIG := $(wildcard dkms/*)
SERVICES_IN := $(wildcard systemd/*.service.in)
SERVICES := $(patsubst %.in,%,$(SERVICES_IN))

all: $(SERVICES)

install: all
	install -d $(DESTDIR)$(sbindir)
	install -m 0755 $(BINARIES) $(DESTDIR)$(sbindir)
	install -d $(DESTDIR)/$(sysconfdir)/dkms
	install -m 0644 $(DKMS_CONFIG) $(DESTDIR)/$(sysconfdir)/dkms
	install -d $(DESTDIR)$(systemdunitsdir)
	install -m 0644 $(SERVICES) $(DESTDIR)$(systemdunitsdir)
	$(call enable-systemd-units,$(DESTDIR)$(systemdunitsdir),$(notdir $(SERVICES)))
