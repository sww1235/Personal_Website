# Main Workstation Build Script and Notes

This is the build script for my main workstation PC.

## TODO

- 	Change to rEFInd for boot manager

## Build Script {#build-script}

### Initial Configuration {#initial-config}

1.	Download the `void-live-x86_64.iso` of void linux from reputable sources,
	currently [here](https://alpha.de.repo.voidlinux.org/live/current/)

2.	Burn image to USB thumbdrive using either `dd` or whatever windows tool is
	the popular thing and preferably doesn't use electron.

3.	Login as root with default password of `void-linux` to live image.

4.	Make sure you are booted using UEFI by validating presence of
	`/sys/firmware/efi` directory

5.	run `void-installer`

6.	Proceed through installation wizard

	1.	Keyboard=us

	2.	Select Static and enter information from static-ip document

	3.	Source=network

	4.	Hostname=the-beast

	5.	System Locale=en\_US.UTF-8

	6.	Timezone=America/Denver or appropriate

	7.	Root password from password manager - generated

	8.	User account from password manager

	9.	Select grub to autoinstall GRUB2 bootloader. TODO: change to rEFInd instead

	10.	Partition main SSD using GPT scheme

		1.	Create a 500MiB partition of type `EFI system`

		2.	Create a second partition with the remaining space of type
			`linux-filesystem`

		3.	Select write to write partitions to disk

	11.	Set filesystems

		1.	Set 500MiB partition `vfat` filesystem and mount it at `/boot/efi`

		2.	Set second partition to `ext4` and mount it at `/`

	12.	Review settings

	13.	Install

	14.	Wait

	15.	Reboot

7.  Login to newly installed Void Linux using root account and password found
	in password database. This is due to the fact that we haven't configured
	sudo yet.

8.  Configure `sudo` to allow full access to members of `wheel` group. Run
	`visudo` and uncomment the line

	```sudo
	#%wheel ALL=(ALL) ALL
	```

9.	Log out and log back in as the new user you created

10.	Update the system by running the following command until there is no output.

	```sh
	sudo xbps-install -Svu
	```

11.	Configure custom repository using steps found in [void-builder
	config](./build-script-notes-vm-void-builder.md)

12.	Install the following packages. The st-terminfo install fixes `st-256color
	unknown terminal type` issues as well as backspace and tab issues when
	`ssh`ing in from other computers using the `st` terminal emulator.

	```sh
	sudo xbps-install vim-huge gvim st-terminfo git xorg xorg-fonts arandr xscreensaver cups
	sudo xbps-install firefox freecad kicad rsync tmux zip wget unzip
	```

13.	Enable NTP service:

	```sh
	sudo xbps-install chrony
	ln -s /etc/sv/ntpd /var/service
	```

14.	Setup system logging using socklog

	```sh
	sudo xbps-install socklog-void
	# enable services
	sudo ln -s /etc/sv/socklog-unix/ /var/service
	sudo ln -s /etc/sv/nanoklogd/ /var/service
	# add user to log group
	sudo usermod -a -G socklog $USER
	# log out and log back in
	```

15.	Set up ssh-agent using user specific services. Instructions taken from
		<https://www.daveeddy.com/2018/09/15/using-void-linux-as-my-daily-driver/>

	1.	Create user specific service directory:

		```sh
		sudo mkdir /etc/sv/runit-user-toxicsauce
		```

	2.	Create run script for user specific service by adding the following
		into `/etc/sv/runit-user-toxicsauce/run`

		```sh
		#!/bin/sh
		exec 2>&1
		exec chpst -u toxicsauce:toxicsauce runsvdir /home/toxicsauce/runit/service
		```

	3.	Mark it as executable:

		```sh
		sudo chmod +x /etc/sv/runit-user-toxicsauce/run
		```

	4.	Create necessary user specific service directories:

		```sh
		mkdir ~/runit
		mkdir ~/runit/sv
		mkdir ~/runit/service
		```

	5.	Start this service of services with:

		```sh
		sudo ln -s /etc/sv/runit-user-toxicsauce /var/service
		```

	6.	Now set up `ssh-agent` service:

		```sh
		mkdir ~/runit/sv/ssh-agent
		```

	7.	Create run script for `ssh-agent` service by adding the following into `~/runit/sv/ssh-agent/run`.

		```sh
		#!/usr/bin/env bash

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

		```sh
		chmod +x ~/runit/sv/ssh-agent/run
		```

	9.	Now start the service with:

		```sh
		ln -s ~/runit/sv/ssh-agent ~/runit/service
		```

		**NOTE**: you need the following line in bashrc in order to get it working
		in new shells. This is already in my dotfiles bashrc

		```sh
		# source ssh-agent file

		[ -f $HOME/.ssh/ssh-agent-env ] && source $HOME/.ssh/ssh-agent-env
		```

16. Generate ssh-keys `ssh-keygen -t ed25519` and enter passphrase from
	password manager

17. Add public key to github.

18.	Set up git.

	```sh
	git config --global user.email "github@sww1235.net"
	git config --global user.name "Stephen Walker-Weinshenker"
	```

18.	Create Projects directory tree in `~` as follows:

	```sh
	mkdir -p ~/projects/src/github.com/sww1235
	```

	This mirrors the structure of how golang wants to set things up.

19.	Make symlink in `~` as follows:

	```sh
	ln -s ~/projects/src/github.com/sww1235 myprojects
	```

20.	Clone dotfiles repo from GitHub using ssh and install vim and bash files
	using `install.sh` script.

21. Modify ~/.xinitrc to contain the following:

	```xinitrc
	slstatus &
	exec dwm
	```

22.	Clone projects from github into Projects tree as desired.

### Extra Host Configuration [#extra-host-config}

1.	Install network-ups-tools.

	```sh
	sudo xbps-install network-ups-tools
	```

2.	Edit `/etc/ups/upsmon.conf` and add the following lines:

	```conf
	MONITOR cyberpower@$rackmonitorIP 1 upsmonSlave $password slave
	```

3.	Start `upsmon` service `ln -s /etc/sv/upsmon/ /var/service`

```tags
build-script, main-ws-host, workstation, notes
```
