### ks/include/ks-elX-95opt-STIG.inc

# Run Optional Script(s)
[ -r "/opt/STIG/ks/opt_STIG-post.sh" ] && /bin/sh "/opt/STIG/ks/opt_STIG-post.sh"

