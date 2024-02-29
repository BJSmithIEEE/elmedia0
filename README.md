> ***WARNING:*** *This README is not completed yet.  It will be drastically modified in the near future.*

# Enterprise Linux Media [Builder] Naught (elmedia0)

Build Bootable (e.g., BIOS/uEFI ISO9660 image or native uEFI VFAT USB devcies) Enterprise Linux Media with Automated Kickstarts for CentOS/RHEL 7/8/9 (hereafter EL7/8/9) to DISA STIG and FIPS 140 Compliance


## Overview

The project tree has the following structure, each with their own README files.

> ***TODO:*** *This should be a table* - to be far more readable

* **`./elmedia0/bin/`** (see [./bin/](./bin/)) - Bash scripts, purposely under a `./bin`, for SELinux considerations (e.g., `# restorecon -Rv /opt/github/elmedia0/`)
* **`./elmedia0/bin/`** - Alternative, separate, external location (to the `elmedia0` project) location for the site-specific Custom Variables (`./bin/custom.vars`) that may be maintained in another repository (e.g., in GitLab, et al.), and is preferred over `./elmedia0/bin/custom.vars`
* **`./elmedia0/custom/` (see [./custom/](./custom/)) - Site-specific customiations to Boot Menu and Anaconda-Installer Kickstart, files/functions/includes
* **`./elmedia0.custom/custom/`** - Alternative, separate, external location (to the `elmedia0` project) location that may be maintained by users in another repository (e.g., in GitLab, et al.), and is preferred over `./elmedia0/custom/`
* **`./elmedia0/default/`** (see [./default/](./default/)) - Default elmedia0 [Boot Menu](./default/hardcode/) and Anaconda-Installer [Kickstart files/functions/includes](./default/ks/)  -- overridden by those files in `./elmedia0/custom/` (and `./elmedia0.custom/custom/`)
* **`./elmedia0/softdist/`** (see [./softdist/](./softdist/)) - A local, manually maintained repository of software distribution archive files, instead of storing on a centralized web server -- see the sections [Ansible](#ansible) and [Distribution](#distribution) -- for inclusion of Additional Packages (not in the base CentOS/Stream media), Ansible (e.g., 2.9 for EL7/8 install-time only) and Optional trees (i.e., under `/opt/`) on newly built systems, including Ansible DISA STIG playbooks
* **`./elmedia0/staging/`** (see [./staging/](./staging/)) - A temporary downloading/staging area of softawre distribution archive files when building that is **not** cleared after each execution (caches downloads/extractions from a web server or `./softdist/`)


## Quickstart

To begin building your first ISO or USB, reference the following syntax.

> **TIP:**  The script can be run from anywhere, and will auto-revolve it's parent and other directories to the tree is accessible.  It usually works with most symlinks for directories as well (have tested several scenarios).

``` console
$ ./bin/mkelmedia.sh

mkelmedia.sh - Make ISO or Populate VFAT-formatted USB for installing Enterprise Linux

mkelmedia.sh  iso|usb  [-f]  dst_dir  src_iso_mnt  [dst_lbl]

        iso|usb      Make ISO9660 Yellow Book Data Track (.iso) file *OR* Populate VFAT-formatted USB
        [-f]         [optional] Force full checksum (rsync) or overwrite (cp) of existing USB distribution
        dst_dir      Target DIR (destination directory) where to write ISO file or populate mounted USB device
        src_iso_mnt  Source DIR/ISO (mounted or contents copied to directory) of Enterprise Linux distro
        [dst_lbl]    [opt] ISO (default '[CR][7-9]ELMEDIA') and optional USB (reads) Label

Examples:
        mkelmedia.sh  iso  /tmp                          /run/media/bjs/RHEL-8-9-0-BaseOS_x86_64    [R8ELMEDIA]
        mkelmedia.sh  usb  /run/media/bjs/R8ELMEDIA      /run/media/bjs/RHEL-8-9-0-BaseOS_x86_64    [R8ELMEDIA]
        mkelmedia.sh  iso  /cygdrive/c/tmp               /cygdrive/d                                [R7ELMEDIA]         <== in Cygwin/MobaXterm
        mkelmedia.sh  usb  /cygdrive/f                   /cygdrive/d                                [C8ELMEDIA]         <== in Cygwin/MobaXterm
        mkelmedia.sh  iso  /c/tmp                        /d                                         [R7ELMEDIA]         <== in MinGW / Git bash
        mkelmedia.sh  usb  /f                            /d                                         [C8ELMEDIA]         <== in MinGW / Git bash
```

The positional paramters are as follows (**TODO:** need to adopt bash getopt).

1. **Type** (`iso`|`usb`) - ***BIOS/uEFI Bootable ISO***9660 Yellow Book image (`iso`) or native ***uEFI Bootable USB VFAT***-formatted (recommend FAT32 up to 128GiB/133GB) media (`usb`) -- 3.x for speed, 2.0 for older uEFI boot compatibility 
2. **Destination** (*dst_dir*) - the ***directory*** to build/output the ISO file (2x run-time storage is required, temporary and final ISO) or the ***mount*** where the USB media is already [auto-]mounted (it will read the USB label)
3. **Source** (*src_iso_mnt*) - the ***mount*** (including on loopback) where the bootable Enterprise Linux ISO media is located, or the ***directory*** where its contents have been copied

Optionally, an ISO or USB label may be passed as the fourth argument, but the USB label for the VFAT file system must match.  The script does read the existing label, so it usually does **not** need to be passed. Unfortunately, at this time, the script does not support changing the USB VFAT label in many environemnts (it can read, but not change).  A matching label, to the ISO or USB VFAT file system label, is required for the Boot Menu to work.

> **IMPORTANT:**  `mkelmedia.sh` has only been tested under GNU/Linux, various MinSys/MinGW solutions (e.g., Git Shell), various Cygwin solutions (e.g., MobaXterm, with added packages), and may or may not work under some WSL2 distributions and/or Powershell.

> **TIP:**  Ensure all text files are UTF-8 with CR/LF.  E.g., in Git, configure with with `autocflf` (`git config --global core.autocrlf 'input'`).  Not doing so will result in errors at `%pre` after boot of the media such as messages like *'file not found'* (the all-important Kickstart include files).


## Ansible

Ansible is used for automating several post-installation components.  These vary based on the Kickstart files/includes and are covered more in-depth in the [./elmedia0/default/](./default) documentation.

For EL9+, and even late EL8 releases, Ansible Core (`ansible-core`) is included in the media.  But some playbooks may require additional Ansible Community/Galaxy components.  Alternatively full Ansible (`ansible`) from EPEL maybe used, but then an Ansible package will need to be included.

> **IMPORTANT:**  EL9 support is still in its infancy, including the lack of DISA STIG Ansible Playbooks from US DoD CyberX, Ansible Lockdown on GitHub, et al.  So as of right now, only expect basic DISA STIG compliance with EL9 (e.g., file system layout and some required/removed packages).

For EL7 and, subsequently, EL8, Ansible 2.x was chosen, ultimately Ansible 2.9 by 2019 (thru 2023), because many Upstream and Government funded projects for EL8, and definitely EL7, built their Ansible playbooks around long-term (2019-2023) version 2.9.  It can be removed and/or upgraded to a newer `ansible-core` (e.g., in EL8) or full `ansible` (e.g., in EPEL8), but the modifications to the default Kickstart files/includes required may be non-trivial.

For more information on Ansible 2.9 in EL7/8, please see [Software Distribution - EL7 Ansible 2.9](./softdist/README.md#el7-ansible-29) and [Software Distribution - EL8 Ansible 2.9](./softdist/README.md#el8-ansible-29), respectively.  I.e., a tarball with a YUM repository (e.g., named `ansible.8-validated.tar`) will need to be dropped into the local Software Distribution directory (`./elmedia0/softdist/`) and/or put on a web server (which is defined in `custom.vars`).

> **IMPORTANT:**  Ansible 2.9 in EL7/8 is no longer maintained by Red Hat after 2023Q3.  However, for boot/installation-time support. `elmedia0` will continue to focus on Ansible 2.9, which can be upgraded post-install.  This may change in the future, as EL7 under ELS (2024Q3-2028Q2) becomes less and less used, and Ansible Core in EL8 more on-par to EL9 (and EL10 by 2025+).


## Distribution

*TODO/Complete*

See the [./elmedia0/softdist/](./softdist/) documentation for more on the local Software Distribution, as well as building tarballs of software components and support for post-install operations.


## History

Since 2001, I've been creating Red Hat Linux (RHL, now Fedora) Anaconda-installer Kickstart files, when I was first self-employed and has several clients using them.  They've actually been around since the very late '90s in RHL6, I believe RHL6.1 in '99 (but don't quote me).

Around 2005 -- please keep this date in mind when you look at the script and *'roll your eyes'* :) -- as a side project whlie self-employed for various clients I was engaged at, I started codifying an 'includes' approach, with a `%pre` section, to be more dynamic for Red Hat Enterprise Linux (RHEL) release 3 and 4 automated inatallations.

By 2007 -- when Red Hat hired me directly as a Senior Engagement Engineer (I joke I had the 'longest interview' process, 2005-2007) -- I had a notebook with a dedicated CardBus (later ExpressCard, and then just USB3) GbE that, when plugged in, bridged to the already running (on a disconnected bridge) DHCP service (that way the DHCP didn't go out anything except that dedicated card and its MAC) and served out a menu of various RHEL4/5 Kickstart options.  The highlight of one of my engagements was in 2008, where on a 2-week engagement, and Oracle consultant asked if I could have at least the base RHEL5 OS installed on all servers by the end of the first week.  I told him if I could plug my notebook into the switch, they'd all be up by lunch ... that was Monday, the first day.

Concurrently by 2008, another consultant developed one of the first DISA STIG remediations inside a Kickstart, using straight-forward shell code, for RHEL5.  That was my first exposure to STIGs, as I had been in financial for awhile (with a short stint at Boeing, plus a Satellite communcations provider) in the mid '00s.  I integrated these into my dynamic Kickstarts via include files.  I started making this more modular for myself, and other consulting engineers at Red Hat, including .  This is also when DeHaan's -- the future father of Ansible, and he has already created its precursor, the Fedora Unified Network Controler, FUNC -- Cobbler became popular for Kickstart snippets.  Eventually by 2010, Red Hat began employing a dedicated individuals (at least in Services) to address DISA STIG post-install.  Another client caused me to take it up for RHEL6+ STIG once more, as STIGs were getting more extensive

So by 2010-2011, I stopped maintaining my code, and would not revisit it until 2014-2015 at HP (during their illfated OpenStack investment, great code creation/stewardship for the greater community, poor execution on the customer side for early adoption, don't get me started) and then Red Hat (now a hourly contractor, or with various partners, et al.).  By then, ironic and other deployment mechanisms were being created (largely by HP), along with Ruby-based Puppet (or even older Perl-based cfengine, or newer Python-based bcfg2) and Cobbler/Koan was less used.  DeHaan himself had evolved FUNC into Ansible and had left Red Hat.

Which brings me to 2018+ ... and the decision to finally put this on GitHub when it became a major focus for 'airgap' environments (e.g., larger, closed optical media, or systems heading into an 'airgap' environment, so USB can be used) once again in 2021+.  It's massively expanded from its original purpose, and I'm still trying to integrate more options in, without much overhead required (but some will always be).

Please feel free to reach out to me with questions, as **not** everything is *'usable out of the box.'*  If anything, it will force me to write the documentation explaining it, as well as more *'helper scripts'* where required.


## Dedication

This project is dedicated to everyone who has ever helped me with the Anaconda-installer and Kickstart files, as well as orchestration solutions like Ansible.  Not that this pathetic piece of code would be used by him, but I dedicated any of my Kickstart, Cobbler, FUNC and, now, Ansible success to DeHaan, who I spent a fascinating number of hours with at Red Hat Summit / FUDCon 2008 (2008 Spring) in Boston, before a potential client engagement *'pulled me away.'*

One day I'm going to make a full list and put it here.

