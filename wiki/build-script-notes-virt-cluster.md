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

	3.	Add the ports tree.

	4.	Hit Ok to configure network for installation.

	5.	Configure IPv4 and use DHCP

	6.	Confirm resolver config. (Defaults picked up from DHCP should be good
		to go.)

	7.	Select default (main) FreeBSD mirror.

	8.	Select Auto (UFS) and then Entire Disk.

	9.	Select GPT for partition scheme

	10.	Review autogen partition layout, which should be good for our usages
		then hit finish and Commit.

	11.	Wait for download, verification and extraction.

	12.	Enter root password from password manager.

	13.	Choose yes at CMOS clock prompt. Make sure this gets set in BIOS properly.

	14.	Choose timezone.

	15.	Skip time and date setup if it is correct.

	16.	Enable `local_unbound`, `sshd`, `ntpdate`, `ntpd`, `powerd` and
		`dumpdev` services to be started at boot

	17.	Enable all security options except `disable_syslogd`, and `secure_console`.

	18.	Add new admin user.

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

	19.	hit exit, and no to exit installer.

	20. Hit reboot.

	21.	Stop CD media after system has rebooted.

7.	Login as the new user you created

8.	Become root with `su -`. You will need root's password.

9.	Update system and install software

	```sh
	freebsd-update fetch
	freebsd-update install

	pkg update
	# answer yes to install pkg system
	pkg upgrade

	pkg install nano sudo vim-console
	```

10.	Configure sudo. `visudo` and uncomment line `%wheel ALL=(ALL) ALL`

11.	Setup system logging and disable sendmail:

	1.	Edit `/etc/rc.conf` and add the following lines to disable sendmail and
		enable syslog.

		```conf
		# disable sendmail and enable syslog
		syslogd_enable="YES"
		newsyslog_enable="YES" # make sure this doesn't break in future defaults
		sendmail_enable="NO" # modify existing line
		sendmail_submit_enable="NO"
		sendmail_outbound_enable="NO"
		sendmail_msp_queue_enable="NO"
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
		# never going to use locate on a virtualization host
		weekly_locate_enable="NO"	#Disable weekly locate run.
		```

13.	Reboot


<h2 id="cluster-setup">Cluster Setup</h2>

1.	Before UEFI support for XEN is merged in a freebsd release version, need to
	fetch and compile from source. Wait until commit `97527e9c4fd37140` is
	merged into master before removing these instructions and running on
	release version.

2.	Run the following commands as root to build and install FreeBSD from source

	```sh
	git clone --branch releng/10.3 https://git.FreeBSD.org/src.git /usr/src
	cd /usr/src/
	make buildworld && make buildkernel
	make installkernel
	shutdown -r now
	cd /usr/src/
	make installworld
	shutdown -r now
	```

3.	Once the reboots have completed, need to merge config files, and check for
	outdated libraries. Run as root.

	```sh
	etcupdate diff # to see what changed in settings
	etcupdate # to automagically merge changes
	etcupdate resolve # if needed to resolve any changes that couldn't be merged automatically
	cd /usr/src/
	make check-old # obsolete files or directories
	make delete-old
	make check-old-libs # obsolete libraries
	make delete-old-libs
	shutdown -r now
	```

4.	Finally start installing Xen. All commands run as root.

	1.	sudo pkg install xen-kernel xen-tools. May have to regenerate pkg database

	2.	add the line `vm.max_user_wired=-1` to `/etc/sysctl.conf`

	3.	add the line `xc0     "/usr/libexec/getty Pc"         xterm   onifconsole  secure` to `/etc/ttys`

	4.	edit `/boot/loader.conf` and add the following lines for 2G memory and 1vCPU core dom0:

		```conf
		if_tap_load="YES"
		xen_kernel="/boot/xen"
		xen_cmdline="dom0_mem=2048M dom0_max_vcpus=1 dom0=pvh com1=115200,8n1 guest_loglvl=all loglvl=all console=vga,com1"
		boot_multicons="YES"
		boot_serial="YES"
		console="commconsole,vidconsole"
		```
	5.	run the following commands:
		```sh
		sysrc xencommons_enable=yes
		sysrc closed_interfaces="bridge0"
		sysrc ifconfig_bridge0="addm em0 SYNCDNCP"
		sysrc ifconfig_em0="up"
		```
	6.	Reboot system

```tags
cluster, virtualization, virt, NUC, xcp-ng
```
