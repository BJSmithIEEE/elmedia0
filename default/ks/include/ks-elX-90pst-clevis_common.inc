### ks/include/ks-elX-90pst-clevis_common.inc


###	Common Clevis-LUKS Prep
# Prep for various Clevis/LUKS options, including Dracut and GRUB2 modifications
# also see 90pst-clevis_* includes (ks-elX-90pst-clevis_*.inc)


## LUKS (example/modify) - /etc/crypttab
# Example entry - non-root VG, via TPM2 chip (or manual passphrase entry)
echo -e "\n# TPM2 - non-root VG #    DMname4TPM2orManual    UUID=01234567-89ab-cdef-0123-456789abcdef    none" >> /etc/crypttab 
# Example entry - non-root VG, via Tang server (after network is up)
echo -e "\n# Tang RHEL8+ (no _netdev) - non-root VG #    DMname4Tang            UUID=01234567-89ab-cdef-0123-456789abcdef    none" >> /etc/crypttab 
echo -e "\n# Tang RHEL7 (use _netdev) - non-root VG #    DMname4Tang            UUID=01234567-89ab-cdef-0123-456789abcdef    none    _netdev" >> /etc/crypttab 


## DRACUT (config) - /etc/dracut.conf.d/99-kcs4500491.conf
# Embed rd.luks.uuid, rd.lvm.lv and rd.lvm.vg from GRUB2 into initramfs per Red Hat Article 4500491
cat << 'EOF' > '/etc/dracut.conf.d/99-kcs4500491.conf'
hostonly_cmdline="yes"
EOF


## DRACUT (example/modify) - /etc/dracut.conf.d/static_ip.conf
# Example config for static IPv4, if static IPv4 (not DHCP) will be used
cat << 'EOF' > '/etc/dracut.conf.d/static_ip.conf'
### uncomment/modify for static IPv4:  
# RHEL8+ # kernel_cmdline="ip=10.10.10.100:::255.255.255.0::eno1:none nameserver=10.10.10.20 nameserver=10.10.10.10"
# RHEL7  # kernel_cmdline="ip=10.10.10.100 netmask=255.255.255.0 nameserver=10.10.10.20 nameserver=10.10.10.10"
EOF

## SCRIPT - /usr/local/bin/getAllEth.sh 
# Example script to list all Ethernet interface details
cat << 'EOF' > '/usr/local/bin/getAllEth.sh'
#!/bin/bash

# Print a wide, formatted header
printf "\n"
printf "%8s  %10s  %-34s  %-12s  %12s  %-10s  %s\n" "LINK" " TOP SPEED" "INTERFACE (MAC ADDRESS)"            "Driver"       "PCId:bb:dd.f" "Location *" "Hardware Details"
printf "%8s  %10s  %-34s  %-12s  %12s  %-10s  %s\n" "====" "==========" "==================================" "------------" "------------" "----------" "--------------------------------------"

# Use nmcli to cleanly grab only Ethernet interfaces
interfaces=$(nmcli -t -f DEVICE,TYPE dev | awk -F: '$2=="ethernet" {print $1}')

for iface in $interfaces; do
    # 1. MAC and Link from sysfs
    mac=$(cat "/sys/class/net/$iface/address" 2>/dev/null)
    link=$(cat "/sys/class/net/$iface/operstate" 2>/dev/null)

    # 2. Extract raw ethtool text output once to save processing time
    eth_raw=$(ethtool "$iface" 2>/dev/null)

    # 3. Max Speed via User's Descending Array Method
    speed="Unknown"
    # We loop through the speeds from highest to lowest.
    for s in 100000 40000 25000 10000 5000 2500 1000 100; do
        # Use grep with -E and \b (word boundary) so searching for "100base" 
        # doesn't accidentally match "1000base" or "10000base".
        if echo "$eth_raw" | grep -q -E "\b${s}base"; then
            speed="${s} Mb"
            break # We found the highest supported speed, exit the loop!
        fi
    done

    # 4. Driver and PCI Bus via ethtool
    driver=$(ethtool -i "$iface" 2>/dev/null | awk '/driver:/ {print $2}')
    bus_info=$(ethtool -i "$iface" 2>/dev/null | awk '/bus-info:/ {print $2}')
    pci_dom_slot=$(echo "$bus_info" | awk -F ':' '{print $1 ":" $2}')

    # 5. Vendor/Hardware Details via lspci
    if [[ "$bus_info" == *":"* ]]; then
        hw_info=$(lspci -s "$bus_info" 2>/dev/null | awk -F': ' '{print $2}')
    else
        hw_info="Virtual/Unknown"
    fi

    # 6. Location Hint (Based on RHEL7 Naming Conventions)
    if [[ "$iface" == eno* || "$iface" == em* ]]; then
        loc_hint="On-board *"
    elif [[ "$iface" == enp* || "$iface" == p* ]]; then
        if [ "${pci_dom_slot}" == "0000:00" ] ; then loc_hint="On-board *"
        else loc_hint="PCI slot *"
        fi
    elif [[ "$iface" == ens* ]]; then
        loc_hint="Hot-plug"
    elif [[ "$iface" == eth* ]]; then
        loc_hint="(legacy) *"
    else
        loc_hint="(unknown)"
    fi

    # Clean up any missing values
    [ -z "$mac" ]      && mac="N/A"
    [ -z "$link" ]     && link="N/A"
    [ -z "$driver" ]   && driver="N/A"
    [ -z "$bus_info" ] && bus_info="N/A"
    [ -z "$hw_info" ]  && hw_info="N/A"

    # Print the formatted row
    printf "%8s  %10s  %-34s  %-12s  %12s  %-10s  %s\n" "$link" "$speed" "$iface ($mac)" "$driver" "$bus_info" "$loc_hint" "$hw_info"
