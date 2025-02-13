include ../common.mk

STEAMOS_DEBUGINFOD_CONFIG := $(wildcard *.urls)

all:

install: all
	install -d $(DESTDIR)/etc/debuginfod
	install -m 0644 $(STEAMOS_DEBUGINFOD_CONFIG) $(DESTDIR)/etc/debuginfod/

