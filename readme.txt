1.install tools.
apt install build-essential git vim flex bison libncurses-dev pkg-config 
apt install bc expect libssl-dev file wget squashfs-tools u-boot-tools tree hexdump

2.install toolchain
wget https://snapshots.linaro.org/gnu-toolchain/14.0-2023.06-1/aarch64-linux-gnu/gcc-linaro-14.0.0-2023.06-x86_64_aarch64-linux-gnu.tar.xz
wget https://snapshots.linaro.org/gnu-toolchain/14.0-2023.06-1/arm-linux-gnueabihf/gcc-linaro-14.0.0-2023.06-aarch64_arm-linux-gnueabihf.tar.xz
mkdir -p /opt/toolchain/
tar gcc-linaro-14.0.0-2023.06-x86_64_aarch64-linux-gnu.tar.xz -C /opt/toolchain/
tar gcc-linaro-14.0.0-2023.06-aarch64_arm-linux-gnueabihf.tar.xz -C /opt/toolchain/

3.build.
make all
make image
ls images
Image  rootfs.img