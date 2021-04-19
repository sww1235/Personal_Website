<h1 id="top">Virtualization Cluster Configuration</h1>

Documentation on setup of virtualization cluster. Some info may be split into its own page.

Current status of cluster, is 3 Intel NUCs, each running Xen as a tier 1 hypervisor with FreeBSD as Dom0.


<h2 id="ind-host-setup">Individual Host Setup</h2>

<h3 id="bios-config">BIOS Configuration</h3>

1.	Boot system into BIOS by spamming `F2` key after pressing power button.

2.	Check that all RAM and CPU are properly detected on `Main` tab.

3.	Under `Advanced->Storage`: Disable SATA port since we are not using it.

4.	Under `Advanced->Onboard Devices`: Disable HD Audio, WLAN, Bluetooth,
	Gaussian Mixture Models, HDMI CEC Control, and Enable IOMMU during pre-boot

5.	Under `Advanced->Video`: Set IGD Primary Video Port to HDMI and enable
	`Virtual Display Emulation` under `Display Emulation`

6.	Under `Security`: Enable USB Provisioning of Intel AMT.

7.	Under `Power->Secondary Power Settings`: Change After Power Failure to
	Power On.

8.	Under `Boot->Secure Boot`: Disable Secure Boot

9.	Under `Boot->Boot Priority`: Enable Boot USB Devices First, and disable
	Boot Network Devices Last.

11.	Under `Boot->Boot Display Configuration`: Disable Suppress Alert
	Messages At Boot, and Enable F12 for network boot.

12.	Under `Main` Select System Time and Set BIOS clock to UTC time.

13.	Press F10 to save and Exit. On Reboot, press `CTRL-P` to get into Intel AMT configuration

<h3 id="amt-config">AMT Configuration</h3>

1.	Press `CTRL-P` at boot prompt to enter Intel AMT configuration.

2.	Hit `Enter` to login to AMT, with default password of `admin`. When
	prompted to enter new password, use password out of password manager.

3.	Under `Intel AMT Configuration->User Consent`: Change User Opt-in to NONE.

4.	Under `Intel AMT Configuration->Network Setup->Intel ME Network Name
	Settings`: Set hostname and domain to desired values. Leave
	Shared/Dedicated FQDN set to shared.

5.	Set static DHCP lease in DHCP server if not done already.

<h3 id="os-install">Install Operating System</h3>

1.	Download FreeBSD-bootonly ISO from reputable sources. Use this to reduce loading times

2.	Connect to system using Mesh Commander.

3.	Mount ISO using IDE-R, and select `Reset to IDE-R` in `Power Actions` menu.

4.	Let FreeBSD boot to the install menu. Don't exit out of the autoboot menu.

5.	Press enter to start the installation process.

6.	Proceed through installation wizard. Press space to select options.

	1.	Keymap = United States of America. Space will not work here, just
		scroll down and hit enter.

	2.	Enter hostname

	3.	Add the ports tree. Optionally, add the src tree (prior to multiboot2
		xen patch being included in a release version).

	4.	Hit Ok to configure network for installation.

	5.	Configure IPv4 and use DHCP

	6.	Confirm resolver config. (Defaults picked up from DHCP should be good
		to go.)

	7.	Select default (main) FreeBSD mirror.

	8.	Select Auto (UFS) and then Entire Disk.

	10.	Select GPT for partition scheme

	11.	Review autogen partition layout, which should be good for our usages
		then hit finish and Commit.

	12.	Wait for download, verification and extraction.

	13.	Enter root password from password manager.

	14.	Choose yes at CMOS clock prompt. Make sure this gets set in BIOS properly.

	15.	Choose timezone.

	16.	Skip time and date setup if it is correct.

	17.	Enable `local_unbound`, `sshd`, `ntpdate`, `ntpd`, `powerd` and `dumpdev` services
		to be started at boot

	18.	Enable all security options except `disable_syslogd`, and `secure_console`.

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

7.	Login as the new user you created

8.	Become root with `su -`. You will need root's password.

9.	Update system and install software

	```sh
	freebsd-update fetch
	freebsd-update install

	pkg update
	# answer yes to install pkg system
	pkg upgrade

	pkg install nano sudo
	```

10.	Configure sudo. `visudo` and uncomment line `%wheel ALL=(ALL) ALL`

11.	Setup system logging and disable sendmail:

	1.	Edit `/etc/rc.conf` and add the following lines to disable sendmail and enable syslog.
		```conf
		# disable sendmail and enable syslog
		syslogd_enable="YES"
		sendmail_enable="NO" # modify existing line
		sendmail_submit_enable="NO"
		sendmail_outbound_enable="NO"
		sendmail_msp_queue_enable="NO"
		newsyslog_enable="YES" # make sure this doesn't break in future defaults
		# fix cron trying to send mail
		cron_flags="-m ''"
		```

	2.	Create log files needed for next step:

		```sh
		sudo touch /var/log/console.log
		sudo chmod 600 /var/log/console.log
		sudo touch /var/log/all.log
		sudo chmod 600 /var/log/all.log
		```

	3.	Edit `/etc/syslog.conf` and uncomment the lines for `console.log` and
		`all.log`. TODO: setup remote logging.

	4.	Check `/etc/newsyslog.conf` to confirm log rotation is setup correctly.

	5.	Edit `/etc/periodic.conf` and add the following to the beginning of the
		file to disable sending root email and instead log to syslog. (This
		will override the defaults in `/etc/defaults/periodic.conf`)

		```conf
		# redirect periodic output to syslog files
		daily_output="/var/log/daily.log" # user or /file
		weekly_output="/var/log/weekly.log" # user or /file
		monthly_output="/var/log/monthly.log" # user or /file
		# turn off sendmail periodic functions
		daily_clean_hoststat_enable="NO"
		daily_status_mail_rejects_enable="NO"
		daily_status_include_submit_mailq="NO"
		daily_submit_queuerun="NO"
		```

	6.	Fix crontab logging by editing `/etc/crontab` and appending `2>&1 |
		/usr/bin/logger -t cron_xxx` and replacing xxx with whatever the cron
		command was doing. Do not need to do this for periodic and periodic
		snapshot sections.

12.	Random sysadmin tweaks:

	1.	Edit `/etc/periodic.conf` and include the following lines:

		```conf
		# never going to use locate on a fileserver
		weekly_locate_enable="NO"	#Disable weekly locate run.
		```

13.	Reboot


<h2 id="cluster-setup">Cluster Setup</h2>


```tags
cluster, virtualization, virt, NUC, xcp-ng
```
