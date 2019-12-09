# -------- Installation directories -------- #

prefix     := /usr
sysconfdir := /etc

bindir     := $(prefix)/bin
datadir    := $(prefix)/share
libdir     := $(prefix)/lib
sbindir    := $(prefix)/sbin
systemdunitsdir := $(libdir)/systemd/system
systemdgeneratorsdir := $(libdir)/systemd/system-generators


# -------- Some tweaks -------- #

# Delete default rules, otherwise the rule '%: %.in' won't catch
# the files with the extention '.sh.in'
.SUFFIXES:

# If ever DESTDIR is a relative path, it will be relative to each
# subdir where we invoke `$(MAKE) -C ...`, resulting in multiple
# destination directories. To avoid that, we resolve it as an
# absolute path now. At the moment CURDIR is not TOPDIR, so we
# make sure to move to TOPDIR, then let realpath sort things out.
#
# It might seem complicated, but it's actually easier to solve it
# here rather than in the main Makefile. We don't really know if
# DESTDIR comes from the environment, or from the make command line.
# Using `override` works only for environment variables, not for
# command line variables, so overriding in the main Makfile is not
# guaranteed to work, unless we want to mess with MAKEOVERRIDES.
ifneq ($(DESTDIR),)
override DESTDIR := $(shell cd $(TOPDIR) && realpath $(DESTDIR))
endif


# -------- SteamOS variables -------- #

# The number of SteamOS partitions
STEAMOS_N_PARTITIONS := 10

# The SteamOS partition labels
STEAMOS_ALL_PARTLABELS := esp efi-A efi-B verity-A verity-B rootfs-A rootfs-B var-A var-B home

# GRUB binary (relative to the efi mountpoint)
GRUB_BINARY_RELPATH := EFI/steamos/grubx64.efi

# GRUB configuration (relative to the efi mountpoint)
GRUB_ROOT_CONFIG_RELPATH := EFI/steamos/grub-root.cfg
GRUB_VAR_CONFIG_RELPATH  := EFI/steamos/grub-var.cfg

# Bootconf file (relative to the efi mountpoint)
BOOTCONF_RELPATH := SteamOS/bootconf

# Partition definitions dir (relative to the efi mountpoint)
PARTDEFS_RELDIR := SteamOS/partitions

# Roothash file (relative to the efi mountpoint)
ROOTHASH_RELPATH := SteamOS/roothash

# Factory reset stampfile
FACTORY_RESET_STAMPFILE := /run/steamos/factory-reset

# Directory for the /etc overlay
ETC_OVERLAY_ABSDIR := /var/lib/overlays/etc

# Directory for the offloading scheme bind mounts
OFFLOAD_RELDIR := .steamos/offload
OFFLOAD_ABSDIR := /home/$(OFFLOAD_RELDIR)

# Directory where partition symlinks are created
UDEV_SYMLINKS_RELDIR := disk/steamos
UDEV_SYMLINKS_ABSDIR := /dev/$(UDEV_SYMLINKS_RELDIR)

%: %.in
	@echo "Substituting @variables@ in $<"
	@sed \
	  -e 's;@bindir@;$(bindir);g' \
	  -e 's;@libdir@;$(libdir);g' \
	  -e 's;@sbindir@;$(sbindir);g' \
	  -e 's;@steamos_n_partitions@;$(STEAMOS_N_PARTITIONS);g' \
	  -e 's;@steamos_all_partlabels@;$(STEAMOS_ALL_PARTLABELS);g' \
	  -e 's;@grub_binary_relpath@;$(GRUB_BINARY_RELPATH);g' \
	  -e 's;@grub_root_config_relpath@;$(GRUB_ROOT_CONFIG_RELPATH);g' \
	  -e 's;@grub_var_config_relpath@;$(GRUB_VAR_CONFIG_RELPATH);g' \
	  -e 's;@bootconf_relpath@;$(BOOTCONF_RELPATH);g' \
	  -e 's;@roothash_relpath@;$(ROOTHASH_RELPATH);g' \
	  -e 's;@partdefs_reldir@;$(PARTDEFS_RELDIR);g' \
	  -e 's;@factory_reset_stampfile@;$(FACTORY_RESET_STAMPFILE);g' \
	  -e 's;@etc_overlay_absdir@;$(ETC_OVERLAY_ABSDIR);g' \
	  -e 's;@offload_absdir@;$(OFFLOAD_ABSDIR);g' \
	  -e 's;@offload_reldir@;$(OFFLOAD_RELDIR);g' \
	  -e 's;@udev_symlinks_absdir@;$(UDEV_SYMLINKS_ABSDIR);g' \
	  -e 's;@udev_symlinks_reldir@;$(UDEV_SYMLINKS_RELDIR);g' \
	  $< > $@
	@if grep -q '@[[:alnum:]_]*@' $@; then \
	  echo >&2 "Substitution error!!!"; \
	  grep -Hn '@[[:alnum:]_]*@' $@; \
	  false; \
	fi


# -------- Functions -------- #

# _enable-systemd-unit -- Create a symlink to enable a systemd unit

define _enable-systemd-unit
	wantedby=$$(sed -n -E 's/(WantedBy|RequiredBy)\s*=\s*//p' $(1)/$(2)); \
	if [ "$$wantedby" ]; then \
	  install -d "$(1)/$$wantedby.wants"; \
	  cd "$(1)/$$wantedby.wants" && ln -srfv "../$(2)"; \
	fi;
endef

# enable-systemd-units -- Create a symlink to enable a systemd units
#
# Call this funtion during the make install target only, there's no reason
# to call it at any other moment.
#
# Argument 1 is the location of the unit file (eg 'usr/lib/systemd/system')
# Argument 2 is a list of units               (eg 'foo.service bar.mount')

define enable-systemd-units
	@echo "Enabling systemd units $(2)"
	@$(foreach service,$(2),$(call _enable-systemd-unit,$(1),$(service)))
endef
