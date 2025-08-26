### ks/include/ks-elX-40dev-00el0_luks-if-not-vm.inc

# Moving to a 35% reserve (no longer 15%)
volgroup vg1 --pesize=4096 --reserved-percent=35 pv.01

# Use LVM, if not a VM, use LUKS Encryption using DEFAULT elmedia-Naught temporary LUKS password 
# WARNING:  Since LUKS password can*NOT* be encrypted/hashed, change this from Default-elmedia-Naught *AFTER* installation
%include /tmp/pv.01.inc

