DESCRIPTION = "Tools for mender integration with ZynqMP Yocto images"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

ROOTFS_POSTPROCESS_COMMAND += " mender_uboot_rootfs_upd; "

mender_uboot_rootfs_upd () {
    # /boot subdirectory is used because it won't be excluded by other Mender recipes/scripts
    install -d ${IMAGE_ROOTFS}/boot/mender-uboot-xlnx-upd
    
    lclImageBootFilesRootfsInstall="${@get_mender_uboot_rootfs_install_full_str(d)}"
    
    for i in ${lclImageBootFilesRootfsInstall}
    do
        # Replace ; that splits the pair and write install command
        argStr=$(echo "$i" | sed -e 's/;/\ /')
        #bbwarn "install -m 0644 ${argStr}"
        install -m 0644 ${argStr}
    done
    
    lclImageBootFiles="${@get_mender_uboot_rootfs_files_str(d)}"
    
    manifest_file="${WORKDIR}/manifest.deploy"
    if [ -e ${manifest_file} ]; then
        rm -f $manifest_file
    fi
    touch $manifest_file
    
    for i in ${lclImageBootFiles}
    do
        echo "$i" >> $manifest_file
    done
    install -m 0644 $manifest_file ${IMAGE_ROOTFS}/boot/mender-uboot-xlnx-upd/
}

def get_mender_uboot_rootfs_install_tasks(d):
    import os
    import re
    from glob import glob
    
    kernel_dir = d.getVar('DEPLOY_DIR_IMAGE')
    if not kernel_dir:
        raise Error("Couldn't find DEPLOY_DIR_IMAGE, exiting")
    
    boot_files = d.getVar('IMAGE_BOOT_FILES')
    if boot_files is None:
        raise Error('No boot files defined, IMAGE_BOOT_FILES unset')
    
    # list of tuples (src_name, dst_name)
    deploy_files = []
    for src_entry in re.findall(r'[\w;\-\./\*]+', boot_files):
        if ';' in src_entry:
            dst_entry = tuple(src_entry.split(';'))
            if not dst_entry[0] or not dst_entry[1]:
                raise Error('Malformed boot file entry: %s' % src_entry)
        else:
            dst_entry = (src_entry, src_entry)
        
        deploy_files.append(dst_entry)
    
    install_task = []
    for deploy_entry in deploy_files:
        src, dst = deploy_entry
        if '*' in src:
            # by default install files under their basename
            entry_name_fn = os.path.basename
            if dst != src:
                # unless a target name was given, then treat name
                # as a directory and append a basename
                entry_name_fn = lambda name: \
                                os.path.join(dst,
                                             os.path.basename(name))
            
            srcs = glob(os.path.join(kernel_dir, src))
            
            for entry in srcs:
                src = os.path.relpath(entry, kernel_dir)
                entry_dst_name = entry_name_fn(entry)
                install_task.append((src, entry_dst_name))
        else:
            install_task.append((src, dst))
    
    return install_task

def get_mender_uboot_rootfs_install_full_str(d):
    import os
    
    kernel_dir = d.getVar('DEPLOY_DIR_IMAGE')
    if not kernel_dir:
        raise Error("Couldn't find DEPLOY_DIR_IMAGE, exiting")
    
    rootfs_dir = d.getVar('IMAGE_ROOTFS')
    upddir = rootfs_dir + '/boot/mender-uboot-xlnx-upd'
    
    install_task = get_mender_uboot_rootfs_install_tasks(d)
    install_task_full = []
    for task in install_task:
        src_path, dst_path = task
        install_task_full.append(os.path.join(kernel_dir, src_path) + ';' + os.path.join(upddir, dst_path))
    
    rvalStr = ' '.join(install_task_full)
    
    return rvalStr

def get_mender_uboot_rootfs_files_str(d):
    install_task = get_mender_uboot_rootfs_install_tasks(d)
    files_list = []
    for task in install_task:
        src_path, dst_path = task
        files_list.append(dst_path)
    
    rvalStr = ' '.join(files_list)
    
    return rvalStr


FILES:${PN} += "\
    /boot/mender-uboot-xlnx-upd \
    /boot/mender-uboot-xlnx-upd/manifest.deploy \
    ${@get_mender_uboot_rootfs_files_str(d)} \
"

