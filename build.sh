# Build script written by Vagelis1608 @xda-developers
# Note: CROSS_COMPILE must be set manually before executing this

# Input handling
usage() {
    echo "Build script written by Vagelis1608 @xda-developers"
    echo "Usage: ./build.sh [-cn] 'version'"
    echo "-c   run 'make clean' for a clean build"
    echo "-n   don't create a zip (version not needed if selected)"
    echo ""
    echo "-h or --help   prints this message"
    exit 0
}

if [ -z "$CROSS_COMPILE" ]; then
    echo "Note: CROSS_COMPILE must be set manually before executing"
    echo ""
    usage
fi

if [ "$1" == "-c" ]; then
    CLEAN=1
    if [ -n "$2" ]; then
        VERSION=$2
    fi
elif [ "$1" == "-n" ]; then
    NOZIP=1
elif [ "$1" == "-cn" -o "$1" == "-nc" ]; then
    CLEAN=1
    NOZIP=1
elif [ -z "$1" -o "$1" == "-h" -o "$1" == "--help" ]; then
    usage
elif [ -n "$1" ]; then
    VERSION=$1
fi

if [ -z "$VERSION" -a "$NOZIP" != "1" ]; then
    usage
fi

# Clean up the build dirs using 'make clean', if -c flag was given
if [ "$CLEAN" == "1" ]; then
    echo "Cleaning up..."
    echo ""
    make clean
    echo ""
    echo "Clean-up complete"
    echo ""
fi

echo "Making zImage..."
echo ""

# This builds the zImage (kernel)
# The -jx tells make how many CPUs to use, where x is the number of CPUs + 1
# So, for my Dual-core system, x= 2 + 1 = 3
make -j3 ARCH=arm

echo ""
echo "zImage done"
echo ""
echo "dtbTool starting..."
echo ""

# This combines the dtbs into a single, bootable one (dt.img)
./dtbToolCM -2 -o ./arch/arm/boot/dt.img -s 2048 -p ./scripts/dtc/ ./arch/arm/boot/

echo ""
echo "dtbTool done"

# Copy zImage and dt.img to the template (AnyKernel2)
if [ -e AnyKernel2 ]; then
    TE=1
    echo ""
    echo "Coping files to template..."
    echo ""
    cp -avf arch/arm/boot/zImage AnyKernel2
    cp -avf arch/arm/boot/dt.img AnyKernel2
    echo ""
    echo "Copy done"
fi

# Creating zip
if [ "$NOZIP" != "1" -a "$TE" == "1" ]; then
    echo ""
    echo "Creating zip..."
    cd AnyKernel2
    zip -r9 UPDATE-V-_Kernel_X_v$VERSION.zip * -x README.md
    if [ -e /media/sf_Android ]; then
        echo ""
        echo "sf_android found. Copying..."
        echo ""
        sudo cp -avf UPDATE-V-_Kernel_X_v*.zip /media/sf_Android
        echo ""
        echo "Done"
        echo ""
    fi
    cd ..
    cp -avf AnyKernel2/UPDATE-V-_Kernel_X_v*.zip zips
    rm -f AnyKernel2/UPDATE-V-_Kernel_X_v*.zip
fi

echo ""
echo "All done!"

