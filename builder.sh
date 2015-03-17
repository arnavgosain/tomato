#!/bin/bash
echo "Welcome to Velvet Kernel Builder!"
LC_ALL=C date +%Y-%m-%d
#toolchain="/root/velvet/toolchains/linaro_toolchains_2014/arm-cortex_a15-linux-gnueabihf-linaro_4.9.3-2014.12/bin/arm-eabi-"
#toolchain="/root/velvet/toolchains/arm-cortex_a15-linux-gnueabihf-linaro_4.9.1/bin/arm-gnueabi-"
toolchain="/root/velvet/toolchains/SaberNaro-arm-eabi-4.9/bin/arm-eabi-"
build=/root/velvet/out/tomato
kernel="velvet"
version="R5"
rom="cm"
vendor="yu"
device="tomato"
date=`date +%Y%m%d`
ramdisk=ramdisk
config=velvet_tomato_defconfig
kerneltype="zImage"
base=0x80000000
ramdisk_offset=0x01000000
pagesize=2048
cmdline="androidboot.console=ttyHSL0 androidboot.hardware=qcom user_debug=31 msm_rtb.filter=0x3F ehci-hcd.park=3 androidboot.bootdevice=7824900.sdhci sched_enable_hmp=1"
jobcount="-j$(grep -c ^processor /proc/cpuinfo)"
export KBUILD_BUILD_USER=arnavgosain
export KBUILD_BUILD_HOST=velvet

#rm -rf out
#mkdir out
#mkdir out/tmp
echo "Checking for build..."
if [ -f zip/zImage ]; then
	read -p "Previous build found, clean working directory..(y/n)? : " cchoice
	case "$cchoice" in
		y|Y )
			export ARCH=arm
			export CROSS_COMPILE=$toolchain
			echo "  CLEAN zip"
#			rm -rf zip/boot.img
			rm -rf zip/zImage
			rm -rf arch/arm/boot/"$kerneltype"
#			rm -rf zip/system
#			mkdir -p zip/system/lib/modules
			make clean && make mrproper
			echo "Working directory cleaned...";;
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
	cp arch/arm/boot/"$kerneltype" zip/tools
else
	echo "Nothing has been made..."
	read -p "Clean working directory..(y/n)? : " achoice
	case "$achoice" in
		y|Y )
			export ARCH=arm
                        export CROSS_COMPILE=$toolchain
                        echo "  CLEAN zip"
#                        rm -rf zip/boot.img
			rm zip/zImage
                        rm -rf arch/arm/boot/"$kerneltype"
                        make clean && make mrproper
                        echo "Working directory cleaned...";;
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

#echo "Making ramdisk..."
#if [ -d $ramdisk ]; then
#	boot_tools/mkboot#fs $ramdisk | gzip > out/ramdisk.gz
#else
#	echo "No ramdisk found..."
#	exit 0;
#fi

#echo "Making dt.img..."
#./boot_tools/dtbToolCM --force-v2 -o out/dt.img -s 2048 -p ./scripts/dtc/ ./arch/arm/boot/dts/

#echo "Making boot.img..."
#if [ -f out/"$kerneltype" ]; then
#	./boot_tools/mkbootimg --kernel out/"$kerneltype" --ramdisk out/ramdisk.gz --cmdline $cmdline --base $base --pagesize $pagesize --ramdisk_offset $ramdisk_offset --dt out/dt.img -o zip/boot.img
#	./boot_tools/mkbootimg --base 0x80000000 --kernel out/zImage --ramdisk_offset 0x01000000 --cmdline "androidboot.console=ttyHSL0 androidboot.hardware=qcom user_debug=31 msm_rtb.filter=0x3F ehci-hcd.park=3 androidboot.bootdevice=7824900.sdhci sched_enable_hmp=1" --ramdisk out/ramdisk.gz --dt out/dt.img -o out/boot.img
#else
#	echo "No $kerneltype found..."
#	exit 0;
#fi

#echo "Copying boot.img to out dir..."
#cp out/boot.img zip

echo "Zipping..."
if [ -f arch/arm/boot/"$kerneltype" ]; then
	cd zip
	zip -r ../"$kernel"."$version"-"$rom"."$vendor"."$device"."$date".zip .
	mv ../"$kernel"."$version"-"$rom"."$vendor"."$device"."$date".zip $build
	rm zImage
	cd ..
	echo "Done..."
	exit 0;
else
	echo "No $kerneltype found..."
	exit 0;
fi
# Export script by Savoca
# Thank You Savoca!
