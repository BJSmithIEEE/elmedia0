#
#       /opt/cyberx_view/ks/opt_cyberx_view-post.sh
#

### GLOBALS

elVerRel="8"
myOpt="cyberx_view"	# Tooling
ADM_USR="1000:1000"	# Administrative User/Group

### Ensure ownership
[ "${myOpt}" != "" ] && [ -d "/opt/${myOpt}" ] && [ "${ADM_USR}" != "" ] && /bin/chown -R ${ADM_USR} "/opt/${myOpt}"

