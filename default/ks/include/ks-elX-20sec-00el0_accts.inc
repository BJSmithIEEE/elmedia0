### ks/include/ks-elX-20sec-00el0_accts.inc

# IMPORTANT:
#  - Default system users need to be UID >=1000 for remote SSH login
#  - Default system users are located on root (/) in /homesys (home for local system) for two (2) reasons.
#    1.  Guaranteed Local:    Does not conflict with any NFS or CIFS mounted /home, which may or may not have full SELinux contexts
#    2.  Guaranteed Context:  Working automation/orchestration (e.g., ansible) with default 'exec' on root (/) and with full SELinux contexts
#  - WARNING:  By default the /home file system will be mounted 'noexec' per DISA STIG and NIST CUI (and NFS mounted should as well)

# Default root account for Default-elmedia-Naught
rootpw --iscrypted --lock $6$61MtJBCKiY2X6gpX$DAv9omcXhg98YfULmGqgsBkoBxPgcN.OZc3MaXVpK/BHVlQE3Sc8riduMZuTjYFMUOotBhY/s1pIG1A4u.1T50

# Default local system admin account for Default-elmedia-Naught
user --name=sysadmin --gid=1000 --uid=1000 --homedir=/homesys/sysadmin --groups=wheel --iscrypted --password=$6$61MtJBCKiY2X6gpX$DAv9omcXhg98YfULmGqgsBkoBxPgcN.OZc3MaXVpK/BHVlQE3Sc8riduMZuTjYFMUOotBhY/s1pIG1A4u.1T50

# Default local ansible admin
# NOTE:  Do not put ansadmin in wheel, use an explicit sudoers configuration
user --name=ansadmin --gid=1010 --uid=1010 --homedir=/homesys/ansadmin --iscrypted --password=$6$61MtJBCKiY2X6gpX$DAv9omcXhg98YfULmGqgsBkoBxPgcN.OZc3MaXVpK/BHVlQE3Sc8riduMZuTjYFMUOotBhY/s1pIG1A4u.1T50

