include ../common.mk

PW_CONFIG:= $(wildcard pipewire.conf.d/*)

all:

install: all
	install -d $(DESTDIR)$(datadir)/pipewire/pipewire.conf.d/
	install -m 0644 $(PW_CONFIG) $(DESTDIR)$(datadir)/pipewire/pipewire.conf.d/
