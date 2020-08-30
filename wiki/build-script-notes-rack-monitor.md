<h1 id="top">Rack Monitor Build Script and Notes</h1>

This is the build script and notes for the raspberry pi that monitors my Rack
and UPS.

<h2 id="notes">Notes</h2>

<h2 id="build-script">Build Script</h2>

<h3 id="initial-configuration">Initial Configuration</h3>

1.	Download the rpi2-musl image of void linux from reputable sources, currently
	[here](https://alpha.de.repo.voidlinux.org/live/current/)

2.	Burn image to MicroSD card using either `dd` or whatever windows tool is the
	popular thing and preferably doesn't use electron.

3.	Use `cfdisk` to expand main partition from 2GB to remaining size of MicroSD
	card.

4.	Login as root with default password of `void-linux`

5.	Need to get correct time and network set up in order to update system and
	install packages (as root) Remember that the only available text editor is
	`vi`!

	1.	Configure static IP address by editing `/etc/dhcpd.conf` with the
		following lines at the bottom of the file.  Actual IP addresses are
		found in the network documentation.  We use DHCP rather than manual
		`ip` commands in `/etc/rc.local` to take advantage of other aspects of
		DHCP including auto DNS server population and domain name.

		also uncomment ntp_servers option

		dns server is usually pfsense default gateway

		```conf
		interface eth0
		inform ip_address=$IPaddress
		static ip_address=$IPaddress
		static routers=$defaultgateway
		static domain_name_servers=$dnsserver
		```

	2.	edit `/etc/rc.conf` and change the following lines to set keymap and
		timezone:

		```conf
		TIMEZONE="America/Denver" # or appropriate timezone
		KEYMAP="us"
		```

	3.	Enable NTP and DHCP services:

		```bash
		ln -s /etc/sv/ntpd /var/service
		ln -s /etc/sv/dhcpcd /var/service
		```

	4.	Check `/etc/ntpd.conf` for constraints line, and comment out. This
		doesn't work on Raspi due to lack of HWCLK

	5.	Add `server $gateway` to `/etc/ntpd.conf` since it doesn't seem to pick
		it up from DHCP. NTP server will usually be the pfsense gateway, but
		use whatever machine is actually the NTP server

	6.	Create new non-root user, replacing $newusername with the actual name
		of the user. This command adds the user to the wheel group, which
		allows `sudo` access

		```bash
		useradd -m -s /bin/bash -U -G wheel,users,audio,video,cdrom,input $newusername
		```

	7.	Set system hostname by editing `/etc/hostname`

6.	Reboot the system using `reboot` command. This should allow DHCP and NTP to
	do their thing and allow us to update the system and install new packages.

7.	Log in as the new user you created

8.	Update the system by running the following command until there is no output.

	```bash
	sudo xbps-install -Svu
	```

9.	Install the following packages.


	```bash
	sudo xbps-install nano network-ups-tools rng-tools thefuck vim htop
	```

10.	Install terminfo package to fix issues with ssh

	```bash
	sudo xbps-install st-terminfo
	```

11.	Setup syslog daemon

	```bash
	sudo xbps-install socklog-void
	sudo ln -s /etc/sv/socklog-unix /var/service
	sudo ln -s /etc/sv/nanoklogd /var/service
	# so normal user can access logs
	sudo usermod -a -G socklog $USER
	```

<h3 id="nut-config">NUT Configuration</h3>

Config files for Network UPS Tool (NUT) are found at `/etc/ups/`

`nut.conf` has a few global config options, which are not important on void.

`ups.conf` is where you configure what UPSes the system will be interacting
with

`upsd.conf` is the configuration for the UPS data server

Configuration steps as follows:

1.	Edit `/etc/ups/nut.conf` and set `MODE=netserver`. This is not strictly
	required on void, but still better to set.

2.	Run `nut-scanner` to generate config options for attached UPSes

3.	Edit `/etc/ups/ups.conf` and add the results of `nut-scanner` to the
	begining of the file, except the vendor line. Add `[cyberpower]` before.
	See syntax examples in config file.

4.	Edit `/etc/ups/upsd.conf` and update listen directive to the IP address of
	the local system.

5.	Edit `/etc/ups/upsd.users` and add an `admin` user, and `upsmon` users with
	passwords from password safe. One `upsmon` user per machine connected to
	UPS.

	-	admin user has set actions and all instcmds
	-	upsmon user is set up per example in config file with slave attributes

Need to change ownership of config files on void linux as the default is set up
incorrectly:

```bash
sudo chown root:nut /etc/ups/*
sudo chmod 640 /etc/ups/*
```

start the following services:

 ```bash
sudo ln -s /etc/sv/upsdrvctl/ /var/service
sudo ln -s /etc/sv/upsd/ /var/service
```

check status of ups with the following command to make sure it is detected
properly

```bash
upsc cyberpower
```

```tags
build-script, rack-monitor, notes
```
