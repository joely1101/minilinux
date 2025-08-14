SRC_URL := https://www.openssl.org/source/openssl-3.3.2.tar.gz
DESTDIR := openssl

# Configure command for cross-compilation
CONFIGURE_CMD := ./Configure \
    linux-generic32 \
    --prefix=/usr \
    --openssldir=/etc/ssl \
    shared no-tests no-ui-console

# Compile command
MAKE:=make
COMPILE_CMD := make

include $(TOPDIR)/include.mk/common.mk

romfs:
	echo "do ${DESTDIR} install"
	make -C $(DESTDIR) DESTDIR=$(ROOTFS) install_dev

