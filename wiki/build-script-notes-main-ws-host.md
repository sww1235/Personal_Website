<h1 id="top">Main Workstation Build Script and Notes</h1>

This is the build script for my main workstation PC and associated VMs 

<h2 id="notes">Notes</h2>

<h2 id="build-script">Build Script</h2>

<h3 id="initial-configuration">Initial Configuration</h3>

1. Download the void-live-musl\_x86-64 .iso of void linux from reputable
   sources, currently [here](https://alpha.de.repo.voidlinux.org/live/current/)

2. Burn image to USB thumbdrive using either `dd` or whatever windows tool is
   the popular thing and preferably doesn't use electron.

3. Login as root with default password of `void-linux` to live image.

4. Make sure you are booted using UEFI by validating presence of
   `/sys/firmware/efi` directory

4. run `void-installer`

5. Proceed through installation wizard
	1. Keyboard=us
	2. Either interface is fine, along with DHCP. This will get changed when we set up the VMs
	3. Source=network
	4. Hostname=main-ws-host
	5. Timezone=America/Denver or appropriate
	6. Root password from password manager - generated
	7. User account from password manager
	8. Select grub to autoinstall GRUB2 bootloader. TODO: change to rEFInd instead
	9. Partition main SSD using GPT scheme
	10. Set filesystems
	11. Review settings
	12. Install
	13. Wait
	14. Reboot
6. Log in as the new user you created
7. Update the system by running the following command until there is no output.
	```bash
	sudo xbps-install -Svu
	```
9. Install and remove the following packages. Want to use simpler NTP implementation.
	```bash
	sudo xbps-install nano openntpd thefuck
	sudo xbps-remove chrony
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

11.	Create Projects directory tree in `~` as follows:

	```bash
	mkdir -p ~/Projects/src/github.com/sww1235
	```

	This mirrors the structure of how golang wants to set things up.

12.	Clone dotfiles repo from GitHub and install vim and bash files using
	`install.sh` script.

13.	Set up ssh-agent using user specific services. Instructions taken from
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

14.	Clone projects from github into Projects tree as desired.

15.	Set up void-packages per the [instructions](void-packages-setup.html) in
	this wiki.

16.	Make sure `build-branch-the-machine` in my fork of `void-packages` is
	checked out, and up to date with desired patches. See the [suckless
	page](void-suckless-config.html) for more info.

17.	Build binary packages of `dwm`, `dmenu`, `st` and `slstatus` as follows:

	```bash
	cd ~/Projects/src/github.com/sww1235/void-packages
	./xbps-src pkg dwm
	./xbps-src pkg dmenu
	./xbps-src pkg st
	./xbps-src pkg slstatus
	```

18.	Install `dwm`, `dmenu`, `st` and `slstatus` with the command:

	```bash
	sudo xbps-install --repository=hostdir/binpkgs/build-branch-the-machine dwm dmenu st slstatus
	```

19.	Modify ~/.xinitrc to contain the following:

	```xinitrc
	slstatus &
	exec dwm
	```

<h3 id="vfio-kvm-qemu-config">VFIO/KVM/QEMU Configuration</h3>

1. `xbps-install dbus qemu libvirtd virt-manager bridge-utils iptables2` 

ln -s /etc/sv/dbus /var/service
ln -s /etc/sv/libvirtd /var/service
ln -s /etc/sv/virtlockd /var/service
ln -s /etc/sv/virtlogd /var/service

it is not in xbps so need to manually download from [https://www.kraxel.org/repos/jenkins/edk2/](https://www.kraxel.org/repos/jenkins/edk2/) as of the writing of this build. Download the ovmf appropriate either 32 or 64 bit version then use

install rpmextract package xbps
```bash
rpm2cpio <file>.rpm | xz -d | cpio -idmv
```
otherwise you could try:
```bash
rpm2cpio <file>.rpm | lzma -d | cpio -idmv
```
to extract the files needed.

`./user/share` is inside the extracted filesystem

copy files in `./usr/share/edk2.git/ovmf-x64` to `/usr/share/ovmf`

and then set the config option in `/etc/libvirt/qemu.conf`

`nvram` to the appropriate locations. smm varients include secure boot code, csm varients include legacy compat modules.

code and vars are separate files that are both contained in OVMF base.

<h2 id="sources">Sources</h2>

<https://www.reddit.com/r/voidlinux/comments/ghwvv5/guide_how_to_setup_qemukvm_emulation_on_void_linux/>


```tags
build-script, main-ws-host, workstation, notes, QEMU, KVM, VFIO, Passthrough
```
