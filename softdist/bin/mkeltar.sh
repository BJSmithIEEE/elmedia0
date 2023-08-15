#!/bin/bash

#set -ox

###     Globals

# Parameters
myCwd="$(pwd)"
myNam="$(basename ${0})"
myBas0="$(dirname ${0})"
myBas="$(/usr/bin/readlink -f ${myBas0})"
myDir="$(/usr/bin/readlink -f ${myBas}/../)"
myRel="${1}"
myTar="${2}"


###     Set Umask to 002
umask 002

###     Globals
myDt="$(date +%Y%b%d-%H%M%S)"
myEnd=9

###     Input and Output dirs
myIn="${myDir}"
myOut="${myDir}"


###     Functions

# outSyntax - Print syntax and exit
outSyntax() {
        local outDir=""
        local outRel=""
        echo -e "\n${myNam} - Make Enterprise Linux (EL) media builder tarball for EL release\n" >> /dev/stderr
        echo -e "${myNam}  ELrelease  tarName\n" >> /dev/stderr
        echo -e "\nDirectory Options:" >> /dev/stderr
        cd "${myIn}"
        for d in * ; do
                if [ -d "${d}" ] && [ "${d}" != "bin" ] ; then
                        outDir="$(echo -e ${d} | sed -e 's/[.][0-9]\+//g')"
                        outRel="$(echo -e ${d} | sed -e 's/^.*[.]//g')"
                        if [ "${d}" != "opt.${outRel}" ] ; then
                                echo -e "\t\t${outRel}\t${outDir}"
                        else
                                cd "./opt.${outRel}"
                                if [ $? -eq 0 ] ; then
                                        for e in * ; do
                                                if [ -d "${e}" ] && [ "${e}" != "bin" ] ; then
                                                        echo -e "\t\t${outRel}\t${e}"
                                                fi
                                        done
                                fi
                        fi
                fi
                cd "${myCwd}"
        done
        echo -e "\n"
}


if [ "${myRel}" == "" ] ; then
        outSyntax
        exit 127
fi
let R=myRel 2>> /dev/null
if [ $? -ne 0 ] || [ ${R} -lt 7 ] || [ ${R} -gt ${myEnd} ] ; then
        echo -e "\nWARNING:\tInvalid release (${myRel})\n" >> /dev/stderr
        outSyntax
        exit 126
fi
if [ "${myTar}" == "" ] || [ "${myTar}" == "bin" ] || [ "${myTar}" == "." ] || [ "${myTar}" == ".." ] || [ "${myTar}" == "/" ] || [ "${myTar}" == "./" ] || [ "${myTar}" == "../" ] ; then
        echo -e "\nWARNING:\tMissing valid parameter (tarName)\n"
        outSyntax
        exit 127
fi
if [ ! -d "${myIn}/${myTar}.${myRel}" ] && [ ! -d "${myIn}/opt.${myRel}/${myTar}" ] ; then
        echo -e "\nWARNING:\tCannot locate tree (${myIn}/${myTar}.${myRel})\n\t\t\tor (${myIn}/opt.${myRel}/${myTar})\n"
        outSyntax
        exit 125
fi


###     MAIN

cd "${myIn}"
if [ -d "${myTar}.${myRel}" ] ; then
        #       Don't bother with extended attributes/SELinux - they won't be preserved on installer media
        /usr/bin/tar cvf "${myOut}/${myTar}.${myRel}-${myDt}.tar" "./${myTar}.${myRel}"
elif [ -d "opt.${myRel}/${myTar}" ] ; then
        #       Don't bother with extended attributes/SELinux - they won't be preserved on installer media
        /usr/bin/tar cvf "${myOut}/opt_${myTar}.${myRel}-${myDt}.tar" "./opt.${myRel}/${myTar}"
fi
cd "${myCwd}"
