### ks/include/ks-elX-45sto-00el0_home_opt.inc

# Storage layout defaults - DISA STIG and NIST CUI Compliant
#   - Requires separate home w/noexec
#   - Also including a separate /opt with exec for project/user software, as /home does not allow exec

# Default home/opt LV minimum usage of 9.2GiB (9.9GB) = 8.0GiB LVs + 1.2GiB reserved (15% of 8.0GiB)
logvol /opt --fstype=xfs --name=lv_opt --vgname=vg1 --size=4096 --grow --maxsize=16384 --fsoptions="nodev,nosuid"
logvol /home --fstype=xfs --name=lv_home --vgname=vg1 --size=4096 --grow --maxsize=16384 --fsoptions="nodev,noexec,nosuid"
# custom exec on /home # logvol /home --fstype=xfs --name=lv_home --vgname=vg1 --size=4096 --grow --maxsize=16384 --fsoptions="nodev,nosuid"

