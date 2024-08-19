cs()
{
   pushd .
   cd ${KERNEL_BUILD}
   if egrep "^(x86|arm|arm64|mips|ppc)$" <(echo "$1") >/dev/null 2>&1
   then
      prefix=$1
   fi
   if [[ -v prefix ]]
   then
      for file in ${prefix}.cscope.*
      do
          ln -sf $file ${file/${prefix}./}
      done
      unset prefix
   fi
   cscope -d
   popd
}

gencs()
{
	pushd .
	cd ${KERNEL_SOURCE}
	for arch in x86 arm arm64 mips
	do
		make ARCH=${arch} O=${KERNEL_BUILD} cscope
		cd ${KERNEL_BUILD}
		rename "cscope." "${arch}.cscope." cscope.*
		cd ${KERNEL_SOURCE}
	done
	popd
}
