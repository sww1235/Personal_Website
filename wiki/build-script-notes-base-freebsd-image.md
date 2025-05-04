# Base FreeBSD Machine Configuration

## Initial Installation {#initial-installation}

Proceed through installation wizard. Press space to select options.

1.	Keymap = US. This should be default. Space will not work here, just scroll
	down and hit enter.

2.	Enter hostname. (this is a FQDN)

3.	Remove all optional system components unless specified in other build script.

4.	Select Auto (ZFS) and use defaults unless specified in other build script.

5.	Wait for download, verification and extraction of distribution files

6.	Enter root password from password manager.

7.	Select main network interface.

8.	Configure Networking as [below](#networking)

9.	Choose yes at CMOS clock prompt. Make sure this gets set in BIOS properly.

10.	Choose timezone.

11.	Skip time and date setup if it is correct.

12.	Enable `sshd`, `ntpdate`, `ntpd`, `powerd` and `dumpdev` services to be
	started at boot

13.	Enable all security options except `clear_temp`, `disable_syslogd`, and
	`secure_console`.

14.	Install fw packages if prompted

15.	Add new admin user.

	1.	Username = `toxicsauce`
	2.	Full Name = `toxicsauce`
	3.	UID = (hit enter to accept default)
	4.	Login group = (hit enter to accept default)
	5.	Invite User to other groups = wheel
	6.	Login class = (hit enter to accept default)
	7.	Shell = sh (default)
	8.	home directory = (hit enter to accept default)
	9.	home directory permissions = (hit enter to accept defaults)
	10.	enable ZFS encryption = no (default)
	11.	password auth = yes
	12.	empty password = no
	13.	random password = no
	14.	Enter password from password manager
	15.	lock account = no
	16.	check options and type in yes to confirm.
	17.	add additional users = no.

16.	hit exit, and no to exit installer.

17.	Hit reboot.

## Configure Networking {#networking}

### Static Networking Configuration

This should already be set up during initial configuration. Included as a reference

Set following variables in `/etc/rc.conf`

```conf
# This is a FQDN
hostname = "hostname"
# this may change based on what the interface is called. Run ipconfig to determine what interface is needed
ifconfig_re0 = "inet XXX.XXX.XXX.XXX netmask YYY.YYY.YYY.YYY"
defaultrouter = "ZZZ.ZZZ.ZZZ.ZZZ"
```

Set following variables in `/etc/resolv.conf`

```conf
nameserver QQQ.QQQ.QQQ.QQQ
```

## Update System {#update-system}

1.	Login as the new user you created.
2.	Become root with `su -`. You will need root's password.
3.	Run the following commands.

```sh
freebsd-update fetch
freebsd-update install
pkg update
# answer yes to install pkg
pkg upgrade
```

## Install Basic Packages {#install-base-packages}

1.	Login as the new user you created.
2.	Become root with `su -`. You will need root's password.
3.	Run the following commands.

```sh
pkg install sudo nano
```

## Configure Sudo {#configure-sudo}

1.	Login as the new user you created.
2.	Become root with `su -`. You will need root's password.
3.	Configure sudo. `visudo` and uncomment line `%wheel ALL=(ALL) ALL`
4.	check if admin user is in `wheel` group. `id username`.
	- If not, add them to the group with the command: `pw group mod wheel -m username`

## Setup system logging and disable sendmail {#configure-logging-sendmail}

1.	Edit `/etc/rc.conf` and add the following lines to disable sendmail and enable syslog.

	```conf
	# disable sendmail and enable syslog
	syslogd_enable="YES"
	sendmail_enable="NO"
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
	file to disable sending root email and instead log to syslog. (This will
	override the defaults in `/etc/defaults/periodic.conf`). File may need to
	be created first.

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
	command was doing.  Do not need to do this for periodic and periodic
	snapshot sections.

## Set up ssh-agent {#ssh-agent}
