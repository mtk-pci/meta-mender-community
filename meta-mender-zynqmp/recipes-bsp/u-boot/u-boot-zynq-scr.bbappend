SUMMARY = "U-boot boot scripts for ZynqMP devices with Mender included"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += "file://boot.cmd.sd.mender"

BOOTMODE = "sd"
BOOTFILE_EXT = ".mender"
