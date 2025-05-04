# Rack Monitor Build Script and Notes

This is the build script and notes for the Dell Wyse 5070 that monitors my Rack
and UPS.

## Notes {#notes}

## Build Script {#build-script}

### Initial Configuration {#initial-config}

1.	Download the most recent memstick version of FreeBSD from reputable sources, currently
	[here](https://download.freebsd.org/releases/ISO-IMAGES/)

2.	Burn image to MicroSD card using either `dd` or whatever windows tool is the
	popular thing and preferably doesn't use electron.

3.	Boot to USB stick using `F12` key.

4.	Follow installer instructions. A Few notes:
	-	Remember that hostname needs to be a FQDN
	-	Only install base system, no optional components
	-	Guided Root on ZFS
		-	Can usually use GPT and default partition configuration

5.	Set root password at prompt

6.	Configure Networking
	1.	Select correct interface
	2.	Select `Use IPv4`
	3.	Select `No` to not use DHCP
	4.	Enter networking information when prompted
	5.	For now, select `No` to not configure IPv6. This may change in future TODO
	6.	Enter DNS info in the DNS configuration

7.	Proceed through remainder of installer until service enablement

8.	Enable the following services:
	-	`sshd`
	-	`ntpd`
	-	`ntpd_sync_on_start`
	-	`powerd`
	-	`dumpdev`

9.	Enable the following hardening options
	-	`hide_uids`
	-	`hide_gids`
	-	`hide_jail`
	-	`read_mesgbuf`
	-	`proc_debug`
	-	`random_pid`

10.	Create new non-root user when prompted. Make sure to invite into `wheel` group. Most options can be left default.

11.	Select `no` when prompted, as we don't want to add more users after the main admin non-root user.

12.	If you need to fix anything do so now, else select `EXIT` to apply the configuration.

13.	No need to make any manual changes so selecte `No`.

14.	Reboot the system when prompted.

### Basic configuration {#basic-config}

1.	Log in as the new user you created during inital configuration.
2.	Follow the steps included in
	[base-freebsd-config](./build-script-notes-base-freebsd-image) to establish
	baseline
3.	Install the following additional packages:

	```sh
	pkg install nut
	```

### NUT Configuration {#nut-config}

Always check the installation and configuration instructions online if anything
new has changed during updates to NUT.

Thanks to [this
blog](https://vermaden.wordpress.com/2025/03/06/ups-on-freebsd/) for help
setting up the new 2.8.X version of NUT on FreeBSD, including the fact that you
need to enable and start a service.

Config files for Network UPS Tool (NUT) are found at `/usr/local/etc/nut/`

`nut.conf` has a few global config options.

`ups.conf` is where you configure what UPSes the system will be interacting
with

`upsd.conf` is the configuration for the UPS data server

Configuration steps as follows:

1.	Edit `/etc/ups/nut.conf` and set `MODE=netserver`.

2.	Run `nut-scanner` to generate config options for attached UPSes

3.	Edit `ups.conf` and add the results of `nut-scanner` to the
	begining of the file, except the vendor line. Add `[cyberpower-ups1]` before.
	See syntax examples in config file.

4.	Edit `upsd.conf` and update listen directive to the IP address of
	the local system with standard port.

5.	Edit `upsd.users` and add an `admin` user, `upsmonLocal` and
	`upsmonRemote` users with passwords from password safe.

	-	`admin` user has set actions and all instcmds.

		```conf
		[admin]
			password = $password
			actions = SET
			instcmds = ALL
		```

	-	`upsmonLocal` user is set up  with primary attributes for local monitoring.

		```conf
		[upsmonLocal]
			password = $password
			upsmon primary
		```

	-	`upsmonRemote` user is set up  with secondary attributes for remote monitoring by other clients.

		```conf
		[upsmonRemote]
			password = $password
			upsmon secondary
		```

6.	Edit `upsmon.conf` to set up local UPS monitoring. Add the
	following lines to the config file.

	```conf
	# local system has 1 power supply connected to this UPS. It is primary
	# because it is the monitoring system for the ups.
	# other systems will be listed as secondary
	MONITOR cyberpower-ups1@localhost 1 upsmonLocal $password primary
	# all other values can be left as defaults for now
	```

7.	Restart `devd` so automatically generated rules are applied. `service devd restart`

8.	Make sure the correct USB device is owned by group `nut` when running `ls -l /dev/usb`


9.	Enable `nut` service with `service nut enable` and then start it: `/usr/local/etc/rc.d/nut start`


check status of ups with the following command to make sure it is detected
properly

```bash
upsc cyberpower-ups1
```

```tags
build-script, rack-monitor, notes, ups
```
