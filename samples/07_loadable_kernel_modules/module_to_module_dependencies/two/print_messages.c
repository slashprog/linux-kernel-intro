#include <linux/kernel.h>
#include <linux/module.h>

void print_greet_message(void);
void print_exit_message(void);

void print_greet_message(void)
{
	pr_notice("%s:%s: greetings from kernel-space.\n", KBUILD_MODNAME, __func__);
}

void print_exit_message(void)
{
	pr_info("%s:%s: bye bye!\n", KBUILD_MODNAME, __func__);
}

MODULE_LICENSE("GPL");
EXPORT_SYMBOL(print_greet_message);
EXPORT_SYMBOL_GPL(print_exit_message);
