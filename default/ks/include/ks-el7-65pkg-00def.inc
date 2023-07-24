### ks/include/ks-el7-65pkg-00def.inc

### EL7-specific from SCAP Security Guide (SSG) legacy CentOS/RHEL7 Kickstart

# EL7-specific from default installer
@base
@core
@fonts
@network-file-system-client
@networkmanager-submodules
@guest-agents
kexec-tools

# EL7-specific SCAP Security Guide (SSG) Requirements
aide
bzip2
dos2unix
dracut-fips
fipscheck
krb5-libs
krb5-workstation
pam_krb5
unix2dos
unzip
vlock
xz
yum-utils
zip

# EL7-specific Other
vim-enhanced
postfix
mailx

# EL7-specific Attempt to Match New RHEL8 COMPS/STIG Security Profile - where available
@legacy-unix
@security-tools
@smart-card
audit
chrony
firewalld
gnutls-utils
opensc
openscap
openscap-scanner
policycoreutils
rsyslog
rsyslog-gnutls
scap-security-guide
subscription-manager
tmux
usbguard

# EL7-specific Security Tools
policycoreutils-python

# EL7-specific Boom Snapshots
lvm2-python-boom

# EL7-specific REMOVE PACKAGES
-abrt*
-avahi*
-iwl*
-ivtv-firmware



