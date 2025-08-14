# common.mk

# 使用者需定義
# SRC_URL := ...
# DESTDIR := ...
# PATCH_DIR := patchdir/000*-xxx.diff
# PACKAGE := 套件名稱 (用於 log)
# COMPILE_CMD := (可選) 編譯指令，例如 "make"、"cmake --build ."
PACKAGE ?= $(notdir  $(DL_DIR))
# 從 URL 判斷協議 (file/http/ftp/scp...)
SRC_SCHEME := $(firstword $(subst :, ,$(SRC_URL)))

# 取得檔名（去除目錄部分）
DL_FILE    := $(notdir $(SRC_URL))

# 如果是 file:// 開頭，轉成實際路徑
LOCAL_PATH := /$(patsubst file://%,%,$(SRC_URL))

# 預設下載目錄（可在外部 Makefile 覆蓋）
DL_DIR ?= .
.PHONY: overwrite
overwrite =

.ONESHELL:

.PHONY: source download extract patch build clean
all:download extract patch configure build
source: download extract patch

ifeq ($(TOPDIR),)
$(error TOPDIR must be set)
endif
ifeq ($(ROOTFS),)
$(error ROOTFS must be set)
endif

ifeq ($(CROSS_COMPILE),)
$(error CROSS_COMPILE must be set)
endif

ifeq (, $(shell command -v $(CROSS_COMPILE)gcc 2>/dev/null))
$(error [FAIL] $(CROSS_COMPILE)gcc not found in PATH)
endif

download:$(DESTDIR)/.downloaded
extract: $(DESTDIR)/.extracted
configure: $(DESTDIR)/.configured
patch: $(DESTDIR)/.patched
build: $(DESTDIR)/.built

$(DESTDIR)/.downloaded:
	@if [ -f $(DL_DIR)/$(DL_FILE) ]; then \
		echo "[$(PACKAGE)] $(DL_FILE) already exists locally.";\
		exit 0;\
    fi
ifeq ($(SRC_SCHEME),file)
	@if [ ! -f $(DL_DIR)/$(DL_FILE) ]; then \
		echo "[$(PACKAGE)] Copying local file $(LOCAL_PATH) → $(DL_DIR)/"; \
		cp $(SRC_OPTS) "$(LOCAL_PATH)" "$(DL_DIR)/"; \
	else \
		echo "[$(PACKAGE)] $(DL_FILE) already exists locally."; \
	fi
else ifeq ($(SRC_SCHEME),http)
	@echo "[$(PACKAGE)] Downloading via HTTP: $(SRC_URL)"
	@wget $(SRC_OPTS) -O "$(DL_DIR)/$(DL_FILE)" "$(SRC_URL)"
else ifeq ($(SRC_SCHEME),https)
	@echo "[$(PACKAGE)] Downloading via HTTPs: $(SRC_URL)"
	@wget $(SRC_OPTS) --no-check-certificate -O "$(DL_DIR)/$(DL_FILE)" "$(SRC_URL)"
else ifeq ($(SRC_SCHEME),ftp)
	@echo "[$(PACKAGE)] Downloading via FTP: $(SRC_URL)"
	@wget $(SRC_OPTS) -O "$(DL_DIR)/$(DL_FILE)" "$(SRC_URL)"
else ifeq ($(SRC_SCHEME),scp)
	@echo "[$(PACKAGE)] Copying via SCP: $(SRC_URL)"
	@scp $(SRC_OPTS) "$(subst scp://,,$(SRC_URL))" "$(DL_DIR)/"
else ifeq ($(SRC_SCHEME),git)
	@echo "[$(PACKAGE)] git clone: $(SRC_URL)"
	@if [ -d $(DESTDIR) ]; then \
		echo "[$(PACKAGE)] $(DESTDIR) already exists locally."; exit 0;\
	fi
	@git clone $(SRC_OPTS) "$(SRC_URL)" "$(DESTDIR)"
else
	$(error Unsupported SRC_SCHEME '$(SRC_SCHEME)' in SRC_URL=$(SRC_URL))
endif



$(DESTDIR)/.extracted:$(DESTDIR)/.downloaded
	@if [ -f $(@) ]; then \
		echo "[$(PACKAGE)] $(DESTDIR) already extracted.";\
		exit 0;\
    fi

	@echo "[$(PACKAGE)] Extract step"
ifeq ($(SRC_SCHEME),git)
	@echo "[$(PACKAGE)] Git clone done, no extraction needed."
else
	@if [ ! -d $(DESTDIR) ]; then \
		echo "[$(PACKAGE)] Extracting $(DL_FILE) into $(DESTDIR)..."; \
		mkdir -p $(DESTDIR); \
		case $(DL_FILE) in \
			*.tar.gz|*.tgz) tar -xzf $(DL_FILE) -C $(DESTDIR) --strip-components=1 ;; \
			*.tar.bz2) tar -xjf $(DL_FILE) -C $(DESTDIR) --strip-components=1 ;; \
			*.tar.xz) tar -xJf $(DL_FILE) -C $(DESTDIR) --strip-components=1 ;; \
			*.zip) unzip -q $(DL_FILE) -d $(DESTDIR) ;; \
			
			*) echo "[$(PACKAGE)] Unknown archive format: $(DL_FILE)"; exit 1 ;; \
		esac \
	else \
		echo "[$(PACKAGE)] $(DESTDIR) already exists, skipping extract."; \
	fi;
