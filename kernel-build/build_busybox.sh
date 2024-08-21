#!/bin/sh

# Building busybox using preset configuration

BUSYBOX_VERSION=1.36.1
BUSYBOX_BUILD_SUFFIX=vbox

BUSYBOX_RELEASE="${BUSYBOX_VERSION}-${BUSYBOX_BUILD_SUFFIX}"

BUSYBOX_DOWNLOAD_URL="https://busybox.net/downloads/busybox-${BUSYBOX_VERSION}.tar.bz2"
BUSYBOX_PRESET_CONFIG_URL="https://raw.githubusercontent.com/slashprog/linux-kernel-intro/main/kernel-build/busybox-config-vbox"

WORK_FOLDER=$HOME
SOURCE_FOLDER=/usr/local/src/busybox-${BUSYBOX_VERSION}/
BUILD_FOLDER=/usr/local/build/busybox-${BUSYBOX_RELEASE}/

### Step 1: Prepare the build environment
cd $WORK_FOLDER
curl -O $BUSYBOX_DOWNLOAD_URL

tar xvf busybox-${BUSYBOX_VERSION}.tar.bz2 -C /usr/local/src
chattr -Rf +i $SOURCE_FOLDER

mkdir -p $BUILD_FOLDER
curl -o ${BUILD_FOLDER}/.config $BUSYBOX_PRESET_CONFIG_URL

#### Step 2: Configure the build
cd $SOURCE_FOLDER
make O=${BUILD_FOLDER} oldconfig 
#make O=${BUILD_FOLDER} menuconfig

#### Step 3: Build
make O=${BUILD_FOLDER}

#### Step 4: Install (by default under $BUILD_FOLDER/_install)
make O=${BUILD_FOLDER} install


