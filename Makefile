
#export MAKE:=make -j$(shell getconf _NPROCESSORS_ONLN)
export MAKE:=make

#export PATH:=$(PATH):/usr/local/toolchain/arm-gnu-toolchain-14.3.rel1-x86_64-arm-none-linux-gnueabihf/bin
#export CROSS_HOST:=arm-none-linux-gnueabihf
export PATH:=$(PATH):/usr/local/toolchain/marvell-tools-12006.0/bin
export CROSS_COMPILE_KERNEL:=aarch64-marvell-linux-gnu-
export PATH:=$(PATH):/usr/local/toolchain/gcc-linaro-14.0.0-2023.06-x86_64_arm-linux-gnueabihf/bin
export CROSS_HOST:=arm-linux-gnueabihf
export CROSS_COMPILE:=${CROSS_HOST}-
#export PATH:=$(PATH):/usr/local/toolchain/gcc-linaro-14.0.0-2023.06-x86_64_aarch64-linux-gnu/bin
#export CROSS_COMPILE_KERNEL:=aarch64-linux-gnu-
export TOPDIR=$(shell pwd)
export ROOTFS:=$(TOPDIR)/rootfs

dirs:=kernel/linux-6.1.x user
.ONESHELL:

.PHONY: all showconfig romfs_prepare romfs build_all image

all: romfs_prepare build_all romfs image
	echo "build all finished"

build_all:
	for dir in $(dirs); do
		make -C $$dir || exit 1;
	done
%:
	for dir in $(dirs); do
		make -C $$dir $@;
	done

%_only:
	[ ! -d "$(@:_only=)" ] || make -C $(@:_only=)

%_romfs:
	[ ! -d "$(@:_romfs=)" ] || make -C $(@:_romfs=) romfs

%_source:
	[ ! -d "$(@:_source=)" ] || make -C $(@:_source=) source

%_build:
	[ ! -d "$(@:_build=)" ] || make -C $(@:_build=) build

%_clean:
	[ ! -d "$(@:_clean=)" ] || make -C $(@:_clean=) clean

%_distclean:
	[ ! -d "$(@:_distclean=)" ] || make -C $(@:_distclean=) distclean

romfs_prepare:
	mkdir -p rootfs images
	cp -a rootfs.base/* rootfs/
	mkdir -p rootfs/{lib,dev,proc,sys,tmp,usr,etc,bin,sbin,var}
	mkdir -p rootfs/etc/ssh

romfs: romfs_prepare
	for dir in $(dirs); do
		make -C $$dir romfs;
	done
	./copy_toolchian_lib.sh rootfs $(CROSS_HOST)
image:
	ln -sf busybox rootfs/bin/init
	rm -f images/rootfs.img rootfs.sqsh
	mksquashfs rootfs rootfs.sqsh -comp gzip
	mkimage -A arm64 -O linux -T ramdisk -C none -n "My RootFS" -d rootfs.sqsh images/rootfs.img
	rm rootfs.sqsh
	ls images/

showconfig:
	echo "dirs:$(dirs)"
	echo "TOPDIR:$(TOPDIR)"
	echo "CROSS_COMPILE=$(CROSS_COMPILE)"
