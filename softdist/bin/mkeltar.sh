#!/bin/bash

#set -ox

###     Globals

# Evaluate positional and optional parameters (this needs to be re-written to do bash getopts proper) 
myRel="${1}"
myTar="${2}"
# Other Parameters and Globals
myCwd="$(pwd)"
myNam="$(basename ${0})"
myBas0="$(dirname ${0})"
myBas="$(/usr/bin/readlink -f ${myBas0})"
myDir="$(/usr/bin/readlink -f ${myBas0}/../)"
myEl0="$(/usr/bin/readlink -f ${myBas0}/../../)"
myCus="$(/usr/bin/readlink -f ${myBas0}/../../../elmedia0.custom/)"
myCsd="$(/usr/bin/readlink -f ${myCus}/softdist/)"
# if myCsd (per elmedia0.custom/softdist) doesn't exist, use 'empty' string for custom softdist
if [ "${myCsd}" != "" ] && [ ! -d "${myCsd}" ] ; then
        myCsd=""
fi

###     Set Umask to 002
umask 002

###	Date-timestamp
myDt="$(date +%s_%Y%b%d)"

###     Input and Output dirs
myIn=""
myOut="${myDir}"


###     Functions

# outSyntax - Print syntax and exit
outSyntax() {
        local outDir=""
        local outRel=""
        echo -e "\n${myNam} - Make Enterprise Linux (EL) media builder tarball for EL release\n" >> /dev/stderr
	echo -e "${myNam}\tELrel\ttarName"
	for c in ${myCsd} ${myDir} ; do 
		echo -e "\n\tPossible Tarballs to create from Directory(${c}/)"
		cd "${c}"
	        for d in * ; do
	                if [ -d "${d}" ] && [ "${d}" != "bin" ] ; then
	                        outDir="$(echo -e ${d} | sed -e 's/[.][0-9]\+//g')"
	                        outRel="$(echo -e ${d} | sed -e 's/^.*[.]//g')"
	                        if [ "${d}" != "opt.${outRel}" ] ; then
	                                echo -e "\t\t  ${outRel}\t ${outDir}"
	                        else
	                                cd "./opt.${outRel}"
	                                if [ $? -eq 0 ] ; then
	                                        for e in * ; do
	                                                if [ -d "${e}" ] && [ "${e}" != "bin" ] ; then
	                                                        echo -e "\t\t  ${outRel}\t ${e}"
	                                                fi
	                                        done
	                                fi
	                        fi
	                fi
			cd "${c}"
		done
        done
        echo -e "\n"
}


if [ "${myRel}" == "" ] ; then
        outSyntax
        exit 127
fi
let R=myRel 2>> /dev/null
if [ $? -ne 0 ] || [ ${R} -lt 7 ] || [ ${R} -gt 99 ] ; then
        echo -e "\nWARNING:\tInvalid EL release (${myRel})\n" >> /dev/stderr
        outSyntax
        exit 126
fi
if [ "${myTar}" == "" ] || [ "${myTar}" == "bin" ] || [ "${myTar}" == "." ] || [ "${myTar}" == ".." ] || [ "${myTar}" == "/" ] || [ "${myTar}" == "./" ] || [ "${myTar}" == "../" ] ; then
        echo -e "\nWARNING:\tMissing valid parameter (tarName)\n"
        outSyntax
        exit 127
fi
if [ ! -d "${myCsd}/${myTar}.${myRel}" ] && [ ! -d "${myCsd}/opt.${myRel}/${myTar}" ] && [ ! -d "${myDir}/${myTar}.${myRel}" ] && [ ! -d "${myDir}/opt.${myRel}/${myTar}" ] ; then
        echo -e "\nWARNING:\tCannot locate tree (softdist/${myTar}.${myRel})\n\t\t\tor (softdist/opt.${myRel}/${myTar})\n"
        outSyntax
        exit 125
fi


###     MAIN

myIn=""
for c in "${myCsd}" "${myDir}" ; do
	for d in "${myTar}.${myRel}" "opt.${myRel}/${myTar}"  ; do 
		e="${c}/${d}"
		if [ "${myIn}" == "" ] && [ "${e}" != "/" ] && [ "${e}" != "/${d}" ]  && [ -d "${e}" ] ; then
			myIn="${e}"
			echo -e "\nCreating tarball(${myOut}/${myTar}.${myRel}-${myDt}.tar) ...\n\tfrom subdirectory(./${myTar}.${myRel}/)\n\tin directory(${c}/)\n"
			cd "${c}"
			#       Don't bother with extended attributes/SELinux - they won't be preserved on installer media
	                /usr/bin/tar cvf "${myOut}/${myTar}.${myRel}-${myDt}.tar" "./${d}"
		fi
		cd "${myCwd}"
	done
done