done
printf "%96s\n\n" 'best guess based on interface name *'
EOF
chmod 755 /usr/local/bin/getAllEth.sh

## SCRIPT (modify-exec) - /root/clevis_tang-luks_bind.sh
# Example script to use clevis luks bind to tang server and modify /etc/fstab
cat << 'EOF' > '/root/clevis_tang-luks_bind.sh'
#!/bin/bash
#
#       /root/clevis_tang-luks_bind.sh
#       Example script to use clevis luks bind to tang server
#

####	GLOBALS

fictTang="http://NoTangServer:7500"		# do NOT modify this line
myTang="${fictTang}"     			# do NOT modify this line
#myTang="http://10.x.y.z:7500"			# my tang server (uncomment and MODIFY this line)


#####	CONSTANTS

MIN_ENTROPY=1024		# WARNING:  Some VMs don't do more than 256


#####	FUNCTIONS

# getMoRand() - get M'Entropy for Randomization
getMoRand() {
	while [ $(/bin/cat /proc/sys/kernel/random/entropy_avail) -lt $MIN_ENTROPY ]; do
		echo -e "\t    waiting for entropy>=${MIN_ENTROPY} ($(cat /proc/sys/kernel/random/entropy_avail)) ... "
		# Generate randomness
        	/usr/bin/find /etc -xdev -type f | /usr/bin/xargs /bin/cat {} > /dev/null 2>&1 \;
		sleep 2
	done
}


#####	MAIN

if [ "${myTang}" == "" ] || [ "${myTang}" == "${fictTang}" ] ; then
	echo -e "\n*****\tModify this script to use your Tang server http://address[:port] (myTang=)\n"
else

	# Enable systemd to watch Clevis service and ask for password
	systemctl enable clevis-luks-askpass.path

	# Run commands to bind Clevis to tang server for each block device required
	for d in $(lsblk -p -n -s -r | awk '$6 == "crypt" { getline; print $1 }' | sort -u) ; do
	        echo -e "\n*****\t${d}"
		getMoRand
	        echo -e "\n\texec:\tclevis luks bind -d ${d} tang '{\"url\":\"${myTang}\"}'\n"
	        clevis luks bind -d ${d} tang '{"url":"'${myTang}'"}'
	done

	# Insert rd.neednet=1 if not in GRUB default 
	echo -e "\n*****\tScript is modifying /etc/default/grub with 'rd.neednet=1' ... "
	grep -qie "^[ \t]*GRUB_CMDLINE_LINUX.*rd.neednet=1.*$" /etc/default/grub
	[ $? -ne 0 ] &&	sed -i 's,^[ \t]*GRUB_CMDLINE_LINUX=",GRUB_CMDLINE_LINUX="rd.neednet=1 ,g' /etc/default/grub
	echo -e "\tDONE."
	
	# Now modify /etc/fstab so system file systems know they are mounted in initrd (append 'x-initrd.mount' to options)
	echo -e "\n*****\tScript is modifying /etc/fstab so system file systems have option 'x-initrd.mount' appended ... "
	sed -i 's/x-systemd.device-timeout=0[ \t]\+/x-systemd.device-timeout=0,x-initrd.mount  /g' /etc/fstab
	echo -e "\tDONE."

	echo -e "\n*****\tList all network interfaces, and which one(s) are currently plugged in ... \n"
	# List all network interfaces
	[ -x "/usr/local/bin/getAllEth.sh" ] && /usr/local/bin/getAllEth.sh

	# Inform sysadmin that if a Static IP is to be used, they need to edit the relevant file
	echo -e "\n*****\tUSER TODO:  Please modify Dracut config file(/etc/dracut.conf.d/static_ip.conf) if a static IP is to be used (instead of DHCP)"

	# Inform sysadmin to rebuild all initramfs files (after any further modifications) and rebuild the GRUB configuration
	echo -e "\n*****\tUSER TODO:  After all modifications (e.g., Static IP for Dracut), please run the following commands BEFORE rebooting ... "
	echo -e "\tRHEL(all):\t# dracut -fv"
	echo -e "\tthen ..."
	echo -e "\t   RHEL9+:\t# grub2-mkconfig --update-bls-cmdline -o /boot/grub2/grub.cfg"
	if [ -d "/sys/firmware/efi" ] ; then
		echo -e "\t  RHEL6-8:\t# grub2-mkconfig -o /boot/efi/EFI/redhat/grub.cfg"
	else
		echo -e "\t  RHEL6-8:\t# grub2-mkconfig -o /boot/grub2/grub.cfg"
	fi
	echo -e "\nIMPORTANT:\t*ALL* LUKS volumes *MUST* be opened (e.g., listed in 'lsblk') for mounts in /etc/fstab\n\t\twhen executing 'dracut -fv' to update the initramfs for the current kernel\n"
fi
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
		grub2-mkconfig -o /boot/efi/EFI/redhat/grub.cfg
	else
		# for BIOS (/etc/grub2.cfg = /boot/grub2/grub.cfg) if /sys/firmware/efi does *NOT* exist
		grub2-mkconfig -o /boot/grub2/grub.cfg
	fi
fi

