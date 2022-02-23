include ../common.mk

BINARIES_IN := $(wildcard bin/*.in)
BINARIES := $(patsubst %.in,%,$(BINARIES_IN))
# This setuid wrapper exposes a limited subset of steamos-bootconf's
# functionality to unprivileged callers: specifically the set-mode
# actions used to configure the well-known boot requests such as:
# reboot reboot-other update (for example). This allows things like
# steam and the plasma UI to request those update modes safely.
SUIDBINS := bin/steamos-set-bootmode
COMPLETIONS := $(wildcard completions/*)
SERVICES_IN := $(wildcard systemd/*.service.in)
SERVICES := $(patsubst %.in,%,$(SERVICES_IN))

all: $(BINARIES) $(LIBRARIES_EXEC) $(SERVICES) $(SUIDBINS)

bin/steamos-set-bootmode: bin/steamos-set-bootmode.c
	$(CC) -Wall -Wextra $^ -DBINDIR=\"$(bindir)\" -o $@

install: all
	install -d $(DESTDIR)$(sbindir)
	install -m 0755 $(BINARIES) $(DESTDIR)$(sbindir)
	for i in steamos-halt steamos-poweroff; do \
		ln -sfv steamos-reboot $(DESTDIR)$(sbindir)/$$i; \
	done
	install -m 4755 $(SUIDBINS) $(DESTDIR)$(sbindir)
	install -d $(DESTDIR)$(completionsdir)
	install -m 0644 $(COMPLETIONS) $(DESTDIR)$(completionsdir)
	for i in steamos-halt steamos-poweroff; do \
		ln -sfv steamos-reboot $(DESTDIR)$(completionsdir)/$$i; \
	done
	install -d $(DESTDIR)$(systemdunitsdir)
	install -m 644 $(SERVICES) $(DESTDIR)$(systemdunitsdir)
	$(call enable-systemd-units,$(DESTDIR)$(systemdunitsdir),$(notdir $(SERVICES)))
