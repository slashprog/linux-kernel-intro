# Building the Linux kernel from the official stable kernel sources

Steps involved:
  1. Preparing the build environment
      - Ensure the existence of the following tools:
         - gcc / LLVM clang compiler
         - GNU make
         - GNU binutils
         - GNU flex
         - GNU bison
         - GNU bc
         - GNU tar
         - GNU cpio
         - GNU bash
         - GNU GRUB
         - util-linux
         - kmod
         - pahole
     
        On Arch Linux, installing the base-devel package would provide
        most of the above tools.
     
        On Debian / Ubuntu based distros, install the build-essentials
        package along with bc, flex and bison
     
     - Download the kernel source tarball and untar the same in the source
       folder
     - Create a build folder

  2. Setup the kernel build configuration
      - Create a .config file in the build folder either by copying a template
        .config of an earlier kernel build and running 'make oldconfig'
      - Or do it from scratch via 'make nconfig' or 'make menuconfig'

  3. Build the kernel
      - Run 'make'

  4. Create kernel install package / tarball
      - Run 'make install' and 'make modules_install' in a skeleton tar-file
        folder and create a tarball
      - Or run 'make tarxz-pkg' or 'make bindeb-pkg' or 'make binrpm-pkg'

  5. Install the kernel and setup the boot loader config
      - Install the kernel binary image package or tarball on target machine
      - Setup the boot loader (easily via 'grub-mkconfig')

  6. Reboot and Test the newly built kernel
