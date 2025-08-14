PACKAGE := dropbear-2025.88
SRC_URL := https://matt.ucc.asn.au/dropbear/releases/dropbear-2025.88.tar.bz2
DESTDIR := dropbear
ROOTFS:=$(TOPDIR)/rootfs
CONFIGURE_CMD:=./configure --host=$(CROSS_HOST) --with-zlib=$(ROOTFS)/usr
COMPILE_CMD:=make

#export CFLAGS=-I$ROOTFS/usr/include
#export LDFLAGS=-L$ROOTFS/usr/lib
export CFLAGS=-DHAVE_CRYPT=1

include $(TOPDIR)/include.mk/common.mk

romfs:
	@echo "install $(DESTDIR) to $(ROOTFS)"
	make -C $(DESTDIR) DESTDIR=$(ROOTFS) install
#compile:source
#	@echo "[$(PACKAGE)] Compile step"
