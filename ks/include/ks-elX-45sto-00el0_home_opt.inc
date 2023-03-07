### ks/include/ks-elX-45sto-00el0_home_opt.inc

# Create local /home and /opt - Use Default-elmedia-Naught temporary LUKS password
#   - disk needs to be a minimum of 40GiB
#   - so minimum 40GiB for PV
# WARNING:  Since LUKS password can*NOT* be encrypted/hashed, change this from Default-elmedia-Naught after installation
part pv.01 --size=40960 --grow --encrypted --passphrase=elmedia0!
logvol /home --fstype=xfs --name=lv_home --vgname=vg1 --size=4096 --grow --maxsize=16384 --fsoptions="nodev,noexec,nosuid"
logvol /opt --fstype=xfs --name=lv_opt --vgname=vg1 --size=4096 --grow --maxsize=16384 --fsoptions="nodev,nosuid"


