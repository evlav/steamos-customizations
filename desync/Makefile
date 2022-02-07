include ../common.mk

DESYNC_CONFIG := $(wildcard desync/*)

all: $(DESYNC_CONFIG)

install: all
	install -d 0755 $(DESTDIR)$(sysconfdir)/desync
	install -m 0600 $(DESYNC_CONFIG) $(DESTDIR)$(sysconfdir)/desync
