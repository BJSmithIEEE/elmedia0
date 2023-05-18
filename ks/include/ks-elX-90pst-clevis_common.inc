### ks/include/ks-elX-90pst-clevis_common.inc


###	Common Clevis-LUKS Prep
# Prep for various Clevis/LUKS options, including Dracut and GRUB2 modifications
# also see 90pst-clevis_* includes (ks-elX-90pst-clevis_*.inc)


## LUKS (example/modify) - /etc/crypttab
# Example entry - added volume, non-root, via TPM2 chip (or manual passphrase entry)
echo -e "\n# TPM2 - added volume, non-root #    DMname4TPM2orManual    UUID=01234567-89ab-cdef-0123-456789abcdef    none" >> /etc/crypttab 
# Example entry - added volume, non-root, via Tang server (after network is up)
echo -e "\n# Tang - Added volume - non-root #    DMname4Tang           UUID=01234567-89ab-cdef-0123-456789abcdef    none    _netdev" >> /etc/crypttab 


## DRACUT (config) - /etc/dracut.conf.d/99-kcs4500491.conf
# Embed rd.luks.uuid, rd.lvm.lv and rd.lvm.vg from GRUB2 into initramfs per Red Hat Article 4500491
cat << 'EOF' > '/etc/dracut.conf.d/99-kcs4500491.conf'
hostonly_cmdline="yes"
EOF


## DRACUT (example/modify) - /etc/dracut.conf.d/static_ip.conf
# Example config for static IPv4, if static IPv4 (not DHCP) will be used
cat << 'EOF' > '/etc/dracut.conf.d/static_ip.conf'
### uncomment/modify for static IPv4:  
# kernel_cmdline="ip=192.168.0.100 netmask=255.255.255.0 nameserver=192.168.0.20 nameserver=192.168.0.10"
EOF


## SCRIPT (modify-exec) - /root/clevis_tang-luks_bind.sh
# Example script to use clevis luks bind to tang server and modify /etc/fstab
cat << 'EOF' > '/root/clevis_tang-luks_bind.sh'
#!/bin/bash
#
#       /root/clevis_tang-luks_bind.sh
#       Example script to use clevis luks bind to tang server
#
myTang="http://tang.mydomain.com:7500"     # my tang server (modify)

# Enable systemd to watch Clevis service and ask for password
systemctl enable clevis-luks-askpass.path

# Run commands to bind Clevis to tang server for each block device required
for d in $(lsblk -p -n -s -r | awk '$6 == "crypt" { getline; print $1 }' | sort -u) ; do
        echo -e "\n*****\t${d}\n"
        echo -e "\texec:\tclevis luks bind -d ${d} tang '{\"url\":\"${myTang}\"}'"
        clevis luks bind -d ${d} tang '{"url":"'${myTang}'"}'
done

# Now modify /etc/fstab so system file systems know they are mounted in initrd (append 'x-initrd.mount' to options)
echo -e "\n*****\tModify /etc/fstab so system file systems have option 'x-initrd.mount' appended\n"
sed -i 's/x-systemd.device-timeout=0[ \t]\+/x-systemd.device-timeout=0,x-initrd.mount  /g' /etc/fstab

# Inform sysadmin that if a Static IP is to be used, they need to edit the relevant file
echo -e "\n*****\tPlease modify Dracut config file(/etc/dracut.conf.d/static_ip.conf) if a static IP is to be used (instead of DHCP)"

# Inform sysadmin to rebuild all initramfs files (after any further modifications)
echo -e "\n*****\nPlease execute command(dracut --regenerate-all --force) to rebuild all initramfs boot files (after any further modifications)\n"

EOF


## GRUB2 (config) - edit /etc/default/grub to add LUKS UUID and 'root' LUKS Volume VG vg1 (so all 'root' LUKS Volume LVs) to kernel command line
# We only do this for Default-elbuild-Naught vg1, so it will not work if the VG has changed
l="$(vgs -qo pv_all --noheading vg1 | sed -n 's,^.*[/]dev[/]mapper[/]\(luks-[^ \t]\+\)[ \t]\+.*$,\1,p')"
if [ "${l}" != "" ] ; then
	# Found LUKS backing for vg1
	# Insert rd.luks.uuid=luks-XXXX if not in GRUB default (Anaconda should do this)
	grep -qie "^[ \t]*GRUB_CMDLINE_LINUX.*rd.luks.uuid=${l}.*$" /etc/default/grub
	[ $? -ne 0 ] &&	sed -i 's,^[ \t]*GRUB_CMDLINE_LINUX=",GRUB_CMDLINE_LINUX="rd.luks.uuid='${l}' ,g' /etc/default/grub
	# Insert rd.lvm.vg=vg1 if not in GRUB default (Anaconda typically does *NOT* do this for LVM on LUKS, so add it, removes the need to have all rd.lvm.lv= entries)
	grep -qie "^[ \t]*GRUB_CMDLINE_LINUX.*rd.lvm.vg=vg1.*$" /etc/default/grub
	[ $? -ne 0 ] &&	sed -i 's,^[ \t]*GRUB_CMDLINE_LINUX=",GRUB_CMDLINE_LINUX="rd.lvm.vg=vg1 ,g' /etc/default/grub
	# Regenerate GRUB2
	if [ -d "/sys/firmware/efi" ] ; then
		# for uEFI (/etc/grub2-efi.cfg = /boot/efi/EFI/redhat/grub.cfg) if /sys/firmware/efi exists
		#grub2-mkconfig -o /etc/grub2-efi.cfg
		grub2-mkconfig -o /boot/efi/EFI/redhat/grub.cfg
	else
		# for BIOS (/etc/grub2.cfg = /boot/grub2/grub.cfg) if /sys/firmware/efi does *NOT* exist
		#grub2-mkconfig -o /etc/grub2.cfg
		grub2-mkconfig -o /boot/grub2/grub.cfg
	fi
fi

