#!/bin/bash
export ARCH=arm
if [ "$1" == "local" ]; then
	echo "Local Build"
	build=/home/savoca/dev/output
	export CROSS_COMPILE=/home/savoca/toolchains/android-toolchain-eabi/bin/arm-eabi-
else
	echo "Remote Build"
	build=/home/savoca/downloads/furnace/mako/aosp
	export CROSS_COMPILE=/home/savoca/storage/toolchains/android-toolchain-eabi/bin/arm-eabi-
fi
kernel="furnace"
version="1.0.0"
rom="aosp"
variant="mako"
ramdisk=ramdisk
config="furnace_defconfig"
kerneltype="zImage"
jobcount="-j$(grep -c ^processor /proc/cpuinfo)"
ps=2048
base=0x80200000
ramdisk_offset=0x01600000
tags_offset=0x00000100
cmdline="console=ttyHSL0,115200,n8 androidboot.hardware=mako lpj=67677 user_debug=31"

function cleanme {
	if [ -f arch/arm/boot/"$kerneltype" ]; then
		echo "  CLEAN   ozip"
	fi
	rm -rf ozip/boot.img
	rm -rf arch/arm/boot/"$kerneltype"
	mkdir -p ozip/system/lib/modules
	make clean && make mrproper
	echo "Working directory cleaned..."
}

rm -rf out
mkdir out
mkdir out/tmp
echo "Checking for build..."
if [ -f ozip/boot.img ]; then
	read -p "Previous build found, clean working directory..(y/n)? : " cchoice
	case "$cchoice" in
		y|Y )
			cleanme;;
		n|N )
			exit 0;;
		* )
			echo "Invalid...";;
	esac
	read -p "Begin build now..(y/n)? : " dchoice
	case "$dchoice" in
		y|Y)
			make "$config"
			make "$jobcount"
			exit 0;;
		n|N )
			exit 0;;
		* )
			echo "Invalid...";;
	esac
fi
echo "Extracting files..."
if [ -f arch/arm/boot/"$kerneltype" ]; then
	cp arch/arm/boot/"$kerneltype" out
	rm -rf ozip/system
	mkdir -p ozip/system/lib/modules
	find . -name "*.ko" -exec cp {} ozip/system/lib/modules \;
	if [ -e ozip/system/lib/modules/*.ko ]; then
		echo "Modules found."
	else
		echo "No modules"
		rm -rf ozip/system
	fi
else
	echo "Nothing has been made..."
	read -p "Clean working directory..(y/n)? : " achoice
	case "$achoice" in
		y|Y )
			cleanme;;
		n|N )
			exit 0;;
		* )
			echo "Invalid...";;
	esac
	read -p "Begin build now..(y/n)? : " bchoice
	case "$bchoice" in
		y|Y)
			make "$config"
			make "$jobcount"
			exit 0;;
		n|N )
			exit 0;;
		* )
			echo "Invalid...";;
	esac
fi

echo "Making ramdisk..."
if [ -d $ramdisk ]; then
	mkbootfs $ramdisk | gzip > out/ramdisk.gz
else
	echo "No ramdisk found..."
	exit 0;
fi

echo "Making boot.img..."
if [ -f out/"$kerneltype" ]; then
	mkbootimg --kernel out/"$kerneltype" --ramdisk out/ramdisk.gz --cmdline "$cmdline" --base $base --pagesize $ps --ramdisk_offset $ramdisk_offset --tags_offset $tags_offset --output ozip/boot.img
else
	echo "No $kerneltype found..."
	exit 0;
fi

echo "Zipping..."
if [ -f arch/arm/boot/"$kerneltype" ]; then
	cd ozip
	zip -r ../"$kernel"-$version-"$rom"_"$variant".zip .
	mv ../"$kernel"-$version-"$rom"_"$variant".zip $build
	cd ..
	rm -rf out ozip/system
	echo "Done..."
	echo "Output zip: $build/$kernel-$version-$(echo $rom)_$variant.zip"
	exit 0;
else
	echo "No $kerneltype found..."
	exit 0;
fi
