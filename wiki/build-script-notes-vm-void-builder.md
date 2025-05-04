# Void Builder VM Configuration

On each 
## VM Configuration {#vm-configuration}

Thanks to [this link](https://trent.utfs.org/wiki/Void_Linux#Xen_DomU) for good instructions on the first couple of steps.

Instructions on how to mount `.img` files on FreeBSD from [here](https://gist.github.com/yzgyyang/4965d5673b5c79c644a695dd75fa8e05)

1.	Download a RootFS image from the usual void linux download location.
2.	If doing this on FreeBSD, you need to install the `linux-utils` and `qemu-img` packages
3.	Create a base disk image using the following command `qemu-img create -f raw void_builder.img 20G`.
4.	Create the file `/usr/local/etc/xen/void_builder.cfg` with the following contents:
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
