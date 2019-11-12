include ../common.mk

MOUNTS_IN := $(wildcard systemd/*.mount.in)
MOUNTS := $(patsubst %.in,%,$(MOUNTS_IN))
TARGETS := $(wildcard systemd/*.target)
UNITS := $(MOUNTS) $(TARGETS)

all: $(MOUNTS)

install: all
	install -d $(DESTDIR)$(systemdunitsdir)
	install -m 644 $(UNITS) $(DESTDIR)$(systemdunitsdir)
	$(call enable-systemd-units,$(DESTDIR)$(systemdunitsdir),$(notdir $(UNITS)))
