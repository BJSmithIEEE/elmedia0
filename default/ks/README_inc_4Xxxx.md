

# Kickstart Storage - Injected Functions and Include Files

There are two (2) aspects to how the dynamic Kickstart of elmedia0 works.

1. `%pre` Globals and Functions via an *'injected'* partial file (during build time via the build script)
2. `%pre` Include Files for Storage via the block device files (`ks-elX-40dev*.inc`) and [volume] storage Files (`ks-elX-45sto-*.inc`)


## %pre Globals and Functions - Find the Block Devices

In [any main Kickstart file (elmedia0 *.ks files)](./), the `%pre` section starts as follows.  The file (`/tmp/ks-script_elmedia-pre.log`) is available during Kickstart, and will be copied to the target system storage (`/var/log/anaconda/ks-script_elmedia-pre.log`) during `%post`.
``` shell
    ...
###	PRE
%pre --log /tmp/ks-script_elmedia-pre.log
echo -e "\n===============\n[elmedia]\tKickstart %pre\n===============\n"
    ... 
```

The four (4) environmental variables that will be set for block devices/storage that will be set during installation are as follows, and this is the shared.

``` shell
    ... 
## %pre - Globals
export TLD_KS=""	# Top Level Directory (TLD) of Kickstart Media
export DIR_KS=""	# Full Path to /ks Subdirectory under TLD
export BLK_KS=""	# Backing Block Device of Kickstart Media
    ... 
export DEV_KS=""	# 1st Block Device on System that is not Kickstart Media
    ... 
```

> **IMPORTANT:** From an elmedia0 media builder standpoint, this is the only portion of the Kickstart that is **neither** in [any main Kickstart file (elmedia0 *.ks)](./), nor in any [Kickstart include files (elmedia0 *.inc)](include).  It is [a partial file injected (substituted)](inject/ks-elmedia.inject) into the Kickstart files during the build of the ISO, USB, etc... installation media by the [main script mkelmedia.sh](../../bin/mkelmedia.sh).  That way only one copy is required for all kickstart files.

The first two (2) are paths to the Kickstart Media.  They are fairly straight-forward.  The actual logic is provided via the following.

``` 
# Find kickstart media block device
for d in /run/install/repo ; do
	[ -d "${d}/ks" ] && export DIR_KS="${d}/ks" && export TLD_KS="${d}"
	[ "${DIR_KS}" != "" ] && break
done
``` 

This includes finding the ... 
 * `TLD_KS` which is the *'Top Level Directory (TLD) of Kickstart Media'* (`TLD_KS`), which is actually first found by checking for the ... 
 * `DIR_KS` which is the *'Full Path to the /ks Subdirectory under TLD'* (`DIR_KS`], where a simple `for` loop is used (see the **IMPORTANT** note)

> **IMPORTANT:** After many attempts to be flexible, because the repositories have to be *'hard coded'* in any main Kickstart file (elmedia0 *.ks files)](./), the `TLD_KS` will always be the same path (`/run/install/repo`).  Should this change in future RHEL Anaconda Kickstart designs, the for loop could be used to check other paths, in a specific order.

The more complex are the two (2) block devices, one (1) for the Kickstart Media, the other for the actual, *'first'* block device using a *'preferred order check,' which we will discuss.

``` 
## %pre - Functions

# fndInsDev - find the backing block device for the kickstart media
#	ret = return string of device found, empty if not - e.g., sdb1 for uEFI USB, sr0 for ISO, etc...
fndInsDev() {
	local r=""
	r="$(/bin/sed -n 's,^/dev/\([0-9A-Za-z_-]\+\)[ \t]\+'${TLD_KS}'[ \t]\+.*$,\1,p' /proc/mounts)"
	echo "${r}"
}

# fndSysDev - find a device, in decreasing order of preference (first = most, last = least)
#       $1  = root path under /sys -- e.g., 'block', 'class/net', etc...
#       $2+ = list (space separated) of devices, in increasing order of preference - single quote (') each to preserve slashes and wildcards
#       ret = return string of device found, empty if not
fndSysDev() {
	local P="$1"
    shift
    local L="$@"
    local l=""
	    ... 
	if [ "${P}" != "" ] ; then
	    cd "/sys/${P}"
        for l in ${L} ; do
            if [ -d "${l}" ] ; then
				case "${P}" in
					'block')
						# block - check if same as Media Block
                        [ "${BLK_KS}" != "" ] && [[ "${BLK_KS}" != "${l}"* ]] && r="${l}"
						;;
                    ...
				esac
               	[ "${r}" != "" ] && break
                fi
			fi
            ...
		done
	fi
        ...
	echo "${r}"
}
``` 

We use a pair of functions for the two (2) as follows.
 * `BLK_KS` which is the *'Backing Block Device of Kickstart Media'* via function(`fndInsDev`) must be found first, and it merely looks for the *'TLD of Kickstart Media'* (`TLD_KS`), which is the mount point, and the corresponding block device.
 * `DEV_KS` which is the *'1st Block Device on System that is not Kickstart Media'*, via function (`fndSysDev`) we have to check through a *'preferred order'* of devices, and also verify it's not the same as the *'Backing Block Device of Kickstart Media'*

What is the preferred device order?  Looking at the rest of section of the [partial, injected file](inject/ks-elmedia.inject), you'll see the 

```
	... 
## %pre - Find Devices 
export BLK_KS="$(fndInsDev)"
    ...
export DEV_KS="$(fndSysDev 'block' md127 md126 md125 md124 md123 md122 md121 md120 md119 md118 'md?' 'nvme?n?' 'vd?' 'sd?')"
```

Why this order?
 1. Multi-disk (MD), including Fake/Firmware RAID:  `md127`, `md126` ... `md118` or `md0` ... `md9`
 2. NVMe storage such as M.2, U.2, EDSFF Ex, etc... PCIe/nVME:  `nvme?n?` (sorted numerically)
 3. QEMU-KVM/oVirt and other Virtual Disks:  `vd?` (sorted alphabetically)
 4. baremetal ATA/SCSI-3, ESXi/vSphere and Hyper-V disks:  `sd?` (sorted alphabetically)

The Multi-Disk (MD) is almost non-standard, and various PC ODM/OEM and HBA firmware differs on naming convensions, of which the Linux kernel via `udev` namespace **DOES** *'respect'* (e.g., `biosdevname`).  So the first ten (10) MD devices, from 127 down to 118, then 0 to 9, are tested first, in that order.

> **WARNING:**  Some installations use `md127` as a meta-device, and **NOT** an *'actual device.'*  The function(`fndSysDev`) will be modified to do size-based testing, which needs to be more than just *'non-zero'* (`0`), but actually a *'minimum size.*  But even the block size is not always reported via the standard Block System (`/sys/block/`) interfaces uniformly.  Various testing is still on-going.


## %pre Globals and Functions - Define the Partitions and Volumes



