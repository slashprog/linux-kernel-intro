export EDITOR=/usr/bin/vim
export BROWSER=/usr/bin/elinks
export PAGER=/usr/bin/most
export MANPAGER=$PAGER


# Temporarily turned off as kernel builds fail with Out-Of-Memory since 5.1 kernel
#export MAKEFLAGS="-j${nproc}"
#export CFLAGS='-march=native -O3 -pipe'
#export CXXFLAGS=$CFLAGS

#export CC='ccache gcc'

export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

