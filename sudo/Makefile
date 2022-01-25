include ../common.mk

SUDOERS_CONFIG := $(wildcard sudoers.d/*)

all: $(SUDOERS_CONFIG)

install: all
	install -d 0750 $(DESTDIR)$(sysconfdir)/sudoers.d
	install -m 0440 $(SUDOERS_CONFIG) $(DESTDIR)$(sysconfdir)/sudoers.d
