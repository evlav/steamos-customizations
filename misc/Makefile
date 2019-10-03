include ../common.mk

BINARIES_IN := $(wildcard bin/*.in)
BINARIES := $(patsubst %.in,%,$(BINARIES_IN)) bin/mkswapfile bin/steamos-create-homedir-if-needed
LIBRARIES := lib/steamos-partitions-lib
SDDM_CONFIG := sddm.conf.d/steamos.conf
SUDOERS_CONFIG := sudoers.d/no-fqdn
TMPFILES_CONFIG := tmpfiles.d/0steamos.conf
XORG_CONFIG := xorg.conf.d/10-steamos-virtualdisplaysize.conf

SERVICES_IN := $(wildcard systemd/*.service.in)
SERVICES := $(patsubst %.in,%,$(SERVICES_IN))

all: $(BINARIES) $(SERVICES)

install: all
	install -d $(DESTDIR)$(sbindir)
	install -m 0755 $(BINARIES) $(DESTDIR)$(sbindir)
	install -d $(DESTDIR)$(libdir)
	install -m 0644 $(LIBRARIES) $(DESTDIR)$(libdir)
	install -d $(DESTDIR)$(libdir)/sddm/sddm.conf.d/
	install -m 0644 $(SDDM_CONFIG) $(DESTDIR)$(libdir)/sddm/sddm.conf.d
	install -d $(DESTDIR)$(sysconfdir)/sudoers.d
	install -m 0644 $(SUDOERS_CONFIG) $(DESTDIR)$(sysconfdir)/sudoers.d
	install -d $(DESTDIR)$(libdir)/tmpfiles.d
	install -m 0644 $(TMPFILES_CONFIG) $(DESTDIR)$(libdir)/tmpfiles.d
	install -d $(DESTDIR)$(datadir)/X11/xorg.conf.d
	install -m 0644 $(XORG_CONFIG) $(DESTDIR)$(datadir)/X11/xorg.conf.d
	install -d $(DESTDIR)$(systemdunitsdir)
	install -m 0644 $(SERVICES) $(DESTDIR)$(systemdunitsdir)
	$(call enable-systemd-units,$(DESTDIR)$(systemdunitsdir),$(notdir $(SERVICES)))
