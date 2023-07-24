### ks/include/ks-elX-90pst-00el0_home.inc

#####	Use regardless if /home is local or NFS mounted

###	Ensure /etc/default/useradd has users going into /home, not /homesys
# During install, default may be in /homesys, so it could modify useradd defaults ... change them back (if changed)
# Changing the default to /homesys causes issues with SELinux, so ensure it is always /home, even for NFS mounted /home
/usr/bin/sed -i 's,^[^#]*HOME[ \t]*[=][ \t]*[/]homesys[ \t]*$,HOME=/home,g' /etc/default/useradd

###	Add SELinux equivalence for /home <== /homesys
# During install %post chroot, /home should still be the default
# So set equivalence for /homesys being the same as /home as far as SELinux file contexts
/usr/sbin/semanage fcontext -a -e /home /homesys
#	Restore File Contexts to /homesys on root (/) file system
/usr/sbin/restorecon -Rv /homesys

