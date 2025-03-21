# Base FreeBSD Machine Configuration

## Configure Networking

### Static Networking Configuration

Set following variables in `/etc/rc.conf`
```
hostname = "hostname"
# this may change based on what the interface is called. Run ipconfig to determine what interface is needed
ifconfig_re0 = "inet XXX.XXX.XXX.XXX netmask YYY.YYY.YYY.YYY"
defaultrouter = "ZZZ.ZZZ.ZZZ.ZZZ"
```

Set following variables in `/etc/resolv.conf`
```
nameserver QQQ.QQQ.QQQ.QQQ
```

## Update System

```sh
freebsd-update fetch
freebsd-update install
pkg update
# answer yes to install pkg
pkg upgrade
 ```


## Install Basic Packages
```
pkg install sudo nano
```

## Configure Sudo

Configure sudo. `visudo` and uncomment line `%wheel ALL=(ALL) ALL`

check if admin user is in `wheel` group. `id username`.

If not, add them to the group with the command: `pw group mod wheel -m username`

## Setup system logging and disable sendmail:

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
		file to disable sending root email and instead log to syslog. (This
		will override the defaults in `/etc/defaults/periodic.conf`). File may need to be created first.

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
6. Fix crontab logging by editing `/etc/crontab` and appending `2>&1 | /usr/bin/logger -t cron_xxx` and replacing xxx with whatever the cron command was doing. Do not need to do this for periodic and periodic snapshot sections.

## Set up ssh-agent
