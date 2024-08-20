#!/bin/sh

# Building Linux kernel from the stable tree source tarball
# ----------------------------------------------------------

# Variables that you may change to suit the kernel version
# and your folder layout

KERNEL_VERSION=6.10.6
KERNEL_MAJOR_VERSION=v6.x

# This suffix will be added to the build folders and the kernel release
# As we are building a kernel customized for VirtualBox VM hardware
# configuration, we will add '-vbox' as the suffix. But you may change
# this to your own preference.

KERNEL_BUILD_SUFFIX=vbox
KERNEL_RELEASE="${KERNEL_VERSION}-${KERNEL_BUILD_SUFFIX}"

KERNEL_SOURCE="linux-${KERNEL_VERSION}"
KERNEL_BUILD="linux-${KERNEL_RELEASE}"

KERNEL_SOURCE_URL="https://cdn.kernel.org/pub/linux/kernel/${KERNEL_MAJOR_VERSION}/${KERNEL_SOURCE}.tar.xz"

KERNEL_CONFIG_URL="https://raw.githubusercontent.com/slashprog/linux-kernel-intro/main/kernel-build/kernel-config-vbox"

# You may use this alternate URL instead of the long github url if you prefer 
#KERNEL_CONFIG_URL="https://files.chandrashekar.info/kernel-config-vbox"

SOURCE_FOLDER=/usr/local/src/${KERNEL_SOURCE}
BUILD_FOLDER=/usr/local/build/${KERNEL_BUILD}
WORK_FOLDER=${HOME}

#----------------------------------------------------------------------------
#### Preparing the environment

# Change to user's home folder and download the tarball
cd $WORK_FOLDER
curl -O $KERNEL_SOURCE_URL 

# Ensure that the source and build folders exist, else create them
mkdir -p /usr/local/src
mkdir -p /usr/local/build

# Untar the kernel source tarball into /usr/local/src/ folder
tar xvf ${KERNEL_SOURCE}.tar.xz -C /usr/local/src/

# Good practice for beginners:
# Write-protect the source folder tree to avoid accidental changes
# to source files that can mess up kernel builds and also complicate
# kernel module development. We are root user, so chmod/chown wont
# help. We need to use 'chattr' command to set the immutability
# attribute (+i) recursively to the source folder. The 'f' switch
# silences errors that occur on symlinks as they do not support
# changing attributes (only regular files and folders do).
chattr -Rf +i $SOURCE_FOLDER 

# Create a custom build folder to host the kernel config and build files.
# Note: we are adding a -vbox suffix to indicate that the build is meant
# for VirtualBox VM emulated hardware configuration.
mkdir -p $BUILD_FOLDER 

### Step 1: Create a .config using the make configuration target
# In our specific case - we will use a template .config file that I've
# used to build an earlier kernel version to save time.
curl -o ${BUILD_FOLDER}/.config $KERNEL_CONFIG_URL 
  
# Change current working directory to the source folder
cd $SOURCE_FOLDER

# Use the existing .config file that we downloaded into the build folder
# and customize options specific to the newer kernel based on this .config
# Note that capital - O and not zero (0) after the make command.
# Also, no spaces surround the = sign
make O=${BUILD_FOLDER} oldconfig

# The 'oldconfig' target above will use the existing .config file in the
# BUILD_FOLDER as the template and prompt for any new config settings as
# per new kernel features. In order to review the configuration thoroughly
# and make customizations, you can uncomment either of the following commands:

# Launch a modern ncurses-based Textual User Interface to review configuration
# and customize the same
#make O=${BUILD_FOLDER} nconfig

# Launch a dialog-based Textual User Interface (most popular and existed from
# the earliest versions of Linux kernel) to review configuration and customize
#make O=${BUILD_FOLDER} menuconfig

### Step 2: Build the kernel and create a build tarball
# Traditionally, you could build the kernel binary image separately, 
# then build (loadable) kernel modules, and install the same. But the install
# target is known to break on many Linux distributions as distros expect us
# to build kernel from their own maintained source packages. 
# Therefore, we will create a build tarball that we can manually install.
#
# UPDATE: I've encountered a bug in 6.10.6 where tarxz-pkg breaks while
# running depmod command as the tar skeleton folder is not fully FHS 
# compliant. We might have to create a build tarball manually for now.
#make O=${BUILD_FOLDER} tarxz-pkg

