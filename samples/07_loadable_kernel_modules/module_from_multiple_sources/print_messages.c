#include <linux/kernel.h>
#include "kernel_greeter.h"

void print_greet_message(void)
{
	pr_notice("%s:%s: greetings from kernel-space.\n", KBUILD_MODNAME, __func__);
}

void print_exit_message(void)
{
	pr_info("%s:%s: bye bye!\n", KBUILD_MODNAME, __func__);
}
