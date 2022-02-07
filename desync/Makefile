include ../common.mk

DESYNC_CONFIG_IN := desync/config.json.in
DESYNC_CONFIG := $(patsubst %.in,%,$(DESYNC_CONFIG_IN))
CLEANABLE := $(DESYNC_CONFIG)

all: $(DESYNC_CONFIG)

install: all
	install -d 0755 $(DESTDIR)$(sysconfdir)/desync
	install -m 0600 $(DESYNC_CONFIG) $(DESTDIR)$(sysconfdir)/desync
