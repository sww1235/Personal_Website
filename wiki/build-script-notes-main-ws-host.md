<h1 id="top">Main Workstation Build Script and Notes</h1>

This is the build script for my main workstation PC and associated VMs 


<h2 id="notes">Notes</h2>

-

<h2 id="build-script">Build Script</h2>

<h3 id="initial-configuration">Initial Configuration</h3>

1. Download the void-live-musl\_x86-64 .iso of void linux from reputable sources, currently [here](https://alpha.de.repo.voidlinux.org/live/current/)
2. Burn image to USB thumbdrive using either `dd` or whatever windows tool is the popular thing and preferably doesn't use electron.
3. Login as root with default password of `void-linux` to live image.
4. Make sure you are booted using UEFI by validating presence of `/sys/firmware/efi` directory
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

<h3 id="vfio-kvm-qemu-config">VFIO/KVM/QEMU Configuration</h3>

1. `xbps-install dbus qemu libvirtd virt-manager bridge-utils iptables2`
2. 

ln -s /etc/sv/dbus /var/service
ln -s /etc/sv/libvirtd /var/service
ln -s /etc/sv/virtlockd /var/service
ln -s /etc/sv/virtlogd /var/service

it is not in xbps so need to manually download from [https://www.kraxel.org/repos/jenkins/edk2/](https://www.kraxel.org/repos/jenkins/edk2/) as of the writing of this build. Download the ovmf appropriate either 32 or 64 bit version then use

install rpmextract package xbps

    rpm2cpio <file>.rpm | xz -d | cpio -idmv

otherwise you could try:

    rpm2cpio <file>.rpm | lzma -d | cpio -idmv

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
