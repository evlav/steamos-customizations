include ../common.mk

BINARIES_IN := $(wildcard bin/*.in)
BINARIES := $(patsubst %.in,%,$(BINARIES_IN)) bin/steamos-setupverity bin/steamos-create-homedir-if-needed
LIBRARIES := lib/steamos-partitions-lib
COMPLETIONS := completions/steamos-chroot completions/steamos-partdefs completions/steamos-setupverity
SDDM_CONFIG := sddm.conf.d/steamos.conf
PROFILE_CONFIG := profile.d/steamos.sh
SUDOERS_CONFIG := sudoers.d/no-fqdn
XORG_CONFIG := xorg.conf.d/10-steamos-virtualdisplaysize.conf

MOUNTS_IN := $(wildcard systemd/*.mount.in)
MOUNTS := $(patsubst %.in,%,$(MOUNTS_IN))
SERVICES_IN := $(wildcard systemd/*.service.in)
SERVICES := $(patsubst %.in,%,$(SERVICES_IN))
UNITS := $(SERVICES) $(MOUNTS)

all: $(BINARIES) $(UNITS)

install: all
	install -d $(DESTDIR)$(sbindir)
	install -m 0755 $(BINARIES) $(DESTDIR)$(sbindir)
	install -d $(DESTDIR)$(libdir)
	install -m 0644 $(LIBRARIES) $(DESTDIR)$(libdir)
	install -d $(DESTDIR)$(completionsdir)
	install -m 0644 $(COMPLETIONS) $(DESTDIR)$(completionsdir)
	install -d $(DESTDIR)$(libdir)/sddm/sddm.conf.d/
	install -m 0644 $(SDDM_CONFIG) $(DESTDIR)$(libdir)/sddm/sddm.conf.d
	install -d $(DESTDIR)$(sysconfdir)/profile.d
	install -m 0644 $(PROFILE_CONFIG) $(DESTDIR)$(sysconfdir)/profile.d
	install -d $(DESTDIR)$(sysconfdir)/sudoers.d
	install -m 0644 $(SUDOERS_CONFIG) $(DESTDIR)$(sysconfdir)/sudoers.d
	install -d $(DESTDIR)$(datadir)/X11/xorg.conf.d
	install -m 0644 $(XORG_CONFIG) $(DESTDIR)$(datadir)/X11/xorg.conf.d
	install -d $(DESTDIR)$(systemdunitsdir)
	install -m 0644 $(UNITS) $(DESTDIR)$(systemdunitsdir)
	$(call enable-systemd-units,$(DESTDIR)$(systemdunitsdir),$(notdir $(UNITS)))
