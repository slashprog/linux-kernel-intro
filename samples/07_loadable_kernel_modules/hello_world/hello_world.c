#include <linux/module.h>
#include <linux/kernel.h>

static int hello_world_init(void)
{
	pr_notice("%s:[%s:%d]:%s: Hello, world - from kernel-space.\n",
               KBUILD_MODNAME, __FILE__, __LINE__, __func__);

	/*
	* printk(KERN_NOTICE "Hello world");
	* printk("<5>Hello world");
	*/
	return 0;
}

static void hello_world_exit(void)
{
	pr_info("%s:[%s:%d]:%s: Hello, world - from kernel-space.\n",
               KBUILD_MODNAME, __FILE__, __LINE__, __func__);
}

module_init(hello_world_init);
module_exit(hello_world_exit);

MODULE_LICENSE("GPL");

MODULE_DESCRIPTION("A simple hello-world module.");
MODULE_AUTHOR("Chandrashekar Babu <chandra@slashprog.com>");


/*  Try out the following changes:
*     1. Try returning a negative number from hello_world_init()
*     1a. Try returning a positive number from hello_world_init()
*
*     2. Try changing the MODULE_LICENSE() from "GPL" to any other string
*        like "Proprietary"
*
*     3. Try removing module_exit(), build, insert, remove and test.
*
*
*   */
