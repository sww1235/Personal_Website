# Void Builder VM Configuration

On each 
## VM Configuration {#vm-configuration}

Thanks to [this link](https://trent.utfs.org/wiki/Void_Linux#Xen_DomU) for good instructions on the first couple of steps.

Instructions on how to mount `.img` files on FreeBSD from [here](https://gist.github.com/yzgyyang/4965d5673b5c79c644a695dd75fa8e05)

1.	Download a RootFS image from the usual void linux download location.
2.	If doing this on FreeBSD, you need to install the `linux-utils` and `qemu-img` packages
3.	Create a base disk image using the following command `qemu-img create -f raw void_builder.img 20G`.
4.	Create an ext4 filesystem on the raw image using `mkfs.ext4 void_builder.img`.
5.	You can confirm that the filesystem was created by running `file void_builder.img` and looking for `ext4` in the output.
6.	`sudo mkdir /mnt/disk` if it doesn't exist already.
7.	If on FreeBSD, use `mdconfig -a -t vnode -f /nas/vm-store/void_builder/void_builder.img -u 0` to mount the image to a virtual device.
8.	Run `mount -t ext4 void_builder.img /mnt/disk` or on FreeBSD: `mount -t ext2fs /dev/md0 /mnt/disk` to mount the new disk image temporarily.
9.	Now extract the rootfs onto the image using `tar`. `tar -C /mnt/disk/ -xvf void-x86_64-ROOTFS-{date}.tar.xz`
10.	Now you need to configure certain files within the image in order to get things booting properly.
	1.	If on FreeBSD, you must enable the linux compat service using `service linux onestart` to start it once.
	2.	Now `chroot /mnt/disk/`
 	3.	Enable the xen console agetty service with `ln -s /etc/sv/agetty-hvc0 /etc/runit/runsvdir/default/`
	4.	Exit out of the chroot.
11.	Unmount the image after extracting the rootfs with `umount /mnt/disk`
12.	If on FreeBSD, you must also remove the virtual device with `mdconfig -d -u 0`
13.	Copy the image you created to the image store at `/nas/vm-store/`
14.	Create the file `/usr/local/etc/xen/void_builder.cfg` with the following contents:
    ```config
    name = "void_builder"
    type = "pvh"
    kernel = "/nas/vm-store/void_builder/vmlinuz-6.12.23_1"
    ramdisk = "/nas/vm-store/void_builder/initramfs-6.12.23_1.img"
    # extra kernel command line options
    extra = "root=/dev/xvd1 rootfstype=ext4 console=hvc0 debug"
    # initial memory allocation (MB)
    memory = 512
    vcpus = 4
    # Network devices
    # List of virtual interface devices  or 'vifspec'
    vif = ['']
    # Disk Devices
    # a list of 'diskspec' devices
    disk=['/nas/vm-store/void_builder/void_builder.img,raw,xvd1,rw']
    ```

## Void Builder Configuration {#void-builder-config}
