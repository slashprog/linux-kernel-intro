#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/delay.h>

char hello_msg[] __initdata = "Hello, world - from kernel-space.";

static int __init hello_world_init(void)
{
	pr_notice("%s:[%s:%d]:%s: %s\n",
               KBUILD_MODNAME, __FILE__, __LINE__, __func__, hello_msg);

	dump_stack();
/* 	msleep_interruptible(30000);
 */
	pr_info("%s:%s: returning out.\n", KBUILD_MODNAME, __func__);

	return 0;
}

static void __exit hello_world_exit(void)
{
	pr_info("%s:[%s:%d]:%s: Goodbye, cruel world.\n",
               KBUILD_MODNAME, __FILE__, __LINE__, __func__);

	dump_stack();
/* 	msleep_interruptible(30000);
 */
	pr_info("%s:%s: returning out.\n", KBUILD_MODNAME, __func__);
}

module_init(hello_world_init);
module_exit(hello_world_exit);

MODULE_LICENSE("GPL");

MODULE_DESCRIPTION("A simple hello-world module.");
MODULE_AUTHOR("Chandrashekar Babu <chandra@slashprog.com>");
