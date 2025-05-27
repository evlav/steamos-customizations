include ../common.mk

BINARIES_IN := $(wildcard bin/*.in)
BINARIES := $(patsubst %.in,%,$(BINARIES_IN))
LIBRARIES_EXEC_IN := $(wildcard libexec/*.in)
LIBRARIES_EXEC := $(patsubst %.in,%,$(LIBRARIES_EXEC_IN))
COMPLETIONS := $(wildcard completions/*)
REPART_CONFIG := $(wildcard repart.d/*.conf)
SYSCTL_CONFIG := $(wildcard sysctl.d/*.conf)
SDDM_CONFIG := sddm.conf.d/steamos.conf
LODIND_CONFIG := $(wildcard journald.conf.d/*.conf)
SLEEP_CONFIG := $(wildcard sleep.conf.d/*.conf)
PROFILE_CONFIG := profile.d/steamos.sh
XORG_CONFIG := xorg.conf.d/10-steamos-virtualdisplaysize.conf
PROTON_LIMITS_CONFIG := limits.d/15-proton-nice.conf
SYSTEMD_LOGIND_CONFIG := systemd-logind.service.d/homedir-override.conf
MODULES_LOAD_CONFIG := $(wildcard modules-load.d/*.conf)
UDEV_RULES := $(wildcard rules.d/*.rules)
UDEV_HWDB := $(wildcard hwdb.d/*.hwdb)

MOUNTS_IN := $(wildcard systemd/*.mount.in)
MOUNTS := $(patsubst %.in,%,$(MOUNTS_IN))
SERVICES_IN := $(wildcard systemd/*.service.in)
SERVICES := $(patsubst %.in,%,$(SERVICES_IN))
SYSUSERS := $(wildcard sysusers/*)
UNITS := $(SERVICES) $(MOUNTS)
CLEANABLE := $(BINARIES) $(LIBRARIES_EXEC) $(UNITS)

all: $(BINARIES) $(LIBRARIES_EXEC) $(UNITS)

install: all
	install -d $(DESTDIR)$(sbindir)
	install -m 0755 $(BINARIES) $(DESTDIR)$(sbindir)
	ln -sfv steamos-mount $(DESTDIR)$(sbindir)/mount.steamos
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
	install -d $(DESTDIR)$(libdir)/systemd/journald.conf.d/
	install -m 0644 $(LODIND_CONFIG) $(DESTDIR)$(libdir)/systemd/journald.conf.d/
	install -d $(DESTDIR)$(libdir)/systemd/sleep.conf.d/
	install -m 0644 $(SLEEP_CONFIG) $(DESTDIR)$(libdir)/systemd/sleep.conf.d/
	install -d $(DESTDIR)$(sysconfdir)/profile.d
	install -m 0644 $(PROFILE_CONFIG) $(DESTDIR)$(sysconfdir)/profile.d
	install -d $(DESTDIR)$(sysconfdir)/limits.d
	install -m 0644 $(PROTON_LIMITS_CONFIG) $(DESTDIR)$(sysconfdir)/limits.d
	install -d $(DESTDIR)$(datadir)/X11/xorg.conf.d
	install -m 0644 $(XORG_CONFIG) $(DESTDIR)$(datadir)/X11/xorg.conf.d
	install -d $(DESTDIR)$(systemdunitsdir)
	install -m 0644 $(UNITS) $(DESTDIR)$(systemdunitsdir)
	$(call enable-systemd-units,$(DESTDIR)$(systemdunitsdir),$(notdir $(UNITS)))
	install -d $(DESTDIR)$(libdir)/sysusers.d
	install -m 0644 $(SYSUSERS) $(DESTDIR)$(libdir)/sysusers.d
	install -d $(DESTDIR)$(sysconfdir)/systemd/system/systemd-logind.service.d
	install -m 0644 $(SYSTEMD_LOGIND_CONFIG) $(DESTDIR)$(sysconfdir)/systemd/system/systemd-logind.service.d
	install -d $(DESTDIR)$(libdir)/modules-load.d/
	install -m 0644 $(MODULES_LOAD_CONFIG) $(DESTDIR)$(libdir)/modules-load.d/
	install -d $(DESTDIR)$(libdir)/udev/rules.d/
	install -m 0644 $(UDEV_RULES) $(DESTDIR)$(libdir)/udev/rules.d/
	install -d $(DESTDIR)$(libdir)/udev/hwdb.d/
	install -m 0644 $(UDEV_HWDB) $(DESTDIR)$(libdir)/udev/hwdb.d/
