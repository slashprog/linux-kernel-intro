debug_kernel()
{
  MODE=$1

  KERNEL=/boot/vmlinuz
  SERIAL_DEVICE=tcp::4444,server,nowait
  INITRD=/boot/initrd.gz

  if [[ $MODE == kgdb ]]; then
     KERNEL_PARAMS="root=/dev/sda kgdboc=ttyS0,115200 kgdbwait"
     qemu-system-x86_64 -serial $SERIAL_DEVICE   \
                      -kernel $KERNEL          \
                      -append "$KERNEL_PARAMS" \
                      -initrd $INITRD -curses 

  elif [[ $MODE == kdb ]]; then
     KERNEL_PARAMS="root=/dev/sda kgdboc=kdb"
     qemu-system-i386 -serial $SERIAL_DEVICE   \
                      -kernel $KERNEL          \
                      -append "$KERNEL_PARAMS" \
                      -initrd $INITRD -curses 

  elif [[ $MODE == start ]]; then
     qemu-system-i386 -serial $SERIAL_DEVICE   \
                      -kernel $KERNEL          \
                      -append "$KERNEL_PARAMS" \
                      -initrd $INITRD -curses 
  elif [[ $MODE == stop ]]; then
     killall qemu-system-i386 
  else
     echo "usage: $0 {kgdb|kdb|stop}" >&2
  fi

}

