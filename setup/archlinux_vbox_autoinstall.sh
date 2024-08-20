#!/bin/bash

# Create a single large partition for the first hard-drive (sda) using 
# MS-DOS partitioning scheme. The VirtualBox BIOS is configured to boot
# in Legacy BIOS mode and not UEFI. So GPT-style partitioning scheme is not used
parted -s /dev/sda mklabel msdos
parted -s /dev/sda mkpart primary ext4 0% 100%

# Format this partition (sda1) using Ext4 filesystem format.
mkfs.ext4 -F /dev/sda1

# Mount the freshly created and formatted partition into /mnt
mount /dev/sda1 /mnt

# The following command updates the mirrorlist by testing their access speeds
reflector > /etc/pacman.d/mirrorlist

# Install the following packages (some are needed for kernel build / development)
# There are others which are optional (vim, tmux, mc, most, tree, etc...)
pacstrap /mnt base base-devel grub parted openssh git bc cpio ntp htop cscope \
	      linux-lts linux-lts-headers linux-lts-docs linux-api-headers    \
	      man-db man-pages texinfo most bat tree mc vim tmux starship     \
	      linux-firmware ccache llvm gdb lldb crash pahole kexec-tools    \
	      bpftrace perf trace-cmd elfutils strace


# Create a stage 2 installer script that sets up the system profile/configuration
cat > /mnt/root/install_stage2.sh <<ENDSTAGE2
#!/bin/bash

# Install GRUB on the first sector of hard disk (sda) a.k.a the MBR
grub-install /dev/sda

cat > /etc/default/grub <<ENDGRUBDEFAULT
GRUB_DEFAULT=0
GRUB_TIMEOUT=5
GRUB_DISTRIBUTOR="Arch"
GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3"
GRUB_CMDLINE_LINUX=""
GRUB_PRELOAD_MODULES="part_msdos"
GRUB_TIMEOUT_STYLE=menu
GRUB_TERMINAL_INPUT=console
GRUB_TERMINAL_OUTPUT=console
GRUB_DISABLE_LINUX_UUID=true
GRUB_DISABLE_RECOVERY=true
ENDGRUBDEFAULT

grub-mkconfig -o /boot/grub/grub.cfg  

# Setup timezone (sorry, it is in Indian timezone now)
# Kindly change to your country's timezone as required
ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
hwclock --systohc

sed -ie 's/#en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen
locale-gen
echo 'LANG=en_US.UTF-8.UTF-8' > /etc/locale.conf

# Setup network configuration
cat > /etc/systemd/network/20-wired.network <<ENDNETCONF
[Match]
Name=enp0s*

[Network]
DHCP=yes
ENDNETCONF

systemctl enable systemd-networkd
systemctl enable systemd-resolved

# Configure SSH server and allow login as 'root' user from remote hosts.
sed -ie 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
systemctl enable sshd

# The root user's password is set to 'welcome'. We are not building a secure system.
echo 'root:welcome' | chpasswd

timedatectl set-ntp true # This didn't work. Need to re-check as to 'why it failed'

# Setup basic shell and vim profile to be more kernel developer-friendly
# These scripts work for now, but needs a more thorough review.
cd /root
curl -o - https://files.chandrashekar.info/root_shell_profile.tar.gz | gunzip -c | tar x

# This is where we will maintain kernel and busybox builds
mkdir -p /usr/local/build

# Template .config files for building Linux kernel and Busybox
# tailored to work within our VirtualBox emulated hardware setup
mkdir /root/config_files
cd /root/config_files
curl -O https://files.chandrashekar.info/linux-config-archvm
curl -O https://files.chandrashekar.info/busybox-config

exit
ENDSTAGE2
chmod +x /mnt/root/install_stage2.sh

arch-chroot /mnt /root/install_stage2.sh
rm /mnt/root/install_stage2.sh

umount /mnt        # Installation complete. Unmount /mnt
eject /dev/cdrom   # Eject CD-ROM, in order to boot from hard-disk image 
poweroff           # Power down the VM

