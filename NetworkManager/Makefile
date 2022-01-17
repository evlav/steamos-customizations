include ../common.mk

NM_CONFIG:= $(wildcard conf.d/*)

all:

install: all
	install -d $(DESTDIR)$(sysconfdir)/NetworkManager/conf.d/
	install -m 0644 $(NM_CONFIG) $(DESTDIR)$(sysconfdir)/NetworkManager/conf.d/
