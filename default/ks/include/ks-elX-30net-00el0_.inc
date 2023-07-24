### ks/include/ks-elX-30net-00el0_.inc

## Network setup DHCP on first device 'up' (link status):  em* eno* eth* ens* p*p* enp* enx*
#   em* - Ethernet on Motherboard - BIOSDEVNAME
#  eno* - Ethernet NICs On-board - FreeDesktop Predictable Network Interface Names (systemd)
#  eth* - Ethernet [legacy] - typically ESXi/vSphere, Hyper-V and some KVM/oVirt
#  ens* - Ethernet NICs in hotplug Slot - FreeDesktop Predictable NetworK Interface Names (systemd)
#  p*p* - [Ethernet] PCI[e] slot Port - BIOSDEVNAME
#  enp* - Ethernet NICs PCI[e] slot - FreeDesktop Predictable Network Interface Names (systemd)
#  enx* - Ethernet NICs heXadecimal address - FreeDesktop Predictable Network Interface Names (systemd)

# NO LINK # network --activate --bootproto=dhcp --device=????? --onboot=on --ipv6=auto

