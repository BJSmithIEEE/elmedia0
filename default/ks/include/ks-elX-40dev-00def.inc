### ks/include/ks-elX-40dev-00def.inc

# Storage device defaults
zerombr
# First 2GiB used by EFI System Partition and GRUB2 /boot
part /boot/efi --fstype=efi --size=1023 --fsoptions="nosuid"
part /boot --fstype=xfs --size=1024 --fsoptions="nodev,noexec,nosuid"

