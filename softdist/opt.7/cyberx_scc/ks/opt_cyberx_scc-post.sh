#
#       /opt/cyberx_scc/ks/opt_cyberx_scc-post.sh
#

### GLOBALS

elVerRel="7"
myOpt="cyberx_scc"	# Tooling
ADM_USR="1000:1000"	# Administrative User/Group
sccVen="rhel${elVerRel}"
sccVer="5.8"

### Ensure ownership
[ "${myOpt}" != "" ] && [ -d "/opt/${myOpt}" ] && [ "${ADM_USR}" != "" ] && /bin/chown -R ${ADM_USR} "/opt/${myOpt}"

### SCC
# Install NAVWAR SCC GPG Key
if [ -r "/opt/${myOpt}/extracted/RPM-GPG-KEY-scc${sccVer}" ] ; then
	/bin/cp  "/opt/${myOpt}/extracted/RPM-GPG-KEY-scc${sccVer}" "/etc/pki/rpm-gpg/"
	/usr/bin/rpm --import "/opt/${myOpt}/extracted/RPM-GPG-KEY-scc${sccVer}"
fi

# Install NAVWAR SCC RPM
if [ -r "/opt/${myOpt}/extracted/scc-${sccVer}_${sccVen}_x86_64/scc-${sccVer}_rhel${elVerRel}.x86_64.rpm" ] ;
       	/bin/rpm -Uhv "/opt/${myOpt}/extracted/scc-${sccVer}_${sccVen}_x86_64/scc-${sccVer}_rhel${elVerRel}.x86_64.rpm"
fi

