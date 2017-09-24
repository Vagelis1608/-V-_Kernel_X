#!/system/bin/sh

# -V- Kernel X main script file
# Written for -V- Kernel X by Vagelis1608 @xda-developers

# Variables
# Busybox build by osm0sis @xda-developers
BB=/sbin/bb/busybox
PROP=/data/vkx.prop

# Create the properties file, if missing, then set permissions/owner.
if [ ! -e $PROP ]; then
    touch $PROP
    echo "# Properties file for -V- Kernel X" > $PROP
    echo "" >> $PROP
fi
chmod 644 $PROP
chown root.root $PROP

# Grab properties
gprop() { $BB grep "^$1" "$PROP" | $BB cut -d= -f2; }

MPDS=`gprop persist.mpdecision.stop`
if [ -z $MPDS ]; then
    echo "persist.mpdecision.stop=1" >> $PROP
    MPDS=1
fi

UBZR=`gprop persist.use.big.zram`
if [ -z $UBZR ]; then
    echo "persist.use.big.zram=1" >> $PROP
    UBZR=1
fi

USF=`gprop persist.using.swap.file`
if [ -z $USF ]; then
    echo "persist.using.swap.file=0" >> $PROP
    UBZR=1
fi

UKSM=`gprop persist.use.ksm`
if [ -z $UKSM ]; then
    echo "persist.use.ksm=1" >> $PROP
    UKSM=1
fi

UIT=`gprop persist.use.intelli_thermal`
if [ -z $UIT ]; then
    echo "persist.use.intelli_thermal=1" >> $PROP
    UIT=1
fi

# Check for Magisk
if [ -e /dev/magisk ]; then
    SYSTEM=/dev/magisk/mirror/system
else
    SYSTEM=/system
fi

# Force stop MPDecision if the prop persist.mpdecision.stop is set to 1
if [ "$MPDS" == "1" ]; then
    setprop ctl.stop mpdecision
    stop mpdecision
    if [ -e $SYSTEM/bin/mpdecision ]; then
        mount -t auto -o rw,remount $SYSTEM
        $BB cp -af $SYSTEM/bin/mpdecision $SYSTEM/bin/mpdecision-dis
        $BB rm -f $SYSTEM/bin/mpdecision
        mount -t auto -o ro,remount $SYSTEM
    fi
elif [ -e $SYSTEM/bin/mpdecision-dis ]; then
    mount -t auto -o rw,remount $SYSTEM
    $BB cp -af $SYSTEM/bin/mpdecision-dis $SYSTEM/bin/mpdecision
    $BB rm -f $SYSTEM/bin/mpdecision-dis
    mount -t auto -o ro,remount $SYSTEM      
fi

# Set ZRAM to 500MB if the prop persist.use.big.zram is set to 1
if [ "$UBZR" == "1" ]; then
    # Also set swappiness to '100' if the user doesn't use a swap file (persist.using.swap.file=0)
    if [ "$USF" == "0" ]; then
        echo '100' > /proc/sys/vm/swappiness
    fi
    $BB swapoff /dev/block/zram0
    echo '1' > /sys/block/zram0/reset
    echo '0' > /sys/block/zram0/disksize
    echo '524288000' > /sys/block/zram0/disksize
    $BB mkswap /dev/block/zram0
    $BB swapon /dev/block/zram0
fi

# Activate KSM if the prop persist.use.ksm is set to 1
if [ "$UKSM" == "1" ]; then
    echo '1' > /sys/kernel/mm/ksm/run
fi

# Activate Intelli_Thermal if the prop persist.use.intelli_thermal is set to 1
if [ "$UIT" == "1" ]; then
    echo '1' > /sys/module/msm_thermal/core_control/enabled
    echo '75' > /sys/module/msm_thermal/parameters/core_limit_temp_degC
    echo '65' > /sys/module/msm_thermal/parameters/limit_temp_degC
    echo '500' > /sys/module/msm_thermal/parameters/poll_ms
    echo 'Y' > /sys/module/msm_thermal/parameters/enabled
fi

