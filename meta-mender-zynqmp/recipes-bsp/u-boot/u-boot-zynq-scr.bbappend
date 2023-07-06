SUMMARY = "U-boot boot scripts for ZynqMP devices with Mender included"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += "file://boot.cmd.sd.mender"

BOOTMODE = "sd"
BOOTFILE_EXT = ".mender"

do_compile:prepend:u96v2-sbc () {
    # Change default bootargs for u96v2-sbc
    sed -i '/^setenv default_bootargs ${bootargs}/c\setenv default_bootargs ${bootargs} earlycon console=ttyPS0,115200 clk_ignore_unused rw rootwait cma=512M rfkill.default_state=1' ${WORKDIR}/boot.cmd.sd.mender
}

#do_compile:prepend:zynqmp-iwg36s () {
# Change default bootargs for zynqmp-iwg36s
#    sed -i '/^setenv default_bootargs ${bootargs}/c\setenv default_bootargs ${bootargs} earlycon console=ttyPS0,115200 clk_ignore_unused rw rootwait cma=512M rfkill.default_state=1' ${WORKDIR}/boot.cmd.sd.mender
#}
