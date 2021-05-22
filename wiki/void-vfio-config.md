# Void Linux VFIO Config

install DBUS from xbps

Add iommu=pt and either:

-	For Intel CPUs (VT-d) set `intel_iommu=on`
-	For AMD CPUs (AMD-Vi) set `amd_iommu=on`

to `GRUB_CMDLINE_LINUX_DEFAULT` line in `/etc/default/grub`

confirm that iommu is on:

`dmesg | grep -e DMAR -e IOMMU`

## iommu group check

``` bash
#!/bin/bash
shopt -s nullglob
for d in /sys/kernel/iommu_groups/*/devices/*; do
    n=${d#*/iommu_groups/*}; n=${n%%/*}
    printf 'IOMMU Group %s ' "$n"
    lspci -nns "${d##*/}"
done;
```

make sure only to add pci ids of graphics card and associated audio device, not
the root if in the same group.

## configure vfio-pci

change IDs to match those found through lspci for your specific card

```
/etc/modprobe.d/vfio.conf

options vfio-pci ids=10de:13c2,10de:0fbb
```

to load kernel modules:

make file in `/etc/modules-load.d/` (may need to make directory first)

file can be called anything with a .conf after it. modules are listed one per
line. I loaded

-	`vfio`
-	`vfio-pci`
-	`vfio-virqfd`

`dracut` is used to make initramfs

its config is `/etc/dracut.conf.d/dracut.conf`

need to add kernel modules to initramfs

use `add_drivers+="vfio-pci vfio vfio_iommu_type1 vfio_virqfd"` as an example

also need to `add_dracutmodules+="kernel-modules"` in order for dracut to look at `modprobe/modules-load`

I also needed to blacklist nouvaeu on the host using a config file in
`/etc/modprobe.d/` containing `blacklist nouveau` and in dracut.conf using
`omit_drivers+="nouveau"

regen initramfs using `dracut --force` to overwrite the existing one

## getting OVMF

it is not in xbps so need to manually download from
<https://www.kraxel.org/repos/jenkins/edk2/> as of the writing of this
document. download the ovmf appropriate either 32 or 64 bit version then use

```sh
rpm2cpio <file>.rpm | xz -d | cpio -idmv
```

otherwise you could try:

```sh
rpm2cpio <file>.rpm | lzma -d | cpio -idmv
```

to extract the files needed.

install rpmextract package xbps

copy files in `./usr/share/edk2.git/ovmf-x64` to `/usr/share/ovmf`

and then set the config option in `/etc/libvirt/qemu.conf`

`nvram` to the appropriate files. smm varients include secure boot code, csm
varients include legacy compat modules.  code and vars are separate files taht
are both contained in OVMF base.

need to add user to kvm and libvirt groups
