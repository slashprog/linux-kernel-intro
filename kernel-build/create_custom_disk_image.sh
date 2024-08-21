#!/bin/sh

# Create a new disk image with custom kernel build with busybox as user-land
# ---------------------------------------------------------------------------

# You should notice existence of a new hard drive labeled sdb
# when you run this command on our VirtualBox VM setup.
lsblk

# Create a DOS MBR disklabel (partition format)
parted -s /dev/sdb mklabel msdos

# Create a new partition on this hard drive
parted -s /dev/sdb mkpart primary ext4 1% 100%

# Verify the partition name shown as sdb1
lsblk

# Format this partition (sdb1) using Ext4 filesystem format.
mkfs.ext4 -F /dev/sdb1

# Mount the newly formatted partition into /mnt
mount /dev/sdb1 /mnt

# Install the kernel tarball of our custom kernel build into this
# mounted partition
cd /mnt
tar xvf /usr/local/build/linux-6.10.6-vbox/linux-6.10.6-vbox-x86.tar.xz

# Install the GRUB boot loader on this hard drive - where stage1 of
# the boot loader would reside in the MBR (first sector of the hard drive)
# and grub modules would reside in the /boot/grub/ folder on this
# hard drive's first partition (mounted on /mnt/)
grub-install --boot-directory=/mnt/boot /dev/sdb

# Create a simple GRUB configuration file to boot our kernel.
cat > /mnt/boot/grub/grub.cfg <<END_GRUB_CONFIG
menuentry "Boot Linux 6.10.6-vbox with BusyBox" {
    linux (hd1,1)/boot/vmlinuz-6.10.6-vbox root=/dev/sdb1 rw
}
END_GRUB_CONFIG

# Install BusyBox user-land tools
cp -a /usr/local/build/busybox-1.36.1-vbox/_install/* /mnt/

# Create important top-level folders that are crucial for
# mounting - proc, sysfs, devtmpfs and tmpfs pseudo-filesystems
cd /mnt
mkdir proc sys dev tmp

# The following folders are optional, but good to have them created.
mkdir etc etc var root mnt media run srv

# Busybox init program expects rcS script to be in /etc/init.d/rcS
mkdir -p etc/init.d

# Some var subfolders that might be used by certain services/daemons
mkdir -p var/log var/lib var/local var/cache var/spool var/mail
ln -s ../run var/run
ln -s ../tmp var/tmp

# Create a basic sysinit script that will be run by BusyBox init
cat > /mnt/etc/init.d/rcS << END_RCS
#!/bin/sh

mount proc /proc -t proc
mount sysfs /sys -t sysfs
mount tmpfs /tmp -t tmpfs
mkdir -p /dev/pts
mount devpts /dev/pts -t devpts

# Launch any custom service / application by adding commands below:
echo "Linux system with BusyBox is ready."

END_RCS

chmod +x /mnt/etc/init.d/rcS

