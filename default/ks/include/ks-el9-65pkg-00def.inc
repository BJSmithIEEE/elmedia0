### ks/include/ks-el9-65pkg-00def.inc

# COMPS Security Profile - Based on old EL8 OSCAP Profile - Compatible (with both DISA STIG and NIST CUI)
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

# COMPS Security Profile - Based on old EL8 OSCAP Profile - Common (between DISA STIG and NIST CUI)
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
# Legacy package (abrt) replaced by another solution (systemd-coredump) in EL9, which is not in EL9 base media
#-systemd-coredump
-iprutils
-sendmail

# COMPS Security Profile - Based on old EL8 OSCAP Profile - DISA STIG only
opensc
openssl-pkcs11
rng-tools
# Legacy package (rsh-server) not in EL9 base media
#-rsh-server
-telnet-server
-tftp-server
-tuned
-vsftpd

# COMPS Security Profile - Based on old EL8 OSCAP Profile - NIST CUI only
audispd-plugins
chrony
crypto-policies
dnf-automatic
# Separate package (dnf-plugin-subscription-manager) is not EL9 (or base media)
openssh-clients
policycoreutils-python-utils
subscription-manager
sudo
# Required for Desktop # -gssproxy
# Required for Desktop # -nfs-utils

# Security Tools - Based on old EL8
policycoreutils-python-utils

# DISA STIG Adds - Based on old EL8
opensc

# SSSD Auth/ID - Based on old EL8
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
# separate package (boom-boot-grub2) not in EL9 base media (still needed?)
python3-boom

# Other - Based on old EL8
# Legacy package (mailx) replaced by another solution (s-mail) in EL9
s-nail
postfix
sysstat

