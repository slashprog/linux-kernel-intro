#!/bin/bash

### Change the following variables to suit your requirements/configuration

# The folder path where the hard disk image and ISO images will be stored
WORK_FOLDER=~/Linux_Kernel_Development/VirtualBox

# The path to the Linux ISO image
LINUX_ISO_IMAGE=${WORK_FOLDER}/archlinux.iso

# This will be the name as listed in VirtualBox VMs
VM_NAME=ARCHLinuxVM

# Leave this as default (recommended)
VM_OSTYPE=ArchLinux_64

# Minimum recommended RAM is 4 GiB, increase as desired
VM_RAM=8192

# 64 MiB of video RAM, should suffice
VM_VRAM=64

# Number of CPUs alloted for the VM, change as desired
VM_CPUS=4

# The default port to tunnel SSH from localhost to the VM
VM_SSH_PORT=2222

# Minimum recommended disk capacity is 32 GiB, higher the better
VM_HARD_DISK1_SIZE=32768  

# Second hard drive which will be blank for now.  
VM_HARD_DISK2_SIZE=200

# The names of hard disk images to be created in WORK_FOLDER
VM_HARD_DISK1=$WORK_FOLDER/archvm.vdi
VM_HARD_DISK2=$WORK_FOLDER/miniboot.vdi

# Setup VBoxManage in PATH for macOS environments.
if [[ "$(uname)" == "Darwin" ]]; then
   VIRTUALBOX_PATH=/Applications/VirtualBox.app/Contents/MacOS/VBoxManage
   PATH=$PATH:$VIRTUALBOX_PATH
fi

# The redirector URL for the latest ARCHLinux x86_64 ISO file
LINUX_ISO_URL=https://scripts.chandrashekar.info/archlinux.iso

# Scan-codes for automating keystrokes during boot: 
#   <TAB> <SPACE> script=https://files.chandrashekar.info/archlinux_vbox_autoinstall.sh <ENTER> 
SCRIPT_SCANCODE="0f 8f 39 b9 1f 9f 2e ae 13 93 17 97 19 99 14 94 0d 8d 23 a3 14 94 14 94 19 99 1f 9f 36 27 b6 a7 35 b5 35 b5 21 a1 17 97 26 a6 12 92 1f 9f 34 b4 2e ae 23 a3 1e 9e 31 b1 20 a0 13 93 1e 9e 1f 9f 23 a3 12 92 25 a5 1e 9e 13 93 34 b4 17 97 31 b1 21 a1 18 98 35 b5 1e 9e 13 93 2e ae 23 a3 26 a6 17 97 31 b1 16 96 2d ad 36 0c b6 8c 2f af 30 b0 18 98 2d ad 36 0c b6 8c 1e 9e 16 96 14 94 18 98 17 97 31 b1 1f 9f 14 94 1e 9e 26 a6 26 a6 34 b4 1f 9f 23 a3 1c 9c"

#### End of configurable variables.

#### The following commands can be customized to suit your requirements.
# Look-up the help for VBoxManage options 

# Create the work folder if necessary
mkdir -p $WORK_FOLDER

# Download the ISO image using aria2c / curl / wget
if which aria2c >/dev/null; then
   aria2c -c $LINUX_ISO_URL -d $WORK_FOLDER -o $(basename $LINUX_ISO_IMAGE)
elif which curl >/dev/null; then
   curl -L -C - $LINUX_ISO_URL -o $LINUX_ISO_IMAGE
elif which wget >/dev/null; then
   wget -c $LINUX_ISO_URL -O $LINUX_ISO_IMAGE
else
   echo "Missing 'aria2c', 'wget' and 'curl' - required to download ISO image."
   echo "Kindly download the latest ARCHLinux ISO image as '${LINUX_ISO_IMAGE}'"
   echo "Once downloaded, press <Enter> key to proceed."
   read
fi

# No point proceeding if LINUX_ISO_IMAGE is missing.
if [[ ! -f $LINUX_ISO_IMAGE ]]; then
   echo "Failed to locate $LINUX_ISO_IMAGE. Exiting..."
   exit 1
fi

# Create a new VM named with title as per VM_NAME variable
VBoxManage createvm --name $VM_NAME --ostype $VM_OSTYPE --register

