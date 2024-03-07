##!/bin/bash

#set -ox

###     Globals

# Whitelist Remediations - Things not caught by CyberX DISA STIG Ansible Playbooks
myEl="8"
myCat1="010140 010150"
myCat2="010130 010290 010290 010291 010671 020017 020040 030650 040080 040090 040259 040282"
myCat3="040021 040022 040023 040024 040025 040026 040300 040310"
gitPnt="ansible-lockdown"
gitPrj="RHEL${myEl}-STIG"

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

# Get Ansible-Lockdown RHEL STIG
if [ "${gitPrj}" != "" ] && [ -e "${gitPrj}" ] ; then
	cd "${myBas}/${gitPrj}/"
	git pull
	[ $? -ne 0 ] && exit 2
	cd "${myBas}"
elif [ "${gitPnt}" != "" ] && [ "${gitPrj}" != "" ] ; then
	cd "${myBas}"
	git clone https://github.com/${gitPnt}/${gitPrj}.git
	[ $? -ne 0 ] && exit 2
else
	exit 2
fi

# Remove any appended elmedia0-related lines in site.yaml
cd "${myBas}"
/usr/bin/sed -i '/^### elmedia0 software distribution - do NOT append below this line ###.*$/Q' RHEL8-STIG/site.yml

# Blacklist all Cat-I/II/III remediations by default
myBlk="$(cat ${gitPrj}/tasks/*.yml | sed -n "s/^.*\(rhel_${myRel}_[0-9]\{6,6\}\)[^0-9]*$/\1/p" | sort -u)"
echo -e "### elmedia0 software distribution - do NOT append below this line ###" >> ${gitPrj}/site.yml
echo -e "  vars:" >> ${gitPrj}/site.yml
for b in ${myBlk} ; do
	echo -e "    - ${b}: false" >> ${gitPrj}/site.yml
done

# Whitelist designated remediations
for l in ${myCat1} ; do
	sed -i "s/rhel_${myRel}_${l}[:].*$/rhel_${myRel}_${l}: true  # remediate Cat-I/g" RHEL8-STIG/site.yml
done
for l in ${myCat2} ; do
	sed -i "s/rhel_${myRel}_${l}[:].*$/rhel_${myRel}_${l}: true  # remediate Cat-II/g" RHEL8-STIG/site.yml
done
for l in ${myCat3} ; do
	sed -i "s/rhel_${myRel}_${l}[:].*$/rhel_${myRel}_${l}: true  # remediate Cat-III/g" RHEL8-STIG/site.yml
done

# Return to original directory
cd "${myCwd}"

