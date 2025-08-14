PACKAGE := bash
SRC_URL := file://home/jlee/work2/2025/08/vos6.1/src-dl/bash-5.2.tar.gz
SRC_OPTS :=
DESTDIR := bash
PATCH_DIR := 
TOPDIR?=../
TOPDIR:=$(shell readlink -f $(TOPDIR))
ROOTFS:=$(TOPDIR)/rootfs
CONFIGURE_CMD:=./configure --prefix=/ --bindir=/bin --without-bash-malloc --host=$(CROSS_HOST) 
COMPILE_CMD:=make -j8

include $(TOPDIR)/include.mk/common.mk

overwrite romfs:
	install -D $(DESTDIR)/bash $(ROOTFS)/bin/bash
	$(CROSS_HOST)-strip $(ROOTFS)/bin/bash
#compile:source
#	@echo "[$(PACKAGE)] Compile step"
