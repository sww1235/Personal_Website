<h1 id="top">Homelab Setup Notes</h1>


<h2 name="overview">Overview</h2>

Currently, my homelab consists of the following systems:

-   [Brian](#brian)
-   [Stephenpi](#stephenpi)
-   [Main Workstation Host](#ws-host)
-   [Windows 10 VM](#vm-win10)
-   [PfFirewall](#pffirewall)
-   [Den1](#den1)

My website and DNS are hosted through NearlyFreeSpeech.net

<h2 name="future-plans">Future Plans</h2>

-   Move fileserver duties from main workstation to dedicated FreeNAS file
server with ZFS
-   Migrate to 10Gb networking
-   Add UPS
-   Upgrade brian
-   Setup pfsense box at parents house
-   Setup reciprocal offsite backups at parents house.

<h2 name="far-future-plans">Far Future Plans</h2>

-   All servers either run OpenBSD or FreeBSD unless specific exception is
needed.
-   Package caching servers used for all 3rd party binary packaging systems in
use in homelab
-   All computers run custom linux image, probably a modified version of void
linux
-   All linux software (including kernel) is compiled from source, targeting
different architectures as necessary.
-   All source code for compiled software is kept in an archive as long as that
version is installed in a production or testing environment, and minimally for
a period of 1 year if it has been installed.
    -   If software is not updated, then keep most complete version. clone git
		repo if possible.
-   As much as possible, all images use musl libc or derivative.
-   Use automated continuous integration process for new software versions
    -   For all software, try to automatically pull down new releases of
		software and build in testing environment. Send weekly email of successes
		and failures.
    -   Software is manually pushed into production using automation similar to
		Ansible.
-   Ideally I would be able to take a stock OpenBSD image, clone some setup
scripts, and be able to build images for the rest of the server infrastructure,
then install them using a network boot server. This would have a temporary DHCP
and DNS server, along with a firewall and router config based on pf, to allow
the network to exist without any other infrastructure. This would be easily
disabled during the initial script options, as well as after the fact.

<h2 name="brian">Brian</h2>

Brian, (name subject to change), is currently intended to be my main
authentication server, running a combination of Kerberos and openLDAP.

**Hardware:** Ancient Mac Mini

**Software:** stock OpenBSD without any x11 crap

<h2 name="stephenpi">Stephenpi</h2>

This currently only runs an IRC client in tmux. It might do some automation type
stuff later.

**Hardware:** Raspberry Pi 2B V1.1

**Software:** Musl Void Linux for ARM

<h2 name="ws-host">Main Workstation Host</h2>

This acts a both a vm host using kvm/qemu, and a file server with a btrfs pool
shared over SAMBA.

**Hardware:** 

**Software:** Musl Void Linux for ARM

<h3 name="vm-win10">Primary Windows 10 VM</h3>

<h2 name="pffirewall">PfFirewall</h2>

<h2 name="den1">Den1</h2>

```tags
Homelab, Documentation
```