# The above command should build the kernel image, modules and create 
# a tarball that would reside in the BUILD_FOLDER as ${KERNEL_BUILD}-x86.tar.xz
# e.g., /usr/local/build/linux-6.10.6-vbox-x86.tar.xz

# If you face errors during the build process where the compiler processes
# get SIGKILLed due to Out-Of-Memory (OOM) issues, try adding a '-j1'
# switch to avoid parallel compilation; trade-off is that the build process
# will take a much longer time (can run to a couple of hours).
# I have noticed this issue on my machines, both VM and bare-metal system
# (my laptop that has 32 GiB of RAM) since Linux 5.1 kernel builds.
# Strangely, this has not being reported as a bug by anyone else for a long
# time - which could mean that this is something specific to my build 
# configuration. I'm still investigating this issue and update accordingly.
#
# TLDR; comment the line with 'make' command above and uncomment the line
# below and run again if your build breaks.
#make -j1 O=${BUILD_FOLDER} tarxz-pkg

make -j1 O=${BUILD_FOLDER} # Remove the -j1 switch to parallelize the build

# After the build is complete, the bootable kernel image is located as 
# ${BUILD_FOLDER}/arch/x86/boot/bzImage. Let us create a skeletal top-level
# folder tree and copy the kernel there.
# We are doing this manually right now as 'make tarxz-pkg' is broken
# on Linux 6.10.6. 
mkdir -p ${BUILD_FOLDER}/tar-install/boot
cp ${BUILD_FOLDER}/arch/x86/boot/bzImage \
   ${BUILD_FOLDER}/tar-install/boot/vmlinuz-${KERNEL_RELEASE}

# Let's create the skeletal module folders and install modules there.
mkdir -p ${BUILD_FOLDER}/tar-install/usr/lib/modules
ln -s usr/lib ${BUILD_FOLDER}/tar-install/lib
make O=${BUILD_FOLDER} INSTALL_MOD_PATH=${BUILD_FOLDER}/tar-install/ modules_install 

# Now let's create a tarball from the tar-install/ folder
tar cvJf ${BUILD_FOLDER}/${KERNEL_BUILD}-x86.tar.xz -C \
	${BUILD_FOLDER}/tar-install boot lib usr


### Step 3: Install the kernel and modules
# Kernel binary image for x86-based machines generally reside
# as /boot/vmlinuz-${KERNEL_RELEASE}
cd /  # The tar file stores entries in relative path
tar xvf ${BUILD_FOLDER}/${KERNEL_BUILD}-x86.tar.xz \
	boot/vmlinuz-${KERNEL_RELEASE} -C /

# There are other files in /boot folder within the build tar-ball 
# (vmlinux, config and System.map) which we do NOT need for booting
# the kernel. These files are useful for kernel debugging purposes.
# We have also embedded the .config into the kernel image as part
# of the kernel build (using CONFIG_IKCONFIG=y), so we dont need
# the config file to be there in the /boot folder.


# The in-tree loadable kernel modules generally reside
# under /lib/modules/${KERNEL_RELEASE}/.
# NOTE: On most modern Linux distros, /lib is a symlink, so extracting from
# tarball must be done carefully as to NOT overwrite the existing symlink

tar xvf ${BUILD_FOLDER}/${KERNEL_BUILD}-x86.tar.xz \
	lib/modules/${KERNEL_RELEASE} -C /


### Step 4: Update the boot loader
# For the current scenario, we can simply use 'grub-mkconfig' command that
# will detect the newly copied kernel image in /boot and add a sub-menu entry
# under "Advanced options for Arch Linux" boot menu

grub-mkconfig -o /boot/grub/grub.cfg

### Final step: Reboot and test booting from the new kernel
reboot
# Select "Advanced options for Arch Linux" in GRUB's boot menu and select the
# new kernel that will be listed as new menu entry at the end titled 
# "Arch Linux, with Linux 6.10.6-vbox" for instance (the kernel version could
# be different based on your build).

# And that's it! You should be able to boot into your Arch Linux with the 
# new kernel. Once logged in, try running the command 'uname -r' to verify
# your new kernel release.

