SUMMARY += " and modifies boot.bin generation for Xilinx targets using Mender"

# Remove bitstream from boot.bin, to be loaded from rootfs partition instead
BIF_PARTITION_ATTR:remove = " \
    bitstream \
"
