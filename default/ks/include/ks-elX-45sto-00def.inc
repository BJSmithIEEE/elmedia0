### ks/include/ks-elX-45sto-00def.inc

# Storage layout defaults - DISA STIG and NIST CUI Compliant
volgroup vg1 --pesize=4096 pv.01
logvol / --fstype=xfs --name=lv_root --vgname=vg1 --size=8192 --grow --maxsize=16384
logvol swap --fstype=swap --name=lv_swap --vgname=vg1 --size=1024 --grow --maxsize=4096
logvol /tmp --fstype=xfs --name=lv_tmp --vgname=vg1 --size=4096 --grow --maxsize=16384 --fsoptions="nodev,noexec,nosuid"
logvol /var --fstype=xfs --name=lv_var --vgname=vg1 --size=4096 --grow --maxsize=16384 --fsoptions="nodev,noexec,nosuid"
logvol /var/log --fstype=xfs --name=lv_log --vgname=vg1 --size=4096 --grow --maxsize=32768 --fsoptions="nodev,noexec,nosuid"
logvol /var/log/audit --fstype=xfs --name=lv_audit --vgname=vg1 --size=4096 --grow --maxsize=32768 --fsoptions="nodev,noexec,nosuid"


