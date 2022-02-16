include ../common.mk

WP_CONFIG:= $(wildcard main.lua.d/*)
WP_BL_CONFIG:= $(wildcard main.lua.d/*)

all:

install: all
	install -d $(DESTDIR)$(datadir)/wireplumber/main.lua.d/
	install -m 0644 $(WP_CONFIG) $(DESTDIR)$(datadir)/wireplumber/main.lua.d/
	install -d $(DESTDIR)$(datadir)/wireplumber/bluetooth.lua.d/
	install -m 0644 $(WP_CONFIG) $(DESTDIR)$(datadir)/wireplumber/bluetooth.lua.d/
