> ***WARNING:*** *This README is not completed yet.  It will be drastically modified in the near future.*

# elmedia0 Software Distribution

This directory exists to create tarballs of, but not limited to, Additional Packages (not in the base CentOS/Stream media), Ansible (e.g., 2.9 for EL7/8 install-time only) and Optional trees (i.e., under `/opt/`) on newly built systems, including Ansible DISA STIG playbooks

## Overview

*TODO*


## Additional Packages

*TODO*


## Ansible 

> ***TODO:*** *This would be better summarized in a table*

The Ansible Core package (`ansible-core`) is included in the EL9, and latter EL8 Updates (e.g., RHEL8.7) installation media.  At this time, this package is not utilized.

The full Ansible package (`ansible`) was not included in the EL7/8 installation media, but is (or was) made avaialble in child channels.  At the time this solution was refactored for EL7 with Ansible, Ansible 2.x was used, with 2.9 being the long-term release (2019-2023).  This continued with EL8, especially since many existing DISA STIG and other Ansible Playbooks assume full Ansible, and often version 2.9, or require many Community/Galaxy modules be installed for Ansible Core.

If the Ansible package used is not included in the default EL media, a YUM repoistory with its packages and dependencies not included must be packaged into a tarball for deployment on the media (e.g., `./ansible.8-validated.tar`).  This tarball must be either located in the local Software Distribution directory (`./elmedia0/softdist/`), or located on a web server the script will pull from (i.e., as defined in the `custom.vars` file under `./elmedia0/bin/` or user-maintained `./elmedia0.custom/bin/`).

*TODO/finish*

### EL9 Ansible Options

*TODO*

### EL8 Ansible 2.9

Any vendor EL included Ansible Core (`ansible-core`) or EPEL downloaded full Ansible (`ansible`) usage for EL9 should apply to EL8 as well, including the modifications.  This section will solely focus on Ansible 2.9 from vendor EL8.

#### Common EL8

Instead of using Ansible from the Fedora Project's Extra Packages for Enterprise Linux (EPEL), we use the packages from the long-term, sustained (with backported security fixes, at least through 2023Q3) repositories for each release.

