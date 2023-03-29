include ../common.mk

GEN_HOOKS_IN := initcpio/hooks/steamos.in
HOOKS_IN := $(GEN_HOOKS_IN)
HOOKS := $(patsubst %.in,%,$(HOOKS_IN))
GEN_INSTS_IN := initcpio/install/steamos.in
INSTS_IN := $(wildcard initcpio/install/*.in) $(GEN_INSTS_IN)
INSTS := $(patsubst %.in,%,$(INSTS_IN))
CLEANABLE := $(GEN_HOOKS_IN) $(HOOKS) $(GEN_INSTS_IN) $(INSTS)

initcpio/hooks/steamos.in: initcpio/hooks/steamos.tmpl ../initrd/steamos-etc-overlay.ash \
		../initrd/steamos-factory-reset.ash ../initrd/steamos-udev-rules.ash \
		../initrd/steamos-var-lib-modules.ash ../initrd/steamos-var.ash

	cat $< | ../initrd/inline-file.sh "@STEAMOS_ETC_OVERLAY@" ../initrd/steamos-etc-overlay.ash | \
		../initrd/inline-file.sh "@STEAMOS_FACTORY_RESET@" ../initrd/steamos-factory-reset.ash | \
		../initrd/inline-file.sh "@STEAMOS_UDEV_RULES@" ../initrd/steamos-udev-rules.ash | \
		../initrd/inline-file.sh "@STEAMOS_VAR_LIB@" ../initrd/steamos-var-lib-modules.ash | \
		../initrd/inline-file.sh "@STEAMOS_VAR@" ../initrd/steamos-var.ash | \
		sed -e 's|@INFO@|msg|g;s|@WARN@|err|g;s|@WAIT_FOR_DEV@|poll_device|g' > $@

initcpio/install/steamos.in: initcpio/install/steamos.tmpl ../initrd/steamos-files.bash
	../initrd/inline-file.sh "@STEAMOS_BINARIES@" $^ > $@

all: $(GEN_HOOKS_IN) $(HOOKS) $(GEN_INSTS_IN) $(INSTS)

install: all
	install -d $(DESTDIR)$(libdir)/initcpio/hooks
	install -m 0644 $(HOOKS) $(DESTDIR)$(libdir)/initcpio/hooks
	install -d $(DESTDIR)$(libdir)/initcpio/install
	install -m 0644 $(INSTS) $(DESTDIR)$(libdir)/initcpio/install
