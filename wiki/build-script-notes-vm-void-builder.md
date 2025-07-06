# Void Builder VM Configuration

TODO:

-	Configure logging properly
-	Investigate certs and HTTPS

## VM Configuration {#vm-configuration}

1.	Download a glibc iso file from the usual void linux download location.

2.	If doing this on FreeBSD, you need to install the `qemu-img` packages

3.	Create a base disk image using the following command `qemu-img create -f
	raw void_builder.img 20G`.

4.	Create the file `/usr/local/etc/xen/void_builder.cfg` with the following
	contents:

	```config
	name = "void_builder"
	type = "hvm"
	# initial memory allocation (MB)
	memory = 512
	vcpus = 4
	firmware="uefi"
	bios="ovmf"
	# Network devices
	# List of virtual interface devices  or 'vifspec'
	vif = ['']
	# Disk Devices
	# a list of 'diskspec' devices
	disk=[
	'/nas/vm-store/void_builder/void_builder.img,raw,xvda,rw',
	'/path/to/void-iso,raw,devtype=cdrom,hdc,r'
	]
	on_reboot="restart"
	on_crash="preserve"
	on_poweroff="preserve"
	vnc=1
	vnclisten="0.0.0.0"
	serial="pty"
	usbdevice="tablet"
	```

## Void Builder Configuration {#void-builder-config}

### OS Configuration {#os-cfg}

1.	Login as `root` with password `voidlinux`

2.	Run `void-installer`

3.	Set keymap to `us`

4.	Set network to static using info out of IPAM tool

5.	Select local for the source

6.	Set hostname to `void-builder`

7.	Set locale to `en_US.UTF-8`

8.	Set timezone to `America/Denver`

9.	Set root password from password manager

10.	Create user with name `toxicsauce` and password from password manager

11.	Create the following partitions:

	1.	Create a `1G` partition of type `EFI System`

	2.	Create a `4G` partition of type `Linux Swap`

	3.	Create a partition with the remaining space of type `Linux Filesystem`

12.	Set up filesystems:

	1.	Create a `vfat` filesystem on the `EFI System` partition mounted at
		`/boot/efi`

	2.	Create a `swap` filesystem on the `Linux Swap` partition.

	3.	Create a `ext4` filesystem on the `Linux Filesystem` partition mounted
		at `/`

13.	Select `Install`

14.	Enable/disable the following services. Leave the others as default.

	1.	Enable: `agetty-hvc0`

	2.	Enable: `agetty-hvsi0`

	3.	Disable: `wpa_supplicant`

15.	Reboot from installer. This will boot you back into the live installer
	image due to the configuration of the domU. log back in and then shutdown
	using `shutdown -h now`.

16.	The VM will be in a suspended state so you must run `xl destroy
	void_builder` to completely shut it down.

17.	Comment out the `cdrom` line in diskspec line of configuration file

18.	Start VM again with `xl create /usr/local/etc/xen/void_builder.cfg -c`

19.	If dropped into a UEFI shell, run `fs0:\boot\efi\EFI\void_grub\grubx64.efi`
	using tab to get completions, in order to boot into the system again.

20.	SSH into the system while still keeping the vm console open.

21.	Install `rEFInd` once in the system with the commands:

	```bash
	sudo xbps-install refind
	sudo refind-install
	```

22.	Change the timeout setting in `/boot/efi/EFI/refind/refind.conf` to 5 seconds.

23.	Uncomment the `textonly` setting in `/boot/efi/EFI/refind/refind.conf`

24.	Uncomment the line `resolution 1024 768` in `/boot/efi/EFI/refind/refind.conf`

25.	Reboot and immediately enter the vm console again with `xl console void_builder` if dropped.

26.	Type `exit` at UEFI prompt to drop to BIOS config.

27.	Select `Boot Maintenance Manager` -> `Boot Options` -> `Add Boot Option`
	and then choose the disk with the EFI system partion, typically the first
	option.

28.	Now navigate through the file system to find and select the EFI executable.
	With `rEFInd` installed, it is typically at `EFI/refind/refind_x64.efi`

29.	Enter name of boot option by hitting enter in the description box. This
	should be called `void_linux`

30. Select `Commit Changes and Exit`

31.	Now select `Change Boot Order` and then hit enter again to load the menu.

32.	Select the `void_linux` option in the list with the arrow keys, and move it
	to the top with the `+` key.

33. Select `Commit Changes and Exit` and then `Continue` to boot into the new
	boot entry as long as it is present in `Boot Next Value` entry.

34.	At the `rEFInd` prompt, you will probably have to select the
	`/boot/vmlinuz` entry as the grub cfg file may still be the default.

35.	Remove the `/boot/grub` folder and the `/boot/efi/EFI/void_linux/grubx64.efi` file and containing folder.

36. Reboot again to make sure everything functions correctly.

37.	Uninstall the following packages `grub grub-i386-efi grub-x86_64-efi void-live-audio void-docs-browse`

38.	Run `sudo xbps-remove -o` and `sudo xbps-remove -O` to remove unnessary dependancies and clean cache.

### Package Builder Configuration {#pkg-build-cfg}

There will be 2 repositories and builders set up for automatic building. One
that mirrors void-packages with modifications and the other with custom
packages.

