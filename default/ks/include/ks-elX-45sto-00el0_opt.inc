### ks/include/ks-elX-45sto-00el0_opt.inc

# Storage layout defaults - DISA STIG and NIST CUI Compliant
#   - Does not require a separate /opt as of RHEL9.6, but some application STIGs may require such

# Default opt LV minimum usage of 2GiB + 0.7GiB (35% reservation add) = 2.7GiB (2.9GB) min increase to add separate /opt
logvol /opt --fstype=xfs --name=lv_opt --vgname=vg1 --size=2048 --grow --maxsize=8192 --fsoptions="nodev,nosuid"
