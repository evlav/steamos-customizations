include ../common.mk

TMPFILES_IN := $(wildcard tmpfiles.d/*.conf.in)
TMPFILES := $(patsubst %.in,%,$(TMPFILES_IN))

MOUNTS_IN := $(wildcard systemd/*.mount.in)
MOUNTS := $(patsubst %.in,%,$(MOUNTS_IN))
TARGETS := $(wildcard systemd/*.target)
UNITS := $(MOUNTS) $(TARGETS)
CLEANABLE := $(MOUNTS) $(TMPFILES)

all: $(MOUNTS) $(TMPFILES)

install: all
	install -d $(DESTDIR)$(libdir)/tmpfiles.d
	install -m 0644 $(TMPFILES) $(DESTDIR)$(libdir)/tmpfiles.d
	install -d $(DESTDIR)$(systemdunitsdir)
	install -m 644 $(UNITS) $(DESTDIR)$(systemdunitsdir)
	$(call enable-systemd-units,$(DESTDIR)$(systemdunitsdir),$(notdir $(UNITS)))
