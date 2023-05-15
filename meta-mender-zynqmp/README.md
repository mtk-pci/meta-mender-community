# meta-mender-zynqmp

Mender integration for Xilinx ZynqMP-based boards

The supported and tested boards are:

 - Ultra96-V2


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

The current layer expects to be used within the Petalinux tool provided by Xilinx, which uses Yocto under the hood but in a more constrained way.  Guidance below is based on use within the Petalinux framework.

## Petalinux Setup

The Mender integration found here was developed and tested with Petalinux version 2022.1, which was a milestone release for Petalinux that included systemd enabled by default.  Petalinux 2022.1 uses the Yocto honistor (3.4) version under the hood.

Petalinux projects include a default structure that requires placing the meta-mender-zynqmp layer (and dependency meta-mender-core layer) in the following directory locations:

<petalinux project directory (name of project)>/project-spec/meta-mender-zynqmp
<petalinux project directory (name of project)>/project-spec/meta-mender-core

There is a default layer within Petalinux which will be located here (referenced below):

<petalinux project directory (name of project)>/project-spec/meta-user

### Petalinux Patch Required

The patch ./recipes-bsp/images/patches/0001_Mender_PLNX_Deploy.patch must be applied to the Petalinux project installation before building this recipe.

The plnx-deploy.bbclass file was not configured to handle some naming requirements assumed by the Mender recipe, and it also didn't allow for separation of build outputs by the IMAGE_NAME variable.  Both features are enabled in the patched version of plnx-deploy.bbclass.

### Include local.conf in Petalinux build
In <petalinux project directory>/project-spec/meta-user/conf/petalinuxbsp.conf

Add the following line to include required configuration settings for Mender:

include conf/mender-zynqmp.conf


## Content covered by LICENSE_mender-zynq
./recipes-bsp/u-boot/u-boot-mender-zynqmp.inc (from u-boot-mender-zynq.inc)
./recipes-bsp/u-boot/u-boot-xlnx_%.bbappend

Using v2021.1 workaround found here: https://support.xilinx.com/s/article/75730?language=en_US


## Errata

The zynmp-boot update script will install correctly and appear accessible to Mender tools.  However, it has not yet successfully tested an update of BOOT.BIN or it's multiboot fallback equivalents.  Further debugging and feature updates required.
