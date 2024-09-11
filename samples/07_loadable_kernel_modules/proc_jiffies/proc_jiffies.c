// SPDX-License-Identifier: GPL-2.0
#include <linux/module.h>
#include <linux/kernel.h>

#include <linux/proc_fs.h>
#include <linux/seq_file.h>
#include <linux/jiffies.h>

static int jiffies_proc_show(struct seq_file *m, void *v)
{
	dump_stack();
	seq_printf(m, "Jiffies = %8llu\n", get_jiffies_64()); 
	return 0;
}

static int __init proc_jiffies_init(void)
{
	struct proc_dir_entry *pde;

	pde = proc_mkdir("jiffies", NULL);
	proc_create_single("value", 0, pde, jiffies_proc_show);
	return 0;
}

static void __exit proc_jiffies_exit(void)
{
	remove_proc_subtree("jiffies", NULL);
}

module_init(proc_jiffies_init);
module_exit(proc_jiffies_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Chandrashekar Babu <chandra@slashprog.com>");
MODULE_DESCRIPTION("A simple kernel module to expose jiffies to user-space via /proc");
