<h1 id="top">Windows 10 VM Build Script and Notes</h1>

This is the build script and notes for the Windows 10 VM.

<h2 id="notes">Notes</h2>

<h2 id="build-script">Build Script</h2>

<h3 id="initial-configuration">Initial Configuration</h3>


<h4 id="windows-installation">Windows Installation</h4>

1.  Download a copy of Windows 10 Education from Microsoft

2.	Set win10 iso as CD drive in `vm-manager.sh` script.

3.	Comment out NIC declaration in script so the vm doesn't have an internet
	connection during windows installation.

4.	Create qcow2 disk image if not reusing an existing one.

5.	Start windows install process. Select Language, Time and Keyboard options
	then press next.

6.	Click Install Now.

7.	Accept Terms and Conditions

8.	Select Custom: Install Windows Only.

9.	Let windows autopartition drive.

10.	Wait for several reboots

11.	Select Customize Settings option on Express Settings Prompt.

12.	Turn off all Privacy and tracking options

13.	When prompted to create an account, click join a Domain and follow prompts
	to create a local account.

14.	After setup is finished, uninstall all apps that can be uninstalled, and
	clean up the start menu.

15.	Shutdown VM

16.	uncomment NIC declaration in script, and comment out CDROM declaration.

```tags
build-script, void-linux,laptop, lenovo, notes
```
