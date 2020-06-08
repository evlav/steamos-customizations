include ../common.mk

BINARIES_IN := $(wildcard bin/*.in)
BINARIES := $(patsubst %.in,%,$(BINARIES_IN))
LIBRARIES_IN := $(wildcard lib/*.in)
LIBRARIES := $(patsubst %.in,%,$(LIBRARIES_IN))
COMPLETIONS := completions/steamos-reboot completions/steamos-shutdown
SERVICES_IN := $(wildcard systemd/*.service.in)
SERVICES := $(patsubst %.in,%,$(SERVICES_IN))

all: $(BINARIES) $(LIBRARIES) $(SERVICES)

install: all
	install -d $(DESTDIR)$(sbindir)
	install -m 0755 $(BINARIES) $(DESTDIR)$(sbindir)
	for i in steamos-halt steamos-poweroff; do \
		ln -sfv steamos-reboot $(DESTDIR)$(sbindir)/$$i; \
	done
	install -d $(DESTDIR)$(libdir)/steamos
	install -m 0755 $(LIBRARIES) $(DESTDIR)$(libdir)/steamos
	install -d $(DESTDIR)$(completionsdir)
	install -m 0644 $(COMPLETIONS) $(DESTDIR)$(completionsdir)
	for i in steamos-halt steamos-poweroff; do \
		ln -sfv steamos-reboot $(DESTDIR)$(completionsdir)/$$i; \
	done
	install -d $(DESTDIR)$(systemdunitsdir)
	install -m 644 $(SERVICES) $(DESTDIR)$(systemdunitsdir)
	$(call enable-systemd-units,$(DESTDIR)$(systemdunitsdir),$(notdir $(SERVICES)))
