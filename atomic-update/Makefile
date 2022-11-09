include ../common.mk

BINARIES := $(wildcard bin/*)
LIBRARIES_EXEC_IN := $(wildcard libexec/*.in)
LIBRARIES_EXEC := $(patsubst %.in,%,$(LIBRARIES_EXEC_IN))
COMPLETIONS := $(wildcard completions/*)
RAUC_CONFIG_IN := rauc/system.conf.in
RAUC_CONFIG :=  $(patsubst %.in,%,$(RAUC_CONFIG_IN))
RAUC_HOOKS_IN := $(wildcard rauc/*.sh.in)
RAUC_HOOKS := $(patsubst %.in,%,$(RAUC_HOOKS_IN))
STEAMOS_ATOMUPD_CONFIG_IN := steamos-atomupd/client.conf.in
STEAMOS_ATOMUPD_CONFIG := $(patsubst %.in,%,$(STEAMOS_ATOMUPD_CONFIG_IN))
SERVICES_IN := $(wildcard systemd/*.service.in)
SERVICES := $(patsubst %.in,%,$(SERVICES_IN))
SERVICES_OVERRIDE_IN := $(wildcard systemd/*/override.conf.in)
SERVICES_OVERRIDE := $(patsubst %.in,%,$(SERVICES_OVERRIDE_IN))
TMPFILES_IN := $(wildcard tmpfiles.d/*.conf.in)
TMPFILES := $(patsubst %.in,%,$(TMPFILES_IN))
TARGETS := $(wildcard systemd/*.target)
CLEANABLE := $(LIBRARIES_EXEC) $(RAUC_CONFIG) $(SERVICES_OVERRIDE) $(STEAMOS_ATOMUPD_CONFIG)

all: $(LIBRARIES_EXEC) $(RAUC_CONFIG) $(RAUC_HOOKS) $(SERVICES) $(SERVICES_OVERRIDE) $(TMPFILES) $(STEAMOS_ATOMUPD_CONFIG)

install: all
	install -d $(DESTDIR)$(sbindir)
	install -m 0755 $(BINARIES) $(DESTDIR)$(sbindir)
	install -d $(DESTDIR)$(libexecdir)/steamos
	install -m 0755 $(LIBRARIES_EXEC) $(DESTDIR)$(libexecdir)/steamos
	install -d $(DESTDIR)$(completionsdir)
	install -m 0644 $(COMPLETIONS) $(DESTDIR)$(completionsdir)
	install -d $(DESTDIR)$(sysconfdir)/rauc
	install -m 0644 $(RAUC_CONFIG) $(DESTDIR)$(sysconfdir)/rauc
	install -d $(DESTDIR)$(libdir)/rauc
	install -m 0755 $(RAUC_HOOKS) $(DESTDIR)$(libdir)/rauc
	install -d $(DESTDIR)$(sysconfdir)/steamos-atomupd
	install -m 0644 $(STEAMOS_ATOMUPD_CONFIG) $(DESTDIR)$(sysconfdir)/steamos-atomupd
	install -d $(DESTDIR)$(systemdunitsdir)
	install -m 644 $(SERVICES) $(DESTDIR)$(systemdunitsdir)
	for i in $(SERVICES_OVERRIDE); do \
		install -D -m 644 $$i $(DESTDIR)$(systemdunitsdir)/$${i#systemd/}; \
	done
	$(call enable-systemd-units,$(DESTDIR)$(systemdunitsdir),$(notdir $(SERVICES)))
	install -m 644 $(TARGETS) $(DESTDIR)$(systemdunitsdir)
	install -d $(DESTDIR)$(libdir)/tmpfiles.d
	install -m 0644 $(TMPFILES) $(DESTDIR)$(libdir)/tmpfiles.d
