include ../common.mk

CONFIG := $(wildcard dracut.conf.d/*)
MODULES_IN := $(wildcard modules.d/*.sh.in)
MODULES := $(patsubst %.in,%,$(MODULES_IN))
README := modules.d/README

all: $(MODULES)

install: all
	install -d $(DESTDIR)$(sysconfdir)/dracut.conf.d
	install -m 0644 $(CONFIG) $(DESTDIR)$(sysconfdir)/dracut.conf.d
	install -d $(DESTDIR)$(libdir)/dracut/modules.d/60steamos
	install -m 0755 $(MODULES) $(DESTDIR)$(libdir)/dracut/modules.d/60steamos
	install -m 0644 $(README)  $(DESTDIR)$(libdir)/dracut/modules.d/60steamos

