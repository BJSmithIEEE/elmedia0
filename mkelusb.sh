#!/bin/bash
#
#	mkelusb.sh
#	Make an uEFI bootable USB device for installing Enterprise Linux from an ISO source (mounted)
#	NOTE:  This script is designed to work with Linux (even Busybox), and may work under Cygwin or even MinGW/MinSy


#set -ox

###	Globals

# Parameters
myNam="$(basename ${0})"
myDir="$(dirname ${0})"
if [ "${1}" == "-f" ] ; then let gOver=1 ; shift ; fi ; myDst="${1}"
if [ "${2}" == "-f" ] ; then let gOver=1 ; shift ; fi ; mySrc="${2}"
if [ "${3}" == "-f" ] ; then let gOver=1 ; shift ; fi ; myLbl="${3}"
if [ "${4}" == "-f" ] ; then let gOver=1 ; shift ; fi 


###	Source Common Functions/Globals
. ${myDir}/elmedia.func


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

echo -e "\n${myNam}:\tCheck Destination USB against Source ISO"
cpTree  "${mySrc}"  "${myDst}"  ${gOver}  0

echo -e "\n${myNam}:\tGet Additional Packages (addlpkgs) Repo (if no local copy)"
getFilTar "${myDir}" "addlpkgs.${gVer}-validated.tar" "addlpkgs.${gVer}/addlpkgs.${gRelVer}/repodata"

echo -e "\n${myNam}:\tCopy Additional Packages (addlpkgs) Repo for Distribution"
cpTree "${myDir}/addlpkgs.${gVer}/addlpkgs.${gRelVer}" "${myDst}/addlpkgs"  1  1

echo -e "\n${myNam}:\tGet Ansible Repo (if no local copy)"
getFilTar "${myDir}" "ansible.${gVer}-validated.tar" "ansible.${gVer}/ansible${gAnsVer}.${gRelVer}/repodata"

echo -e "\n${myNam}:\tCopy Ansible Repo for Distribution"
cpTree "${myDir}/ansible.${gVer}/ansible${gAnsVer}.${gRelVer}" "${myDst}/ansible${gAnsVer}"  1  1

echo -e "\n${myNam}:\tGet Optional Files (if no local copy)"
getFilTar "${myDir}" "opt.${gVer}-validated.tar" "opt.${gVer}/STIG"

echo -e "\n${myNam}:\tGet Optional Third Party Software (TPS, if no local copy)"
getFilTar "${myDir}" "opt_TPS.${gVer}-validated.tar" "opt.${gVer}/TPS"

echo -e "\n${myNam}:\tCopy Optional Files for Distribution"
cpTree "${myDir}/opt.${gVer}" "${myDst}/opt"  1  1

echo -e "\n${myNam}:\tCopy Kickstart Files"
cpTree "${myDir}/ks" "${myDst}/ks"  1	1

echo -e "\n${myNam}:\tInject Kickstart Files w/Globals-Functions"
for f in ${myDst}/ks/ks-el*.ks ; do
	sed -i '/^[ \t]*[#][ \t]\+XXXXX[ \t]\+INJECT_KSPRE[ \t]\+XXXXX[ \t]*$/r ks/inject/ks-elmedia.inject' ${f}
done

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



