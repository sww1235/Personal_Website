<h1 id="top">Virtualization Cluster Configuration</h1>

Documentation on setup of virtualization cluster. Some info may be split into its own page.

Current status of cluster, is 3 Intel NUCs, each running XCP-ng as a tier 1 hypervisor.


<h2 id="ind-host-setup">Individual Host Setup</h2>

<h3 id="bios-config">BIOS Configuration</h3>

1.	Boot system into BIOS by spamming `F2` key after pressing power button.

2.	Check that all RAM and CPU are properly detected on `Main` tab.

3.	Under `Advanced->Storage`: Disable SATA port since we are not using it.

4.	Under `Advanced->Onboard Devices`: Disable HD Audio, WLAN, Bluetooth,
	Gaussian Mixture Models, HDMI CEC Control, and Enable IOMMU during pre-boot

5.	Under `Advanced->Video`: Set IGD Primary Video Port to HDMI and enable `Virtual Display Emulation` under `Display Emulation`

6.	Under `Security`: Enable USB Provisioning of Intel AMT.

7.	Under `Power->Secondary Power Settings`: Change After Power Failure to
	Power On.

8.	Under `Boot->Secure Boot`: Disable Secure Boot

9.	Under `Boot->Boot Priority`: Enable Boot USB Devices First, and disable
	Boot Network Devices Last.

10.	Under `Boot->Boot Display Configuration`: Disable Suppress Alert Messages
	At Boot, and Enable F12 for network boot.

11.	Press F10 to save and Exit. On Reboot, press `CTRL-P` to get into Intel AMT configuration

<h3 id="amt-config">AMT Configuration</h3>

1.	Press `CTRL-P` at boot prompt to enter Intel AMT configuration.

2.	Hit `Enter` to login to AMT, with default password of `admin`. When
	prompted to enter new password, use password out of password manager.

3.	Under `Intel AMT Configuration->User Consent`: Change User Opt-in to NONE.

4.	Under `Intel AMT Configuration->Network Setup->Intel ME Network Name
	Settings`: Set hostname and domain to desired values. Leave Shared/Dedicated FQDN set to shared.

5.	Set static DHCP lease in DHCP server if not done already.

<h3 id="hypervisor-install">Install Hypervisor</h3>

1.	Download FreeBSD-bootonly ISO from reputable sources. Use this to reduce loading times

2.	Connect to system using Mesh Commander.

3.	Mount ISO using IDE-R, and select `Reset to IDE-R` in `Power Actions` menu.

4.	Wait for system to finish booting

5.	Select Install

6.	Select us keymap

7.	enter hostname

8.	configure network - IPv4 and DHCP

9.	use Auto (UFS) partitioning scheme and accept defaults

10.	Select default (main) FreeBSD mirror.

<h2 id="cluster-setup">Cluster Setup</h2>


```tags
cluster, virtualization, virt, NUC, xcp-ng
```
