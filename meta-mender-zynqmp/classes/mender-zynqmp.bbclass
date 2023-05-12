DESCRIPTION = "Tools for mender integration with ZynqMP Yocto images"
LICENSE = "MIT"

mender_install_boot_rootfs() {
    install -d ${IMAGE_ROOTFS}/boot
    # Remove default boot files for now until default Petalinux recipes can be tweaked to prevent extraneous installs
    rm -rf ${IMAGE_ROOTFS}/boot/*
    install -m 0644 ${DEPLOY_DIR_IMAGE}/Image ${IMAGE_ROOTFS}/boot/
    install -m 0644 ${DEPLOY_DIR_IMAGE}/system.dtb ${IMAGE_ROOTFS}/boot/
    
    # If the system.bit file doesn't exist at this time, copy from pre-built (quirk of current package settings)
    if [ ! -f ${PLNX_DEPLOY_DIR}/system.bit ]
    then
        install -m 0644 ${PROOT}/pre-built/linux/images/system.bit ${PLNX_DEPLOY_DIR}/
    fi
    
    install -m 0644 ${PLNX_DEPLOY_DIR}/system.bit ${IMAGE_ROOTFS}/boot/
}
ROOTFS_POSTPROCESS_COMMAND += " mender_install_boot_rootfs; "
