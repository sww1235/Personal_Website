## Install DWM

install from xbps:

wget
gz
xrandr
make
thefuck
clang
libX11-devel
xtools
libxft
libXft-devel
libXinerama-devel
xorg-minimal
xorg-fonts
xterm


change x11 path in config.mk to /usr/include/X11

## qemu  install

sudo ln -s /etc/sv/libvirtd/ /var/service
sudo ln -s /etc/sv/virtlogd/ /var/service/
sudo ln -s /etc/sv/virtlockd/ /var/service/
sudo usermod -a -G libvirt toxic

sudo sv start libvirtd

install from xbps:
xz
rpmextract

## other tools

smartmontools
nano
firefox

start sshd sudo ln -s /etc/sv/sshd/ /var/service

## nfs-server

install nfs-utils

start nfs-server, rpcbind, statd services

edit /etc/exports