* *now archived* [CentOS Configuration Management (CM) / Ansible Special Interest Group (SIG) and their repositories (repos)](https://wiki.centos.org/SpecialInterestGroup/ConfigManagementSIG)
* *now redirects* [Red Hat Enterprise Linux 'Ansible Engine' repository (fka 'child channels') for each RHEL release](https://access.redhat.com/products/red-hat-ansible-engine/)

#### CentOS8

Required packages for CentOS [Stream] Ansible Support

* `ansible` - obviously
* `centos-release-ansible-XX` - CentOS CM/Ansible SIG Repo Support - Release XX (e.g., 29 for 2.9)
* `centos-release-configmanagement` - CentOS CM SIG Repo Support - prerequisite for the CM/Ansible SIG Repo - This package is in the main repos
* `sshpass` - required for ansible

Current packages from CentOS Main Repos and CM/Ansible SIG Repos.

* `ansible-2.9.27-1.el8.noarch.rpm`
* `centos-release-ansible-29-1-2.el8.noarch.rpm`
* `centos-release-configmanagement-1-1.el8.noarch.rpm`
* `sshpass-1.06-8.el8.x86_64.rpm`

> **TIP:** Unlike on RHEL, once the CM/Ansible repo packages are installed as part of the Kickstart from ISO/USB, the system is 'subscribed' to the CM/Ansible repositories.  No further action is required to get updates from CentOS, they will be updated with any `dnf` or `yum` command.


#### RHEL8

Required packages for RHEL Ansible Support.

* `ansible` - obviously
* `sshpass` - required for ansible

Current packages from RHEL Ansible Engine (note the `el8ae` 'disttag') Child Channel.

* `ansible-2.9.27-1.el8ae.noarch.rpm`
* `sshpass-1.06-3.el8ae.x86_64.rpm`

> **IMPORTANT:** A system needs to be subscribed to the 'ansible 2.9' repo/channel to receive updates.  These are not in the main RHEL repository.  E.g., `subscription-manager repos --enable ansible-2.9-for-rhel8-x86_64-rpms`

> **WARNING:** Red Hat no longer maintains Ansible 2.9 after 2003Q3, and it is strongly recommended the final packages be mirrored and maintained in a tarball for long-term usage through 2029.  Either that, or switch to Ansible Core or Ansible from EPEL, and modify accordinly. This project may commit to this change at some point as well, depending on DoD CyberX, Ansible Lockdown and/or other projects.


### EL7 Ansible 2.9

As EL8, instead of using Ansible from the Fedora Project's Extra Packages for Enterprise Linux (EPEL), we use the packages from the long-term, sustained (with backported security fixes, at least through 2023Q3) repositories for each release.

> **WARNING:**  RHEL7 and, therefore, CentOS7 are EoL after 2024Q2.  Extended Lifecycle Support (ELS) may extend this support through 2028Q2, but it's only a subset of packages. This is in addition to the updates only being for high, important or critical Security Errata (RHSA).

> **TIP:**  See the [Red Hat Enterprise Linux Life Cycle](https://access.redhat.com/support/policy/updates/errata) page for a full discussion of how long RHEL is maintained, along with the ELS option.

Instead of using Ansible from the Fedora Project's Extra Packages for Enterprise Linux (EPEL), we use the packages from the [CentOS Configuration Management (CM) / Ansible Special Interest Group (SIG) and their repositories (repos)](https://wiki.centos.org/SpecialInterestGroup/ConfigManagementSIG).  They match the long-term, sustained (with backported security fixes), dedicated Red Hat Enterprise Linux 'Ansible Engine' repositories (fka 'child channels') for each RHEL release.

* *now archived* [CentOS Configuration Management (CM) / Ansible Special Interest Group (SIG) and their repositories (repos)](https://wiki.centos.org/SpecialInterestGroup/ConfigManagementSIG)
* *now redirects* [Red Hat Enterprise Linux 'Ansible Engine' repository (fka 'child channels') for each RHEL release](https://access.redhat.com/products/red-hat-ansible-engine/)


#### CentOS7

Required packages for CentOS Ansible Support

* `ansible` - obviously
* `centos-release-ansible-XX` - CentOS CM/Ansible SIG Repo Support - Release XX (e.g., 29 for 2.9)
* `centos-release-configmanagement` - CentOS CM SIG Repo Support - prerequisite for the CM/Ansible SIG Repo - This package is in the main repos
* `sshpass` - required for ansible

Current packages from CentOS Main Repos and CM/Ansible SIG Repos.

* `ansible-2.9.27-1.el7.noarch.rpm`
* `centos-release-ansible-29-1-1.el6.noarch.rpm`
* `centos-release-configmanagement-1-1.el7.centos.noarch.rpm`
* `sshpass-1.06-2.el7.x86_64.rpm`

We are using Ansible 2.9, which is a well supported and sustained base version for most RHEL6-8 solutions, especially module compatibility.  E.g., 2.9 is largely feature-rich compared to older versions, but not too new that older modules have been deprecated.

> **TIP:** Unlike on RHEL, once the CM/Ansible repo packages are installed as part of the Kickstart from ISO/USB, the system is 'subscribed' to the CM/Ansible repositories.  No further action is required to get updates from CentOS, they will be updated with any `dnf` or `yum` command.

#### RHEL7

Required packages for RHEL Ansible Support.

* `ansible` - obviously
* `sshpass` - required for ansible

Current packages from RHEL Ansible Engine (note the `el7ae` 'disttag') Child Channel.

* `ansible-2.9.27-1.el7ae.noarch.rpm`
* `sshpass-1.06-2.el7.x86_64.rpm`

> **IMPORTANT:** A system needs to be subscribed to the 'ansible 2.9' repo/channel to receive updates.  These are not in the main RHEL repository.  E.g., `subscription-manager repos --enable ansible-2.9-for-rhel7-x86_64-rpms`


## DISA STIG






