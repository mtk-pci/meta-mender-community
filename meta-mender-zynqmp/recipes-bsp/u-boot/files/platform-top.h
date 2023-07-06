#include <configs/xilinx_zynqmp.h>
/*#include <configs/platform-auto.h>*/

#undef CONFIG_EXTRA_ENV_SETTINGS
#define CONFIG_EXTRA_ENV_SETTINGS \
   ENV_MEM_LAYOUT_SETTINGS \
   BOOTENV
