### ks/include/ks-elX-20sec-00def.inc

# Base Security Defaults
authconfig --enableshadow --passalgo=sha512
firewall --service=ssh
firstboot --disable
selinux --enforcing

