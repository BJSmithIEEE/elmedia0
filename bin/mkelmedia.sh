#!/bin/bash
#
#	mkelmedia.sh
#	Make either:  
#	  - an MBR/uEFI bootable ISO device for installing Enterprise Linux from an ISO source (mounted)
#         - an uEFI bootable USB device for installing Enterprise Linux from an ISO source (mounted)
#	NOTE:  This script is designed to work with Linux (even Busybox), and may work under Cygwin or even MinGW/MinSys


#set -ox

###	Globals

# Parameters
myCwd="$(pwd)"
myNam="$(basename ${0})"
myBas0="$(dirname ${0})"
myBas="$(/usr/bin/readlink -f ${myBas0})"
myDir="$(/usr/bin/readlink -f ${myBas}/../)"
let gOverParm=0
if [ "${1}" == "-f" ] ; then let gOverParm=1 ; shift ; fi ; myOut="${1}"
if [ "${2}" == "-f" ] ; then let gOverParm=1 ; shift ; fi ; myDst="${2}"
if [ "${3}" == "-f" ] ; then let gOverParm=1 ; shift ; fi ; mySrc="${3}"
if [ "${4}" == "-f" ] ; then let gOverParm=1 ; shift ; fi ; myLbl="${4}"
if [ "${5}" == "-f" ] ; then let gOverParm=1 ; shift ; fi 

###     Source Common Functions/Globals
. "${myDir}/bin/elmedia.func"
[ -r "${myDir}/bin/custom.vars" ] && . "${myDir}/bin/custom.vars"

###	Evaluate Overwrite Flag
if [ "${myOut}" != "iso" ] ; then 
	# USB - Don't overwrite by default, unless -f passed
	gOver="${gOverParm}"
else
	# ISO - Always overwrite (into temporary directory)
	gOver=1
fi


###	Functions

# outSyntax - Print syntax and exit
outSyntax() {
	echo -e "\n${myNam} - Make ISO or Populate VFAT-formatted USB for installing Enterprise Linux\n" >> /dev/stderr
	echo -e "${myNam}  iso|usb  [-f]  dst_dir  src_mnt  [dst_lbl]\n" >> /dev/stderr
	echo -e "\tiso|usb      Make ISO9660 Yellow Book Data Track (.iso) file *OR* Populate VFAT-formatted USB" >> /dev/stderr
	echo -e "\t[-f]         [optional] Force full checksum (rsync) or overwrite (cp) of existing USB distribution" >> /dev/stderr
	echo -e "\tdst_dir      Target DIR (destination directory) where to write ISO file or populate mounted USB device" >> /dev/stderr
	echo -e "\tsrc_iso_mnt  Source DIR/ISO (mounted or contents copied to directory) of Enterprise Linux distro" >> /dev/stderr
	echo -e "\t[dst_lbl]    [opt] ISO (default '[CR][7-9]ELMEDIA') and optional USB (reads) Label" >> /dev/stderr
	echo -e "\nExamples:" >> /dev/stderr
	echo -e "\t${myNam}  iso  /tmp                          /run/media/${USER}/RHEL-8-9-0-BaseOS_x86_64  [R8ELMEDIA]" >> /dev/stderr
        echo -e "\t${myNam}  usb  /run/media/${USER}/R8ELMEDIA  /run/media/${USER}/RHEL-8-9-0-BaseOS_x86_64  [R8ELMEDIA]" >> /dev/stderr
	echo -e "\t${myNam}  iso  /cygdrive/c/tmp               /cygdrive/d  [R7ELMEDIA]         <== in Cygwin/MobaXterm" >> /dev/stderr
        echo -e "\t${myNam}  usb  /cygdrive/f                   /cygdrive/d  [C8ELMEDIA]         <== in Cygwin/MobaXterm" >> /dev/stderr
	echo -e "\t${myNam}  iso  /c/tmp                        /d           [R7ELMEDIA]         <== in MinGW / Git bash" >> /dev/stderr
        echo -e "\t${myNam}  usb  /f                            /d           [C8ELMEDIA]         <== in MinGW / Git bash" >> /dev/stderr
	echo -e "\n"
}


