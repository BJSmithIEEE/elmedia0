### ks/include/ks-elX-95opt-STIG.inc

# Run Optional Script(s)
X95name="STIG"
[ -r "/opt/${X95name}/ks/opt_${X95name}-post.sh" ] && /bin/sh "/opt/${X95name}/ks/opt_${X95name}-post.sh"

