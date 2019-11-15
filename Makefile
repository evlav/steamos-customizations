# Canonical top directory
TOPDIR := $(realpath $(CURDIR))
export TOPDIR

# Debugging?
$(info "MAKE         : $(MAKE)")
$(info "CURDIR       : $(CURDIR)")
$(info "MAKEFLAGS    : $(MAKEFLAGS)")
$(info "MAKEOVERRIDES: $(MAKEOVERRIDES)")
$(info "TOPDIR: $(TOPDIR)")
$(info "DESTDIR: $(DESTDIR)")

.PHONY: all install clean

all: all-atomic-update all-chainloader all-dracut all-gpd-quirks all-glx all-grub all-misc all-swap

install: install-atomic-update install-chainloader install-dracut install-gpd-quirks install-glx install-grub install-misc install-swap
	# Make sure that all variables were substituted
	@if [ "$(DESTDIR)" ]; then \
	  if grep -rq '@[[:alnum:]_]*@' "$(DESTDIR)"; then \
	    echo >&2 "Substitution error!!!"; \
	    grep -rHn '@[[:alnum:]_]*@' "$(DESTDIR)"; \
	    exit 1; \
	  fi; \
	fi

all-%:
	$(MAKE) -C $* all


install-%:
	$(MAKE) -C $* install

