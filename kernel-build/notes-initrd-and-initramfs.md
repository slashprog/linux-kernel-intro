What is the role of initrd / initramfs ?

The initrd / initramfs driver within the Linux kernel provides
a mechanism to host an in-memory filesystem that can be mounted
as root filesystem during the early boot by the kernel. This
in-memory filesystem is loaded by the boot loader along-side
with the kernel

