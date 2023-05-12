FILESEXTRAPATHS:prepend := "${THISDIR}/patches:${THISDIR}/files:"

# Remove an inexact patch for U-Boot from Mender code, and replace with the customized version below
SRC_URI:remove:mender-uboot = " file://0003-Integration-of-Mender-boot-code-into-U-Boot.patch"

SRC_URI += "file://0001_Configure_Env_And_Bootcount.patch \
            file://0002_Integration-of-Mender-boot-code-into-U-Boot-XLNX.patch \
            file://0003_Env_Is_In_MMC.patch \
            file://platform-top.h \
            file://bsp.cfg \
            "

require recipes-bsp/u-boot/u-boot-mender.inc
require u-boot-mender-zynqmp.inc

PROVIDES += "u-boot"
RPROVIDES:${PN} += "u-boot"

do_configure:append () {
                install ${WORKDIR}/platform-top.h ${S}/include/configs/
}

ALLOW_EMPTY:${PN} = "1"
