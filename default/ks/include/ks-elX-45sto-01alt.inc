### ks/include/ks-elX-45sto-01alt.inc

# Storage layout defaults - DISA STIG and NIST CUI Compliant (Alternative, designed for 35% reservation)
#   - separate swap, /tmp, /var, /var/log, /var/log/audit, /var/tmp
#   - newer benchmarks now require a separate /var/tmp, which must be persistent (unlike /tmp), so no tmpfs (must be disk)

# Default base LV min 27GiB + 9.5GiB (35% reservation) = 36.5GiB (39.2GB) in LVs + 2GiB for boot/ESP = 38.5GiB (41.3GB) min
logvol / --fstype=xfs --name=lv_root --vgname=vg1 --size=8192 --grow --maxsize=16384
logvol swap --fstype=swap --name=lv_swap --vgname=vg1 --size=1024 --grow --maxsize=4096
logvol /tmp --fstype=xfs --name=lv_tmp --vgname=vg1 --size=4096 --grow --maxsize=16384 --fsoptions="nodev,noexec,nosuid"
logvol /var --fstype=xfs --name=lv_var --vgname=vg1 --size=4096 --grow --maxsize=16384 --fsoptions="nodev,noexec,nosuid"
logvol /var/log --fstype=xfs --name=lv_log --vgname=vg1 --size=4096 --grow --maxsize=16384 --fsoptions="nodev,noexec,nosuid"
logvol /var/log/audit --fstype=xfs --name=lv_audit --vgname=vg1 --size=4096 --grow --maxsize=16384 --fsoptions="nodev,noexec,nosuid"
logvol /var/tmp --fstype=xfs --name=lv_vartmp --vgname=vg1 --size=2048 --grow --maxsize=8192 --fsoptions="nodev,noexec,nosuid"
