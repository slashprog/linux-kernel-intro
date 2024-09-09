#!/bin/sh

# Create a new initramfs image with custom kernel build with busybox as user-land
# -------------------------------------------------------------------------------

# Step 1: Create a template folder to host initramfs filesystem contents
mkdir -p /usr/local/build/initramfs-6.10.6-vbox/rootfs

# Install kernel modules of our custom kernel build into this folder
# We dont need the kernel image in the initramfs, just loadable kernel
# modules that are part of the kernel build should do.
cd /usr/local/build/initramfs-6.10.6-vbox/rootfs
tar xvf /usr/local/build/linux-6.10.6-vbox/linux-6.10.6-vbox-x86.tar.xz lib usr/lib

# Install BusyBox user-land tools
cp -a /usr/local/build/busybox-1.36.1-vbox/_install/* .

# Modern initramfs image requires /init and not /linuxrc
mv linuxrc init

# Create important top-level folders that are crucial for
# mounting - proc, sysfs, devtmpfs and tmpfs pseudo-filesystems
mkdir proc sys dev tmp

# The following folders are optional, but good to have them created.
mkdir etc var root mnt media run srv

# Busybox init program expects rcS script to be in /etc/init.d/rcS
mkdir -p etc/init.d

# Some var subfolders that might be used by certain services/daemons
mkdir -p var/log var/lib var/local var/cache var/spool var/mail
ln -s ../run var/run
ln -s ../tmp var/tmp

# Create a basic sysinit script that will be run by BusyBox init
# Note that we need to manually mount devtmpfs in this script
# as the kernel does not mount devtmpfs while booting via initramfs
cat > etc/init.d/rcS << END_RCS
#!/bin/sh

mount proc /proc -t proc
mount sysfs /sys -t sysfs
mount tmpfs /tmp -t tmpfs
mount devtmpfs /dev -t devtmpfs # this is required
mkdir -p /dev/pts
mount devpts /dev/pts -t devpts

# Launch any custom service / application by adding commands below:
echo "Linux system with BusyBox is ready."

END_RCS

chmod +x etc/init.d/rcS

### Step 2: Create a cpio archive from the template folder
# Now create a cpio archive using the new cpio format from this folder
find . | cpio -H newc -o | gzip -c > ../initramfs-6.10.6-vbox.cpio.gz

### Step 3: Install the initramfs image so that the boot loader can locate them.
# Let us install this initramfs image on your new hard drive boot
mount /dev/sdb1 /mnt
cp /usr/local/build/initramfs-6.10.6-vbox/initramfs-6.10.6-vbox.cpio.gz /mnt/boot/

### Step 4: Configure the boot loader to load initramfs alongside with the kernel
# Add a new entry in the GRUB configuration file to boot our kernel
# with initramfs image as root filesystem
cat >> /mnt/boot/grub/grub.cfg <<END_GRUB_CONFIG
menuentry "Boot Linux 6.10.6-vbox with BusyBox via initramfs" {
    linux (hd1,1)/boot/vmlinuz-6.10.6-vbox
    initrd (hd1,1)/boot/initramfs-6.10.6-vbox.cpio.gz
}
END_GRUB_CONFIG