### MAIN

if [ "${mySrc}" == "" ] ; then
	outSyntax
	exit 127
elif [ "${myOut}" != "iso" ] && [ "${myOut}" != "usb" ] ; then
	echo -e "\nERROR(32): output format must be ISO file or USB device (mounted)\n" >> /dev/stderr
	outSyntax
	exit 32
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
if [ "${myOut}" == "iso" ] ; then
	[ "${bMkiso}" == "" ] && echo -e "\nERROR(96): binary 'mkisofs' required, not found in PATH\n" >> /dev/stderr && exit 96
	[ "${bHyiso}" == "" ] && echo -e "\nERROR(97): binary 'isohybrid' required, not found in PATH\n" >> /dev/stderr && exit 97 
fi

echo -e "\n${myNam}:\tIdentify Distribution and Release"
getRelVer "${mySrc}"
echo -e "\tusing relver(${gRelVer})"

# Set default label
myLblDef="$(echo ${gRelVer}ELMEDIA | tr [:lower:] [:upper:])"
if [ "${myOut}" != "iso" ] && [ "${myLbl}" == "" ] ; then 
	# Get label from USB device (uses Linux udev or WMI as appropriate)
        myLbl=$(getLabel "${myDst}")
	echo -e "\n${myNam}:\tUSB Label Read(${myLbl})"
        if [ "${myLbl}" == "" ] ; then
		# USB device does not have a label, we need one passed
		echo -e "\nERROR(35):  USB device does not have a label, label must be passed and/or volume name set in OS)\n" >> /dev/stderr
                outSyntax
                exit 35
        fi
fi
[ "${myLbl}" == "" ] && myLbl="${myLblDef}"
echo -e "\tusing label(${myLbl})"

if [ "${myOut}" != "iso" ] ; then 
	# USB:  myDstTmp = myDst (direct to mounted device)
	myDstTmp="${myDst}"
	# USB:  Don't overwrite by default, unless -f passed
	gOver="${gOverParm}"
else
	# ISO:  Temporary build area in output directory for ISO (not required for USB)
	myDstTmp="${myDst}/elmedia-isobuild_${gDt}"
	echo -e "\n${myNam}:\tCreate Temporary Build Subdirectory for ISO9660 Yellow Book Data (.iso) file"
	mkdir -p "${myDstTmp}"
	# ISO:  Always overwrite (into temporary directory)
	gOver=1
fi

# Copy distribution - This is the most time consuming, unless the distribution is already on the media (in the case of USB)
if [ "${myOut}" == "usb" ] && [ "${gOver}" == 0 ] ; then
	echo -e "\n${myNam}:\tCheck Destination USB against Source ISO Distro (No Overwrite)"
	cpTree  "${mySrc}"  "${myDstTmp}"  ${gOver}  0
else
	# ISO Copy / USB Overwrite
	echo -e "\n${myNam}:\tCopy Source ISO distro files to Destination (Create/Overwrite)"
fi
echo -e "\n${myNam}:\t\tWARNING:  Time Consuming  (no progress bar)"
cpTree  "${mySrc}"  "${myDstTmp}"  ${gOver}  0

# NOTE:  Always do these steps after the distribution - in case the directories already exist

