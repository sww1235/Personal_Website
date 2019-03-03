<h1 id="top">Void Linux  Notes</h1>


<h2 name="after-install">After Installation Configuration</h2>

check contents of /var/service and remove uncessary ones. If running with static
IP ([Static Networking](#network-static)) then remove dhcpcd.

uncomment wheel line in `/etc/sudoers` using `visudo` to enable

**NOTE:** Locale does not exist on Musl libc editions of void.

<h3 name="timezone-clock">Timezone and Clock Configuration</h3>

edit `/etc/rc.conf` as root (sudo doesn't work) and change the following lines:

```
HARDWARECLOCK="UTC"
TIMEZONE="America/Denver" # or appropriate timezone
KEYMAP="us"
```

enable NTP:

```sh
sudo ln -s /etc/sv/ntpd /var/service/
```

<h3 name="network">Network Configuration</h3>

<h4 name="network-static">Static Networking</h4>

edit `/etc/rc.local` and add following commands.
Verify interface names are correct from ip link.

```sh
ip link set dev eth0 up
ip addr add 10.0.1.12/24 brd + dev eth0
ip route add default via 10.0.1.1
```


<h4 name="network-dhcp">DHCP</h4>

enable dhcpcd with

```sh
sudo ln -s /etc/sv/dhcpcd /var/service/
```

```tags
Void, Linux, Homelab, Setup
```
