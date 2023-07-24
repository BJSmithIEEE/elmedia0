### ks/include/ks-elX-80add-openscap_stig_cui.inc

# Red Hat Anaconda-enforced - Password Security Policy
%anaconda
# Password Security Policy - Common or greater of both DISA STIG and NIST CUI
pwpolicy root --minlen=15 --minquality=1 --notstrict --nochanges --notempty
pwpolicy user --minlen=15 --minquality=1 --notstrict --nochanges --emptyok
pwpolicy luks --minlen=15 --minquality=1 --notstrict --nochanges --notempty
%end

# OpenSCAP Security Profile - DISA STIG
%addon org_fedora_oscap
    content-type = scap-security-guide
    profile = xccdf_org.ssgproject.content_profile_stig
%end

# OpenSCAP Security Profile - NIST CUI
%addon org_fedora_oscap
    content-type = scap-security-guide
    profile = xccdf_org.ssgproject.content_profile_cui
%end

