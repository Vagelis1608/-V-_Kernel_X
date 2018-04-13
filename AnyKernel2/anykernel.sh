# AnyKernel2 Ramdisk Mod Script
# osm0sis @ xda-developers

## AnyKernel setup
# begin properties
properties() {
kernel.string=-V- Kernel X v1.3.1 by Vagelis1608 @ xda-developers
do.devicecheck=0
do.modules=0
do.cleanup=1
do.cleanuponabort=0
device.name1=g2m
device.name2=d620
device.name3=d620r
device.name4=d618
device.name5=d610
} # end properties

# shell variables
block=/dev/block/platform/msm_sdcc.1/by-name/boot;
is_slot_device=0;


## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see for reference
. /tmp/anykernel/tools/ak2-core.sh;


## AnyKernel permissions
# set permissions for included ramdisk files
chmod -R 755 $ramdisk

## AnyKernel install
dump_boot;

# begin ramdisk changes

# Main script install
backup_file init.rc
insert_line init.rc "import /init.vkx.rc" before "import /init.environ.rc" "import /init.vkx.rc"

# Fix init.d
# By disabling the original service that runs it and running it from init.vkx.rc
backup_file init.cm.rc
replace_string init.cm.rc "    # start sysinit" "    start sysinit" "    # start sysinit"

# Remove 'placeholder' file added by mistake in v1.0
if [ -e placeholder ]; then
    CHK=`cat placeholder`
    if [ -z "$CHK" ]; then
        rm -f placeholder
    fi
fi

# end ramdisk changes

write_boot;

## end install

