<h1 id="top">OpenBSD  Notes</h1>


<h2 id="doas">Doas Configuration</h2>

see doas.conf(5) for more details.

This is a base configuration for all openBSD systems I use.

rules work in a **last match** manner.

```
permit persist :wheel
permit nopass keepenv root # allow root to do whatever
permit :wheel cmd reboot # relist command to ensure password is needed.
permit :wheel cmd halt
permit :wheel cmd poweroff
```
this can be further customized based on need.

sourced from openbsd doas mastery.

<h2 id="power">Power Management</h2>

poweroff/shutdown gracefully shutdown system

reboot/halt kill system immediately

<h2 id="ports">Ports Usage</h2>

most systems will be running release versions of openBSD

use packages unless ports are needed. If ports are needed use `-stable` in order
to get security fixes from `-current` tree.

add the following to `/etc/mk.conf`

```sh
PORTS_PRIVSEP=YES
WRKOBJDIR=/usr/obj/ports
DISTDIR=/usr/distfiles
PACKAGE_REPOSITORY=/usr/packages
```

create the directories above then change ownership to local user and group, make sure they are world readable.

also following commands:

```sh
mkdir -p ports src
cngrp wsrc ports src
chmod 775 ports src
```

add the following lines to `doas.conf` and add `SUDO=doas` to `/etc/mk.conf`

```doas
permit keepenv nopass toxic as _pbuild
permit keepenv nopass toxic as _pfetch
```

add user to `wsrc` group: `doas usermod -G wsrc toxic`.

Also add

download stable ports branch from anonCVS:

```sh
cd /usr
cvs -qd anoncvs@anoncvs3.usa.openbsd.org:/cvs checkout -rOPENBSD_6_4 -P ports
```

to update after initial clone:

```sh
cd /usr/ports
cvs -q up -Pd -rOPENBSD_6_4
```

default shell is `ksh`. Configuration goes in `.profile`


```tags
OpenBSD, Homelab, Setup
```
