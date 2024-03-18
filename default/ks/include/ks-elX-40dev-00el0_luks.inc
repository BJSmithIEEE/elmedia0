### ks/include/ks-elX-40dev-00el0_luks.inc

# Default disk minimum is 42.0GiB (45.0GB) = 2.0GiB boot/ESP + 40.0GiB PV (rounded up)

volgroup vg1 --pesize=4096 --reserved-percent=15 pv.01
# Default PV minimum is 39.1GiB (42.0GB) = 26GiB base LVs + 8 GiB home/opt LVs + 5.1GiB reserved (15% of 34GiB)
# Round up to 42.0GiB (40,960MiB)
# Use LVM w/LUKS Encryption using DEFAULT elmedia-Naught temporary LUKS password 
part pv.01 --size=40960 --grow --encrypted --passphrase=elmedia0!
# WARNING:  Since LUKS password can*NOT* be encrypted/hashed, change this from Default-elmedia-Naught *AFTER* installation

