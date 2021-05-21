# Lenovo Laptop Build Script

This is the build script and notes for my Lenovo T490 laptop.

## Notes {#notes}

## Build Script {#build-script}

### Initial Configuration {#initial-configuration}

Laptop will start from factory with preinstalled Windows 10 Pro + bloatware.
Reimage then setup dual booting.

#### Windows Installation {#windows-installation}

1.  Download a copy of Windows 10 Pro from Microsoft

2.	Create bootable USB stick using instructions on Microsoft website.

3.	Disable fast boot in preinstalled windows.

	1.	Go to Settings -> System -> Power & Sleep -> Additional Power Settings
		-> Choose What Power Buttons Do -> Change settings that are currently
		unavailable

	2.	Uncheck "Turn on Fast Startup". This prevents skipping the BIOS screen.

4.	Verify BIOS is set to allow booting from USB sticks. Also verify that BIOS
	is only set to UEFI mode

5.	Make sure laptop does not have an internet connection. This allows for the
	creation of a local user account without a Microsoft account.

6.	Insert USB stick and boot. Hit enter to interrupt startup, then select USB
	stick as boot drive.

7.	Start windows install process. Select Language, Time and Keyboard options
	then press next.

8.	Click Install Now.

9.	Accept Terms and Conditions

10.	Select Custom: Install Windows Only.

11.	Wipe out all existing partitions on the main SSD, then create the following:

	-	A main 120GB partition for windows
	-	A 500GB partition for passthrough between Windows and Linux OS installs.

	Leave the remaining space unpartitioned. This will be partitioned during the
	linux install.

	These will both be NTFS. Windowe will create additional partitions at the
	beginning of the partition list for recovery ETC.

12.	Select the 120GB partiton to install windows on.

13.	Wait for several reboots

14.	Select Customize Settings option on Express Settings Prompt.

15.	Turn off all Privacy and tracking options

16.	When prompted to create an account, click join a Domain and follow prompts
	to create a local account.

17.	After setup is finished, uninstall all apps that can be uninstalled, and
	clean up the start menu.

18.	Install Lenovo Vantage from Lenovo's website and make sure BIOS and
	drivers are installed and up to date. (Especially important for
	Thunderbolt devices)

#### rEFInd Installation {#refind-installation}

Install rEFInd boot manager. These steps are shamelessly reappropriated and
modified from <https://rodsbooks.com/refind/installing.html#windows>

1.	Download rEFInd as a binary ZIP file from reputable sources, currently:
	<https://rodsbooks.com/refind/getting.html>

2.	Unzip the file in a place you can find it. Usually Desktop or Downloads is
	best.

3.	Open an Administrator Command Prompt.

4.	Type `mountvol S: /S` in the Administrator Command Prompt window. This
	makes the ESP accessible as drive S: from that window. (You can use a drive
	identifier other than S: if you like.)

5.	Use `CD` command to change into the main rEFInd package directory, so that
	the refind subdirectory is visible when you type dir.

