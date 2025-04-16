# Virtualization Cluster Configuration

Documentation on setup of virtualization cluster. Some info may be split into
its own page.

Current status of cluster, is 3 Intel NUCs, each running Xen as a tier 1
hypervisor with FreeBSD as Dom0.

## Individual Host Setup {#initial-host-setup}

### BIOS Configuration {#bios-config}

1.	Boot system into BIOS by spamming `F2` key after pressing power button.

2.	Check that all RAM and CPU are properly detected on `Main` tab.

3.	Under `Advanced->Storage`: Disable SATA port since we are not using it.

4.	Under `Advanced->Onboard Devices`: Disable HD Audio, WLAN, Bluetooth,
	Gaussian Mixture Models, HDMI CEC Control, and Enable IOMMU during pre-boot

5.	Under `Advanced->Video`: Set IGD Primary Video Port to HDMI and enable
	`Virtual Display Emulation` under `Display Emulation`

6.	Under `Security`: Enable USB Provisioning of Intel AMT.

7.	Under `Power->Secondary Power Settings`: Change After Power Failure to
	Power On.

8.	Under `Boot->Secure Boot`: Disable Secure Boot

9.	Under `Boot->Boot Priority`: Enable Boot USB Devices First, and disable
	Boot Network Devices Last.

10.	Under `Boot->Boot Display Configuration`: Disable Suppress Alert
	Messages At Boot, and Enable F12 for network boot.

11.	Under `Main` Select System Time and Set BIOS clock to UTC time.

12.	Press F10 to save and Exit. On Reboot, press `CTRL-P` to get into Intel AMT configuration

### AMT Configuration {#amt-config}

1.	Press `CTRL-P` at boot prompt to enter Intel AMT configuration.

2.	Hit `Enter` to login to AMT, with default password of `admin`. When
	prompted to enter new password, use password out of password manager.

3.	Under `Intel AMT Configuration->User Consent`: Change User Opt-in to NONE.

4.	Under `Intel AMT Configuration->Network Setup->Intel ME Network Name
	Settings`: Set hostname and domain to desired values. Leave
	Shared/Dedicated FQDN set to shared.

5.	Set static DHCP lease in DHCP server if not done already.

### Install Operating System {#os-install}

#### Install Through Mesh Commander

1.	Download FreeBSD-bootonly ISO from reputable sources. Use this to reduce loading times

2.	Connect to system using Mesh Commander.

3.	Mount ISO using IDE-R, and select `Reset to IDE-R` in `Power Actions` menu.

4.	Let FreeBSD boot to the install menu. Don't exit out of the autoboot menu.

5.	Press enter to start the installation process.

6.	Follow the base installation instructions found at [freebsd-base-image](./build-script-notes-base-freebsd-image.md)

7.	Stop CD media after system has rebooted.

#### Install via USB Stick

1.	Download FreeBSD-memstick.img from reputable sources.
2.	Boot to USB using F10
3.	Let FreeBSD boot to install menu.
4.	Press Enter to start the installation process.
5.	Follow the base installation instructions found at [freebsd-base-image](./build-script-notes-base-freebsd-image.md)

### Initial Configuration

Follow instructions at base-image page for basic setup.

Set networking on base interface to static IP in management range first. This should be in Switch ports will be set as trunk with pvid=management_vlan

TODO: fix this


## Cluster Setup {#cluster-setup}

On each host perform the following steps.

1.	sudo pkg install xen-kernel xen-tools qemu-tools.
2.	add the line `vm.max_user_wired=-1` to `/etc/sysctl.conf`
3.	add the line `xc0     "/usr/libexec/getty Pc"         xterm   onifconsole  secure` to `/etc/ttys`
4.	edit `/boot/loader.conf` and add the following lines for 2G memory and 1vCPU core dom0:

	```conf
	if_tap_load="YES"
	xen_kernel="/boot/xen"
	xen_cmdline="dom0_mem=2048M dom0_max_vcpus=1 dom0=pvh com1=115200,8n1 guest_loglvl=all loglvl=all console=vga,com1"
	boot_multicons="YES"
	boot_serial="YES"
	console="comconsole,vidconsole"
	```
5.	run the following commands to configure the vm networking:

	```sh
	sysrc xencommons_enable=yes
	sysrc cloned_interfaces="bridge0 vlan0"
	sysrc ifconfig_em0="up"
 	sysrc ifconfig_vlan12="vlan 12 vlandev em0 up"
 	sysrc ifconfig_bridge0="addm vlan12 up"
	```
6.	Reboot system
7.	Configure NFS client for vm image storage:
   	```sh
    sysrc nfs_client_enable="YES"
    service nfsclient start
    mkdir /nas/vm-store
    # temporaily mount file system to confirm it is working
    # the lack of /the-vault/ at the end of the remote server name, is because this is
    # relative to the mount defined in /etc/exports on the server
    # need to specifically specify nfsv4 else it defaults to nfsv3 which causes confusing errors
    mount -t nfs -o nfsv4 -o rw the-vault.internal.sww1235.net:/vm-store/ /nas/vm-store
    ```
8.	Add the following line to `/etc/fstab` so the mount persists across reboots.
		```sh
		the-vault.internal.sww1235.net:/vm-store/	/nas/vm-store	nfs	rw,nfsv4	0	0
		```
9.	Follow steps in the below listed links to configure vms as necessary:
```tags
cluster, virtualization, virt, NUC, xcp-ng
```
