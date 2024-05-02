#
#       /opt/ansible_collections/ks/opt_ansible_collections-post.sh
#

### GLOBALS

elVerRel="9"
myOpt="ansible_collections"	# Tooling
ADM_USR="1000:1000"		# Administrative User/Group
# Ansible Collections Name (by path) and Version
declare -a anscolnam=("community/general" "ansible/posix")
declare -a anscolver=("8.6.0" "1.5.4")

### Ensure ownership
[ "${myOpt}" != "" ] && [ -d "/opt/${myOpt}" ] && [ "${ADM_USR}" != "" ] && /bin/chown -R ${ADM_USR} "/opt/${myOpt}"

### Create Missing Ansible directories
for d in ansible.ks ansible.ks/${myOpt} ; do
        if [ ! -d "/opt/${d}" ] ; then
                /bin/mkdir -m 0750 -p "/opt/${d}"
                /bin/chown -R ${ADM_USR} "/opt/${d}"
        fi
done

## Ansible Collections
anscolnum=${#anscolnam[@]}
let anscollst=anscolnum-1
for i in $(seq 0 ${anscollst}) ; do
	if [ ! -d "/opt/ansible.ks/${myOpt}/${anscolnam[$i]}" ] ; then
		mkdir -p "/opt/ansible.ks/${myOpt}/${anscolnam[$i]}"
		# The basename for the packages is the same as the pathname, but slashes (/) are replaced by dashes (-)
		anscolbas="$(echo ${anscolnam[$i]} | sed -e 's,/,-,g')"
		tar xvf "/opt/${myOpt}/extracted/${anscolbas}-${anscolver[$i]}.tar.gz" -C "/opt/ansible.ks/${myOpt}/${anscolnam[$i]}"
	fi
done