6.	Type `xcopy /E refind S:\EFI\refind\` to copy the refind directory tree to
	the ESP's EFI directory. If you omit the trailing backslash from this
	command, xcopy will ask if you want to create the refind directory. Tell it
	to do so.

7.	Type `S:` to change to the ESP. (This changes which drive is active in
	Command Prompt)

8.	Type `cd EFI\refind` to change into the refind subdirectory.

9.	Delete the `drivers_ia32`, `refind_ia32.efi`, `tools_ia32`, `drivers_aa64`,
	`refind_aa64.efi` and `tools_aa64` files and directories using the `DEL`
	command. Unnecessary drivers will slow the rEFInd start process.

10.	Type `rename refind.conf-sample refind.conf` to rename rEFInd's
	configuration file.

11.	Type `bcdedit /set "{bootmgr}" path \EFI\refind\refind_x64.efi` to set
	rEFInd as the default EFI boot program. Note that "{bootmgr}" is
	entered as such, including both the quotes and braces ({}).

12.	Type `bcdedit /set "{bootmgr}" description "rEFInd description"` to set a
	description (change rEFInd description as you see fit).

Now, when the laptop is rebooted, rEFInd should present itself with an option
to boot into windows 10.

#### Void Linux Installation {#void-linux-installation}

1.	Download a copy of `void-live-x86_64-date.iso` from reputable sources,
	currently: <https://alpha.de.repo.voidlinux.org/live/current/>.

2.	Create bootable USB stick using `dd` or whatever windows tool is the
	popular thing and preferably doesn't use electron.

3.	Login to live environment as `root` with password `voidlinux`.

4.	Verify system is booted in UEFI mode by verifying the presence of the
	`/sys/firmware/efi/` directory.

5.	run `void-installer` to start the installation wizard.

6.	Specify the `us` keymap.

7.	Select DHCP.

8.	Select install from network.

9.	Set hostname to `the-machine`.

10.	Set Locale to `en_US.UTF-8`.

11.	Set timezone to local timezone.

12.	Set root password to the one stored in password database.

13.	Set up normal user account based on password database.

14.	Select `none` for bootloader since rEFInd was installed earlier.

15.	Create an `Linux filesystem` partition out of the remaining space on disk
	and write the partition map to disk. Make note of the partition names and
	filesystems for the next step.

16.	Proceed through all partitions and set mount points as follows:

	-	Do not set mount points for the `Windows recovery partion`, or the
		`Microsoft reserved` partition.

	-	Set the `EFI System` partition filesystem to `vfat` and the mount point
		to `/boot/efi`.

	-	Set the 500GB `Microsoft basic data` partition to filesystem `ntfs` and
		mountpoint `/mnt/passthrough`.

	-	Set the ~1.3TB `Linux filesystem` partition to filesystem `ext4` and
		mountpoint `/`.

17.	Review settings and install. This will take a while.

18.	Reboot and select Void Linux at rEFInd prompt.

#### Void Linux Configuration {#void-linux-config}

1.	Login to newly installed Void Linux using root account and password found in
	password database. This is due to the fact that we haven't configured sudo
	yet.

2.	Configure `sudo` to allow full access to members of `wheel` group. Run
	`visudo` and uncomment the line

	```sudo
	#%wheel ALL=(ALL) ALL
	```

3.	Enable NTP and DHCP services

	```bash
	ln -s /etc/sv/ntpd /var/service
	ln -s /etc/sv/dhcpcd /var/service
	```

4.	Create `passthrough` folder under `/mnt/` to allow passthrough partition to
	mount correctly.

5.	Update system by running command `xbps-install -Svu` until it shows no
	updates.

6.	Install ntfs driver.

	```bash
	xbps-install ntfs-3g
	```

7.	Reboot system and login as normal user.

8.	Enable trim on SSD by editing `/etc/fstab` and adding `,discard` after the
	defaults line on the `/` and `/mnt/passthrough` mountpoints.

9.	Install and remove the following packages. Want to use simpler NTP
	implementation.

	```bash
	sudo xbps-install nano openntpd rng-tools thefuck vim htop socklog
	sudo xbps-remove chrony
	```

10.	Install commonly used applications.

	```bash
	sudo xbps-install firefox freecad git glow kicad lynx netcat p7zip powertop
	rsync tmux unzip wget zip
	```

11.	Setup system logging using socklog

	```bash
	sudo xbps-install socklog-void
	# enable services
	sudo ln -s /etc/sv/socklog-unix/ /var/service
	sudo ln -s /etc/sv/nanoklogd/ /var/service
	# add user to log group
	sudo usermod -a -G socklog $USER
	# log out and log back in
	```

12.	Create projects directory tree in `~` as follows:

	```bash
	mkdir -p ~/projects/src/github.com/sww1235
	```

	This mirrors the structure of how golang wants to set things up.

13.	Clone dotfiles repo from GitHub and install vim and bash files using
	`install.sh` script.

14.	Set up ssh-agent using user specific services. Instructions taken from
	<https://www.daveeddy.com/2018/09/15/using-void-linux-as-my-daily-driver/>

	1.	Create user specific service directory:

		```bash
		sudo mkdir /etc/sv/runit-user-toxicsauce
		```

	2.	Create run script for user specific service by adding the following
		into `/etc/sv/runit-user-toxicsauce/run`

		```bash
		#!/bin/sh
		exec 2>&1
		exec chpst -u toxicsauce:toxicsauce runsvdir /home/toxicsauce/runit/service
		```

	3.	Mark it as executable:

		```bash
		sudo chmod +x /etc/sv/runit-user-toxicsauce/run
		```

	4.	Create necessary user specific service directories:

		```bash
		mkdir ~/runit
		mkdir ~/runit/sv
		mkdir ~/runit/service
		```

	5.	Start this service of services with:

		```bash
		sudo ln -s /etc/sv/runit-user-toxicsauce /var/service
		```

	6.	Now set up `ssh-agent` service:

		```bash
		mkdir ~/runit/sv/ssh-agent
		```

	7.	Create run script for `ssh-agent` service by adding the following into `~/runit/sv/ssh-agent/run`.

		```bash
		#!/usr/bin/env bash
		#
		# Start ssh-agent from runit

		file=~/.ssh/ssh-agent-env

		exec > "$file"

		echo "# started $(date)"

		# For some reason, this line doesn't get emitted by ssh-agent when it is run
		# with -d or -D.  Since we are starting the program with exec we already know
		# the pid ahead of time though so we can create this line manually
		echo "SSH_AGENT_PID=$$; export SSH_AGENT_PID"

		exec ssh-agent -D
		```

	8.	Mark run file as executable with:

		```bash
		chmod +x ~/runit/sv/ssh-agent/run
		```

	9.	Now start the service with:

		```bash
		ln -s ~/runit/sv/ssh-agent ~/runit/service
		```

15.	Clone projects from github into Projects tree as desired.

16.	Set up void-packages per the [instructions](void-packages-setup.html) in
	this wiki.

17.	Make sure `build-branch-the-machine` in my fork of `void-packages` is
	checked out, and up to date with desired patches. See the [suckless
	page](void-suckless-config.html) for more info.

18.	Build binary packages of `dwm`, `dmenu`, `st` and `slstatus` as follows:

	```bash
	cd ~/Projects/src/github.com/sww1235/void-packages
	./xbps-src pkg dwm
	./xbps-src pkg dmenu
	./xbps-src pkg st
	./xbps-src pkg slstatus
	```

19.	Install `dwm`, `dmenu`, `st` and `slstatus` with the command:

	```bash
	sudo xbps-install --repository=hostdir/binpkgs/build-branch-the-machine \
		dwm dmenu st slstatus
	```

20.	Modify ~/.xinitrc to contain the following:

	```xinitrc
	slstatus &
	exec dwm
	```

21.	Install `tlp` for power management:

	```bash
	sudo xbps-install tlp
	sudo ln -s /etc/sv/tlp /var/service
	```

22.	Setup CUPS for printing:

	1.	Install and enable the service:

		```bash
		sudo xbps-install cups
		sudo ln -s /etc/sv/cupsd/ /var/service
		```

	2.	Edit /etc/cups/cupsd.conf, find line that starts with `<Limit
		CUPS-Add-Modify-Printer` and add `toxicsauce` after `@SYSTEM`

	3.	Restart `cupsd` service

	4. go to <http://localhost:631/> to configure

23.	Need to set up bumblebee/optimus for graphics, set up dropbox and 1password
	cli client.

	install alsa-utils to get audio working

```tags
build-script, void-linux,laptop, lenovo, notes
```
