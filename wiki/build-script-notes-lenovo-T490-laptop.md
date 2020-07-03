<h1 id="top">Rack Monitor Build Script and Notes</h1>

This is the build script and notes for the raspberry pi that monitors my Rack and 


<h2 id="notes">Notes</h2>

-

<h2 id="build-script">Build Script</h2>

<h3 id="initial-configuration">Initial Configuration</h3>

Laptop will start from factory with preinstalled Windows 10 Pro + bloatware. Reimage then setup dual booting.

<h4 id="windows-installation">Windows Installation</h4>

1. Download a copy of Windows 10 Pro from Microsoft 

2. Create bootable USB stick using instructions on Microsoft website.

3. Disable fast boot in preinstalled windows.

	1. Go to Settings -> System -> Power & Sleep -> Additional Power Settings -> Choose What Power Buttons Do -> Change settings that are currently unavailable
	2. Uncheck "Turn on Fast Startup". This prevents skipping the BIOS screen.

3. Verify BIOS is set to allow booting from USB sticks. Also verify that BIOS is only set to UEFI mode

4. Make sure laptop does not have an internet connection. This allows for the creation of a local user account without a Microsoft account.

5. Insert USB stick and boot. Hit enter to interrupt startup, then select USB stick as boot drive.

6. Start windows install process. Select Language, Time and Keyboard options then press next.

7. Click Install Now.

8. Accept Terms and Conditions

9. Select Custom: Install Windows Only.

10. Wipe out all existing partitions on the main SSD, then create the following:

	- A main 120GB partition for windows
	- A 500GB partition for passthrough between Windows and Linux OS installs.

    These will both be NTFS. Windowe will create additional partitions at the beginning of the partition list for recovery ETC.

11. Select the 120GB partiton to install windows on.

12. Wait for several reboots

13. Select Customize Settings option on Express Settings Prompt.

14. Turn off all Privacy and tracking options

15. When prompted to create an account, click join a Domain and follow prompts to create a local account.

16. After setup is finished, uninstall all apps that can be uninstalled, and clean up the start menu.

17. Install Lenovo Vantage from Lenovo's website and make sure BIOS and drivers are installed and up to date. (Especially important for Thunderbolt devices)

<h4 id="refind-installation">rEFInd Installation</h4>

