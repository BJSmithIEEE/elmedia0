#
#       /opt/cyberx_play/opt_cyberx_play-post.sh
#

### GLOBALS

elVerRel="8"
myOpt="cyberx_play"	# Tooling
ADM_USR="1000:1000"	# Administrative User/Group


### Ensure ownership
[ "${myOpt}" != "" ] && [ -d "/opt/${myOpt}" ] && [ "${ADM_USR}" != "" ] && /bin/chown -R ${ADM_USR} "/opt/${myOpt}"

### Create Missing Ansible directories
for d in ansible ansible.ks ansible.ks/${myOpt} ; do
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
        cd ~
        /bin/chown -R ${ADM_USR} /opt/ansible.ks
        # Execute DISA STIG Ansible Playbooks
        if [ -r "/opt/ansible.ks/${myOpt}/site.yaml" ] ; then
                cd "/opt/ansible.ks/${myOpt}"
                # Force DISA STIG playbook to ignore errors
                sed -i 's,^\([ \t]\+\)\(gather_facts.*\)$,\1\2\n\1ignore_errors: yes,g' /opt/ansible.ks/${myOpt}/site.yaml
                LD_LIBRARY_PATH=/usr/lib64 /usr/bin/ansible-playbook site.yaml
        elif [ -r "/opt/ansible.ks/${myOpt}/site.yml" ] ; then
                cd "/opt/ansible.ks/${myOpt}"
                # Force DISA STIG playbook to ignore errors
                sed -i 's,^\([ \t]\+\)\(gather_facts.*\)$,\1\2\n\1ignore_errors: yes,g' /opt/ansible.ks/${myOpt}/site.yml
		LD_LIBRARY_PATH=/usr/lib64 /usr/bin/ansible-playbook site.yml
        fi
fi


