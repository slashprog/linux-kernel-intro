KERNEL_RELEASE=$(uname -r)
KERNEL_SOURCE=/usr/local/src/linux-${KERNEL_RELEASE/-[a-z]*/}
KERNEL_BUILD=/usr/local/build/linux-${KERNEL_RELEASE}
CSCOPE_DB={KERNEL_BUILD}/cscope.out

export KERNEL_RELEASE
export KERNEL_SOURCE
export KERNEL_BUILD

alias build='cd ${KERNEL_BUILD}'
alias src='cd ${KERNEL_SOURCE}'
alias doc='cd ${KERNEL_SOURCE}/Documentation'

