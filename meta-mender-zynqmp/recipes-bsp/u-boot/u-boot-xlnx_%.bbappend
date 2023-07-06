FILESEXTRAPATHS:prepend := "${THISDIR}/patches:${THISDIR}/files:"

# Remove an inexact patch for U-Boot from Mender code, and replace with the customized version below
SRC_URI:remove:mender-uboot = " file://0003-Integration-of-Mender-boot-code-into-U-Boot.patch"

SRC_URI += "\
    file://0001_Configure_Env_And_Bootcount.patch \
    file://0002_Integration-of-Mender-boot-code-into-U-Boot-XLNX.patch \
    file://0003_Env_Is_In_MMC.patch \
    file://platform-top.h \
    file://bsp.cfg \
"

# iWave PATCH000-iW-PRGGG-SC-01-R2.3-REL1.0-PL22.2_HDMI-IN_OUT-UBoot22.01_customization.patch
# creates a new zynqmp_iwg36s_defconfig file, and it uses that files instead of 
# xilinx_zynqmp_virt_defconfig patched by generic 0001_Configure_Env_And_Bootcount.patch, so
# add this alternate specific patch (no need to remove generic, because it just patches an 
# unused file).
SRC_URI:append:zynqmp-iwg36s = "\
    file://PATCH001-iW-PRGGG-SC-01-R2.3-REL1.0-PL22.2_Configure_Env_And_Bootcount.patch \
"

require recipes-bsp/u-boot/u-boot-mender.inc
require u-boot-mender-zynqmp.inc

PROVIDES += "u-boot"
RPROVIDES:${PN} += "u-boot"

do_configure:prepend:zynqmp-iwg36s () {
    # Change bootcmd to 'run distro_bootcmd' after patch is applied
    sed -i '/^CONFIG_BOOTCOMMAND=/c\CONFIG_BOOTCOMMAND=\"run distro_bootcmd\"' ${S}/configs/zynqmp_iwg36s_defconfig
    sed -i '/^CONFIG_BOOTCOMMAND=/c\CONFIG_BOOTCOMMAND=\"run distro_bootcmd\"' ${WORKDIR}/zynqmp_iwg36s.cfg
}

do_configure:append () {
    install ${WORKDIR}/platform-top.h ${S}/include/configs/
}

ALLOW_EMPTY:${PN} = "1"
