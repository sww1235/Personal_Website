<h1 id="top">Homelab Setup Notes</h1>


<h2 id="overview">Overview</h2>

Currently, my homelab consists of the following systems:

-   [Brian](#brian)
-   [Stephenpi](#stephenpi)
-   [Main Workstation Host](#ws-host)
-   [Windows 10 VM](#vm-win10)
-   [PfFirewall](#pffirewall)
-   [Den1](#den1)

My website and DNS are hosted through NearlyFreeSpeech.net

<h2 id="future-plans">Future Plans</h2>

-   Move fileserver duties from main workstation to dedicated FreeNAS file
server with ZFS
-   Migrate to 10Gb networking
-   Add UPS
-   Upgrade brian
-   Setup pfsense box at parents house
-   Setup reciprocal offsite backups at parents house.

<h2 id="far-future-plans">Far Future Plans</h2>

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

<h2 id="hosts">Hosts</h2>

<h3 id="brian">Brian</h3>

Brian, (name subject to change), is currently intended to be my main
authentication server, running a combination of Kerberos and openLDAP.

**Hardware:** Ancient Mac Mini

**Software:** stock OpenBSD without any x11 crap

<h3 id="stephenpi">Stephenpi</h3>

This currently only runs an IRC client in tmux. It might do some automation type
stuff later.

**Hardware:** Raspberry Pi 2B V1.1

**Software:** Musl Void Linux for ARM

<h3 id="ws-host">Main Workstation Host</h3>

This acts a both a vm host using kvm/qemu, and a file server with a btrfs pool
shared over SAMBA.

**Hardware:**

[PCPartPicker part list](https://pcpartpicker.com/list/zpwFbX) / [Price breakdown by merchant](https://pcpartpicker.com/list/zpwFbX/by_merchant/)

|Type|Item|
|:--------|:------------------------------------------------------------------|
| **CPU** |Intel - Core i3-8350K 4 GHz Quad-Core Processor|
| **CPU Cooler** |Noctua - NH-D9L 46.44 CFM CPU Cooler|
| **Motherboard** |ASRock - Fatal1ty Z370 Gaming K6 ATX LGA1151 Motherboard|
| **Memory** |Corsair - Vengeance LPX 16 GB (2 x 8 GB) DDR4-2133 Memory|
| **Storage** |Samsung - 970 Pro 512 GB M.2-2280 Solid State Drive|
| **Storage** |Western Digital - Red Pro 2 TB 3.5" 7200RPM Internal Hard Drive|
| **Storage** |Western Digital - Gold 2 TB 3.5" 7200RPM Internal Hard Drive|
| **Storage** |Western Digital - Gold 4 TB 3.5" 7200RPM Internal Hard Drive|
| **Video Card** |EVGA - GeForce GTX 1060 6GB 6 GB SC GAMING Video Card|
| **Power Supply** |Corsair - HX Platinum 750 W 80+ Platinum Certified Fully-Modular ATX Power Supply|
| **Case Fan** |Noctua - NF-A8 PWM 32.66 CFM 80mm Fan|
| **Case Fan** |Noctua - NF-A12x25 PWM 60.1 CFM 120mm Fan|
| **Other** |Old Rackmount Case|


**Software:** Musl Void Linux for x86_64

<h4 id="vm-win10">Primary Windows 10 VM</h4>

Runs windows 10 for gaming and windows only applications.

<h3 id="pffirewall">PfFirewall</h3>

Primary firewall and router for local network. Runs OpenVPN client connected to
the server running on [Den1](#den1).

**Hardware:** SG-2220 pfSense appliance from Netgate

**Software:** pfSense

<h3 id="den1">Den1</h3>

OpenVPN server and jump box. VPS from Mean Servers in Denver

**Hardware:** Mean Servers VPS

**Software:** pfSense Community Edition

```tags
Homelab, Documentation
```
