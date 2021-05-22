# Void Linux  Notes

## After Installation Configuration {#after-install}

check contents of /var/service and remove uncessary ones. If running with static
IP ([Static Networking](#network-static)) then remove dhcpcd.

uncomment wheel line in `/etc/sudoers` using `visudo` to enable

**NOTE:** Locale does not exist on Musl libc editions of void.

### Timezone and Clock Configuration {#timezone-clock}

edit `/etc/rc.conf` as root (sudo doesn't work) and change the following lines:

```conf
HARDWARECLOCK="UTC"
TIMEZONE="America/Denver" # or appropriate timezone
KEYMAP="us"
```

enable NTP:

```sh
sudo ln -s /etc/sv/ntpd /var/service/
```

### Network Configuration {#network}

#### Static Networking {#network-static}

edit `/etc/rc.local` and add following commands.
Verify interface names are correct from ip link.

```sh
ip link set dev eth0 up
ip addr add 10.0.1.12/24 brd + dev eth0
ip route add default via 10.0.1.1
```

#### DHCP {#network-dhcp}

enable `dhcpcd` with

```sh
sudo ln -s /etc/sv/dhcpcd /var/service/
```

```tags
Void, Linux, Homelab, Setup
```
