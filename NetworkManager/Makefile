include ../common.mk

BINARIES := bin/steamos-set-wifi-backend
COMPLETIONS := $(wildcard completions/*)
NM_CONFIG:= $(wildcard conf.d/*)

all:

install: all
	install -d $(DESTDIR)$(sbindir)
	install -m 0755 $(BINARIES) $(DESTDIR)$(sbindir)
	install -d $(DESTDIR)$(completionsdir)
	install -m 0644 $(COMPLETIONS) $(DESTDIR)$(completionsdir)
	install -d $(DESTDIR)$(sysconfdir)/NetworkManager/conf.d/
	install -m 0644 $(NM_CONFIG) $(DESTDIR)$(sysconfdir)/NetworkManager/conf.d/
	install -d $(DESTDIR)$(systemdunitsdir)/multi-user.target.wants/
	ln -s /usr/lib/systemd/system/systemd-resolved.service $(DESTDIR)$(systemdunitsdir)/dbus-org.freedesktop.resolve1.service
	ln -s /usr/lib/systemd/system/systemd-resolved.service $(DESTDIR)$(systemdunitsdir)/multi-user.target.wants/
