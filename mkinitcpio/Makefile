include ../common.mk

MKINITCPIOD_IN := $(wildcard mkinitcpio.d/*.in)
HOOKSCRIPTS_IN := $(wildcard initcpio/*.hook.in)
INSTSCRIPTS_IN := $(wildcard initcpio/*.inst.in)

ALPM_HOOKS_IN   := $(wildcard alpm/hooks/*.in)
ALPM_HOOKS      := $(patsubst %.in,%,$(ALPM_HOOKS_IN))
ALPM_SCRIPTS_IN := $(wildcard alpm/scripts/*.in)
ALPM_SCRIPTS    := $(patsubst %.in,%,$(ALPM_SCRIPTS_IN))

BINARIES_IN     := $(wildcard bin/*.in)
BINARIES        := $(patsubst %.in,%,$(BINARIES_IN))

MKINITCPIOD := $(patsubst %.in,%,$(MKINITCPIOD_IN))
HOOKSCRIPTS := $(patsubst %.in,%,$(HOOKSCRIPTS_IN))
INSTSCRIPTS := $(patsubst %.in,%,$(INSTSCRIPTS_IN))
CLEANABLE   := $(MKINITCPIOD) $(HOOKSCRIPTS) $(INSTSCRIPTS) $(BINARIES) \
               $(ALPM_SCRIPTS) $(ALPM_HOOKS)

all: $(CLEANABLE)

install: all
	@install -d $(DESTDIR)$(sbindir)
	@install -m 0755 $(BINARIES) $(DESTDIR)$(sbindir)
	@install -d $(DESTDIR)/etc/initcpio/hooks
	@(for S in $(HOOKSCRIPTS); \
	  do \
	      dest=$${S%.hook};  \
	      dest=$${dest##*/}; \
	      install -m 0755 $$S $(DESTDIR)/etc/initcpio/hooks/$$dest; \
	  done)
	@install -d $(DESTDIR)/etc/initcpio/install
	@(for S in $(INSTSCRIPTS); \
	  do \
	      dest=$${S%.inst};  \
	      dest=$${dest##*/}; \
	      install -m 0755 $$S $(DESTDIR)/etc/initcpio/install/$$dest; \
	  done)
	@install -d $(DESTDIR)/etc/mkinitcpio.d
	@install -m 0644 $(MKINITCPIOD) $(DESTDIR)/etc/mkinitcpio.d
	@install -d $(DESTDIR)$(datadir)/libalpm/hooks
	@install -m 644 $(ALPM_HOOKS) $(DESTDIR)$(datadir)/libalpm/hooks
	@install -d $(DESTDIR)$(datadir)/libalpm/scripts
	@install -m 755 $(ALPM_SCRIPTS) $(DESTDIR)$(datadir)/libalpm/scripts
