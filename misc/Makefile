include ../common.mk

BINARIES_IN := $(wildcard bin/*.in)
BINARIES := $(patsubst %.in,%,$(BINARIES_IN))
LIBRARIES := $(wildcard lib/*)
LIBRARIES_EXEC_IN := $(wildcard libexec/*.in)
LIBRARIES_EXEC := $(patsubst %.in,%,$(LIBRARIES_EXEC_IN))
COMPLETIONS := $(wildcard completions/*)
REPART_CONFIG := $(wildcard repart.d/*.conf)
SYSCTL_CONFIG := sysctl.d/10-kernel-panic.conf
SDDM_CONFIG := sddm.conf.d/steamos.conf
PROFILE_CONFIG := profile.d/steamos.sh
SUDOERS_CONFIG := sudoers.d/no-fqdn
XORG_CONFIG := xorg.conf.d/10-steamos-virtualdisplaysize.conf

MOUNTS_IN := $(wildcard systemd/*.mount.in)
MOUNTS := $(patsubst %.in,%,$(MOUNTS_IN))
SERVICES_IN := $(wildcard systemd/*.service.in)
SERVICES := $(patsubst %.in,%,$(SERVICES_IN))
SYSUSERS := $(wildcard sysusers/*)
UNITS := $(SERVICES) $(MOUNTS)

all: $(BINARIES) $(LIBRARIES_EXEC) $(UNITS)

install: all
	install -d $(DESTDIR)$(sbindir)
	install -m 0755 $(BINARIES) $(DESTDIR)$(sbindir)
	ln -sfv steamos-mount $(DESTDIR)$(sbindir)/mount.steamos
	install -d $(DESTDIR)$(libdir)/steamos
	install -m 0755 $(LIBRARIES) $(DESTDIR)$(libdir)/steamos
	install -d $(DESTDIR)$(libexecdir)/steamos
	install -m 0755 $(LIBRARIES_EXEC) $(DESTDIR)$(libexecdir)/steamos
	install -d $(DESTDIR)$(completionsdir)
	install -m 0644 $(COMPLETIONS) $(DESTDIR)$(completionsdir)
	ln -sfv steamos-mount $(DESTDIR)$(completionsdir)/mount.steamos
	install -d $(DESTDIR)$(libdir)/repart.d
	install -m 0644 $(REPART_CONFIG) $(DESTDIR)$(libdir)/repart.d
	install -d $(DESTDIR)$(libdir)/sysctl.d/
	install -m 0644 $(SYSCTL_CONFIG) $(DESTDIR)$(libdir)/sysctl.d/
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
	install -d $(DESTDIR)$(libdir)/sysusers.d
	install -m 0644 $(SYSUSERS) $(DESTDIR)$(libdir)/sysusers.d
