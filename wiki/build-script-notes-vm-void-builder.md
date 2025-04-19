# Void Builder VM Configuration

## VM Configuration {#vm-configuration}

Thanks to [this link](https://trent.utfs.org/wiki/Void_Linux#Xen_DomU) for good instructions on the first couple of steps.

1.	Download a RootFS image from the usual void linux download location. 
2.	Create a base disk image using the following command `qemu-img create -f raw void_builder.img 20G`.
3.	Create an ext4 filesystem on the raw image using `mkfs.ext4 void_builder.img`.
4.	You can confirm that the filesystem was created by running `file void_builder.img` and looking for `ext4` in the output.
5.	`sudo mkdir /mnt/disk` if it doesn't exist already.
6.	Run `mount -t ext4 void_builder.img /mnt/disk` to mount the new disk image temporarily.
7.	Now extract the rootfs onto the image using `tar`. `tar -C /mnt/disk/ -xvf void-x86_64-ROOTFS-{date}.tar.xz`
8.	Unmount the image after extracting the rootfs with `umount /mnt/disk`
9.	Copy the image you created to the image store at `/nas/vm-store/`
10.	Create the file `/usr/local/etc/xen/void_builder.cfg` with the following contents:
    ```config
    name = "void_builder"
    type = "pvh"
    kernel = "/nas/vm-store/void_builder/vmlinuz-6.12.23_1"
    ramdisk = "/nas/vm-store/void_builder/initramfs-6.12.23_1.img"
    # extra kernel command line options
    extra = "root=/dev/xvd1 rootfstype=ext4"
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
