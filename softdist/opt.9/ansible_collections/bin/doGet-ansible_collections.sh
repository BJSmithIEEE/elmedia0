##!/bin/bash

#set -ox

###     Globals

# SCAP Benmhmark/Tool releases/versions
myEl="9"
myOpt="ansible_collections"

# Ansible Collections Name (by path)
declare -a anscolnam=("community/general" "ansible/posix")
declare -a anscolver=("9.5.3" "1.5.4")

# Other Parameters and Globals
myCwd="$(pwd)"
myNam="$(basename ${0})"
myBas0="$(dirname ${0})"
myBas="$(/usr/bin/readlink -f ${myBas0})"
myDir="$(/usr/bin/readlink -f ${myBas0}/../)"
let myRel=myEl
[ $? -ne 0 ] && exit 1
[ ${myRel} -lt 10 ] && myRel="0${myEl}"

###     Set Umask to 002
umask 002

###	Date-timestamp
myDt="$(date +%s_%Y%b%d)"


###	MAIN

cd "${myDir}"
anscolnum=${#anscolnam[@]}
let anscollst=anscolnum-1
echo -e "\nDOWNLOAD the following tarballs and PLACE (do NOT extract) into directory(${myDir}/tar/):\n"
for i in $(seq 0 ${anscollst}) ; do
	echo -e "   - https://galaxy.ansible.com/ui/repo/published/${anscolnam[$i]}?version=${anscolver[$i]}"
done
echo -e "\nNote VERISION and MODIFY array(anscolver) in Kickstart %post script(${myDir}/ks/opt_${myOpt}-post.sh)\n"
echo -e "\nExisting collections (and version) in (${myDir}/tar/):\n"
ls ${myDir}/tar/
echo ""

# Return to original directory
cd "${myCwd}"