Install rEFInd boot manager. These steps are shamelessly reappropriated and modified from <https://rodsbooks.com/refind/installing.html#windows>

	1. Download rEFInd as a binary ZIP file from reputable sources, currently: <https://rodsbooks.com/refind/getting.html>
	2. Unzip the file in a place you can find it. Usually Desktop or Downloads is best.
	3. Open an Administrator Command Prompt.
   	4. Type `mountvol S: /S` in the Administrator Command Prompt window. This makes the ESP accessible as drive S: from that window. (You can use a drive identifier other than S: if you like.)
    	5. Use `CD` command to change into the main rEFInd package directory, so that the refind subdirectory is visible when you type dir.
    	6. Type `xcopy /E refind S:\EFI\refind\` to copy the refind directory tree to the ESP's EFI directory. If you omit the trailing backslash from this command, xcopy will ask if you want to create the refind directory. Tell it to do so.
    	7. Type `S:` to change to the ESP. (This changes which drive is active in Command Prompt)
    	8. Type `cd EFI\refind` to change into the refind subdirectory
    	9. Delete the  drivers_ia32, refind_ia32.efi, tools_ia32, drivers_aa64, refind_aa64.efi and tools_aa64 files and directories using the `DEL` command. Unnecessary drivers will slow the rEFInd start process.
    	10. Type `rename refind.conf-sample refind.conf` to rename rEFInd's configuration file.
    	11. Type `bcdedit /set "{bootmgr}" path \EFI\refind\refind_x64.efi` to set rEFInd as the default EFI boot program. Note that "{bootmgr}" is entered as such, including both the quotes and braces ({}).
    	12. Type `bcdedit /set "{bootmgr}" description "rEFInd description"` to set a description (change rEFInd description as you see fit).

Now, when the laptop is rebooted, rEFInd should present itself with an option to boot into windows 10.

<h4 id="void-linux-installation">Void Linux Installation</h4>

1. Download a copy of `void-live-x86_64-date.iso` from reputable sources, currently: <https://alpha.de.repo.voidlinux.org/live/current/>
2. Create bootable USB stick using `dd` or whatever windows tool is the popular thing and preferably doesn't use electron.


3. Use `cfdisk` to expand main partition from 2GB to remaining size of MicroSD card.

4. Login as root with default password of `void-linux`

5. Need to get correct time and network set up in order to update system and install packages (as root)
   Remember that the only available text editor is `vi`!

	1. Configure static IP address by editing `/etc/dhcpd.conf` with the following lines at the bottom of the file.
	   Actual IP addresses are found in the network documentation.
	   We use DHCP rather than manual `ip` commands in `/etc/rc.local` to take advantage of other aspects of DHCP including auto DNS server population and domain name.
		```conf
		interface eth0
		static ip_address=$IPaddress
		static routers=$defaultgateway
		```

	2. edit `/etc/rc.conf` and change the following lines to set keymap and timezone
		```conf
		TIMEZONE="America/Denver" # or appropriate timezone
		KEYMAP="us"
		```

	3. Enable NTP and DHCP services
		```bash
		ln -s /etc/sv/ntpd /var/service
		ln -s /etc/sv/dhcpcd /var/service
		```

	4. Check `/etc/ntpd.conf` for constraints line, and comment out. This doesn't work on Raspi due to lack of HWCLK
	
	5. Create new non-root user, replacing $newusername with the actual name of the user.
	   This command adds the user to the wheel group, which allows `sudo` access
		```bash
		useradd -m -s /bin/bash -U -G wheel,users,audio,video,cdrom,input $newusername
		```
	
	6. Set system hostname by editing `/etc/hostname`

6. Reboot the system using `reboot` command. This should allow DHCP and NTP to do their thing and allow us to update the system and install new packages.

7. Log in as the new user you created

8. Update the system by running the following command until there is no output.
	```bash
	sudo xbps-install -Svu
	```

9. Install and remove the following packages. Want to use simpler NTP implementation.
	```bash
	sudo xbps-install nano network-ups-tools openntpd rng-tools thefuck vim htop
	sudo xbps-remove chrony
	```

<h3 id="nut-config">NUT Configuration</h3>

Config files for Network UPS Tool (NUT) are found at `/etc/ups/`

`nut.conf` has a few global config options, which are not important on void.

`ups.conf` is where you configure what UPSes the system will be interacting with

`upsd.conf` is the configuration for the UPS data server

Configuration steps as follows:

1. Edit `/etc/ups/nut.conf` and set `MODE=netserver`. This is not strictly required on void, but still better to set.

2. Run `nut-scanner` to generate config options for attached UPSes

3. Edit `/etc/ups/ups.conf` and add the results of `nut-scanner` to the begining of the file, except the vendor line. Add `[cyberpower]` before.
   See syntax examples in config file.

4. Edit `/etc/ups/upsd.conf` and update listen directive to the IP address of the local system.

5. Edit `/etc/ups/upsd.users` and add an `admin` user, and `upsmon` users with passwords from password safe. One `upsmon` user per machine connected to UPS.
	- admin user has set actions and all instcmds
	- upsmon user is set up per example in config file with slave attributes

Need to change ownership of config files on void linux as the default is set up incorrectly

`sudo chown root:nut /etc/ups/*`
`sudo chmod 640 /etc/ups/*`

start the following services:

 ```bash
sudo ln -s /etc/sv/upsdrvctl/ /var/service
sudo ln -s /etc/sv/upsd/ /var/service
```

check status of ups with the following command to make sure it is detected properly


```tags
build-script, rack-monitor, notes
```
