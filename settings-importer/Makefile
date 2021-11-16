include ../common.mk

BINARIES := $(wildcard bin/*)
COMPLETIONS := $(wildcard completions/*)
SERVICES_IN := $(wildcard systemd/*.service.in)
SERVICES := $(patsubst %.in,%,$(SERVICES_IN))
GENERATORS_IN := $(wildcard generator/*-generator.in)
GENERATORS := $(patsubst %.in,%,$(GENERATORS_IN))
UNITS := $(SERVICES)
CLEANABLE := $(GENERATORS)

all: $(SERVICES) $(GENERATORS)

install: all
	install -d $(DESTDIR)$(sbindir)
	install -m 0755 $(BINARIES) $(DESTDIR)$(sbindir)
	install -d $(DESTDIR)$(completionsdir)
	install -m 0644 $(COMPLETIONS) $(DESTDIR)$(completionsdir)
	install -d $(DESTDIR)$(systemdunitsdir)
	install -m 0644 $(UNITS) $(DESTDIR)$(systemdunitsdir)
	$(call enable-systemd-units,$(DESTDIR)$(systemdunitsdir),$(notdir $(UNITS)))
	install -d $(DESTDIR)$(libdir)/systemd/system-generator
	install -m 0644 $(GENERATORS) $(DESTDIR)$(libdir)/systemd/system-generator
