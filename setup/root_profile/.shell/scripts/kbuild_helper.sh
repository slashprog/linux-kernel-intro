kdownload()
{
	pushd .
	cd ~/Downloads
	KERNEL_VERSION="$1"
	wget -c "https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-${KERNEL_VERSION}.tar.xz"
	popd
}

kprep()
{
	KERNEL_VERSION="$1"
	tar xvf ~/Downloads/linux-${KERNEL_VERSION}.tar.xz -C /usr/local/src
	chattr -R +i /usr/local/src/linux-${KERNEL_VERSION} 2>/dev/null
	mkdir -p /usr/local/build/linux-${KERNEL_VERSION}-$(hostname)
	cp /usr/local/build/linux-$(uname -r)/.config \
	   /usr/local/build/linux-${KERNEL_VERSION}-$(hostname)/.config

}

kprep_git()
{
	KERNEL_VERSION="$1"
	cd /usr/local/src/linux-stable
	git checkout master
	git pull
	git pull
	git checkout "v${KERNEL_VERSION}"
	mkdir -p /usr/local/build/linux-${KERNEL_VERSION}-$(hostname)
	cp /usr/local/build/linux-$(uname -r)/.config \
	   /usr/local/build/linux-${KERNEL_VERSION}-$(hostname)/.config
	cd /usr/local/src
	ln -s linux-stable linux-${KERNEL_VERSION}

}

kbuild()
{
	KERNEL_VERSION="$1"
	pushd .
	cd /usr/local/src/linux-${KERNEL_VERSION}
	make -j24 O=/usr/local/build/linux-${KERNEL_VERSION}-$(hostname) $2
	popd
}

kinstall()
{
	KERNEL_VERSION="$1"
	KERNEL_BUILD="linux-${KERNEL_VERSION}-$(hostname)"
	mkdir -p /tmp/ktemp
	tar xvf /usr/local/build/${KERNEL_BUILD}/${KERNEL_BUILD}-x86.tar.xz -C /tmp/ktemp
	cp -av /tmp/ktemp/boot/* /boot/
	cp -av /tmp/ktemp/lib/modules/${KERNEL_VERSION}-$(hostname) /lib/modules/
	rm -rf /tmp/ktemp
}

ksetupboot()
{
	KERNEL_VERSION="$1"
	for file in vmlinuz vmlinux config System.map
	do
		ln -sf /boot/${file}-${KERNEL_VERSION}-$(hostname) /boot/${file}
	done
}

kernel_build()
{
	kdownload "$1"
	kprep "$1"
	kbuild "$1" oldconfig
	kbuild "$1" tarxz-pkg
	kinstall "$1"
	ksetupboot "$1"
}


kernel_build_git()
{
	pushd .
	kprep_git "$1"
	kbuild "$1" oldconfig
	kbuild "$1" tarxz-pkg
	kinstall "$1"
	ksetupboot "$1"
	popd
}

clean()
{
   make -C /lib/modules/$(uname -r)/build M=$(pwd) clean
}

cl()
{
   rm -f *.o *.ko *~ .*.cmd *.mod.* *.mod modules.order Module.symvers 
   rm -rf .tmp_versions
}

mk()
{
  if [[ -f Makefile.tmp ]]; then
     [[ -f Makefile ]] && mv -f Makefile Makefile.old 2>/dev/null
     mv Makefile.tmp Makefile
     return
  fi
  FILES=$(echo *.c)
  FILES=${FILES//\.c/.o}
  echo $FILES
  cat <<END > Makefile.tmp
obj-m := ${FILES}

KDIR := /lib/modules/\$(shell uname -r)/build
PWD := \$(shell pwd)

default:
	\$(MAKE) -C \$(KDIR) M=\$(PWD) modules

clean:
	\$(MAKE) -C \$(KDIR) M=\$(PWD) clean

install:
	\$(MAKE) -C \$(KDIR) M=\$(PWD) modules_install
END
}

mkinitcpio()
{
   if [[ $# -eq 0 ]]; then
      cd /opt/initrd-tree
      find . | cpio -H newc -o | gzip -c > /boot/initrd-$(uname -r).gz
   elif [[ "$1" == "--with-modules" ]]; then
      cp -a /opt/initrd-tree /tmp/initrd-$(uname -r)
      mkdir -p /tmp/initrd-$(uname -r)/lib/modules
      cp -a /lib/modules/$(uname -r) \
            /tmp/initrd-$(uname -r)/lib/modules/$(uname -r)
      cd /tmp/initrd-$(uname -r)
      find . | cpio -H newc -o | gzip -c > \
                                /boot/initrd-with-modules-$(uname -r).gz
      rm -rf /tmp/initrd-$(uname -r)
   else
      echo "usage: mkinitcpio [--with-modules]"
   fi
}

mkinitramdisk()
{
  if [[ $# -eq 1 ]] && [[ "$1" == "--with-modules" ]]; then
     echo "usage: mkinitramdisk [--with-modules]"
     return
  fi

  pushd .
  cd /tmp
  if [[ $# -eq 1 ]] && [[ "$1" == "--with-modules" ]]; then
     dd if=/dev/zero of=initramdisk-$(uname -r).img bs=1M count=64
  else
     dd if=/dev/zero of=initramdisk-$(uname -r).img bs=1M count=4
  fi
  mkfs.ext4 initramdisk-$(uname -r).img
  mkdir initramdisk
  mount initramdisk-$(uname -r).img initramdisk -o loop
  cp -a /opt/initrd-tree/* initramdisk/
  if [[ $# -eq 1 ]] && [[ "$1" == "--with-modules" ]]; then
    mkdir -p initramdisk/lib/modules
    cp -a /lib/modules/$(uname -r) \
            initramdisk/lib/modules/$(uname -r)
  fi
  umount initramdisk
  rmdir initramdisk
  mv initramdisk-$(uname -r).img /boot
  popd
}

