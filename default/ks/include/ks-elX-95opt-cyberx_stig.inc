### ks/include/ks-elX-95opt-cyberx_stig.inc

# Run Optional Script(s)
X95name="cyberx_stig"
[ -r "/opt/${X95name}/ks/opt_${X95name}-post.sh" ] && /bin/sh "/opt/${X95name}/ks/opt_${X95name}-post.sh"