Most of this was manually parsed from
[this](https://github.com/void-ansible-roles/xbps-mini-builder/blob/master/tasks/main.yml)
ansible script.

1.	Install `st-terminfo`, `git`, `make`, `snooze` 'and `nginx` packages using `xbps-install`.

2.	Create the user that will run the scripts and build packages: `useradd -r -m
	pkg-builder`

3.	Create build directories and install scripts.

	```sh
	sudo mkdir -p /opt/void-packages-main/
	sudo mkdir -p /opt/void-packages-custom/
	sudo chown pkg-builder:pkg-builder /opt/void-packages-main/
	sudo chown pkg-builder:pkg-builder /opt/void-packages-custom/
	sudo chmod 0755 /opt/void-packages-main/
	sudo chmod 0755 /opt/void-packages-custom/
	cd /opt/void-packages-main/
	# Obtain script and change ownership
	sudo -u pkg-builder git clone https://github.com/sww1235/xbps-mini-builder.git .
	sudo chown pkg-builder:pkg-builder *
	sudo chown pkg-builder:pkg-builder .*
	sudo chmod 0755 xbps-mini-builder
	cd /opt/void-packages-custom/
	sudo -u pkg-builder git clone https://github.com/sww1235/xbps-mini-builder.git .
	sudo chown pkg-builder:pkg-builder *
	sudo chown pkg-builder:pkg-builder .*
	sudo chmod 0755 xbps-mini-builder
	```

4.	Create `packages.list` file in the `/opt/void-packages-*/` directories with
	the list of packages to build for each repo:

	**void-packages-main**:

	```conf
	dwm
	st
	dmenu
	```

	**void-packages-custom**:

	```conf
	TBD
	```

5.	Create `etc/conf` file in each `/opt/void-packages-*/` directory with the
	following contents:

	**void-packages-main**:

	```conf
	XBPS_ALLOW_RESTRICTED=yes
	```

	**void-packages-custom**:

	```conf
	TBD
	```

6.	Change ownership and mode of these config files:

	```sh
	sudo chown pkg-builder:pkg-builder /opt/void-packages-main/etc/conf
	sudo chmod 0644 /opt/void-packages-main/etc/conf
	sudo chown pkg-builder:pkg-builder /opt/void-packages-custom/etc/conf
	sudo chmod 0644 /opt/void-packages-custom/etc/conf
	sudo chown pkg-builder:pkg-builder /opt/void-packages-main/packages.list
	sudo chmod 0644 /opt/void-packages-main/packages.list
	sudo chown pkg-builder:pkg-builder /opt/void-packages-custom/packages.list
	sudo chmod 0644 /opt/void-packages-custom/packages.list
	```

7.	Create a set of RSA keys to sign packages with `sudo -u pkg-builder openssl
	genrsa -out /home/pkg-builder/private.pem`

8.	Create service directory:

	```bash
	sudo mkdir -p /etc/sv/pkg-builder/
	sudo chmod 0755 /etc/sv/pkg-builder/
	```

9.	Create file with contents at `/etc/sv/pkg-builder/run` and then set owner and mode:

	File contents:

	```sh
	#!/bin/sh

	set -e
	exec 2>&1
	echo "sleeping until time to run"

	exec snooze chpst -u pkg-builder:pkg-builder /opt/void-packages-main/xbps-mini-builder \
		--branch-name="build-branch-builder" --repo="https://github.com/sww1235/void-packages"

	exec snooze chpst -u pkg-builder:pkg-builder /opt/void-packages-custom/xbps-mini-builder
	```

	Change mode:

	```sh
	chmod 0755 /etc/sv/pkg-builder/
	chmod 0755 /etc/sv/pkg-builder/run
	```

10.	Create file with contents at `/etc/sv/pkg-builder/log/run` and then set owner and mode:

	File contents

	```sh
	#!/bin/sh

	exec svlogd -tt /var/log/pkg-builder
	```

	Change mode:

	```sh
	chmod +x /etc/sv/pkg-builder/log/run
	```

11.	Create the directory `/var/log/pkg-builder/` and then create
	`/var/log/pkg-builder/config` with the following contents:

	```conf
	# max size in bytes
	s100000

	# keep max of 10 files
	n10

	# minimum of 5 files
	N5

	# rotate every number of seconds
	# 24 hours
	t86400
	```

12.	Enable the service with `ln -s /etc/sv/pkg-builder/ /var/service`

13.	Configure nginx to host the binpkgs directory for both `void-packages-main`
	and `void-packages-custom`. The server directive below will set that up if
	placed in `/etc/nginx/nginx.conf`

	```conf
	server {
		listen	*:80;
		server_name void-builder.internal.sww1235.net;

		location /void-packages/main/ {
			alias /opt/void-packages-main/void-packages/hostdir/binpkgs;
			autoindex on;
		}
		location /void-packages/custom/ {
			alias /opt/void-packages-custom/personal-void-packages/hostdir/binpkgs;
			autoindex on;
		}
	}
	```

14.	Also set `user nginx;` and `worker_processes 4;` at the beginning of the
	`/etc/nginx/nginx.conf` file.

#### Create Void Packages Fork

**Note**: this may already be done.

1.	Create a fork of the void-packages repo on Github.

2.	Modify packages as necessary.

#### Create Custom Package Repository

**Note**: this may already be done.

1.	Create a new git repository.

## Client Configuration {#client-config}

To use custom repositories on a client system, you must create a file in
`/etc/xbps.d/` with the contents `repository=<URL>` where `<URL>` is either a
local directory or a URL to a remote repository.

To enable the use of the repositories hosted on `void-builder`, make the
following changes to each client system:

1.	Move the file `/etc/xbps.d/00-repository-main.conf` to `/etc/xbps.d/10-repository-official.conf`.

2.	Create the file `/etc/xbps.d/00-repository-a-void-builder-main.conf` with contents `repository=<URL>`.

3.	Create the file `/etc/xbps.d/01-repository-b-void-builder-custom.conf` with contents `repository=<URL>`.
