# -------- Installation directories -------- #

prefix     := /usr
sysconfdir := /etc

bindir     := $(prefix)/bin
datadir    := $(prefix)/share
libdir     := $(prefix)/lib
libexecdir := $(prefix)/libexec
sbindir    := $(prefix)/sbin
systemdunitsdir := $(libdir)/systemd/system
completionsdir := $(shell pkg-config --define-variable=prefix=$(prefix) --variable=completionsdir bash-completion 2>/dev/null \
			  || echo /usr/share/bash-completion/completions/)


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

# GRUB directory (relative to the efi mountpoint)
GRUB_RELPATH := EFI/steamos

# GRUB binary (relative to the efi mountpoint)
GRUB_BINARY_RELPATH := $(GRUB_RELPATH)/grubx64.efi

# GRUB configuration (relative to the efi mountpoint)
GRUB_CONFIG_RELPATH := $(GRUB_RELPATH)/grub.cfg

# SteamOS directory (relative to the efi mountpoint)
STEAMOS_RELPATH := SteamOS

# Bootconf file (relative to the efi mountpoint)
BOOTCONF_OLDPATH := $(STEAMOS_RELPATH)/bootconf
BOOTCONF_RELDIR  := $(STEAMOS_RELPATH)/conf

# Partition sets dir (relative to the efi mountpoint)
PARTSETS_RELDIR := $(STEAMOS_RELPATH)/partsets

# Roothash file (relative to the efi mountpoint)
ROOTHASH_RELPATH := $(STEAMOS_RELPATH)/roothash

# Factory reset config
FACTORY_RESET_CONFIG_DIR := /esp/efi/steamos/factory-reset

# Directory for the /etc overlay
ETC_OVERLAY_ABSDIR := /var/lib/overlays/etc

# Directory for the offloading scheme bind mounts
OFFLOAD_ABSDIR := /home/.steamos/offload

# Directory where partition symlinks are created (relative to /dev)
UDEV_SYMLINKS_RELDIR := disk/by-partsets

# Directory where partition symlinks are created
UDEV_SYMLINKS_ABSDIR := /dev/$(UDEV_SYMLINKS_RELDIR)

# URL to query for updates in atomupd -- maps to ImagesUrl in client.conf
ATOMUPD_IMAGES_URL := https://atomupd-images.steamos.cloud/steamos-holo

# URL to query for updates in atomuud from static .json files -- maps to MetaUrl in client.conf
# This is used by steamos-atomupd >= 0.20220216.0 (steamos-atomupd-git >= r197).
ATOMUPD_META_URL := https://atomupd.steamos.cloud/meta

# Semicolon separated list of known suggested variants that could be chosen.
# This list is currently parsed by atomupd-daemon and exposed in the
# property "VariantsList"
# Please note that the only allowed symbols are lowercase and uppercase
# word characters, numbers, underscore, hyphen and the semicolon as a
# separator.
ATOMUPD_VARIANTS_LIST := holo;holo-beta

# Directory where RAUC will mount the update bundle
RAUC_RUNTIME_DIR := /run/rauc

# Directory where temporary update files will be placed
STEAMOS_ATOMUPD_RUNTIME_DIR := /run/steamos-atomupd

# File used by RAUC to store the installed update version. This allows us to
# record that we have a pending reboot to switch to the new image.
REBOOT_FOR_UPDATE := $(STEAMOS_ATOMUPD_RUNTIME_DIR)/reboot_for_update

# Drop-in directory where users can list additional "/etc" files and
# directories that they want to preserve across updates
ATOMIC_UPDATE_CONF_D := $(sysconfdir)/atomic-update.conf.d

# When applying an update, this is the directory where the edited /etc files
# will be backed up
ETC_BACKUP_DIR := /var/lib/steamos-atomupd/etc_backup

# NOTE: Don't use the semicolon as a separator for sed because it will
# clash with the semicolons used in the variants list
%: %.in
	@echo "Substituting @variables@ in $<"
	@sed \
	  -e 's|@bindir@|$(bindir)|g' \
	  -e 's|@libdir@|$(libdir)|g' \
	  -e 's|@libexecdir@|$(libexecdir)|g' \
	  -e 's|@sbindir@|$(sbindir)|g' \
	  -e 's|@datadir@|$(datadir)|g' \
	  -e 's|@steamos_n_partitions@|$(STEAMOS_N_PARTITIONS)|g' \
	  -e 's|@steamos_all_partlabels@|$(STEAMOS_ALL_PARTLABELS)|g' \
	  -e 's|@grub_binary_relpath@|$(GRUB_BINARY_RELPATH)|g' \
	  -e 's|@grub_config_relpath@|$(GRUB_CONFIG_RELPATH)|g' \
	  -e 's|@steamos_relpath@|$(STEAMOS_RELPATH)|g' \
	  -e 's|@bootconf_reldir@|$(BOOTCONF_RELDIR)|g' \
	  -e 's|@bootconf_oldpath@|$(BOOTCONF_OLDPATH)|g' \
	  -e 's|@roothash_relpath@|$(ROOTHASH_RELPATH)|g' \
	  -e 's|@partsets_reldir@|$(PARTSETS_RELDIR)|g' \
	  -e 's|@factory_reset_config_dir@|$(FACTORY_RESET_CONFIG_DIR)|g' \
	  -e 's|@etc_overlay_absdir@|$(ETC_OVERLAY_ABSDIR)|g' \
	  -e 's|@offload_absdir@|$(OFFLOAD_ABSDIR)|g' \
	  -e 's|@udev_symlinks_reldir@|$(UDEV_SYMLINKS_RELDIR)|g' \
	  -e 's|@udev_symlinks_absdir@|$(UDEV_SYMLINKS_ABSDIR)|g' \
	  -e 's|@atomupd_images_url@|$(ATOMUPD_IMAGES_URL)|g' \
	  -e 's|@atomupd_meta_url@|$(ATOMUPD_META_URL)|g' \
	  -e 's|@atomupd_variants_list@|$(ATOMUPD_VARIANTS_LIST)|g' \
	  -e 's|@rauc_runtime_dir@|$(RAUC_RUNTIME_DIR)|g' \
	  -e 's|@steamos_atomupd_runtime_dir@|$(STEAMOS_ATOMUPD_RUNTIME_DIR)|g' \
	  -e 's|@reboot_for_update@|$(REBOOT_FOR_UPDATE)|g' \
	  -e 's|@atomic_update_conf_d@|$(ATOMIC_UPDATE_CONF_D)|g' \
	  -e 's|@etc_backup_dir@|$(ETC_BACKUP_DIR)|g' \
	  $< > $@
	@if grep -q '@[[:alnum:]_]*@' $@; then \
	  echo >&2 "Substitution error!!!"; \
	  grep -Hn '@[[:alnum:]_]*@' $@; \
	  false; \
	fi

clean:
	@echo checking $(CLEANABLE)
	@for x in $(CLEANABLE); do rm -vf $$x; done

# -------- Functions -------- #

# _enable-systemd-unit -- Create a symlink to enable a systemd unit

define _enable-systemd-unit
	wantedby=$$(sed -n -E 's/(WantedBy|RequiredBy)\s*=\s*//p' $(1)/$(2)); \
	if [ "$$wantedby" ]; then \
	  for unit in $$wantedby; do \
	    install -d "$(1)/$$unit.wants"; \
	    cd "$(1)/$$unit.wants" && ln -srfv "../$(2)"; \
	  done; \
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
