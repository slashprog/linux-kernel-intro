#!/bin/bash

echo '!!! This script will REMOVE Arch Linux VirtualBox VM (ARCHLinuxVM)        !!!'
echo '!!! This will also REMOVE the virtual disk images associated with this VM !!!'
echo 'Press <Enter> to process (or <Ctrl>-c to cancel'
read

### Change the following variables to suit your requirements/configuration

# The folder path where the hard disk image and ISO images will be stored
WORK_FOLDER=~/Linux_Kernel_Development/VirtualBox

# This will be the name as listed in VirtualBox VMs
VM_NAME=ARCHLinuxVM

# The names of hard disk images to be created in WORK_FOLDER
VM_HARD_DISK1=$WORK_FOLDER/archvm.vdi
VM_HARD_DISK2=$WORK_FOLDER/miniboot.vdi

# Setup VBoxManage in PATH for macOS environments.
if [[ "$(uname)" == "Darwin" ]]; then
   VIRTUALBOX_PATH=/Applications/VirtualBox.app/Contents/MacOS/VBoxManage
   PATH=$PATH:$VIRTUALBOX_PATH
fi

# Okay - destruction begins!

VBoxManage storagectl $VM_NAME --name SATA --remove
VBoxManage storagectl $VM_NAME --name IDE --remove

VBoxManage unregistervm $VM_NAME --delete

VBoxManage closemedium $VM_HARD_DISK1 --delete
VBoxManage closemedium $VM_HARD_DISK2 --delete

rm -f $VM_HARD_DISK1
rm -f $VM_HARD_DISK2
rm -rf $HOME/"VirtualBox VMs"/$VM_NAME

# Hopefully, we're cleaned up now. Good luck!


