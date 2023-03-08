include ../common.mk

MKINITCPIOD_IN := $(wildcard mkinitcpio.d/*.in)
HOOKSCRIPTS_IN := $(wildcard initcpio/*.hook.in)
INSTSCRIPTS_IN := $(wildcard initcpio/*.inst.in)

BINARIES_IN     := $(wildcard bin/*.in)
BINARIES        := $(patsubst %.in,%,$(BINARIES_IN))

MKINITCPIOD := $(patsubst %.in,%,$(MKINITCPIOD_IN))
HOOKSCRIPTS := $(patsubst %.in,%,$(HOOKSCRIPTS_IN))
INSTSCRIPTS := $(patsubst %.in,%,$(INSTSCRIPTS_IN))
CLEANABLE   := $(MKINITCPIOD) $(HOOKSCRIPTS) $(INSTSCRIPTS) $(BINARIES)

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
