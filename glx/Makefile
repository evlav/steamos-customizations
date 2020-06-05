include ../common.mk

LIBRARIES_IN := $(wildcard lib/*.in)
LIBRARIES := $(patsubst %.in,%,$(LIBRARIES_IN))
COMPLETIONS := completions/steamos-glx-backend completions/steamos-glx-drivers
SERVICES_IN := $(wildcard systemd/*.service.in)
SERVICES := $(patsubst %.in,%,$(SERVICES_IN))

all: $(LIBRARIES) $(SERVICES)

install: all
	install -d $(DESTDIR)$(libdir)/steamos
	install -m 0755 $(LIBRARIES) $(DESTDIR)$(libdir)/steamos
	install -d $(DESTDIR)$(completionsdir)
	install -m 0644 $(COMPLETIONS) $(DESTDIR)$(completionsdir)
	install -d $(DESTDIR)$(systemdunitsdir)
	install -m 0644 $(SERVICES) $(DESTDIR)$(systemdunitsdir)
	$(call enable-systemd-units,$(DESTDIR)$(systemdunitsdir),$(notdir $(SERVICES)))
