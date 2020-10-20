include ../common.mk

BINARIES_IN := $(wildcard bin/*.in)
BINARIES := $(patsubst %.in,%,$(BINARIES_IN))
LIBRARIES_EXEC_IN := $(wildcard libexec/*.in)
LIBRARIES_EXEC := $(patsubst %.in,%,$(LIBRARIES_EXEC_IN))
GRUB_SCRIPTS_IN := $(wildcard grub.d/*.in)
GRUB_SCRIPTS := $(patsubst %.in,%,$(GRUB_SCRIPTS_IN))
COMPLETIONS := completions/steamos-grub-mkearlyconfig completions/steamos-grub-mkimage completions/update-grub
SERVICES_IN := $(wildcard systemd/*.service.in)
SERVICES := $(patsubst %.in,%,$(SERVICES_IN))
MOUNTS := $(wildcard systemd/*.mount)
UNITS := $(SERVICES) $(MOUNTS)

all: $(BINARIES) $(LIBRARIES_EXEC) $(GRUB_SCRIPTS) $(SERVICES)

install: all
	install -d $(DESTDIR)$(sbindir)
	install -m 0755 $(BINARIES) $(DESTDIR)$(sbindir)
	install -d $(DESTDIR)$(libdir)/steamos
	install -m 0755 $(LIBRARIES_EXEC) $(DESTDIR)$(libdir)/steamos
	install -d $(DESTDIR)$(sysconfdir)/grub.d
	install -m 0755 $(GRUB_SCRIPTS) $(DESTDIR)$(sysconfdir)/grub.d
	install -d $(DESTDIR)$(completionsdir)
	install -m 0644 $(COMPLETIONS) $(DESTDIR)$(completionsdir)
	install -d $(DESTDIR)$(systemdunitsdir)
	install -m 0644 $(UNITS) $(DESTDIR)$(systemdunitsdir)
	$(call enable-systemd-units,$(DESTDIR)$(systemdunitsdir),$(notdir $(UNITS)))
