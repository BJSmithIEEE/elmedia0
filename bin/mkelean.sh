#!/bin/bash
#
#	mkelean.sh
#	Clean-up existing staging dirctory and force re-download/un-archive of required and optional software
#	NOTE:  This script is designed to work with Linux (even Busybox), and may work under Cygwin (including MobaXterm) or even MinGW/MinSys (including Git bash)


#set -ox

###	Globals

# Parameters
myCwd="$(pwd)"
myNam="$(basename ${0})"
myBas0="$(dirname ${0})"
myBas="$(/usr/bin/readlink -f ${myBas0})"
myDir="$(/usr/bin/readlink -f ${myBas}/../)"


###	Source Common Functions/Globals
. "${myDir}/bin/elmedia.func"
[ -r "${myDir}/bin/custom.vars" ] && . "${myDir}/bin/custom.vars"


###	Functions

# outSyntax - Print syntax and exit
outSyntax() {
	echo -e "\n${myNam} - Clean-up existing staging directory and force re-download/un-tar of required and optional software\n" >> /dev/stderr
	echo -e "${myNam}  1\n" >> /dev/stderr
	echo -e "\t1\tMUST pass '1' to execute" >> /dev/stderr
	echo -e "\n\tMoves the following Tarballs:" >> /dev/stderr
	# print out exact tarballs to move
	for f in "${myDir}"/staging/*.tar "${myDir}"/staging/tmp/*.tar ; do 
		echo -e "\t\t - ${f}" >> /dev/stderr
	done
	# print out exact subdirectories to move
	echo -e "\n\tAnd moves the following subdirectories:" >> /dev/stderr
	for d in "${myDir}"/staging/addlpkgs.*/* "${myDir}"/staging/ansible.*/* "${myDir}"/staging/opt.*/* ; do
		[ -d "${d}" ] && echo -e "\t\t - ${d}" >> /dev/stderr
	done
        echo -e "\n\tInto the following subdirectory (based on date-time)" >> /dev/stderr
	echo -e "\t\t - ./old-${gDt}" >> /dev/stderr
	echo -e "\n"
}


### MAIN
if [ "${1}" != '1' ] ; then

	outSyntax
	exit 127

else

	# Make old directory
	echo -e "\n${myNam}:\tCreating backup subdirectory (${myDir}/old-${gDt})"
	mkdir -p "${myDir}/old-${gDt}"
	
	# Move old files
	echo -e "\n${myNam}:\tMoving old Tarballs into backup subdirectory (${myDir}/old-${gDt})"
	for f in "${myDir}"/staging/*.tar "${myDir}"/staging/tmp/*.tar  ; do 
		if [ -f "${f}" ] ; then
			echo -e "\t${myDir}/old-${gDt}\t<==(move)==\t${f}"
			/bin/mv -f "${f}" "${myDir}/old-${gDt}"
		fi
	done
	
	echo -e "\n${myNam}:\tMoving old Subdirectories into backup subdirectory (${myDir}/old-${gDt})"
	for d in "${myDir}"/staging/addlpkgs.*/* "${myDir}"/staging/ansible.*/* "${myDir}"/staging/opt.*/* ; do 
		if [ -d "${d}" ] ; then
			echo -e "\t${myDir}/old-${gDt}\t<==(move)==\t${d}"
			# Save relative path, using underscore (_) instead of forward slashes
			d0="$(echo $d | sed -e 's,^[.]/,,g' | sed -e 's,/,_,g')"
			/bin/mv -f "${d}" "${myDir}/old-${gDt}/${d0}"
		fi
	done
	echo -e ""

fi

