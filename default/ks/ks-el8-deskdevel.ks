###############################################################################
### EL8 - Kickstart - Desktop Developer w/Local /home and /opt
###############################################################################
### metaFilename:deskdevel
### metaShortname:Desktop Developer Local Home Opt
### metaDescription:Desktop Developer with local /home and /opt, no OpenSCAP, STIG Ansible Playbooks

###     Base - Install
# deprecated # install
text
url --url=file:///run/install/repo
repo --name="addlpkgs" --baseurl=file:///run/install/repo/addlpkgs
repo --name="ansible29" --baseurl=file:///run/install/repo/ansible29
repo --name="AppStream" --baseurl=file:///run/install/repo/AppStream


###	PRE
%pre --log /tmp/ks-script_elmedia-pre.log
echo -e "\n===============\n[elmedia]\tKickstart %pre\n===============\n"
export DISTAG="el8"



# XXXXX INJECT_KSPRE XXXXX



## %pre - Dynamically Assemble Kickstart Includes

# 15lcl - Locale - Default-elmedia-Naught Location
mkIncFil 15lcl 00def 00el0_uscdtcst

# 20sec - Security - Defaults and Default-elmedia-Naught Accounts
mkIncFil 20sec 00def 00el0_accts
# custom # mkIncFil 20sec 00def 00cus_accts

# 30net - Network - Defaults and DHCP
mkIncFil 30net 00def 00el0_${NET_KS}

# 40dev - Device - Local Storage Device and GRUB Password
mkIncFil 40dev 00def 00el0_${DEV_KS}
# custom # mkIncFil 40dev 00def 00cus_${DEV_KS}

# 45sto - Storage - Local Storage Layout
mkIncFil 45sto 00def 00el0_home_opt

# 60env - Environment - COMPS Default Environment
mkIncFil 60env 00def deskdevel 

# 65pkg - Packages - COMPS Packages and Roles
mkIncFil 65pkg 00def ansible deskdevel scc tpm2

# 80add - Add-ons - Various add-ons
mkIncFil 80add 00def

# 85pol - Policy - Built-in Security Policy
mkIncFil 85pol anaconda_passwd
# OpenSCAP NIST CUI - Use CyberX and/or Lockdown Instead # mkIncFil 85pol anaconda_passwd openscap_cui
# OpenSCAP DISA STIG - Use CyberX and/or Lockdown Instead # mkIncFil 85pol anaconda_passwd openscap_stig

# 90pst - Post - Post-Install
mkIncFil 90pst 00def 00el0_home 00el0_sshsudo clevis_common dracut_clevis_none
# custom # mkIncFil 90pst 00def 00el0_home 00cus_sshsudo clevis_common dracut_clevis_tpm2
# custom # mkIncFil 90pst 00def 00el0_home 00cus_sshsudo clevis_common dracut_clevis_tang

# 95opt - Post - Optional Software
mkIncFil 95opt cyberx_bench cyberx_scc cyberx_stig cyberx_view lockdown_stig
# custom w/Third Party Software # mkIncFil 95opt cyberx_bench cyberx_scc cyberx_stig cyberx_view lockdown_stig TPS cus

## %pre - end
%end


###     Base - Locale

keyboard us
lang en_US.UTF-8

%include /tmp/ks-15lcl.inc


###     Base - Security

authconfig --enableshadow --passalgo=sha512
firewall --service=ssh
firstboot --disable
selinux --enforcing

%include /tmp/ks-20sec.inc


###     Base - Network

%include /tmp/ks-30net.inc


###     Base - Storage

%include /tmp/ks-40dev.inc
%include /tmp/ks-45sto.inc


###     COMPS and Software
%packages

%include /tmp/ks-60env.inc
%include /tmp/ks-65pkg.inc

%end


###     Add-ons and Policy

%include /tmp/ks-80add.inc
%include /tmp/ks-85pol.inc


###	POST (nochroot)
%post --nochroot --log /mnt/sysimage/var/log/anaconda/ks-script_elmedia-post-nochroot.log
echo -e "\n===============\n[elmedia]\tKickstart %post --nochroot\n===============\n"
export DISTAG="el8"

# Find optional media, in order of most to least preferred
export DIR_OPT=""
for d in /run/install/repo ; do
	[ -d "${d}/opt" ] && export DIR_OPT="${d}/opt"
	[ "${DIR_OPT}" != "" ] && break
done
# Copy optional media to new system /opt
[ -d "${DIR_OPT}" ] && cp -dpR "${DIR_OPT}" "/mnt/sysimage/"

%end


###	POST (chroot)
%post --log /var/log/anaconda/ks-script_elmedia-post.log
echo -e "\n===============\n[elmedia]\tKickstart %post (chroot)\n===============\n"
cat >> /var/log/anaconda/ks-script_elmedia-pre.log << "EOF"
%include /tmp/ks-script_elmedia-pre.log
EOF

%include /tmp/ks-90pst.inc
%include /tmp/ks-95opt.inc

%end

