# Void Builder VM Configuration

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

### OS Configuration

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

18.	Start VM again with `xl create /usr/local/etc/xen/void_builder.cfg`