# Packages not provided in distribution media but required in %packages
for p in ${myPkg} ; do
	echo -e "\n${myNam}:\tGet Packages (${p}) Repo (if no local copy)"
	if [ "${p}" == "ansible" ] && [ ${gVer} -le 8 ] ; then
		getFilTar "${myDir}" "staging" "${p}.${gVer}-validated.tar" "${p}.${gVer}/${p}${gAnsVer}.${gRelVer}/repodata" "softdist"
		echo -e "\n${myNam}:\tCopy Packages (${p}) Repo for Distribution"
		cpTree "${myDir}/staging/${p}.${gVer}/${p}${gAnsVer}.${gRelVer}" "${myDstTmp}/${p}${gAnsVer}"  1  1
	else
		getFilTar "${myDir}" "staging" "${p}.${gVer}-validated.tar" "${p}.${gVer}/${p}.${gRelVer}/repodata" "softdist"
		echo -e "\n${myNam}:\tCopy Packages (${p}) Repo for Distribution"
		cpTree "${myDir}/staging/${p}.${gVer}/${p}.${gRelVer}" "${myDstTmp}/${p}"  1  1
	fi
done

# Optional files to add for %post
for f in ${myOpt} ; do
	echo -e "\n${myNam}:\tGet Optional (${f} Files (if no local copy)"
	getFilTar "${myDir}" "staging" "opt_${f}.${gVer}-validated.tar" "opt.${gVer}/${f}" "softdist"
done
echo -e "\n${myNam}:\tCopy All Optional Files for Distribution"
cpTree "${myDir}/staging/opt.${gVer}" "${myDstTmp}/opt"  1  1

# Kickstart files
echo -e "\n${myNam}:\tCopy Kickstart Files"
cpTree "${myDir}/default/ks" "${myDstTmp}/ks"  1  1
cpTree "${myDir}/custom/ks" "${myDstTmp}/ks"  1  0
echo -e "\n${myNam}:\tInject Kickstart Files w/Globals-Functions"
for f in ${myDstTmp}/ks/ks-el*.ks ; do
	sed -i '/^[ \t]*[#][ \t]\+XXXXX[ \t]\+INJECT_KSPRE[ \t]\+XXXXX[ \t]*$/r ks/inject/ks-elmedia.inject' ${f}
done

# Boot files
echo -e "\n${myNam}:\tGet Boot Files"
getMnuGet "${myDstTmp}"
# Dynamic Menu - TODO
# TODO # echo -e "\n${myNam}:\tGet Kickstart Meta"
# TODO # getMnuKsf "${myDstTmp}"
# TODO # echo -e "\n${myNam}:\tGenerate Kickstart Entries"
# TODO # genMnuKse "${myDstTmp}"
# Static Menu - Interim/Temporary (hardcoded)
echo -e "\n${myNam}:\tCopy Boot Files (hardcoded)"
cpTree "${myDir}/default/hardcode/menu.${gRelVer}"  "${myDstTmp}"  1  1
cpTree "${myDir}/custom/hardcode/menu.${gRelVer}"  "${myDstTmp}"  1  0
# Menu - Set/Replace any ISO default label with actual ISO label
echo -e "\n${myNam}:\tUpdate Boot Files for Media Label (${myLbl})"
setMnuLbl "${myDstTmp}" "${myLbl}" "${myLblDef}"

# Build ISO file (not required for USB) - See Red Hat Solution 60959 - https://access.redhat.com/solutions/60959
if [ "${myOut}" == "iso" ] ; then
	echo -e "\n${myNam}:\tGenerate ISO File"
	cd "${myDstTmp}"
	rmdir rr_moved 2> /dev/null
#	${bMkiso} -o "${myDst}/${myLbl}_${gDt}.iso" -b isolinux/isolinux.bin -J -joliet-long -uid 0 -gid 0 -R -l -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -eltorito-alt-boot -e images/efiboot.img -no-emul-boot -graft-points -V "${myLbl}" . 2>&1 | grep -E '9[.]9.[%]'
#	${bHyiso} --uefi "${myDst}/${myLbl}_${gDt}.iso"
	cd "${myCwd}"
	echo -e "\n${myNam}:\tRemove Temporary ISO Build Subdir"
	# WARNING:  Never use only a variable with no text with 'rm -rf'
#	/bin/rm -rf "${myDst}/elmedia-isobuild_${gDt}"
fi

