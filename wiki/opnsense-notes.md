
## General

If the firewall is set up with only the WAN interface, the anti-lockout rule will be applied there. As soon as you add another interface (OPT1 or LAN), the anti-lockout rule will move automatically and silently in this order `WAN -> OPT1 -> LAN` with LAN interface as highest preference.

https://forum.opnsense.org/index.php?topic=22640.msg107727#msg107727

## Wireguard VPN


make sure to use /32s in the allowed IPs for the tunnel IPs.
