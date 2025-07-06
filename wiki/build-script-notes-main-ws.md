# Main Workstation Build Script and Notes

This is the build script for my main workstation PC.


## Build Script {#build-script}

### Initial Configuration {#initial-config}

1.	Download the void-live-\_x86-64 .iso of void linux from reputable
	sources, currently
	[here](https://alpha.de.repo.voidlinux.org/live/current/)

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
	5.	Timezone=America/Denver or appropriate
	6.	Root password from password manager - generated
	7.	User account from password manager
	8.	Select grub to autoinstall GRUB2 bootloader. TODO: change to rEFInd instead
	9.	Partition main SSD using GPT scheme
	10.	Set filesystems
	11.	Review settings
	12.	Install
	13.	Wait
	14.	Reboot

7.	Log in as the new user you created

8.	Update the system by running the following command until there is no output.

	```bash
	sudo xbps-install -Svu
	```
9.	Configure custom repository using steps found in [void-builder config](./build-script-notes-vm-void-builder.md)

10.	Install the following packages. The st-terminfo install fixes `st-256color
	unknown terminal type` issues as well as backspace and tab issues when
	sshing in from other computers using the `st` terminal emulator.

	```bash
	sudo xbps-install nano vim-huge gvim st-terminfo
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

12.	Set up ssh-agent using user specific services. Instructions taken from
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

		TODO: add in instructions around btrfs and mounting separate file systems

13.	Create Projects directory tree in `~` as follows:

	```bash
	mkdir -p ~/projects/src/github.com/sww1235
	```

	This mirrors the structure of how golang wants to set things up.

14.	Make symlink in `~` as follows:

	```bash
	ln -s ~/projects/src/github.com/sww1235 myprojects
	```

15.	Clone dotfiles repo from GitHub using ssh and install vim and bash files using
	`install.sh` script.

16.	Clone projects from github into Projects tree as desired.

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
