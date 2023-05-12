DESCRIPTION = "Mender addendum layer for ZynqMP boot partition update"
LICENSE = "MIT"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI += "file://zynqmp-boot \
            "

do_install:append() {
    install -d ${D}${datadir}/mender/modules/v3
    install -m 0755 ${WORKDIR}/zynqmp-boot ${D}${datadir}/mender/modules/v3/
}

FILES:${PN} += "\
    ${datadir}/mender/modules/v3/zynqmp-boot \
"
