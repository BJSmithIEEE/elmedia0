### ks/include/ks-elX-20sec-00def.inc

# These should be in the MAIN ks file itself (copy'n uncomment)

#### EL9
## DEPRECATED in old EL8 # authconfig --enableshadow --passalgo=sha512
#authselect select sssd with-faillock with-krb5 with-mkhomedir with-pamaccess	# max backward compatibility
#firewall --service=ssh
#firstboot --disable
#selinux --enforcing

#### EL7/8
## Base Security Defaults
#authconfig --enableshadow --passalgo=sha512
#firewall --service=ssh
#firstboot --disable
#selinux --enforcing

