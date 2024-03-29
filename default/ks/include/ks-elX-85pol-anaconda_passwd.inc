### ks/include/ks-elX-85add-anaconda_passwd.inc

# Red Hat Anaconda-enforced - Password Security Policy
%anaconda
# Password Security Policy - Common or greater of both DISA STIG and NIST CUI
pwpolicy root --minlen=15 --minquality=1 --notstrict --nochanges --notempty
pwpolicy user --minlen=15 --minquality=1 --notstrict --nochanges --emptyok
pwpolicy luks --minlen=15 --minquality=1 --notstrict --nochanges --notempty
%end


