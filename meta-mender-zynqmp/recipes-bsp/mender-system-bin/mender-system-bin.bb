DESCRIPTION = "Generate system.bin file for booting Mender-based images"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

include machine-xilinx-${SOC_FAMILY}.inc

DEPENDS += "bootgen-native"

# There is no bitstream recipe, so really depend on virtual/bitstream
DEPENDS += "${@(d.getVar('BIF_PARTITION_ATTR') or "").replace('bitstream', 'virtual/bitstream')}"

PACKAGE_ARCH = "${MACHINE_ARCH}"

BOOTGEN_EXTRA_ARGS ?= ""

do_patch[noexec] = "1"

S = "${WORKDIR}"

def create_bif(config, attrflags, attrimage, ids, common_attr, biffd, d):
    import re, os
    for cfg in config:
        if cfg not in attrflags and common_attr:
            error_msg = "%s: invalid ATTRIBUTE" % (cfg)
            bb.error("BIF attribute Error: %s " % (error_msg))
        else:
            if common_attr:
                cfgval = d.expand(attrflags[cfg]).split(',')
                cfgstr = "\t [%s] %s\n" % (cfg,', '.join(cfgval))
            else:
                if cfg not in attrimage:
                    error_msg = "%s: invalid or missing elf or image" % (cfg)
                    bb.error("BIF atrribute Error: %s " % (error_msg))
                imagestr = d.expand(attrimage[cfg])
                if os.stat(imagestr).st_size == 0:
                    bb.warn("Empty file %s, excluding from bif file" %(imagestr))
                    continue
                if cfg in attrflags:
                    cfgval = d.expand(attrflags[cfg]).split(',')
                    cfgstr = "\t [%s] %s\n" % (', '.join(cfgval), imagestr)
                else:
                    cfgstr = "\t %s\n" % (imagestr)
            biffd.write(cfgstr)

    return

python do_configure() {
    # If the system.bit file doesn't exist at this time, warn with a fatal error
    # because it must be supplied by a different recipe/script
    if not os.path.exists(d.getVar('PLNX_DEPLOY_DIR') + '/system.bit'):
        bb.fatal('Required file not found: ' + d.getVar('PLNX_DEPLOY_DIR') + '/system.bit')
    else:
        fp = d.getVar('WORKDIR') + '/systemgen.bif'
        
        biffd = open(fp, 'w')
        biffd.write("the_ROM_image:\n")
        biffd.write("{\n")
        
        bifpartition = ("bitstream").split()
        attrflags = { 'bitstream' : 'destination_device=pl' }
        attrimage = { 'bitstream' : '${PLNX_DEPLOY_DIR}/system.bit' }
        ids = {}
        create_bif(bifpartition, attrflags, attrimage, ids, 0, biffd, d)
        
        biffd.write("}")
        biffd.close()
}

do_compile() {
    if [ -f "${S}/systemgen.bif" ] # checking if file exist
    then
        bbnote "Reguire file found: ${S}/systemgen.bif"
        #bbplain "BIF file contents: "
        #while read line
        #do
        #    bbplain "$line"
        #done <"${S}/systemgen.bif" # double quotes important to prevent word splitting
        #bbplain ""
    else
        bbfatal "Required file not found: ${S}/systemgen.bif"
    fi
    
    # Add system.bin generation for u-boot load from rootfs
    rm -f ${S}/system.bin
    bootgen -image ${S}/systemgen.bif -arch ${SOC_FAMILY} -w -o ${S}/system.bin
    if [ ! -e ${S}/system.bin ]; then
        bbfatal "bootgen failed. See log"
    fi
}

do_install() {
    #bbwarn "S: ${S}"
    #bbwarn "D: ${D}"
    install -d ${D}/boot/bitstream
    install -m 0644 ${S}/system.bin ${D}/boot/bitstream/system.bin
}

FILES:${PN} += "/boot/bitstream/system.bin"
