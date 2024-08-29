include ../common.mk

NM_CONFIG:= $(wildcard conf.d/*)

all:

install: all
	install -d $(DESTDIR)$(libdir)/NetworkManager/conf.d/
	install -m 0644 $(NM_CONFIG) $(DESTDIR)$(libdir)/NetworkManager/conf.d/
	install -d $(DESTDIR)$(systemdunitsdir)/multi-user.target.wants/
	ln -s /usr/lib/systemd/system/systemd-resolved.service $(DESTDIR)$(systemdunitsdir)/dbus-org.freedesktop.resolve1.service
	ln -s /usr/lib/systemd/system/systemd-resolved.service $(DESTDIR)$(systemdunitsdir)/multi-user.target.wants/
