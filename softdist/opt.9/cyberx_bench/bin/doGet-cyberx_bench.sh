##!/bin/bash

#set -ox

###     Globals

# SCAP Benmhmark/Tool releases/versions
myEl="9"
bchScp="1-3"

# DoD CyberX - DISA STIG Benchmark (defaults to Public URL)
bchVer="V2R2"
bchArcFil="U_RHEL_${myEl}_${bchVer}_STIG_SCAP_${bchScp}_Benchmark.zip"

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
for f in "${bchArcFil}" ; do
        /usr/bin/curl -kpso "${f}" "https://dl.dod.cyber.mil/wp-content/uploads/stigs/zip/${f}"
        /usr/bin/unzip -d ./extracted "${f}"
	/bin/rm -f "${f}"
done

# Return to original directory
cd "${myCwd}"

