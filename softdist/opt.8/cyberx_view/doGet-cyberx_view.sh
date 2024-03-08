##!/bin/bash

#set -ox

###     Globals

# sCAP Benmhmark/Tool releases/versions
myEl="8"

# DoD CyberX - STIG Viewer v2 (defaults to public URL)
sv2Ver="2-17"
sv2ArcFil="U_STIGViewer_${sv2Ver}_Linux.zip"

# DoD CyberX - STIG Viewer v3 (defaults to public URL)
sv3Ver="3-3-0"
sv3ArcFil="U_STIGViewer-linux_x64-${sv3Ver}.zip"


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
for f in "${sv2ArcFil}" "${sv3ArcFil}" ; do
        /usr/bin/curl -kpso "${f}" "https://dl.dod.cyber.mil/wp-content/uploads/stigs/zip/${f}"
        /usr/bin/unzip -d ./extracted "${f}"
done

# Return to original directory
cd "${myCwd}"

