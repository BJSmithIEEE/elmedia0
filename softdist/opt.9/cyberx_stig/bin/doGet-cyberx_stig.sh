##!/bin/bash

#set -ox

###     Globals

# sCAP Benmhmark/Tool releases/versions
myEl="9"

# DoD CyberX - DISA STIG Ansible Playbook (defaults to Public URL)
ansVer="V1R2"
ansArcFil="U_RHEL_${myEl}_${ansVer}_STIG_Ansible.zip"

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
# Get Archive(s)
for f in "${ansArcFil}" ; do
        /usr/bin/curl -kpso "${f}" "https://dl.dod.cyber.mil/wp-content/uploads/stigs/zip/${f}"
	/usr/bin/unzip -d ./extracted "${f}"
	/bin/rm -f "${f}"
done

# Return to original directory
cd "${myCwd}"

