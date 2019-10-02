include ../common.mk

BINARIES_IN := $(wildcard bin/*.in)
BINARIES := $(patsubst %.in,%,$(BINARIES_IN))
SERVICES_IN := $(wildcard systemd/*.service.in)
SERVICES := $(patsubst %.in,%,$(SERVICES_IN))

all: $(BINARIES) $(SERVICES)

install: all
	install -d $(DESTDIR)$(sbindir)
	install -m 0755 $(BINARIES) $(DESTDIR)$(sbindir)
	install -d $(DESTDIR)$(systemdunitsdir)
	install -m 644 $(SERVICES) $(DESTDIR)$(systemdunitsdir)
	$(call enable-systemd-units,$(DESTDIR)$(systemdunitsdir),$(notdir $(SERVICES)))
