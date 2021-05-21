# Main Workstation Build Script and Notes

This is the build script for my main workstation PC and associated VMs.

## Notes {#notes}

VM specific buildscripts are in their own files and are linked at the bottom of the page

## Build Script {#build-script}

### Initial Configuration {#initial-config}

1.	Download the void-live-musl\_x86-64 .iso of void linux from reputable
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
	2.	Either interface is fine, along with DHCP. This will get changed when we set up the VMs
	3.	Source=network
	4.	Hostname=main-ws-host
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

8.	Static IP address setup. Add the following to `/etc/dhcpcd.conf` and
	restart dhcpcd service `sudo sv restart dhcpcd`.

	```conf
	interface eno1
	inform ip_address=$ipaddress
	static ip_address=$ipaddress/subnet
	static routers=$gateway
	static domain_name_servers=$gateway
	```

9.	Update the system by running the following command until there is no output.

	```bash
	sudo xbps-install -Svu
	```

10.	Install the following packages. The st-terminfo install fixes `st-256color
	unknown terminal type` issues as well as backspace and tab issues when
	sshing in from other computers using the `st` terminal emulator.

	```bash
	sudo xbps-install nano thefuck vim st-terminfo
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

17.	Set up void-packages per the [instructions](void-packages-setup.html) in
	this wiki.

### VFIO/KVM/QEMU Configuration {#vfio-kvm-qemu-config}

1.	install qemu and socat

	```bash
	sudo xbps-install qemu socat
	```

2.	Create QEMU directory

	```bash
	sudo mkdir /etc/qemu
	```

3.	download ovmf. It is not in xbps so need to manually download from
	<https://www.kraxel.org/repos/jenkins/edk2/> as of the writing of this
	build. Download the ovmf appropriate either 32 or 64 bit version. This will
	be in RPM format, so need to:

4.	Install rpmextract.

	```bash
	sudo xbps-install rpmextract
	```

5.	Then run either:

	```bash
	rpm2cpio <file>.rpm | xz -d | cpio -idmv
	```

	or

	```bash
	rpm2cpio <file>.rpm | lzma -d | cpio -idmv
	```

	to extract the files needed.

6.	Copy the files inside the `./usr/share/edk2.git/ovmf-x64` directory inside
	the extracted files, to `/usr/share/ovmf/`. This path is hardcoded in the
	`vm-manager.sh` script and will need to be changed if ovmf is installed in
	another location.

	smm varients include secure boot code, csm varients include legacy compat modules.
	code and vars are separate files that are both contained in OVMF base.

7.	Create kvm:kvm user/group as system group

8.	Clone vm-manager repo into projects directory, and symlink to good location for executable scripts in path

9.	since we are running as -user kvm, need to edit `/etc/security/limits.conf` and
	increase them for user kvm, as well as root and main user. This allows us to
	grant large amounts of memory to the guest.

	Add the following lines to the file.

	```conf
	@kvm		soft	memlock	unlimited
	@kvm		hard	memlock	unlimited
	toxicsauce	soft	memlock	unlimited
	toxicsauce	hard	memlock	unlimited
	root		soft	memlock	unlimited
	root		hard	memlock	unlimited
	```

	From: <https://stackoverflow.com/questions/39187619/vfio-dma-map-error-when-passthrough-gpu-using-libvirt>

10.	Set up kernel drivers for PCIe passthrough.

	1.	Create file `blacklist.conf` in `/etc/modprobe.d/ and add the following
		to the contents. This prevents the nouveau driver from loading and
		taking over the nvidia card before the vfio-pci driver can load.

		```bash
		blacklist nouveau
		```

	2.	Create file `vfio.conf` in `/etc/modprobe.d/` and then set contents to
		the following, changing pcie ids as needed to those found via `lspci`

		```bash
		# 10de:1c03
		# 10de:10f1
		# 1912:0014 - usb3 pcie card
		# 8086:15b8 - 219V ethernet card
		# 8086:1539 - I211 ethernet card
		options vfio-pci ids=10de:1c03,10de:10f1,1912:0014,8086:1539

		# load vfio-pci before xhci-hcd and igb else the usb3 pcie card
		# and intel nic are claimed by xhci_hcd
		softdep xhci_hcd pre: vfio_pci
		softdep igb pre: vfio_pci
		```

		This tells `vfio-pci` to attach to the specified PCIe devices. It also
		creates a soft dependancy of `vfio-pci` on `xhci_hcd` so `vfio-pci`
		will in theory load before `xhci_hcd` and attach to the usb controller
		before `xhci_hcd` does.

	3.	Create file `vfio.conf` in /etc/modules-load.d` with the contents:

		```bash
		vfio
		vfio-pci
		vfio-virqfd
		```

		This loads the specified kernel drivers for VFIO use.

	4.	Create file `dracut.conf` in `/etc/dracut.conf.d/` with the contents:

		```bash
		add_drivers+=" vfio vfio-pci vfio_iommu_type1 vfio_virqfd "
		add_dracutmodules+=" kernel-modules "
		omit_drivers+=" nouveau "
		hostonly=yes
		```

		This adds the correct drivers into the initramfs and prevents the
		nouveau driver from being loaded.

	5.	Now run regenerate initramfs and DKMS modules with:

		```bash
		sudo xbps-reconfigure --force $linux-kernel-package
		```

	6.	Reboot

11.	Check lscpi -v to make sure that `vfio-pci` has correctly bound to the
	graphics card, usb card and nic.

12.	start VM to test using script in vm-manager repo.

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

### VM Specific Setup {#vm-specifics}

-	[Void VM](build-script-notes-void-vm.html)
-	[Win10 VM](build-script-notes-win10-vm.html)



## Resources {#Resources}

<https://www.reddit.com/r/voidlinux/comments/ghwvv5/guide_how_to_setup_qemukvm_emulation_on_void_linux/>


```tags
build-script, main-ws-host, workstation, notes, QEMU, KVM, VFIO, Passthrough
```
