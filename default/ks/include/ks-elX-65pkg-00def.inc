### ks/include/ks-elX-65pkg-00def.inc

# COMPS Security Profile - Compatible (with both DISA STIG and NIST CUI)
@guest-agents
@hardware-monitoring
@infiniband
@legacy-unix
@network-file-system-client
-cockpit
@security-tools
@smart-card
@system-tools
-nmap
-tigervnc
-zsh

# COMPS Security Profile - Common (between DISA STIG and NIST CUI)
aide
audit
fapolicyd
firewalld
gnutls-utils
openscap
openscap-scanner
openssh-clients
openssh-server
policycoreutils
rsyslog
rsyslog-gnutls
scap-security-guide
subscription-manager
tmux
usbguard
-abrt
-abrt-addon-ccpp
-abrt-addon-kerneloops
-abrt-addon-python
-abrt-cli
-abrt-plugin-logger
-abrt-plugin-rhtsupport
-abrt-plugin-sosreport
-iprutils
-sendmail

# COMPS Security Profile - DISA STIG only
opensc
openssl-pkcs11
rng-tools
-rsh-server
-telnet-server
-tftp-server
-tuned
-vsftpd

# COMPS Security Profile - NIST CUI only
audispd-plugins
chrony
crypto-policies
dnf-automatic
dnf-plugin-subscription-manager
openssh-clients
policycoreutils-python-utils
subscription-manager
sudo
# Required for Desktop # -gssproxy
# Required for Desktop # -nfs-utils

# Security Tools
policycoreutils-python-utils

# DISA STIG Adds
opensc

# SSSD Auth/ID
# NOTE:  krb5-workstation keeps being uninstalled by DISA STIG playbooks
krb5-workstation
samba-client
samba-common
samba-common-tools
sssd
sssd-ad
sssd-client
sssd-krb5
sssd-ipa
sssd-ldap
sssd-proxy

# Boom Snaphots
boom-boot
boom-boot-conf
boom-boot-grub2
python3-boom

# Other
mailx
postfix
sysstat

# Remove GNOME Boxes from Desktop Installs
-gnome-boxes

