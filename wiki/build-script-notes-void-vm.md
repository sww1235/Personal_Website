# Main Workstation Build Script and Notes

This is the build script for my main void linux virtual machine that I use as
my main workstation.

## Notes {#notes}

## Build Script {#build-script}

### Initial Configuration {#initial-config}

1.	Download the `void-live-x86_64.iso` of void linux from reputable
	sources, currently
	[here](https://alpha.de.repo.voidlinux.org/live/current/)

2.	Mount iso vm using `vm-manager.sh`

3.	Login as root with default password of `void-linux` to live image.

4.	Make sure you are booted using UEFI by validating presence of
	`/sys/firmware/efi` directory

5.	run `void-installer`

6.	Proceed through installation wizard

	1.	Keyboard=us

	2.	Select DHCP

	3.	Source=network

	4.	Hostname=void-vm

	5.	System Locale=en\_US.UTF-8

	6.	Timezone=America/Denver or appropriate

	7.	Root password from password manager - generated

	8.	User account from password manager

	9.	Select sda1, and no for graphical terminal.

	10.	Partition main SSD using GPT scheme

		1.	Create a 500MiB partition of type `EFI system`

		2.	Create a second partition with the remaining space of type
			`linux-filesystem`

		3.	Select write to write partitions to disk

	11.	Set filesystem

		1.	Set 500MiB partition `vfat` filesystem and mount it at `/boot/efi`

		2.	Set second partition to `ext4` and mount it at `/`

	12.	Review settings

	13.	Install

	14.	Wait

	15.	Exit installer

	16.	Shutdown system with `shutdown -h now`

	17.	Comment out cdrom directives in vm-manager script

	18. Start up VM again

7.	Log in as the new user you created.

8.	Update the system by running the following command until there is no output.

	```bash
	sudo xbps-install -Svu
	```

9.	Install the following packages. The st-terminfo install fixes `st-256color
	unknown terminal type` issues as well as backspace and tab issues when
	sshing in from other computers using the `st` terminal emulator.

	```bash
	sudo xbps-install nano thefuck vim st-terminfo git
	```

10.	Setup system logging using socklog

	```bash
	sudo xbps-install socklog-void
	# enable services
	sudo ln -s /etc/sv/socklog-unix/ /var/service
	sudo ln -s /etc/sv/nanoklogd/ /var/service
	# add user to log group
	sudo usermod -a -G socklog $USER
	# log out and log back in
	```

11.	Start ssh service `sudo ln -s /etc/sv/sshd/ /var/service` so you can log in remotely.

12. Generate ssh-keys `ssh-keygen -t ed25519` and enter passphrase from password manager

13. Add public key to github.

14.	Set up git.

	```bash
	git config --global user.email "github@sww1235.net"
	git config --global user.name "Stephen Walker-Weinshenker"
	```

15.	Set up ssh-agent using user specific services. Instructions taken from
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

		**NOTE**: you need the following line in bashrc in order to get it working
		in new shells. This is already in my dotfiles bashrc

		```bash
		# source ssh-agent file

		[ -f $HOME/.ssh/ssh-agent-env ] && source $HOME/.ssh/ssh-agent-env
		```

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

20.	Set up void-packages per the [instructions](void-packages-setup.html) in
	this wiki.

21.	Make sure `build-branch-void-vm` in my fork of `void-packages` is
	checked out, and up to date with desired patches. See the [suckless
	page](void-suckless-config.html) for more info.

22.	Build binary packages of `dwm`, `dmenu`, and `st` as follows:

	```bash
	cd ~/Projects/src/github.com/sww1235/void-packages
	./xbps-src pkg dwm
	./xbps-src pkg dmenu
	./xbps-src pkg st
	```

23.	Install `dwm`, `dmenu`, and `st` with the command:

	```bash
	sudo xbps-install --repository=hostdir/binpkgs/build-branch-void-vm dwm dmenu st
	```

24.	Install `xorg` and `xorg-fonts` to get graphics working

25.	Install and run `arandr` to generate a `xrandr` command to fix the monitor
	rotation. Save the script as `~/.screenlayout/main.sh`

26.	Install `xscreensaver`, then run `xscreensaver-demo` and unselect the
	screensavers that you don't want to run.

27.	Modify ~/.xinitrc to contain the following:

	```xinitrc
	~/.screenlayout/main.sh
	xscreensaver &
	exec dwm
	```

28.	Setup CUPS for printing:

	1.	Install and enable the service:

		```bash
		sudo xbps-install cups
		sudo ln -s /etc/sv/cupsd/ /var/service
		```

	2.	Edit /etc/cups/cupsd.conf, find line that starts with `<Limit
		CUPS-Add-Modify-Printer` and add `toxicsauce` after `@SYSTEM`

	3.	Restart `cupsd` service

	4. go to <http://localhost:631/> to configure

29.	Install alas-utils to get audio working FIXME:

30.	FIXME: Install NVIDIA drivers

	1.	Take snapshot of VM before installing drivers.

	2.	Install the `nonfree-repository`.

		```sh
		sudo xbps-install void-repo-nonfree
		```

	3.	Upgrade the system

	4.	Install the `nvidia` package.

	5.	Reboot. It should just work.

## Resources {#resources}

```tags
build-script, main-ws-host, workstation, notes, QEMU, KVM, VFIO, Passthrough
```
