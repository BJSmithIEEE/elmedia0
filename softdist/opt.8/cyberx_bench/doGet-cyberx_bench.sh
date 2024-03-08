##!/bin/bash

#set -ox

###     Globals

# sCAP Benmhmark/Tool releases/versions
myEl="8"

# DoD CyberX - DISA STIG Benchmark (defaults to Public URL)
bchVer="V1R12"
bchScp="1-2"
bchArcFil="U_RHEL_${myEl}_${bchVer}_STIG_SCAP_${bchScp}_Benchmark.zip"

# Other Parameters and Globals
myCwd="$(pwd)"
myNam="$(basename ${0})"
myBas0="$(dirname ${0})"
myBas="$(/usr/bin/readlink -f ${myBas0})"
let myRel=myEl
[ $? -ne 0 ] && exit 1
[ ${myRel} -lt 10 ] && myRel="0${myEl}"

###     Set Umask to 002
umask 002

###	Date-timestamp
myDt="$(date +%s_%Y%b%d)"


###	MAIN

cd "${myBas}"
# Get Archive(s)
for f in "${bchArcFil}" ; do
        /usr/bin/curl -kpso "${f}" "https://dl.dod.cyber.mil/wp-content/uploads/stigs/zip/${f}"
        /usr/bin/unzip -d ./extracted "${f}"
done

# Return to original directory
cd "${myCwd}"

