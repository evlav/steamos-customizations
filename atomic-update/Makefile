include ../common.mk

BINARIES := $(wildcard bin/*)
LIBRARIES_EXEC_IN := $(wildcard libexec/*.in)
LIBRARIES_EXEC := $(patsubst %.in,%,$(LIBRARIES_EXEC_IN))
COMPLETIONS := $(wildcard completions/*)
DATA_IN := $(wildcard share/*.in)
DATA := $(patsubst %.in,%,$(DATA_IN))
RAUC_CONFIG_IN := rauc/system.conf.in
RAUC_CONFIG :=  $(patsubst %.in,%,$(RAUC_CONFIG_IN))
RAUC_HOOKS_IN := $(wildcard rauc/*.sh.in)
RAUC_HOOKS := $(patsubst %.in,%,$(RAUC_HOOKS_IN))
STEAMOS_ATOMUPD_CONFIG := steamos-atomupd/client.conf
SERVICES_IN := $(wildcard systemd/*.service.in)
SERVICES := $(patsubst %.in,%,$(SERVICES_IN))
SERVICES_OVERRIDE_IN := $(wildcard systemd/*/override.conf.in)
SERVICES_OVERRIDE := $(patsubst %.in,%,$(SERVICES_OVERRIDE_IN))
TMPFILES_IN := $(wildcard tmpfiles.d/*.conf.in)
TMPFILES := $(patsubst %.in,%,$(TMPFILES_IN))
APPLICATIONS_IN := $(wildcard applications/*.in)
APPLICATIONS := $(patsubst %.in,%,$(APPLICATIONS_IN))
TARGETS := $(wildcard systemd/*.target)

all: $(APPLICATIONS) $(DATA) $(LIBRARIES_EXEC) $(RAUC_CONFIG) $(RAUC_HOOKS) $(SERVICES) $(SERVICES_OVERRIDE) $(TMPFILES)

install: all
	install -d $(DESTDIR)$(sbindir)
	install -m 0755 $(BINARIES) $(DESTDIR)$(sbindir)
	install -d $(DESTDIR)$(libexecdir)/steamos
	install -m 0755 $(LIBRARIES_EXEC) $(DESTDIR)$(libexecdir)/steamos
	install -d $(DESTDIR)$(datadir)/steamos
	install -m 0644 $(DATA) $(DESTDIR)$(datadir)/steamos
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
		install -D -m 644 $$i $(DESTDIR)$(systemdunitsdir)/$$i; \
	done
	$(call enable-systemd-units,$(DESTDIR)$(systemdunitsdir),$(notdir $(SERVICES)))
	install -m 644 $(TARGETS) $(DESTDIR)$(systemdunitsdir)
	install -d $(DESTDIR)$(libdir)/tmpfiles.d
	install -m 0644 $(TMPFILES) $(DESTDIR)$(libdir)/tmpfiles.d
	install -d $(DESTDIR)$(datadir)/applications
	install -m 0644 $(APPLICATIONS) $(DESTDIR)$(datadir)/applications/
