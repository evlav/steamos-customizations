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

SUBDIRS :=		\
	atomic-update	\
	chainloader	\
	dracut		\
	gpd-quirks	\
	glx		\
	grub		\
	misc		\
	offload		\
	plymouth	\
	settings-importer \
	swap

ALL_TARGETS     := $(patsubst %,all-%,$(SUBDIRS))
INSTALL_TARGETS := $(patsubst %,install-%,$(SUBDIRS))

.PHONY: all
all: $(ALL_TARGETS)

.PHONY: install
install: $(INSTALL_TARGETS)
	# Make sure that all variables were substituted
	@if [ "$(DESTDIR)" ]; then \
	  if grep -rq '@[[:alnum:]_]*@' "$(DESTDIR)"; then \
	    echo >&2 "Substitution error!!!"; \
	    grep -rHn '@[[:alnum:]_]*@' "$(DESTDIR)"; \
	    exit 1; \
	  fi; \
	fi

.PHONY: all-%
all-%:
	$(MAKE) -C $* all

.PHONY: install-%
install-%:
	$(MAKE) -C $* install

