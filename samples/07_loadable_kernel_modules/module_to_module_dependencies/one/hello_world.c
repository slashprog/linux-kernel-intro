#include <linux/module.h>

extern void print_greet_message(void);
extern void print_exit_message(void);

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

MODULE_LICENSE("Proprietary");
MODULE_AUTHOR("Chandrashekar Babu <chandra@slashprog.com>");
MODULE_DESCRIPTION("A simple LKM made up of multiple source files");

