<h1 id="top">Main Workstation Build Script and Notes</h1>

This is the build script for my main workstation PC and associated VMs.

<h2 id="notes">Notes</h2>

VM specific buildscripts are in their own files and are linked at the bottom of the page

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

8. Install the following packages. The st-terminfo install fixes `st-256color
   unknown terminal type` issues as well as backspace and tab issues when
   sshing in from other computers using the `st` terminal emulator.

	```bash
	sudo xbps-install nano thefuck vim st-terminfo
	```

9.	Setup system logging using socklog

	```bash
	sudo xbps-install socklog-void
	# enable services
	sudo ln -s /etc/sv/socklog-unix/ /var/service
	sudo ln -s /etc/sv/nanoklogd/ /var/service
	# add user to log group
	sudo usermod -a -G socklog $USER
	# log out and log back in
	```
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

	**NOTE**: you need the following line in bashrc in order to get it working
	in new shells. This is already in my dotfiles bashrc

	```bash
	# source ssh-agent file

	[ -f $HOME/.ssh/ssh-agent-env ] && source $HOME/.ssh/ssh-agent-env
	```

TODO: add in instructions around btrfs and mounting separate file systems

11.	Create Projects directory tree in `~` as follows:

	```bash
	mkdir -p ~/projects/src/github.com/sww1235
	```

	This mirrors the structure of how golang wants to set things up.

12.	Make symlink in `~` as follows:

	```bash
	ln -s ~/projects/src/github.com/sww1235 myprojects
	```

12.	Clone dotfiles repo from GitHub using ssh and install vim and bash files using
	`install.sh` script.


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

1.	install qemu and socat

	```bash
	sudo xbps-install qemu socat
	```

2.	Create QEMU directory

	```bash
	sudo mkdir /etc/qemu
	```

3. download ovmf. It is not in xbps so need to manually download from
   <https://www.kraxel.org/repos/jenkins/edk2/>
   as of the writing of this build. Download the ovmf appropriate either 32 or
   64 bit version. This will be in RPM format, so need to:

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


7.	create/reuse existing qcow2 win10 image

	1.	To create a new qcow2 image, use the below commands.

		```bash
		qemu-img create -f qcow2 -o preallocation=metadata filename.qcow2 size
		```

8.	Create kvm:kvm user/group as system group

9.	Clone vm-manager repo into projects directory, and symlink to good location for executable scripts in path

10.	Create vmbridge interface using iproute2 package

	```bash
	ip link add name vmbridge type bridge
	ip link set vmbridge up
	```

11.	need to add interface to bridge

12.	create acl file at `/etc/qemu/bridge.conf` and set contents to `allow all`

13.	since we are running as -user kvm, need to edit `/etc/security/limits.conf` and
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

14.	Set up kernel drivers for PCIe passthrough.

	1.	Create file `blacklist.conf` in `/etc/modprobe.d/ and add the following
		to the contents. This prevents the nouveau driver from loading and
		taking over the nvidia card before the vfio-pci driver can load.

		```bash
		blacklist nouveau
		```

	2.	Create file `vfio.conf` in `/etc/modprobe.d/ and then set contents to
		the following, changing pcie ids as needed to those found via `lspci`

		```bash
		# 10de:1c03
		# 10de:10f1
		# 1912:0014 - usb3 pcie card
		# 8086:15b8 - V219 ethernet card
		options vfio-pci ids=10de:1c03,10de:10f1,1912:0014

		# load vfio-pci before xhci-hcd else the usb3 ports are claimed by xhci_hcd
		softdep xhci_hcd pre: vfio_pci
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
		sudo xbps-reconfigure --force linux
		```


<h2 id="resources">Resources</h2>

<https://www.reddit.com/r/voidlinux/comments/ghwvv5/guide_how_to_setup_qemukvm_emulation_on_void_linux/>


```tags
build-script, main-ws-host, workstation, notes, QEMU, KVM, VFIO, Passthrough
```
