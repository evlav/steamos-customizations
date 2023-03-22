include ../common.mk

BINARIES := $(wildcard bin/*)
COMPLETIONS := $(wildcard completions/*)
RAUC_CONFIG_IN := rauc/system.conf.in
RAUC_CONFIG :=  $(patsubst %.in,%,$(RAUC_CONFIG_IN))
RAUC_HOOKS_IN := $(wildcard rauc/*.sh.in)
RAUC_HOOKS := $(patsubst %.in,%,$(RAUC_HOOKS_IN))
STEAMOS_ATOMUPD_CONFIG_IN := steamos-atomupd/client.conf.in
STEAMOS_ATOMUPD_CONFIG := $(patsubst %.in,%,$(STEAMOS_ATOMUPD_CONFIG_IN))
SERVICES_OVERRIDE_IN := $(wildcard systemd/*/override.conf.in)
SERVICES_OVERRIDE := $(patsubst %.in,%,$(SERVICES_OVERRIDE_IN))
TMPFILES_IN := $(wildcard tmpfiles.d/*.conf.in)
TMPFILES := $(patsubst %.in,%,$(TMPFILES_IN))
CLEANABLE := $(RAUC_CONFIG) $(RAUC_HOOKS) $(SERVICES_OVERRIDE) $(TMPFILES) $(STEAMOS_ATOMUPD_CONFIG)

all: $(RAUC_CONFIG) $(RAUC_HOOKS) $(SERVICES_OVERRIDE) $(TMPFILES) $(STEAMOS_ATOMUPD_CONFIG)

install: all
	install -d $(DESTDIR)$(sbindir)
	install -m 0755 $(BINARIES) $(DESTDIR)$(sbindir)
	install -d $(DESTDIR)$(completionsdir)
	install -m 0644 $(COMPLETIONS) $(DESTDIR)$(completionsdir)
	install -d $(DESTDIR)$(sysconfdir)/rauc
	install -m 0644 $(RAUC_CONFIG) $(DESTDIR)$(sysconfdir)/rauc
	install -d $(DESTDIR)$(libdir)/rauc
	install -m 0755 $(RAUC_HOOKS) $(DESTDIR)$(libdir)/rauc
	install -d $(DESTDIR)$(sysconfdir)/steamos-atomupd
	install -m 0644 $(STEAMOS_ATOMUPD_CONFIG) $(DESTDIR)$(sysconfdir)/steamos-atomupd
	install -d $(DESTDIR)$(systemdunitsdir)
	for i in $(SERVICES_OVERRIDE); do \
		install -D -m 644 $$i $(DESTDIR)$(systemdunitsdir)/$${i#systemd/}; \
	done
	install -d $(DESTDIR)$(libdir)/tmpfiles.d
	install -m 0644 $(TMPFILES) $(DESTDIR)$(libdir)/tmpfiles.d
