#include <linux/module.h>
#include <linux/kernel.h>  

static int __init mymodule_init(void)
{
    int ret = 0;


exit_success:
    return ret;
} 

static void __init mymodule_exit(void)
{

}

