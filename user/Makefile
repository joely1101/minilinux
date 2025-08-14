dirs:=zlib bash busybox openssl openssh

.ONESHELL:
%:
	for dir in $(dirs); do
		make -C $$dir $@ || exit 1;
	done

all:
	for dir in $(dirs); do
		$(MAKE) -C $$dir || exit 1;
		$(MAKE) -C $$dir romfs || exit 1;
	done

showconfig:
	echo "dirs:$(dirs)"
	echo "CROSS_COMPILE=$(CROSS_COMPILE)"
