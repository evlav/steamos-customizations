include ../common.mk

# the nvidia module name is distro-specific, so we allow the caller
# to set it, and use the reasonable default 'nvidia'.
NVIDIA_MODULE_NAME ?= nvidia

BINARIES := $(wildcard bin/*)
NVIDIA_DKMS_CONFIG := dkms/nvidia.conf
SERVICES_IN := $(wildcard systemd/*.service.in)
SERVICES := $(patsubst %.in,%,$(SERVICES_IN))

all: $(SERVICES)

install: all
	install -d $(DESTDIR)$(sbindir)
	install -m 0755 $(BINARIES) $(DESTDIR)$(sbindir)
	install -d $(DESTDIR)/$(sysconfdir)/dkms
	install -m 0644 $(NVIDIA_DKMS_CONFIG) $(DESTDIR)/$(sysconfdir)/dkms/$(NVIDIA_MODULE_NAME).conf
	install -d $(DESTDIR)$(systemdunitsdir)
	install -m 0644 $(SERVICES) $(DESTDIR)$(systemdunitsdir)
	$(call enable-systemd-units,$(DESTDIR)$(systemdunitsdir),$(notdir $(SERVICES)))
