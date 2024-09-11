obj-m := kernel_greeter.o
kernel_greeter-objs := hello_world.o print_messages.o
#kernel_greeter-objs += hello_world.o 
#kernel_greeter-objs += print_messages.o

KDIR := /lib/modules/$(shell uname -r)/build
PWD := $(shell pwd)

default:
	$(MAKE) -C $(KDIR) M=$(PWD) modules

clean:
	$(MAKE) -C $(KDIR) M=$(PWD) clean

install:
	$(MAKE) -C $(KDIR) M=$(PWD) modules_install
