include ../common.mk

LIBRARIES_EXEC := libexec/steamos-rm-default-swapfile
SERVICES_IN := $(wildcard systemd/*.service.in)
SERVICES := $(patsubst %.in,%,$(SERVICES_IN))
SWAPS := $(wildcard systemd/*.swap)
UNITS := $(SERVICES) $(SWAPS)
CLEANABLE := $(SERVICES)

all: $(SERVICES)

install: all
	install -d $(DESTDIR)$(libexecdir)/steamos
	install -m 0755 $(LIBRARIES_EXEC) $(DESTDIR)$(libexecdir)/steamos
	install -d $(DESTDIR)$(systemdunitsdir)
	install -m 0644 $(UNITS) $(DESTDIR)$(systemdunitsdir)
	$(call enable-systemd-units,$(DESTDIR)$(systemdunitsdir),$(notdir $(UNITS)))
