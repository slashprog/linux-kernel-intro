#include <linux/module.h>
#include "kernel_greeter.h"

static int __init hello_world_init(void) 
{
	print_greet_message();

	return 0;
}

static void __exit hello_world_exit(void)
{
	print_exit_message();
}

module_init(hello_world_init);
module_exit(hello_world_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Chandrashekar Babu <chandra@slashprog.com>");
MODULE_DESCRIPTION("A simple LKM made up of multiple source files");

