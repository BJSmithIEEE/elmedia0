### ks/include/ks-elX-40dev-00el0_bXXXXX.inc (custom - change GRUB root password for editing)

# Install to a dynamically determined block storage device - but don't remove any existing partitions - Use *CUSTOM* firmware/bootloader password
#   - md127...md118 or md0..md9 - first Multi-disk (MD) storage, such as Firmware/Fake RAID (FRAID)
#   - nvme?n? - baremetal M.2 or U.2 PCIe/nVME
#   - vd? - QEMU-KVM/oVirt
#   - sd? - baremetal ATA/SCSI-3, ESXi/vSphere and Hyper-V

bootloader --location=mbr --driveorder=bXXXXX --append="crashkernel=auto audit=1" --iscrypted --password=grub.pbkdf2.sha512.10000.7B4F0A0F27C2606A979BC9C60F8E9D973AB40C9E770F6C01285CCF88837CA5267596DDE57351E14F731770FE6C0E735620E60E5845267F581CE29155E8E26382.2B55480E416A04ACE9BF0E33A27FF989784FD3843D19BAC0D34B87FF5A6EC97C1AC642B4E63D9AB56B4F6C0F8D67C980347F79E64EB03EBDC9B51918AB0D8A57

ignoredisk --only-use=bXXXXX
clearpart --drives=bXXXXX --none --initlabel

