#
#       /opt/cyberx_stig/ks/opt_cyberx_stig-post.sh
#

### GLOBALS

elVerRel="9"
myOpt="cyberx_stig"	# Tooling
ADM_USR="1000:1000"	# Administrative User/Group


### Ensure ownership
[ "${myOpt}" != "" ] && [ -d "/opt/${myOpt}" ] && [ "${ADM_USR}" != "" ] && /bin/chown -R ${ADM_USR} "/opt/${myOpt}"

### Create Missing Ansible directories
for d in ansible.ks ansible.ks/${myOpt} ; do
        if [ ! -d "/opt/${d}" ] ; then
                /bin/mkdir -m 0750 -p "/opt/${d}"
                /bin/chown -R ${ADM_USR} "/opt/${d}"
        fi
done


## DISA STIG Ansible Playbooks
if [ -r "/opt/ansible.ks/${myOpt}/site.yaml" ] || [ -r "/opt/ansible.ks/${myOpt}/site.yml" ] ; then
        # Don't execute if DISA STIG Playboooks have already been extracted previously
        exit 1
# Extract DISA STIG Ansible Playbooks
elif [ -r "/opt/${myOpt}/extracted/rhel${elVerRel}STIG-ansible.zip" ] ; then
        # Extract DISA STIG Ansible Playbooks
        cd "/opt/ansible.ks/${myOpt}/"
        /bin/unzip "/opt/${myOpt}/extracted/rhel${elVerRel}STIG-ansible.zip"
	# Check if there is an Ansible Collections just for Kickstart
	if [ -d "/opt/ansible.ks/ansible_collections/" ] ; then
		# Add COLLECTION_PATHS to ansible.cfg
		sed -i 's,^\([ \t]*\[defaults\].*\)$,\1\nCOLLECTIONS_PATH = ../ansible_collections,g' /opt/ansible.ks/${myOpt}/ansible.cfg
	fi
        cd ~
        /bin/chown -R ${ADM_USR} /opt/ansible.ks
        # Execute DISA STIG Ansible Playbooks
	yamlExt=""
        [ -r "/opt/ansible.ks/${myOpt}/site.yaml" ] && yamlExt="yaml"
        [ -r "/opt/ansible.ks/${myOpt}/site.yml" ] && yamlExt="yml"
	if [ "${yamlExt}" != "" ] ; then
                cd "/opt/ansible.ks/${myOpt}"
                # Force DISA STIG playbook to ignore errors
                sed -i 's,^\([ \t]\+\)\(gather_facts.*\)$,\1\2\n\1ignore_errors: yes,g' /opt/ansible.ks/${myOpt}/site.${yamlExt}
		# Replace any 'systemd_service:' module with 'systemd:'
                sed -i 's,systemd_service:,systemd:,g' /opt/ansible.ks/${myOpt}/roles/rhel9STIG/tasks/main.${yamlExt}
		# Disable USBGuard at the end to prevent the very real, bare metal scenario where no one can login given the automated install
		echo -e "\n- name:  SANErule_258036_usbguard_NEWSYSTEM\n  service:\n    name: usbguard.service\n    enabled: no\n" >> /opt/ansible.ks/${myOpt}/roles/rhel9STIG/tasks/main.${yamlExt}
		# Force en_US.UTF-8
                LANG=en_US.UTF-8 LD_LIBRARY_PATH=/usr/lib64 /usr/bin/ansible-playbook site.${yamlExt}
	fi
fi

