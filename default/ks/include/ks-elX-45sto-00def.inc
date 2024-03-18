### ks/include/ks-elX-45sto-00def.inc

# Storage layout defaults - DISA STIG and NIST CUI Compliant
#   - separate swap, /tmp, /var, /var/log, /var/log/audit
#   - newer benchmarks now require a separate /var/tmp, which must be persistent (unlike /tmp), so no tmpfs (must be disk)

# Default base LV minimum usage of 29.9GiB (32.1GB) = 26GiB LVs + 3.9GiB reserved (15% reserved)
logvol / --fstype=xfs --name=lv_root --vgname=vg1 --size=8192 --grow --maxsize=16384
logvol swap --fstype=swap --name=lv_swap --vgname=vg1 --size=1024 --grow --maxsize=4096
logvol /tmp --fstype=xfs --name=lv_tmp --vgname=vg1 --size=4096 --grow --maxsize=16384 --fsoptions="nodev,noexec,nosuid"
logvol /var --fstype=xfs --name=lv_var --vgname=vg1 --size=4096 --grow --maxsize=16384 --fsoptions="nodev,noexec,nosuid"
logvol /var/log --fstype=xfs --name=lv_log --vgname=vg1 --size=4096 --grow --maxsize=32768 --fsoptions="nodev,noexec,nosuid"
logvol /var/log/audit --fstype=xfs --name=lv_audit --vgname=vg1 --size=4096 --grow --maxsize=32768 --fsoptions="nodev,noexec,nosuid"
logvol /var/tmp --fstype=xfs --name=lv_vartmp --vgname=vg1 --size=1024 --grow --maxsize=4096 --fsoptions="nodev,noexec,nosuid"

