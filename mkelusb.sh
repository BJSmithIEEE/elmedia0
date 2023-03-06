#!/bin/bash
#
#	mkelusb.sh
#	Make an uEFI bootable USB device for installing Enterprise Linux from an ISO source (mounted)
#	NOTE:  This script is designed to work with Linux (even Busybox), and may work under Cygwin or even MinGW/MinSy


#set -ox

###	Globals

# Parameters
myCwd="$(pwd)"
myNam="$(basename ${0})"
myDir="$(dirname ${0})"
myLbl="${3}"
mySrc="${2}"
myDst="${1}"


# Source Common Functions/Globals
. ${myDir}/elmedia.func


# Environment
myPkg="addlpkgs ansible"		# Tarballs of Packages to Include
myOpt="STIG TPS"			# Tarballs of Optional Files to Include
gOver=1					# Always copy/overwrite by default



###	Functions

# outSyntax - Print syntax and exit
outSyntax() {
	echo -e "\n${myNam} - Make VFAT formatted Hybrid USB for installing Enterprise Linux\n" >> /dev/stderr
	echo -e "${myNam}  [-f]  dst_usb_mnt  src_iso_mnt  [dst_usb_lbl]\n" >> /dev/stderr
	echo -e "\t[-f]\t\t[opt] Force checksum/overwrite of existing USB distribution" >> /dev/stderr
	echo -e "\tdst_usb_mnt\tTarget USB (mounted, ideally empty, will NOT delete files)" >> /dev/stderr
	echo -e "\tsrc_iso_mnt\tSource ISO (mounted or copied to directory)" >> /dev/stderr
	echo -e "\t[dst_usb_lbl]\t[opt] USB VFAT Label (must match actual USB label)" >> /dev/stderr
	echo -e "\nExamples:" >> /dev/stderr
	echo -e "\t${myNam}  /run/media/${USER}/RHEL-8  /run/media/${USER}/RHEL-8-4-0-BaseOS_x86_64  [RHEL-8]" >> /dev/stderr
	echo -e "\t${myNam}  /cygdrive/f  /cygdrive/d   [C8ELMEDIA]       <== e.g., Cygwin/MobaXterm" >> /dev/stderr
	echo -e "\t${myNam}  /f           /d            [R8ELMEDIA]       <== e.g., MinGW/Git Bash" >> /dev/stderr
	echo -e "\n"
}



### MAIN

if [ "${myDst}" == "" ] ; then
	outSyntax
	exit 127
elif [ ! -d "${myDst}" ] ; then
	echo -e "\nERROR(33): destination(${myDst}) is not a mounted USB device (or directory)\n" >> /dev/stderr
	outSyntax
	exit 33
elif [ ! -f "${mySrc}/.discinfo" ] ; then
	echo -e "\nERROR(34): source(${mySrc}) is not a mounted ISO with required file (./discinfo)\n" >> /dev/stderr
	outSyntax
	exit 34
fi

echo -e "\n${myNam}:\tIdentify Distribution and Release"
getRelVer "${mySrc}"
echo -e "\tusing relver(${gRelVer})"

myLblDef="$(echo ${gRelVer}ELMEDIA | tr [:lower:] [:upper:])"

echo -e "\n${myNam}:\tUSB Label"
if [ "${myLbl}" == "" ] ; then
	# Get label
	myLbl=$(getLabel "${myDst}")
	if [ "${myLbl}" == "" ] ; then
		echo -e "\nERROR(35): label must be passed\n" >> /dev/stderr
		outSyntax
		exit 35
	fi
fi
echo -e "\tusing label(${myLbl})"

# Copy distribution - This is the most time consuming, unless the distribution is already on the media
echo -e "\n${myNam}:\tCheck Destination USB against Source ISO"
cpTree  "${mySrc}"  "${myDst}"  ${gOver}  0

# NOTE:  Always do these steps after the distribution - in case the directories already exist

# Packages not provided in distribution media but required in %packages
for p in ${myPkg} ; do
	echo -e "\n${myNam}:\tGet Packages (${p}) Repo (if no local copy)"
	if [ "${p}" == "ansible" ] ; then
		getFilTar "${myDir}" "${p}.${gVer}-validated.tar" "${p}.${gVer}/${p}${gAnsVer}.${gRelVer}/repodata"
		echo -e "\n${myNam}:\tCopy Packages (${p}) Repo for Distribution"
		cpTree "${myDir}/${p}.${gVer}/${p}${gAnsVer}.${gRelVer}" "${myDst}/${p}${gAnsVer}"  1  1
	else
		getFilTar "${myDir}" "${p}.${gVer}-validated.tar" "${p}.${gVer}/${p}.${gRelVer}/repodata"
		echo -e "\n${myNam}:\tCopy Packages (${p}) Repo for Distribution"
		cpTree "${myDir}/${p}.${gVer}/${p}.${gRelVer}" "${myDst}/${p}"  1  1
	fi
done

# Optional files to add for %post
for f in ${myOpt} ; do
	echo -e "\n${myNam}:\tGet Optional (${f} Files (if no local copy)"
	getFilTar "${myDir}" "opt_${f}.${gVer}-validated.tar" "opt.${gVer}/${f}"
done
echo -e "\n${myNam}:\tCopy All Optional Files for Distribution"
cpTree "${myDir}/opt.${gVer}" "${myDst}/opt"  1  1

# Kickstart files
echo -e "\n${myNam}:\tCopy Kickstart Files"
cpTree "${myDir}/ks" "${myDst}/ks"  1	1
echo -e "\n${myNam}:\tInject Kickstart Files w/Globals-Functions"
for f in ${myDst}/ks/ks-el*.ks ; do
	sed -i '/^[ \t]*[#][ \t]\+XXXXX[ \t]\+INJECT_KSPRE[ \t]\+XXXXX[ \t]*$/r ks/inject/ks-elmedia.inject' ${f}
done

# Boot files
echo -e "\n${myNam}:\tGet Boot Files"
getMnuGet "${myDst}"
# Dynamic Menu - TODO
#echo -e "\n${myNam}:\tGet Kickstart Meta"
#getMnuKsf "${myDst}"
#echo -e "\n${myNam}:\tGenerate Kickstart Entries"
#genMnuKse "${myDst}"
# Static Menu - Interim/Temporary (hardcoded)
echo -e "\n${myNam}:\tCopy Boot Files (hardcoded)"
cpTree "${myDir}/hardcode/menu.${gRelVer}"  "${myDst}"  1  0
# Menu - Set/Replace any USB default label with actual USB label
echo -e "\n${myNam}:\tUpdate Boot Files for USB Label (${myLbl})"
setMnuLbl "${myDst}" "${myLbl}" "${myLblDef}"


