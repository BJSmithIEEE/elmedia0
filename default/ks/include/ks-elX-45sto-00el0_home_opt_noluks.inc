### ks/include/ks-elX-45sto-00el0_home_opt_noluks.inc

# Create local /home and /opt - NO LUKS password
#   - disk needs to be a minimum of 40GiB 
#   - so minimum 40GiB for PV
part pv.01 --size=40960 --grow
logvol /home --fstype=xfs --name=lv_home --vgname=vg1 --size=4096 --grow --maxsize=16384 --fsoptions="nodev,noexec,nosuid"
logvol /opt --fstype=xfs --name=lv_opt --vgname=vg1 --size=4096 --grow --maxsize=16384 --fsoptions="nodev,nosuid"


