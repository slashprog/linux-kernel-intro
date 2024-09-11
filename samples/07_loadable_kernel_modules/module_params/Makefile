obj-m := simple_kthread.o

KDIR := /lib/modules/$(shell uname -r)/build
PWD := $(shell pwd)

default:
	$(MAKE) -C $(KDIR) M=$(PWD) modules

clean:
	$(MAKE) -C $(KDIR) M=$(PWD) clean

install:
	#$(MAKE) -C $(KDIR) M=$(PWD) INSTALL_MOD_PATH=/mnt INSTALL_MOD_DIR=custom modules_install
	$(MAKE) -C $(KDIR) M=$(PWD) INSTALL_MOD_DIR=custom modules_install
