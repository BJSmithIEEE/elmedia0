#!/bin/bash
#
#	mkeliso.sh
#	Make an MBR/uEFI bootable ISO device for installing Enterprise Linux from an ISO source (mounted)
#	NOTE:  This script is designed to work with Linux (even Busybox), and may work under Cygwin or even MinGW/MinSys


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
gOver=1					# ISO - Always copy/overwrite by default



###	Functions

# outSyntax - Print syntax and exit
outSyntax() {
	echo -e "\n${myNam} - Make ISO formatted for installing Enterprise Linux\n" >> /dev/stderr
	echo -e "${myNam}  dst_iso_dir  src_iso_mnt  [dst_iso_lbl]\n" >> /dev/stderr
	echo -e "\tdst_iso_dir\tTarget DIR (destination directory)" >> /dev/stderr
	echo -e "\tsrc_iso_mnt\tSource ISO (mounted or contents copied to directory)" >> /dev/stderr
	echo -e "\t[dst_usb_lbl]\t[opt] ISO Label (default: '[CR][7-9]ELMEDIA' based on dist/rel)" >> /dev/stderr
	echo -e "\nExamples:" >> /dev/stderr
	echo -e "\t${myNam}  /tmp   /run/media/${USER}/RHEL-8-4-0-BaseOS_x86_64  [R8ELMEDIA]" >> /dev/stderr
	echo -e "\t${myNam}  /cygdrive/c/tmp  /cygdrive/d  [C8ELMEDIA]    <== e.g., Cygwin/MobaXterm" >> /dev/stderr
	echo -e "\t${myNam}  /c/tmp  /d                    [R8ELMEDIA]    <== e.g., MinGW/Git Bash" >> /dev/stderr
	echo -e "\n"
}


### MAIN

if [ "${myDst}" == "" ] ; then
	outSyntax
	exit 127
elif [ ! -d "${myDst}" ] ; then
	echo -e "\nERROR(33): destination(${myDst}) is not a directory\n" >> /dev/stderr
	outSyntax
	exit 33
elif [ ! -f "${mySrc}/.discinfo" ] ; then
	echo -e "\nERROR(34): source(${mySrc}) is not a mounted (or extracted) ISO with required file (./discinfo)\n" >> /dev/stderr
	outSyntax
	exit 34
fi

# mkisofs and hybridiso required for this script
[ "${bMkiso}" == "" ] && echo -e "\nERROR(96): binary 'mkisofs' required, not found in PATH\n" >> /dev/stderr && exit 96
[ "${bHyiso}" == "" ] && echo -e "\nERROR(97): binary 'isohybrid' required, not found in PATH\n" >> /dev/stderr && exit 97 

echo -e "\n${myNam}:\tIdentify Distribution and Release"
getRelVer "${mySrc}"
echo -e "\tusing relver(${gRelVer})"

myLblDef="$(echo ${gRelVer}ELMEDIA | tr [:lower:] [:upper:])"

[ "${myLbl}" == "" ] && myLbl="${myLblDef}"
echo -e "\n${myNam}:\tUSB Label"
echo -e "\tusing label(${myLbl})"

# Temporary build area for ISO (not required for USB)
myDstTmp="${myDst}/elmedia-isobuild_${gDt}"

# Copy distribution - This is the most time consuming, unless the distribution is already on the media
echo -e "\n${myNam}:\tCreate Temporary ISO Build Subdir from Source ISO"
mkdir -p "${myDstTmp}"
cpTree  "${mySrc}"  "${myDstTmp}"  ${gOver}  0

# NOTE:  Always do these steps after the distribution - in case the directories already exist

# Packages not provided in distribution media but required in %packages
for p in ${myPkg} ; do
	echo -e "\n${myNam}:\tGet Packages (${p}) Repo (if no local copy)"
	if [ "${p}" == "ansible" ] ; then
		getFilTar "${myDir}" "${p}.${gVer}-validated.tar" "${p}.${gVer}/${p}${gAnsVer}.${gRelVer}/repodata"
		echo -e "\n${myNam}:\tCopy Packages (${p}) Repo for Distribution"
		cpTree "${myDir}/${p}.${gVer}/${p}${gAnsVer}.${gRelVer}" "${myDstTmp}/${p}${gAnsVer}"  1  1
	else
		getFilTar "${myDir}" "${p}.${gVer}-validated.tar" "${p}.${gVer}/${p}.${gRelVer}/repodata"
		echo -e "\n${myNam}:\tCopy Packages (${p}) Repo for Distribution"
		cpTree "${myDir}/${p}.${gVer}/${p}.${gRelVer}" "${myDstTmp}/${p}"  1  1
	fi
done

# Optional files to add for %post
for f in ${myOpt} ; do
	echo -e "\n${myNam}:\tGet Optional (${f} Files (if no local copy)"
	getFilTar "${myDir}" "opt_${f}.${gVer}-validated.tar" "opt.${gVer}/${f}"
done
echo -e "\n${myNam}:\tCopy All Optional Files for Distribution"
cpTree "${myDir}/opt.${gVer}" "${myDstTmp}/opt"  1  1

# Kickstart files
echo -e "\n${myNam}:\tCopy Kickstart Files"
cpTree "${myDir}/ks" "${myDstTmp}/ks"  1  1
echo -e "\n${myNam}:\tInject Kickstart Files w/Globals-Functions"
for f in ${myDstTmp}/ks/ks-el*.ks ; do
	sed -i '/^[ \t]*[#][ \t]\+XXXXX[ \t]\+INJECT_KSPRE[ \t]\+XXXXX[ \t]*$/r ks/inject/ks-elmedia.inject' ${f}
done

# Boot files
echo -e "\n${myNam}:\tGet Boot Files"
getMnuGet "${myDstTmp}"
# Dynamic Menu - TODO
#echo -e "\n${myNam}:\tGet Kickstart Meta"
#getMnuKsf "${myDstTmp}"
#echo -e "\n${myNam}:\tGenerate Kickstart Entries"
#genMnuKse "${myDstTmp}"
# Static Menu - Interim/Temporary (hardcoded)
echo -e "\n${myNam}:\tCopy Boot Files (hardcoded)"
cpTree "${myDir}/hardcode/menu.${gRelVer}"  "${myDstTmp}"  1  0
# Menu - Set/Replace any ISO default label with actual ISO label
echo -e "\n${myNam}:\tUpdate Boot Files for ISO Label (${myLbl})"
setMnuLbl "${myDstTmp}" "${myLbl}" "${myLblDef}"

# Build ISO file (not required for USB) - See Red Hat Solution 60959 - https://access.redhat.com/solutions/60959
echo -e "\n${myNam}:\tGenerate ISO File"
cd "${myDstTmp}"
rmdir rr_moved 2> /dev/null
${bMkiso} -o "${myDst}/${myLbl}_${gDt}.iso" -b isolinux/isolinux.bin -J -joliet-long -uid 0 -gid 0 -R -l -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -eltorito-alt-boot -e images/efiboot.img -no-emul-boot -graft-points -V "${myLbl}" . 2>&1 | egrep '9[.]9.[%]'
${bHyiso} --uefi "${myDst}/${myLbl}_${gDt}.iso"
cd "${myCwd}"
echo -e "\n${myNam}:\tRemove Temporary ISO Build Subdir"
# WARNING:  Never use only a variable with no text with 'rm -rf'
/bin/rm -rf "${myDst}/elmedia-isobuild_${gDt}"

