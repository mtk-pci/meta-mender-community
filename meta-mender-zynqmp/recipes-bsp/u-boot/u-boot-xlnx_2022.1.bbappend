FILESEXTRAPATHS:prepend := "${THISDIR}/patches:"

# Replace the environment patch for a version specific item.
SRC_URI:remove:mender-uboot = " file://0001_Configure_Env_And_Bootcount.patch"

SRC_URI += "file://0001_Configure_Env_And_Bootcount_xilinx-v2022.1.patch \
            "
