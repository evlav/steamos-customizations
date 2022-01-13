include ../common.mk

PW_CONFIG:= $(wildcard media-session.d/*)

all:

install: all
	install -d $(DESTDIR)$(sysconfdir)/pipewire/media-session.d/
	install -m 0644 $(PW_CONFIG) $(DESTDIR)$(sysconfdir)/pipewire/media-session.d/
