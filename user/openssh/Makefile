
SRC_URL := https://cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-9.5p1.tar.gz
DESTDIR := openssh
CONFIGURE_CMD:=./configure --prefix=/ --host=$(CROSS_HOST) --with-zlib=$(ROOTFS)/usr --with-ssl-dir=$(ROOTFS)/usr
COMPILE_CMD:=$(MAKE)
INSTALL_APP:=ssh scp sshd ssh-keygen sftp-server contrib/ssh-copy-id

include $(TOPDIR)/include.mk/common.mk

romfs:
	for i in $(INSTALL_APP); do \
		install -D $(DESTDIR)/$$i $(ROOTFS)/bin/$$i; \
		$(CROSS_HOST)-strip $(ROOTFS)/bin/$$i; \
	done
	mv $(ROOTFS)/bin/contrib/ssh-copy-id $(ROOTFS)/bin/ssh-copy-id
	rm -rf $(ROOTFS)/bin/contrib

	install -D $(DESTDIR)/ssh        $(ROOTFS)/bin/ssh
	install -D $(DESTDIR)/scp        $(ROOTFS)/bin/scp
	install -D $(DESTDIR)/ssh-keygen $(ROOTFS)/bin/ssh-keygen
	install -D $(DESTDIR)/sftp-server $(ROOTFS)/usr/libexec/sftp-server
	install -D $(DESTDIR)/contrib/ssh-copy-id        $(ROOTFS)/bin/ssh-copy-id
	install -D $(DESTDIR)/sshd        $(ROOTFS)/sbin/sshd
	install -D $(DESTDIR)/sshd_config $(ROOTFS)/etc/sshd_config
	sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' $(ROOTFS)/etc/sshd_config
	sed -i 's@#HostKey /etc/ssh/ssh_host_ecdsa_key@HostKey /etc/ssh/ssh_host_rsa_key@' $(ROOTFS)/etc/sshd_config
	
#compile:source
#	@echo "[$(PACKAGE)] Compile step"
