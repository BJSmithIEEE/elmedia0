##!/bin/bash

#set -ox

###     Globals

# SCAP Benmhmark/Tool releases/versions
myEl="9"

# DoD CyberX - STIG Viewer v2 (defaults to public URL)
svVer[2]="2-18"
svArcFil[2]="U_STIGViewer_${svVer[2]}_Linux.zip"

# DoD CyberX - STIG Viewer v3 (defaults to public URL)
svVer[3]="3-4-0"
svArcFil[3]="U_STIGViewer-linux_x64-${svVer[3]}.zip"

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
for i in 2 3 ; do
	# Don't use subdirs, v3 creates its own # [ ! -e "./extracted/STIGViewer${i}" ] && /bin/mkdir -p "./extracted/STIGViewer${i}"
        /usr/bin/curl -kpso "${svArcFil[${i}]}" "https://dl.dod.cyber.mil/wp-content/uploads/stigs/zip/${svArcFil[${i}]}"
        # Don't use subdirs, v3 creates its own # /usr/bin/unzip -d "./extracted/STIGViewer${i}" "${svArcFil[${i}]}"
        /usr/bin/unzip -d "./extracted" "${svArcFil[${i}]}"
	/bin/rm -f "${svArcFil[${i}]}"
done

# Return to original directory
cd "${myCwd}"

