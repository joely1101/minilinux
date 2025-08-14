PACKAGE := busybox
SRC_URL := git://busybox.net/busybox.git
SRC_OPTS := --depth=1
DESTDIR := busybox
PATCH_DIR := 
ROOTFS:=$(TOPDIR)/rootfs
CONFIGURE_CMD:=cp ../busybox.config .config&&make oldconfig
COMPILE_CMD:=$(MAKE)
include $(TOPDIR)/include.mk/common.mk

romfs:
	make -C $(DESTDIR) CONFIG_PREFIX=$(ROOTFS) install 

#compile:source
#	@echo "[$(PACKAGE)] Compile step"
