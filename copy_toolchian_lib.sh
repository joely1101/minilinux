#!/bin/bash
# copy-needed-libs.sh
# Usage: ./copy-needed-libs.sh /path/to/rootfs aarch64-linux-gnu

ROOTFS="$1"
TOOLCHAIN="$2"

if [[ -z "$ROOTFS" || -z "$TOOLCHAIN" ]]; then
    echo "Usage: $0 /path/to/rootfs aarch64-linux-gnu"
    exit 1
fi

SYSROOT=$("$TOOLCHAIN"-gcc -print-sysroot)
if [[ ! -d "$SYSROOT" ]]; then
    echo "Error: sysroot not found"
    exit 1
fi

COPIED=()

copy_lib() {
    local lib="$1"

    # 檢查是否已經複製過
    for c in "${COPIED[@]}"; do
        if [[ "$c" == "$lib" ]]; then return; fi
    done
    COPIED+=("$lib")

    # 找 sysroot 的實際路徑
    local file
    file=$(find "$SYSROOT/lib" "$SYSROOT/usr/lib" "$SYSROOT/lib64" "$SYSROOT/usr/lib64" -name "$lib*" | head -n1)
    if [[ -z "$file" ]]; then
        echo "[!] Library $lib not found"
        return
    fi

    echo "[*] Copying $file"
    cp -v "$file" "$ROOTFS/lib/"

    # 遞歸複製依賴
    local deps
    deps=$(${TOOLCHAIN}-readelf -d "$file" 2>/dev/null | grep NEEDED | awk -F'[][]' '{print $2}')
    for d in $deps; do
        copy_lib "$d"
    done
}

# 找 rootfs 內所有 ELF 檔
ELFS=$(find "$ROOTFS" -type f -exec file {} \; | grep ELF | cut -d: -f1)

for elf in $ELFS; do
    echo "[*] Checking $elf"
    DEPS=$(${TOOLCHAIN}-readelf -d "$elf" 2>/dev/null | grep NEEDED | awk -F'[][]' '{print $2}')
    for dep in $DEPS; do
        copy_lib "$dep"
    done
done

# 複製動態鏈接器
INTERPRETER=$("$TOOLCHAIN"-gcc -print-file-name=ld-linux-aarch64.so.1)
if [[ -f "$INTERPRETER" ]]; then
    echo "[*] Copying interpreter: $INTERPRETER"
    cp -v "$INTERPRETER" "${ROOTFS}/lib/"
fi

echo "[*] Done. All needed libraries copied."
