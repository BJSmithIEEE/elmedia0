#
#       /opt/cyberx_bench/ks/opt_cyberx_bench-post.sh
#

### GLOBALS

elVerRel="8"
myOpt="cyberx_bench"	# Tooling
ADM_USR="1000:1000"	# Administrative User/Group

### Ensure ownership
[ "${myOpt}" != "" ] && [ -d "/opt/${myOpt}" ] && [ "${ADM_USR}" != "" ] && /bin/chown -R ${ADM_USR} "/opt/${myOpt}"

