# Vault File Server Build Script

This is the build script for my main file server **The Vault**.

## Notes {#notes}

F2 or Enter for BIOS, F11 for boot menu

## Build Script {#build-script}

### Prerequisites {#prerequisites}

1.	Connect to IPMI interface of the server by going to $ip in a web browser.

	-	If this is first startup of system, then configure static IP for IPMI,
		and admin user and password.

### Initial Configuration {#initial-config}

1.	Download the bootonly ISO of the current release of FreeBSD from reputable
	sources. (12.2 as of 11/07/2020)

2.	Enable cd/dvd instance in IPMI under Settings -> Media Redirection Settings
	-> VMedia Instance Settings

3.	Open up HTML5 viewer for IPMI, and attach ISO to virtual CD rom.

4.	Start server, and boot to UEFI CD rom.

5.	Let FreeBSD boot to the install menu. Don't exit out of the autoboot menu.

6.	Press enter to start the installation process.

7.	Proceed through installation wizard. Press space to select options.

	1.	Keymap = United States of America. Space will not work here, just
		scroll down and hit enter.

	2.	Hostname = `the-vault`

	3.	Disable kernel-dbg system component, and add the ports tree.

	4.	Hit Ok to configure network for installation.

	5.	Select gigabit interface 0, or whatever is actually connected.

	6.	Configure IPv4 and use DHCP for now. We will configure static
		networking later.

	7.	Confirm resolver config. (Defaults picked up from DHCP should be good
		to go.)

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

8.	Log in as the new user you created

9.	Become root with `su -`. You will need root's password.

10.	Set up system as described in [base-freebsd-image-script](./build-script-notes-base-freebsd-image.md)

14.	Random sysadmin tweaks:

	1.	Edit `/etc/periodic.conf` and include the following lines:

		```conf
		# never going to use locate on a fileserver
		weekly_locate_enable="NO"	#Disable weekly locate run.
		```

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

### UPS Configuration {#ups-config}

1.	Install Network UPS Tools from packages. `sudo pkg install nut`

