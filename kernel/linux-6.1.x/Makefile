PACKAGE := linux-6.1.x
SRC_URL := https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.1.147.tar.xz
DESTDIR := linux-6.1.147
IMAGE:=$(TOPDIR)/images
CROSS_COMPILE_KERNEL ?= $(CROSS_COMPILE)
COMPILE_CMD:=ARCH=arm64 CROSS_COMPILE=$(CROSS_COMPILE_KERNEL) $(MAKE) Image
include $(TOPDIR)/include.mk/common.mk

.PHONY: build

$(DESTDIR)/.config:
	echo "[$(PACKAGE)] copy ${DESTDIR}/.config file"
	cp kernel.config $(DESTDIR)/.config && make ARCH=arm64 CROSS_COMPILE=$(CROSS_COMPILE_KERNEL) -C $(DESTDIR) olddefconfig

undefine build
build:source $(DESTDIR)/.config
	echo "[$(PACKAGE)] Build step xxxxx"
	make -j8 ARCH=arm64 CROSS_COMPILE=$(CROSS_COMPILE_KERNEL) -C $(DESTDIR) Image

undefine clean
clean:
	echo "[$(PACKAGE)] Build clean step"
	make -j8 ARCH=arm64 CROSS_COMPILE=$(CROSS_COMPILE_KERNEL) -C $(DESTDIR) clean

undefine romfs
romfs:
	cp $(DESTDIR)/arch/arm64/boot/Image $(IMAGE)/Image

#compile:source
#	@echo "[$(PACKAGE)] Compile step"
