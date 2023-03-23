include ../common.mk

ALPM_HOOKS_IN := $(wildcard alpm/hooks/*.in)
ALPM_HOOKS := $(patsubst %.in,%,$(ALPM_HOOKS_IN))
ALPM_SCRIPTS_IN := $(wildcard alpm/scripts/*.in)
ALPM_SCRIPTS := $(patsubst %.in,%,$(ALPM_SCRIPTS_IN))
BINARIES_IN := $(wildcard bin/*.in)
BINARIES := $(patsubst %.in,%,$(BINARIES_IN))
COMPLETIONS := $(wildcard completions/*)
GEN_MOD_IN := modules.d/module-setup.sh.in
GEN_MOD_IN += modules.d/steamos-etc-overlay.sh.in
GEN_MOD_IN += modules.d/steamos-factory-reset.sh.in
GEN_MOD_IN += modules.d/steamos-udev-rules.sh.in
MODULES_IN := $(wildcard modules.d/*.sh.in) $(GEN_MOD_IN)
MODULES := $(patsubst %.in,%,$(MODULES_IN))
README := modules.d/README
CLEANABLE := $(BINARIES) $(ALPM_SCRIPTS) $(ALPM_HOOKS) $(GEN_MOD_IN) $(MODULES)

modules.d/module-setup.sh.in: modules.d/module-setup.tmpl ../initrd/steamos-files.bash
	../initrd/inline-file.sh "@STEAMOS_BINARIES@" $^ > $@

modules.d/steamos-etc-overlay.sh.in: modules.d/steamos-etc-overlay.tmpl ../initrd/steamos-etc-overlay.ash
	../initrd/inline-file.sh "@STEAMOS_ETC_OVERLAY@" $^ | sed -e 's|@INFO@|info|g;s|@WARN@|warn|g' > $@

modules.d/steamos-factory-reset.sh.in: modules.d/steamos-factory-reset.tmpl ../initrd/steamos-factory-reset.bash
	../initrd/inline-file.sh "@STEAMOS_FACTORY_RESET@" $^ | sed -e 's|@INFO@|info|g;s|@WARN@|warn|g' > $@

modules.d/steamos-udev-rules.sh.in: modules.d/steamos-udev-rules.tmpl ../initrd/steamos-udev-rules.bash
	../initrd/inline-file.sh "@STEAMOS_UDEV_RULES@" $^ | \
		sed -e 's|@INFO@|info|g;s|@WARN@|warn|g;s|@WAIT_FOR_DEV@|wait_for_dev|g' > $@

all: $(BINARIES) $(ALPM_SCRIPTS) $(ALPM_HOOKS) $(GEN_MOD_IN) $(MODULES)

install: all
	install -d $(DESTDIR)$(sbindir)
	install -m 0755 $(BINARIES) $(DESTDIR)$(sbindir)
	install -d $(DESTDIR)$(completionsdir)
	install -m 0644 $(COMPLETIONS) $(DESTDIR)$(completionsdir)
	install -d $(DESTDIR)$(sysconfdir)/dracut.conf.d
	install -d $(DESTDIR)$(libdir)/dracut/modules.d/60steamos
	install -m 0755 $(MODULES) $(DESTDIR)$(libdir)/dracut/modules.d/60steamos
	install -m 0644 $(README)  $(DESTDIR)$(libdir)/dracut/modules.d/60steamos
	install -d $(DESTDIR)$(datadir)/libalpm/hooks
	install -m 644 $(ALPM_HOOKS) $(DESTDIR)$(datadir)/libalpm/hooks
	install -d $(DESTDIR)$(datadir)/libalpm/scripts
	install -m 755 $(ALPM_SCRIPTS) $(DESTDIR)$(datadir)/libalpm/scripts