2.	Edit `/usr/local/etc/nut/upsmon.conf` and add in the following lines:

	```conf
	MONITOR cyberpower-ups1@$ipaddress 1 upsmonRemote $password secondary
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

### ZFS Configuration {#zfs-config}

Also see the [ZFS chapter of the FreeBSD
handbook](https://www.freebsd.org/doc/handbook/zfs.html)

The current vdev design is 6 identical disks running in a RAIDZ2
configuration. When the storage is expanded, a new group of 6 disks will be
added to a new vdev and added to the zpool.

vdev = group of drives. You cannot add more drives to a vdev once it is
created.

zpool = group of vdevs. Redundancy is given by vdev configuration, not by
multiple vdevs. if 1 vdev fails completely, **all** data in zpool is lost.

1.	Install `smartmontools` and `e2fsprogs` packages.

2.	If the hard drives are new, Test hard drives with `sudo badblocks -b 4096
	-wsv /dev/da* > da*.log`, replacing * with the number for each HDD. This
	will take a while depending on the size of the hard drives. TODO: add in
	instructions to import an existing pool.

3.	Add the following line to `/etc/rc.conf`, then start the service manually
	`sudo service zfs start` so you don't have to reboot.

	```conf
	zfs_enable="YES"
	```

4.	Add the following lines to `/boot/loader.conf` if they are not already
	there and reboot. This enables unique and static labels per disk, similar
	to `/dev/disk/by-id/` on linux.

	```conf
	geom_label_load="YES"
	kern.geom.label.disk_ident.enable="1"
	```

5.	Now create and configure the zpool and vdevs as follows:

	```sh
	# replace /dev/diskid/... with the names of the disks you are using in the zpool
	sudo zpool create the-vault raidz2 /dev/diskid/...
	# add any additional 6 disk sets
	sudo zpool add the-vault raidz2 /dev/diskid/...
	```

6.	Now create ZFS datasets as follows:

	```tags
	sudo zfs create -o compress=lz4 the-vault/backups
	sudo zfs create -o compress=lz4 the-vault/storage
	sudo zfs create -o compress=lz4 the-vault/media
	sudo zfs create -o compress=lz4 the-vault/archive
 	sudo zfs create -o compress=lz4 the-vault/vm-store
	```

7.	Install `freebsd-snapshot` from pkg.

8.	Edit `/etc/periodic.conf` and add the following lines:

	```conf
	daily_status_zfs
	```

9.	Edit `/etc/crontab` and include the following:

	```crontab

	# Perform hourly/daily/weekly maintenance (FreeBSD UFS2/ZFS snapshots only).
	0       *       *       *       *       root    /usr/local/sbin/periodic-snapshot hourly
	0       0       *       *       *       root    /usr/local/sbin/periodic-snapshot daily
	0       0       *       *       0       root    /usr/local/sbin/periodic-snapshot weekly
	```

10.	Edit `/etc/periodic.conf` and configure according to the datasets. Current config as below.

	```conf
	daily_scrub_zfs_enable="YES"
	snapshot_enable="YES"
	# :4:7:0 = 4 weekly snapshots (1 per week, and storing the last 4,
	# 1 per day and storing the last 7, and 0 per hour, storing the last 0.
	snapshot_schedule="/the-vault/backups:4:7:0 /the-vault/storage:4:7:0 /the-vault/media:2:3:0 /the-vault/archive:2:3:0 /the-vault/vm-store:4:7:0"
	```

### Backups Configuration {#backups-config}

Heavily borrowed from <https://blog.alt255.com/post/restic/>

1.	Install `restic` from pkgs.

2.	Create `/root/.restic/restic-password.sh` which exports `RESTIC_PASSWORD`
	set to the password of your repository. This is in password manager

3.	Create `/root/.restic/b2-credentials.sh` which exports `B2_ACCOUNT_ID` and
	`B2_ACCOUNT_KEY`. These are set up on backblaze's website.

4.	`su` to root and then run the following commands to initialize the repository.

	```sh
	. /root/.restic/b2-credentials.sh
	. /root/.restic/restic-password.sh
	# multiple repos can be in one bucket.
	# need to set up each repo individually
	# RESTIC_REPOSITORY=b2:bucketname:path/to/repo
	# path/to/repo is the path under the root of the bucket.
	# it does not affect which files will actually be backed up.

	export RESTIC_REPOSITORY=b2:the-vault-remote:archive
	restic init

	export RESTIC_REPOSITORY=b2:the-vault-remote:backups
	restic init

	export RESTIC_REPOSITORY=b2:the-vault-remote:media
	restic init

	export RESTIC_REPOSITORY=b2:the-vault-remote:storage
	restic init
	
 	export RESTIC_REPOSITORY=b2:the-vault-remote:vm-store
 	restic init
	```

5.	Initialize the first backups of the repositories. If you do not do this
	now, make sure to exit your root shell session to purge the environment
	variables.

	```sh
	# make sure to only run initial backups when we have enough bandwidth left
	export RESTIC_REPOSITORY=b2:the-vault-remote:archive
	restic backup --exclude-caches --exclude-if-present '.nobackup' /the-vault/archive

	export RESTIC_REPOSITORY=b2:the-vault-remote:backups
	restic backup --exclude-caches --exclude-if-present '.nobackup' /the-vault/backups

	export RESTIC_REPOSITORY=b2:the-vault-remote:media
	restic backup --exclude-caches --exclude-if-present '.nobackup' /the-vault/media

	export RESTIC_REPOSITORY=b2:the-vault-remote:storage
	restic backup --exclude-caches --exclude-if-present '.nobackup' /the-vault/storage

 	export RESTIC_REPOSITORY=b2:the-vault-remote:vm-store
 	restic backup --exclude-caches --exclude-if-present '.nobackup' /the-vault/vm-store
	```

6.	Create `/etc/periodic/daily/601.restic-backblaze-backups` with the following
	contents, and chmod it to 710, so only root can read and wheel can execute
	if need be.

	```sh
	#!/bin/sh

	# modified from script at <https://blog.alt255.com/post/restic/>

	# i18n, some files have non ASCII characters
	export LC_ALL=en_US.UTF-8

	# load credentials
	. /root/.restic/b2-credentials.sh
	. /root/.restic/restic-password.sh

	QUIET="--quiet"
	if [ -n "${NOQUIET}" ] || [ -n "${VERBOSE}" ]; then
		QUIET=""
	fi

	[ -z "${QUIET}" ] && echo "Starting backup set: archive"
	export RESTIC_REPOSITORY=b2:the-vault-remote:archive
	restic backup ${QUIET} \
		--exclude-caches \
		--exclude-if-present '.no-backup' \
		/the-vault/archive

	[ -z "${QUIET}" ] && echo "Starting backup set: backups"
	export RESTIC_REPOSITORY=b2:the-vault-remote:backups
	restic backup ${QUIET} \
		--exclude-caches \
		--exclude-if-present '.no-backup' \
		/the-vault/backups

	[ -z "${QUIET}" ] && echo "Starting backup set: media"
	export RESTIC_REPOSITORY=b2:the-vault-remote:media
	restic backup ${QUIET} \
		--exclude-caches \
		--exclude-if-present '.no-backup' \
		/the-vault/media

	[ -z "${QUIET}" ] && echo "Starting backup set: storage"
	export RESTIC_REPOSITORY=b2:the-vault-remote:storage
	restic backup ${QUIET} \
		--exclude-caches \
		--exclude-if-present '.no-backup' \
		/the-vault/storage

 	[ -z "${QUIET}" ] && echo "Starting backup set: vm-store"
	export RESTIC_REPOSITORY=b2:the-vault-remote:vm-store
	restic backup ${QUIET} \
		--exclude-caches \
		--exclude-if-present '.no-backup' \
		/the-vault/vm-store
	```

7.	Create `/etc/periodic/daily/600.restic-check` with the following contents,
	and chmod it to 710, so only root can read and wheel cna execute if need
	be.

	```sh
	#!/bin/sh

 	# i18n, some files have non ASCII characters
	export LC_ALL=en_US.UTF-8

	# load credentials
	. /root/.restic/b2-credentials.sh
	. /root/.restic/restic-password.sh
 	
	export RESTIC_REPOSITORY=b2:the-vault-remote:archive
	restic check

	export RESTIC_REPOSITORY=b2:the-vault-remote:backups
	restic check

	export RESTIC_REPOSITORY=b2:the-vault-remote:media
	restic check

	export RESTIC_REPOSITORY=b2:the-vault-remote:storage
	restic check
	```

8.	Configure snapshot policies and pruning. TODO

### Fileshare Configuration {#filesharing-config}

#### NFS

1. Run the following commands to enable the services required by the NFS server. The `mountd_enable` line is not technically required since it is forced by nfsd per [this link](https://muc.lists.freebsd.fs.narkive.com/9AJT6yVQ/bug-284262-nfsd-fails-to-start-with-nfsv4-server-only-but-without-rpcbind-mountd) but it doesn't hurt anything. You do not need `rpcbind` for nfsv4 only servers and clients.
   ```sh
   sysrc nfs_server_enable="YES"
   sysrc mountd_enable="YES"
   sysrc nfsv4_server_enable="YES"
   sysrc nfsv4_server_only="YES"
   sysrc nfs_server_flags="-t"
   sysrc nfsuserd_enable="YES"
   ```
2. Add `V4: /the-vault/` to `/etc/exports/`. This is the root directory of all zfs shares per [this link](https://kaeru.my/notes/nfsv4-and-zfs-on-freebsd)
3. Reboot after to launch services
4. run the following commands to set up the actual nfs shares:
	```sh
 	# sharing the vm-store to the management network only
 	zfs set sharenfs="-maproot=root,-network=10.4.0.0/20" the-vault/vm-store
 	```
 5.	Start the share without rebooting by running `sudo zfs share -a`

## Resources {#resources}

-	<https://people.freebsd.org/~thierry/nut_FreeBSD_HowTo.txt>

```tags
build-script, main-ws-host, workstation, notes, QEMU, KVM, VFIO, Passthrough
```
