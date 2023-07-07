# meta-mender-zynqmp

Mender integration for Xilinx ZynqMP-based boards

The supported and tested boards are:

 - Ultra96-V2
 - iWave G36S

Visit the individual board links above for more information on status of the
integration and more detailed instructions on how to build and use images
together with Mender for the mentioned boards.

## Dependencies

This layer depends on:

```
URI: https://git.yoctoproject.org/git/poky
branch: honister
revision: HEAD
```

```
URI: https://github.com/mtk-pci/meta-mender.git
layers: meta-mender-core
branch: honister-xlnx
revision: HEAD
```

## Quick start

N/A (yet)

The current layer expects to be used within the PetaLinux tool provided by Xilinx, which uses Yocto under the hood but in a more constrained way.  Guidance below is based on use within the PetaLinux framework.

## PetaLinux Setup

The Mender integration found here was developed and tested with PetaLinux version 2022.1, which was a milestone release for PetaLinux that included systemd enabled by default.  PetaLinux 2022.1 and 2022.2 use the Yocto honistor (3.4) version under the hood.

PetaLinux projects include a default structure that requires placing the meta-mender-zynqmp layer (and dependency meta-mender-core layer) in the following directory locations:

`<petalinux project directory (name of project)>/project-spec/meta-mender-zynqmp`

`<petalinux project directory (name of project)>/project-spec/meta-mender-core`

There is a default layer within PetaLinux which will be located here (referenced below):

`<petalinux project directory (name of project)>/project-spec/meta-user`

The recipes that were included in the image for testing were added using the following command in <top-level-image-recipe>.inc or <top-level-image-recipe>.bb:

```
IMAGE_INSTALL:append = "\
        mender-server-certificate \
        mender-zynqmp \
        mender-system-bin \
"
```

### PetaLinux Patch Required In Some Cases

The patch ./recipes-bsp/images/patches/0001_Mender_PLNX_Deploy.patch must be applied to the PetaLinux project installation before building this recipe IF the plnx-deploy.bbclass will be inherited by the image recipe.  This is true of the Ultra96-V2 support (via u96v2-sbc.conf and avnet-boot-scr.bb), but not necessarily for other boards.

The plnx-deploy.bbclass file was not configured to handle some naming requirements assumed by the Mender recipe, and it also didn't allow for separation of build outputs by the IMAGE_NAME variable.  Both features are enabled in the patched version of plnx-deploy.bbclass.

### Add target-specific recipes

Additional user recipe(s) should be included to add target-specific settings.  This could be done within the meta-user layer associated with PetaLinux (see above) or with another custom layer added to the system.

Within the templates found in this layer, examples from `templates` could be renamed to their appropriate file types and updated with any required custom settings.  The directory recipes-mender could then be placed in the following location (for example):

```<petalinux project directory (name of project)>/project-spec/meta-user/recipes-mender/```

### Include yocto-style *.conf files in PetaLinux build
First, if necessary, create your own mender-zynqmp-target.conf file based on the example provided in the templates folder of this repository (conf/mender-zynqmp-target.conf.example).  Renamed examples include mender-zynqmp-u96v2.conf or mender-zynmp-iwg36s.conf, but you can name it whatever you like.

Then, in `<petalinux project directory>/project-spec/meta-user/conf/petalinuxbsp.conf` you must add the following lines to include required configuration settings for Mender:

```
include conf/mender-zynqmp.conf
include conf/mender-zynqmp-<target name>.conf
```

PetaLinux may ignore or overwrite the local.conf file that Yocto users would associate with this type of include command.  Instead, PetaLinux requires that manually included conf files be added to the `<petalinux project directory>/project-spec/meta-user/conf/petalinuxbsp.conf` file.

If you are using a non-petalinux flow (pure yocto or other), then the conf files above should be included in the local.conf file for the project.

Also, the image recipe file needs to include `inherit mender-zynqmp` to deploy the correct boot.bin and boot.scr files for Mender rootfs updates.

## iWave G36S eMMC installation

When the WiFi/BT module is installed on the G36S SBC, the SD card interface is not available.  Only the eMMC boot option is available via onboard storage.

To program the eMMC, iWave provides instructions in their Software User Guide for using the FSBL and u-boot binaries, a UART debug cable, and a USB drive to update the eMMC.  It involves using the UART interface to stop the boot at the u-boot console, followed by a boot from a USB image set to complete the eMMC update (while the device is not directly out of the eMMC).

helm/Docs/iW-RainboW-G36S-Zynq-Ultrascale+MPSoC-SBC-Petalinux22.2-SoftwareUserGuide-R2.0-REL1.0.pdf

However, the instructions in the current revision leave out an important adjustment if the image being updated is older and has u-boot environment settings that are incompatible with the expectations of the USB-based image.  Here are the original steps from the doc above plus an update to the usbboot environment variable in u-boot to allow completion of boot.