# Add a new SATA controller for storage devices with 2 storage ports 
VBoxManage storagectl $VM_NAME    \
	   --name SATA            \
	   --add sata             \
	   --controller IntelAHCI \
	   --portcount 2

# Create Hard-disk images and attach them to the SATA controller
VBoxManage createmedium              \
	   --filename $VM_HARD_DISK1 \
	   --size $VM_HARD_DISK1_SIZE

VBoxManage storageattach $VM_NAME     \
	   --storagectl SATA          \
	   --port 0                   \
	   --device 0                 \
	   --type hdd                 \
	   --medium $VM_HARD_DISK1

VBoxManage createmedium               \
	   --filename $VM_HARD_DISK2  \
	   --size $VM_HARD_DISK2_SIZE

VBoxManage storageattach $VM_NAME     \
	   --storagectl SATA          \
	   --port 1                   \
	   --device 0                 \
	   --type hdd                 \
	   --medium $VM_HARD_DISK2

# Create a new IDE controller and attach a DVD drive, 
# with LINUX_ISO_IMAGE inserted.
VBoxManage storagectl $VM_NAME         \
	   --name IDE                  \
	   --add ide

VBoxManage storageattach $VM_NAME      \
	   --storagectl IDE            \
	   --port 0                    \
	   --device 0                  \
	   --type dvddrive             \
	   --medium $LINUX_ISO_IMAGE 

# Configure system RAM and video RAM size
VBoxManage modifyvm $VM_NAME      \
	   --memory $VM_RAM       \
	   --vram $VM_VRAM

# Enable IOAPIC (required for SMP if number of CPUs is more than 1)
VBoxManage modifyvm $VM_NAME --ioapic on

# Setup number of CPUs for the VM
VBoxManage modifyvm $VM_NAME --cpus $VM_CPUS

# Setup boot order (DVD drive first, hard disk next)
VBoxManage modifyvm $VM_NAME    \
	   --boot1 dvd          \
	   --boot2 disk         \
	   --boot3 none         \
	   --boot4 none

# Set graphics-controller to VMSVGA
VBoxManage modifyvm $VM_NAME --graphicscontroller vmsvga

# Setup audio controller (coreaudio for macOS, alsa for Linux)
if [[ "$(uname)" == "Darwin" ]]; then
   VBoxManage modifyvm $VM_NAME --audio coreaudio
elif [[ "$(uname)" == "Linux" ]]; then
   VBoxManage modifyvm $VM_NAME --audio alsa
fi

VBoxManage modifyvm $VM_NAME --audioin on
VBoxManage modifyvm $VM_NAME --audioout on
VBoxManage modifyvm $VM_NAME --audiocontroller hda

# Setup USB OHCI support
VBoxManage modifyvm $VM_NAME --usbohci on
VBoxManage modifyvm $VM_NAME --usbehci off
VBoxManage modifyvm $VM_NAME --usbxhci off

# Setup network adapter 1 as NAT
VBoxManage modifyvm $VM_NAME --nic1 nat

# Setup SSH tunnel - localhost:2222 --> guestvm-ssh:22
VBoxManage modifyvm $VM_NAME --natpf1 "guestssh,tcp,,$VM_SSH_PORT,,22"

# Start the VM
VBoxManage startvm $VM_NAME --type gui

# Initiate automated installation after 5 seconds
for i in {5..1}
do
	printf "\rRunning automated installer in $i seconds..."
	sleep 1
done
echo

VBoxManage controlvm $VM_NAME keyboardputscancode ${SCRIPT_SCANCODE}

until VBoxManage showvminfo ARCHLinuxVM --machinereadable | grep -F 'VMState="poweroff"'
do
	printf "\rArchLinux installation in progress ($((i++)) seconds)...     "
	sleep 1
done
printf "\nArchLinux installation completed.\n"
sleep 2

printf "Removing CD/DVD ROM... "

VBoxManage storageattach $VM_NAME      \
	   --storagectl IDE            \
	   --port 0                    \
	   --device 0                  \
	   --type dvddrive             \
	   --medium none
echo "done."
sleep 2

printf "Restarting the VM (ArchLinux)..."

# Start the VM
VBoxManage startvm $VM_NAME --type gui