endif
	touch $@

$(DESTDIR)/.patched:$(DESTDIR)/.extracted
	@if [ -f $(@) ]; then \
		echo "[$(PACKAGE)] $(DESTDIR) already patched.";\
		exit 0;\
    fi
	@echo "[$(PACKAGE)] Patch step"
	@if [ -f $(DESTDIR)/.patched ]; then \
		echo "[$(PACKAGE)] $(DESTDIR) already patched."; exit 0;\
	fi
	@if [ -d $(DESTDIR) ] && [ -d "$(PATCH_DIR)" ]; then \
		for p in $(shell ls $(PATCH_DIR)/*.diff $(PATCH_DIR)/*.patch 2>/dev/null | sort); do \
			if [ -f "$$p" ]; then \
				echo "[$(PACKAGE)] Applying patch $$p..."; \
				patch -d $(DESTDIR) -p1 < "$$p" || exit 1; \
			fi; \
		done; \
	else \
		echo "[$(PACKAGE)] No patches to apply $(DESTDIR) .. $(PATCH_DIR)."; \
	fi
	touch $@

$(DESTDIR)/.configured: $(DESTDIR)/.patched
	@if [ -f $(@) ]; then \
		echo "[$(PACKAGE)] $(DESTDIR) already configured.";\
		exit 0;\
    fi
ifeq ($(CONFIGURE_CMD),)	
	@echo "[$(PACKAGE)] NO Configuring..."	
else
	@echo "cmd:${CONFIGURE_CMD}"
	@if [ -d $(DESTDIR) ]; then \
		echo "[$(PACKAGE)] Running Configuring $(DESTDIR)..."; \
		(cd $(DESTDIR) && $(CONFIGURE_CMD)) || exit 1; \
	else \
		echo "[$(PACKAGE)] $(DESTDIR) not found, cannot Configuring."; \
		exit 1; \
	fi
endif
	touch $@

$(DESTDIR)/.built:configure
	@echo "[$(PACKAGE)] Compile step"
ifeq ($(COMPILE_CMD),)
	@echo "[$(PACKAGE)] No compile command specified, skipping compile."
else
	@if [ -d $(DESTDIR) ]; then \
		echo "[$(PACKAGE)] Running compile command in $(DESTDIR)..."; \
		(cd $(DESTDIR) && $(COMPILE_CMD)) || exit 1; \
	else \
		echo "[$(PACKAGE)] $(DESTDIR) not found, cannot compile."; \
		exit 1; \
	fi
endif
	touch $@

romfs:
	if [ -z "$(ROOTFS)" ]; then \
		echo "[$(PACKAGE)] ROOTFS not specified."; exit 1; \
	fi
	@echo "install $(DESTDIR) to $(ROOTFS)"
	make -C $(DESTDIR) DESTDIR=$(ROOTFS) install

clean:
	@rm -rf $(DESTDIR)/.built $(DESTDIR)/.configured

distclean:
	@echo "[$(PACKAGE)] Clean step"
	@if [ -d $(DESTDIR) ]; then rm -rf $(DESTDIR); fi
	@if [ -f $(DL_FILE) ]; then rm -f $(DL_FILE); fi
