## Static Networking Configuration

Set following variables in `/etc/rc.conf`
```
hostname = "hostname"
# this may change based on what the interface is called
ifconfig_re0 = "inet XXX.XXX.XXX.XXX netmask YYY.YYY.YYY.YYY"
defaultrouter = "ZZZ.ZZZ.ZZZ.ZZZ"
```

Set following variables in `/etc/resolv.conf`
```
nameserver QQQ.QQQ.QQQ.QQQ
```

## Install Basic Packages
```
pkg install sudo nano
```

### Configure Sudo
```
su
visudo
# uncomment line for wheel group

# add user to wheel group
pw group mod wheel -m username

# check this worked
id username
```
