### ks/include/ks-elX-45sto-00el0_home-exec.inc

# Storage layout defaults - DISA STIG and NIST CUI Compliant
#   - Requires separate home w/noexec -- POA&M Documented Exception for 'exec' on /home

# Default home LV minimum usage of 2GiB + 0.7GiB (35% reservation add) = 2.7GiB (2.9GB) min increase to add separate /home
logvol /home --fstype=xfs --name=lv_home --vgname=vg1 --size=2048 --grow --maxsize=8192 --fsoptions="nodev,nosuid"
