#
#       /opt/lockdown_stig/ks/opt_lockdown_stig-post.sh
#

### GLOBALS

elVerRel="8"
myOpt="lockdown_stig"	# Tooling
ADM_USR="1000:1000"	# Administrative User/Group


### Ensure ownership
[ "${myOpt}" != "" ] && [ -d "/opt/${myOpt}" ] && [ "${ADM_USR}" != "" ] && /bin/chown -R ${ADM_USR} "/opt/${myOpt}"

### Execute
if [ -r "/opt/${myOpt}/cloned/RHEL${elVerRel}-STIG/site.yml" ] ; then
	cd "/opt/${myOpt}/cloned/RHEL${elVerRel}-STIG/"
	LD_LIBRARY_PATH=/usr/lib64 /usr/bin/ansible-playbook -b -i /dev/null site.yml
fi

