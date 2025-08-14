PACKAGE := zlib
SRC_URL := https://zlib.net/zlib-1.3.1.tar.gz
DESTDIR := zlib-1.3.1
CONFIGURE_CMD:=CC=$(CROSS_COMPILE)gcc ./configure --prefix=/usr #--static
COMPILE_CMD:=$(MAKE)

#SYSROOT=/opt/toolchain/aarch64-marvell-linux-gnu/sys-root
#export AR=$(CROSS_COMPILE)ar
#export RANLIB=$(CROSS_COMPILE)ranlib
include $(TOPDIR)/include.mk/common.mk

#compile:source
#	@echo "[$(PACKAGE)] Compile step"
