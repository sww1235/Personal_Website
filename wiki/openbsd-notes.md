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


```tags
OpenBSD, Homelab, Setup
```
