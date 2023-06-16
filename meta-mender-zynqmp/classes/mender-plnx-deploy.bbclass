inherit plnx-deploy

python () {
    bb.warn(d.getVarFlag('do_image_complete','postfuncs', False))
    if bb.data.inherits_class('image', d):
        flagStr = d.getVarFlag('do_image_complete','postfuncs', False)
        flagStr.replace(' plnx_deploy_rootfs', '')
        d.setVarFlag('do_image_complete','postfuncs', flagStr)
        bb.warn(d.getVarFlag('do_image_complete','postfuncs', False))
        d.appendVarFlag('do_image_complete','postfuncs', ' mender_plnx_deploy_rootfs')
        bb.warn(d.getVarFlag('do_image_complete','postfuncs', False))
}

python mender_plnx_deploy_rootfs() {
    import os
    import re
    deploy_dir = d.getVar('IMGDEPLOYDIR') or ""
    image_name = d.getVar('IMAGE_NAME') or ""
    image_suffix = d.getVar('IMAGE_NAME_SUFFIX') or ""
    output_path = d.getVarFlag('plnx_deploy', 'dirs')
    search_str = image_name + image_suffix
    search_str = re.escape(search_str)
    
    image_prefix = ""
    if len(image_name) > 0:
        image_prefix=image_name + '_'
    
    if os.path.exists(deploy_dir):
        for _file in os.listdir(deploy_dir):
            if re.search(search_str, _file) and not _file.endswith('.qemu-sd-fatimg'):
                if image_name.find('initramfs') != -1:
                    dest_name=image_prefix + 'ramdisk'
                else:
                    dest_name=image_prefix + 'rootfs'
                source_name=str(_file)
                
                # image_suffix may be empty
                if not image_suffix:
                    post_name=source_name.split('.', 1)
                    if len(post_name) > 1:
                        dest_name=dest_name + '.' + post_name[1]
                    
                else:
                    post_name=source_name.split(image_suffix, 1)
                    if len(post_name) > 1:
                        dest_name=dest_name + post_name[1]
                
                copy_files(deploy_dir + '/' + source_name,output_path + '/' + dest_name)

    extra_files = d.getVar('EXTRA_FILESLIST') or ""
    for file in extra_files.split():
        input, output = file.split(':')
        copy_files(input,output_path + '/' + output)
}
