<h1 id="top">Vault File Server Build Script</h1>

This is the build script for my main file server **The Vault**.

<h2 id="notes">Notes</h2>

F2 or Enter for BIOS, F11 for boot menu

<h2 id="build-script">Build Script</h2>

<h3 id=prereqs">Prerequisites</h3>

1.	Connect to IPMI interface of the server by going to $ip in a web browser.

<h3 id="initial-configuration">Initial Configuration</h3>

1.	Download the bootonly ISO of the current release of FreeBSD from reputable sources. (12.2 as of 11/07/2020)

2.	Enable cd/dvd instance in IPMI under Settings -> Media Redirection Settings -> VMedia Instance Settings

3.	Open up HTML5 viewer for IPMI, and attach ISO to virtual CD rom.

4.	Start server, and boot to UEFI CD rom.

5.	Let FreeBSD boot to the install menu. Don't exit out of the autoboot menu.

6.	Press enter to start the instllation process.

7.	Proceed through installation wizard. Press space to select options.
	
	1.	Keymap = United States of America. Space will not work here, just
		scroll down and hit enter.

	2.	Hostname = `the-vault`
	
	3.	Disable kernel-dbg system component, and add the ports tree.

	4.	Hit Ok to configure network for installation.

	5.	Select gigabit interface 0, or whatever is actually connected.

	6.	Configure IPv4 and use DHCP for now. We will configure static networking later.

	7.	Confirm resolver config. (Defaults picked up from DHCP should be good to go.)

	8.	Select mirror

	9.	Select Auto (UFS) and then Entire Disk.

	10.	Select GPT for partition scheme

	11.	Review autogen partition layout, which should be good for our usages
		then hit finish and Commit.

	12.	Wait for download, verification and extraction.

	13.	Enter root password from password manager.

	14.	Choose no at CMOS clock prompt. TODO: fix this.

	15.	Choose timezone.

	16.	Skip time and date setup if it is correct.

	17.	Enable `local_unbound`, `sshd`, `ntpd`, `powerd` and `dumpdev` services
		to be started at boot

	18.	Enable all security options except `disable_syslogd` , `secure_console`
		and `disable_sendmail`. Sendmail will be replaced later.

	19.	Add new admin user.
		
		1.	Username = `toxicsauce`
		2.	Full Name = `toxicsauce`
		3.	UID = (hit enter to accept default)
		4.	Login group = (hit enter to accept default)
		5.	Invite User to other groups = wheel
		6.	Login class = (hit enter to accept default)
		7.	Shell = sh (default)
		8.	home directory = (hit enter to accept default)
		9.	home directory permissions = (hit enter to accept defaults)
		10.	password auth = yes
		11.	empty password = no
		12.	random password = no
		13.	Enter password from password manager
		14.	lock account = no
		15.	check options and type in yes to confirm.
		16.	add additional users = no.
	
	20.	hit exit, and no to exit installer.
	
	21. Hit reboot.

	22.	Stop CD media after system has rebooted.

8.	Log in as the new user you created

9.	Become root with `su -`. You will need root's password.

10.	Change root's shell to `sh`: `chsh -s sh`

11.	Log out and su back in again

12.	Update system and install software

	```sh
	freebsd-update fetch
	freebsd-update install

	pkg update
	# answer yes to install pkg system 
	pkg upgrade

	pkg install nano sudo
	```

13.	Configure sudo. `visudo` and uncomment line `%wheel ALL=(ALL) ALL`

14.	Setup system logging

15.	Set up ssh-agent

16.	Create Projects directory tree in `~` as follows:

	```bash
	mkdir -p ~/projects/src/github.com/sww1235
	```

	This mirrors the structure of how golang wants to set things up.

17.	Make symlink in `~` as follows:

	```bash
	ln -s ~/projects/src/github.com/sww1235 myprojects
	```

18.	Clone dotfiles repo from GitHub using ssh and install vim and bash files using
	`install.sh` script.

19.	Clone projects from github into Projects tree as desired.

<h3 id="ups-config">UPS Configuration</h3>

1.	Install Network UPS Tools from packages. `sudo pkg install nut`

2.	Edit `/usr/local/etc/nut/upsmon.conf` and add in the following lines:

	```conf
	MONITOR cyberpower@$ipaddress 1 upsmonSlave $password slave
	```

3.	Edit `/etc/rc.conf` and add the following line:

	```conf
	nut_upsmon_enable="YES"
	```

4.	Start `nut_upsmon` service with `sudo service nut_upsmon start` and make
	sure it doesn't error out.

5.	Reboot system to make sure everything comes up normally.

6.	Run a shutdown test to make sure nut is working properly.

	1.	Login to `rack-monitor` system and run `upsdrvctl -t shutdown`. This
		will show you what will happen during a shutdown without actually
		shutting the systems down.

	2.	Now run the command `upsmon -c fsd`. This will simulate a power failure
		and send the shutdown signal to all connected machines before shutting
		down itself.
	
	3.	This should have worked, so now you need to manually remove power and
		apply power from all machines connected to the UPS to get them to come
		back up.

<h3 id="zfs-config">ZFS Configuration</h3>

<h3 id="filesharing">Fileshare Configuration</h3>


<h2 id="resources">Resources</h2>

-	<https://people.freebsd.org/~thierry/nut_FreeBSD_HowTo.txt>

```tags
build-script, main-ws-host, workstation, notes, QEMU, KVM, VFIO, Passthrough
```