##!/bin/bash

#set -ox

###     Globals

# SCAP Benmhmark/Tool releases/versions
myEl="9"

# DoD CyberX - NAVWAR Security Content Checker (SCC) (defaults to public URL)
sccVen="rhel${myEl}"
sccVen2="oracle-linux${myEl}"
sccVer="5.10.1"
# NO # sccArcFil="scc-${sccVer}_${sccVen}_x86_64_bundle.zip"
sccArcFil="scc-${sccVer}_${sccVen}_${sccVen2}_x86_64_bundle.zip"
# NO # sccArcGpg="RPM-GPG-KEY-scc-5.zip"
sccArcGpg="RPM-GPG-KEY-scc-${sccVer}.zip"

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
for f in "${sccArcFil}" "${sccArcGpg}" ; do
	/usr/bin/curl -kpso "${f}" "https://dl.dod.cyber.mil/wp-content/uploads/stigs/zip/${f}"
	/usr/bin/unzip -d ./extracted "${f}"
	/bin/rm -f "${f}"
done

# Return to original directory
cd "${myCwd}"

