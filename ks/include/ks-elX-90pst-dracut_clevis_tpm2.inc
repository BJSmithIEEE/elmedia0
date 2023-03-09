### ks/include/ks-elX-90pst-dracut_clevis_tpm2.inc

## Dracut for Clevis with or without NetworkManager or TPM2 chip

cat << EOF > /etc/dracut.conf.d/99-clevis-options.conf
#
#	/etc/dracut.conf.d/99-clevis-options.conf
#	Required for NetworkManager modification (e.g., static IP)
#	NOTE:  Spaces after open and before close double-quote (" mod1 mod2 mod3 ") are required


###	dracut modules to omit

## clevis_none - Clevis is not to be used (omit all 3)
# NO NONE # omit_dracutmodules+=" clevis ifcfg network "

## clevis_tang - Clevis via network to tang server, but don't interfere with normal NetworkManager (omit ifcfg)
# NO TANG # omit_dracutmodules+=" ifcfg "

## clevis_tpm2 - Clevis via TPM2 chip (omit ifcfg network)
omit_dracutmodules+=" ifcfg network "
EOF


###	regenerate initramfs
KERNEL_VERSION=$(rpm -q kernel --qf '%{version}-%{release}.%{arch}\n')
dracut -f --regenerate-all /boot/initramfs-${KERNEL_VERSION}.img ${KERNEL_VERSION}

