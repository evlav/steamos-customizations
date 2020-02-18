include ../common.mk

BINARIES := $(wildcard bin/*)

all: $(SERVICES)

install: all
	install -d $(DESTDIR)$(sbindir)
	install -m 0755 $(BINARIES) $(DESTDIR)$(sbindir)
	for i in $(shell bin/steamos-logger --log-level); do \
		ln -sf steamos-logger $(DESTDIR)$(sbindir)/steamos-$$i; \
	done
