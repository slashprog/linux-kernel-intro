#include <linux/module.h>
#include <linux/moduleparam.h>
#include <linux/kernel.h>

#include <linux/kthread.h>
#include <linux/sched.h>
#include <linux/delay.h>

struct task_struct *simple_kthread;

char thread_name[TASK_COMM_LEN] = KBUILD_MODNAME;
module_param_string(name, thread_name, TASK_COMM_LEN, 0644);
MODULE_PARM_DESC(name, "name of the thread as shown in ps listings...");

int count = 0;
module_param(count, int, 0444);
MODULE_PARM_DESC(count, "set the intial count value");

unsigned int delay = 3000;
/* module_param(delay, uint, 0644); */  /* 0644 -> rw- r-- r-- */

static int change_delay(const char *val, const struct kernel_param *kp)
{
	unsigned int d;
	int ret = kstrtouint(val, 0, &d);

	if (ret) {
		pr_err("%s:%s: failed to convert %s to unsigned integer: %pe\n",
				KBUILD_MODNAME, __func__, val, ERR_PTR(ret));
		return ret;
	}

	if (d < 100 || d > 5000) {
		pr_err("%s:%s: delay (%u) not in defined range (100 to 5000)\n",
				KBUILD_MODNAME, __func__, d);
		return -ERANGE;
	}

	delay = d;
	pr_notice("%s:%s: delay changed to %d\n", KBUILD_MODNAME, __func__, d);
	return 0;
}

module_param_call(delay, change_delay, param_get_uint, &delay, 0644);

MODULE_PARM_DESC(delay, "Sets the sleep interval within the loop");

static int simple_kthread_fn(void *data)
{
	unsigned long timeout;

	while (!kthread_should_stop()) {
		pr_notice("%s:%s: counting %d\n", KBUILD_MODNAME, __func__, count);
		timeout = msleep_interruptible(delay);
		if (timeout) {
			pr_warn("%s:%s: sleep cancelled (pending %lums)\n",
					KBUILD_MODNAME, __func__, timeout);
			break;
		}

		pr_info("%s:%s: woke up after sleep (%ums)\n",
				KBUILD_MODNAME, __func__, delay);

		++count;
	}
	return count;
}

static int __init simple_kthread_init(void) 
{

	simple_kthread = kthread_run(simple_kthread_fn, NULL, thread_name);
	if (IS_ERR(simple_kthread)) {
		pr_err("%s:%s: failed to launch a new kthread: %pe\n",
				KBUILD_MODNAME, __func__, simple_kthread);
	} else {
		pr_info("%s:%s: launched a new kthread (comm: %s, pid: %u)\n",
				KBUILD_MODNAME, __func__, thread_name, simple_kthread->pid);
	}

	return PTR_ERR_OR_ZERO(simple_kthread);
}

static void __exit simple_kthread_exit(void)
{
	pr_notice("%s:%s: Stopping kthread...", KBUILD_MODNAME, __func__);
	kthread_stop(simple_kthread);
}

module_init(simple_kthread_init);
module_exit(simple_kthread_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Chandrashekar Babu <chandra@slashprog.com>");
MODULE_DESCRIPTION("A simple LKM to demonstrate usage of kthreads and module parameters");
MODULE_ALIAS("thread-test");
MODULE_ALIAS("count-loop");
