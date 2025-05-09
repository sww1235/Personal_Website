# Base Void Linux Machine Configuration

These steps should be followed roughly in order but may not be applicable on all installs.

## Initial Installation {#initial-installation}

1.	Login as `root` with password `voidlinux`.

2.	Run `void-installer`.

3.	Set keymap to `us`.

4.	Set network as defined in IPAM tool.

5.	Select local for the source.

6.	Set hostname correctly.

7.	Set locale to `en_US.UTF-8`.

8.	Set timezone to `America/Denver`.

9.	Set root password from password manager.

10.	Create user with name `toxicsauce` and password from password manager.

11.	Create partitions as necessary.

12.	Create filesystems as necessary.

13.	Select install.

14.	Enable/disable services as necessary

## Fix $TERM {#fix-term}

This is a problem caused by using `st` as my main terminal emulator on my
laptop and workstation which has a different `$TERM` entry with associated
`terminfo` file that is not available on systems without `st` installed on it.
This is the fix for systems that are never going to have graphical terminals
installed on them or FreeBSD systems.

1.	Edit `/etc/ssh/sshd_config` on the remote machine and change the line
	`#PermitRootLogin prohibit-password` to: `PermitRootLogin yes`. This can be
	quickly accomplished with the command: `$ sudo sed -i 's/#PermitRootLogin
	prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config`. This
	temporarily enables root ssh login with a password.

2.	Restart the `sshd` service on the remote machine.

3.	On a machine with `st` installed on it, run the following command,
	replacing `remote-host` with the correct hostname. `infocmp | ssh
	root@remote-host "tic -"`

4.	Re-ssh into remote machine and revert back the changes to
	`/etc/ssh/sshd_config` made in step 1.

5.	Restart the `sshd` service on the remote machine.
