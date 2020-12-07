<h1 id="top">Networking Notes</h1>

Network reference file for my internal network.

<h2 id="content-guidelines">General Notes</h2>

Firewall rules on an `Interface Tab` in pfSense apply on an inbound direction on that interface. From the pfsense handbook: "This means traffic initiated from the LAN is filtered using the LAN interface rules. Traffic initiated from the Internet is filtered with the WAN interface rules."

to allow access from a interface to the internet, you must have a destination of `any`. If you want to block specific hosts from accessing the internet, you must have a block rule before the allow to any rule. Using the `WAN net` or `WAN address` shortcuts doesn't work, as it would only allow traffic to the network that the WAN interface is in, not the networks the wan interface can get to.

If you want to block specific hosts or networks from other networks, you need a block rule on the `Interface Tab` above the allow rules if the allow any rule is present.


```tags
Contributing, info
```
