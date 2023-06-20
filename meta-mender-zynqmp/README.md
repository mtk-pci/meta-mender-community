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

### PetaLinux Patch Required

The patch ./recipes-bsp/images/patches/0001_Mender_PLNX_Deploy.patch must be applied to the PetaLinux project installation before building this recipe.

The plnx-deploy.bbclass file was not configured to handle some naming requirements assumed by the Mender recipe, and it also didn't allow for separation of build outputs by the IMAGE_NAME variable.  Both features are enabled in the patched version of plnx-deploy.bbclass.

### Add target-specific recipes

Additional user recipe(s) should be included to add target-specific settings.  This could be done within the meta-user layer associated with PetaLinux (see above) or with another custom layer added to the system.

Within the templates found in this layer, examples from `templates` could be renamed to their appropriate file types and updated with any required custom settings.  The directory recipes-mender could then be placed in the following location (for example):

```<petalinux project directory (name of project)>/project-spec/meta-user/recipes-mender/```

### Include yocto-style *.conf files in PetaLinux build
First, if necessary, create your own mender-zynqmp-target.conf file based on the example provided in the templates folder of this repository.  Examples include mender-zynqmp-u96v2.conf or mender-zynmp-iwg36s.conf, but you can name it whatever you like.

Then, in `<petalinux project directory>/project-spec/meta-user/conf/petalinuxbsp.conf` you must add the following lines to include required configuration settings for Mender:

```
include conf/mender-zynqmp.conf
include conf/mender-zynqmp-<target name>.conf
```

PetaLinux may ignore or overwrite the local.conf file that Yocto users would associate with this type of include command.  Instead, PetaLinux requires that manually included conf files be added to the `<petalinux project directory>/project-spec/meta-user/conf/petalinuxbsp.conf` file.

If you are using a non-petalinux flow (pure yocto or other), then the conf files above should be included in the local.conf file for the project.

#### Change to previous

Previously, the image recipe file needed to include `inherit mender-zynqmp`, but that has changed so that the mender-zynqmp.bbclass is no longer needed (functionality replaced by mender-system-bin and other recommended updates).

## Content covered by LICENSE_mender-zynq
./recipes-bsp/u-boot/u-boot-mender-zynqmp.inc (from u-boot-mender-zynq.inc)
./recipes-bsp/u-boot/u-boot-xlnx_%.bbappend

Using v2021.1 workaround found here: https://support.xilinx.com/s/article/75730?language=en_US


## Errata

The zynmp-boot update script will install correctly and appear accessible to Mender tools.  However, it has not yet successfully tested an update of BOOT.BIN or it's multiboot fallback equivalents.  Further debugging and feature updates required.

zynmp-boot is expected to be replaced by state scripts (Mender feature) for updating boot files when necessary.
