### ks/include/ks-elX-90pst-00def.inc

## Fix Dracut for Clevis with NetworkManager

cat << EOF > /etc/dracut.conf.d/99-disable_clevis-ifcfg.conf
#
#	/etc/dracut.conf.d/99-disable_clevis-ifcfg.conf
#	Required for NetworkManager modification (e.g., static IP)
#	NOTE:  Spaces after open and before close double-quote (" mod1 mod2 mod3 ") are required
#
# dracut modules to omit
# NOTE:  'clevis' should not be omitted to support on-board, hardware TPM2 stores
#OLD#omit_dracutmodules+=" clevis ifcfg network "
omit_dracutmodules+=" ifcfg network "
EOF
KERNEL_VERSION=$(rpm -q kernel --qf '%{version}-%{release}.%{arch}\n')
/sbin/dracut -f /boot/initramfs-${KERNEL_VERSION}.img ${KERNEL_VERSION}