1. Install boot.bin and FSBL environment if the eMMC doesn't already have that installed (or it is corrupted), so that u-boot console can be reached (see "3.1 JTAG Programming" in the doc above)

1. Program the USB drive using host PC, by copying all the binaries (Image, system.dtb, rootfs.cpio.gz.u-boot & iwtest) from
deliverables.

1. Insert USB drive to USB Port on board and switch on the board. Stop at U-Boot console and execute the below
commands to boot kernel from USB.

1. setenv usbboot 'usb start && usb info; echo Copying Linux from USB to RAM... && load usb 0 ${fdt_addr_r} system.dtb && load usb 0 ${kernel_addr_r} Image && load usb 0 ${ramdisk_addr_r} rootfs.cpio.gz.u-boot && booti ${kernel_addr_r} ${ramdisk_addr_r} ${fdt_addr_r}'

1. setenv modeboot 'usbboot'

1. saveenv; boot

1. Proceed to formatting the eMMC using fdisk as described in the Software User Guide, with the following configuration:
```
root@IWG36S> fdisk /dev/mmcblk0
Command (m for help): p
Command (m for help): d
(partition 1 if it exists)
Command (m for help): d
(should say there are no paritions to delete)

Command (m for help): n
Partition type:
p primary (0 primary, 0 extended, 4 free)
e extended
Select (default p): p
Partition number (1-4, default 1): 1
First sector (2048-15759359, default 2048): 65536
Last sector, +sectors or +size{K,M,G} (65536-15759359, default 15759359): +262144
Created a new partition 1 of type 'Linux' and of size 128 MiB.
Partition #1 contains a vfat signature.
Do you want to remove the signature? [Y]es/[N]o: Y
The signature will be removed by a write command.

Command (m for help): t
Partition number (1-4): 1
Hex code (type L to list codes): c
Changed system type of partition 1 to c (W95 FAT32 (LBA))

Command (m for help): n
Partition type:
p primary (1 primary, 0 extended, 3 free)
e extended
Select (default p): p
Partition number (1-4, default 2): 2
First sector (264193-15759359, default 266240): 
(Using default value)
Last sector, +sectors or +size{K,M,G} (2048-15759359, default 15759359): +5242880

Created a new partition 2 of type 'Linux' and of size 2.5 GiB.

Command (m for help): t
Partition number (1-4): 2
Hex code or alias (type L to list all): 83

Changed type of partition 'Linux' to 'Linux'.

Command (m for help): n
Partition type:
p primary (2 primary, 0 extended, 2 free)
e extended
Select (default p): p
Partition number (1-4, default 3): 3
First sector (264193-15273599, default 5511168):
(Using default value)
Last sector, +/-sectors or +/-size{K,M,G,T,P} (5511168-15273599, default 15273599): +5242880

Created a new partition 3 of type 'Linux' and of size 2.5 GiB.

Command (m for help): t
Partition number (1-4): 3
Hex code or alias (type L to list all): 83

Changed type of partition 'Linux' to 'Linux'.

Command (m for help): n
Partition type:
p primary (3 primary, 0 extended, 1 free)
e extended
Select (default e): p

Selected partition 4
First sector (264193-15273599, default 10756096):
(Using default value)
Last sector, +/-sectors or +/-size{K,M,G,T,P} (10756096-15273599, default 15273599): +262144

Created a new partition 4 of type 'Linux' and of size 128 MiB.

Command (m for help): t
Partition number (1-4): 4
Hex code or alias (type L to list all): 83

Changed type of partition 'Linux' to 'Linux'.

Command (m for help): a
Partition number (1,2, default 2): 1

The bootable flag on partition 1 is enabled now.

Command (m for help): p
(confirm expected values)
Disk /dev/mmcblk0: 7.28 GiB, 7820083200 bytes, 15273600 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0xd1e893e2

Device         Boot    Start      End Sectors  Size Id Type
/dev/mmcblk0p1 *       65536   264192  262145  128M  c W95 FAT32 (LBA)
/dev/mmcblk0p2        266240  5509120 5242881  2.5G 83 Linux
/dev/mmcblk0p3       5511168 10754048 5242881  2.5G 83 Linux
/dev/mmcblk0p4      10756096 11018240  262145  128M 83 Linux

Filesystem/RAID signature on partition 1 will be wiped.

Command (m for help): w
The partition table has been altered.
Calling ioctl() to re-read par[ 1435.573740]  mmcblk0: p1 p2 p3 p4
tition table.
Syncing disks.

root@zynqmp-iwg36s:~# umount /run/media/mmcblk0p1
umount: /run/media/mmcblk0p1: no mount point specified.
root@zynqmp-iwg36s:~# mkfs.vfat /dev/mmcblk0p1
root@zynqmp-iwg36s:~# umount /run/media/mmcblk0p2
umount: /run/media/mmcblk0p2: no mount point specified.
root@zynqmp-iwg36s:~# mkfs.ext4 /dev/mmcblk0p2
mke2fs 1.46.4 (18-Aug-2021)
Discarding device blocks: done
Creating filesystem with 655360 4k blocks and 163840 inodes
Filesystem UUID: 594086dc-a3cc-4ac8-9d44-c292fc8dd4ae
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376, 294912

Allocating group tables: done
Writing inode tables: done
Creating journal (16384 blocks): done
Writing superblocks and filesystem accounting information: done

root@zynqmp-iwg36s:~# umount /run/media/mmcblk0p3
umount: /run/media/mmcblk0p3: no mount point specified.
root@zynqmp-iwg36s:~# mkfs.ext4 /dev/mmcblk0p3
mke2fs 1.46.4 (18-Aug-2021)
Discarding device blocks: done
Creating filesystem with 655360 4k blocks and 163840 inodes
Filesystem UUID: af659f4d-8007-4c49-8e4a-9517130274b7
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376, 294912

Allocating group tables: done
Writing inode tables: done
Creating journal (16384 blocks): done
Writing superblocks and filesystem accounting information: done

root@zynqmp-iwg36s:~# umount /run/media/mmcblk0p4
umount: /run/media/mmcblk0p4: no mount point specified.
root@zynqmp-iwg36s:~# mkfs.ext4 /dev/mmcblk0p4
mke2fs 1.46.4 (18-Aug-2021)
Discarding device blocks: done
Creating filesystem with 131072 1k blocks and 32768 inodes
Filesystem UUID: 7f280bb2-afee-4b84-bf78-d4a5d347c38c
Superblock backups stored on blocks:
        8193, 24577, 40961, 57345, 73729

Allocating group tables: done
Writing inode tables: done
Creating journal (4096 blocks): done
Writing superblocks and filesystem accounting information: done

root@zynqmp-iwg36s:~# mkdir /run/media/mmcblk0p1
root@zynqmp-iwg36s:~# mount -t vfat /dev/mmcblk0p1 /run/media/mmcblk0p1
root@zynqmp-iwg36s:~# mkdir /run/media/mmcblk0p2
root@zynqmp-iwg36s:~# mount -t ext4 /dev/mmcblk0p2 /run/media/mmcblk0p2
[ 1617.229587] EXT4-fs (mmcblk0p2): mounted filesystem with ordered data mode. Opts: (null). Quota mode: none.
root@zynqmp-iwg36s:~# mkdir /run/media/mmcblk0p3
root@zynqmp-iwg36s:~# mount -t ext4 /dev/mmcblk0p3 /run/media/mmcblk0p3
[ 1631.045156] EXT4-fs (mmcblk0p3): mounted filesystem with ordered data mode. Opts: (null). Quota mode: none.
root@zynqmp-iwg36s:~# mkdir /run/media/mmcblk0p4
root@zynqmp-iwg36s:~# mount -t ext4 /dev/mmcblk0p4 /run/media/mmcblk0p4
[ 1639.053452] EXT4-fs (mmcblk0p4): mounted filesystem with ordered data mode. Opts: (null). Quota mode: none.
root@zynqmp-iwg36s:~# cp -a /run/media/sdb1/boot.* /run/media/mmcblk0p1/
cp: failed to preserve ownership for '/run/media/mmcblk0p1/boot.bin': Operation not permitted
cp: failed to preserve ownership for '/run/media/mmcblk0p1/boot.scr': Operation not permitted
root@zynqmp-iwg36s:~# cp -a /run/media/sdb2/* /run/media/mmcblk0p2/
root@zynqmp-iwg36s:~# cp -a /run/media/sdb3/* /run/media/mmcblk0p3/
root@zynqmp-iwg36s:~# cp -a /run/media/sdb4/* /run/media/mmcblk0p4/
root@zynqmp-iwg36s:~# sync
root@zynqmp-iwg36s:~# umount /run/media/mmcblk0p*
root@zynqmp-iwg36s:~# umount /run/media/sdb*
```

## Content covered by LICENSE_mender-zynq
./recipes-bsp/u-boot/u-boot-mender-zynqmp.inc (from u-boot-mender-zynq.inc)
./recipes-bsp/u-boot/u-boot-xlnx_%.bbappend

Using v2021.1 workaround found here: https://support.xilinx.com/s/article/75730?language=en_US


## Errata

The zynmp-boot update script will install correctly and appear accessible to Mender tools.  However, it has not yet successfully tested an update of BOOT.BIN or it's multiboot fallback equivalents.  Further debugging and feature updates required.

zynmp-boot is expected to be replaced by state scripts (Mender feature) for updating boot files when necessary.
