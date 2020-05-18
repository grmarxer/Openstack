# VCP 1.x Configuration and Deployment Guide for Openstack Newton (RHOSP 10) on RHEL 7.7
- RHEL 7.7 is required to match VCP environment  
- This deployment is meant for SR-IOV only on the Intel x520 NIC  
- This guide builds everything using the admin tenant  
- This deployment consists of one controller node and two compute nodes all of which are  Dell PowerEdge R640 servers  
-  This procedure is performed as the root user.  

## Enable SR-IOV in the BIOS on the PowerEdge R640 using iDRAC (Compute Nodes Only)  

1.  Log into iDRAC using the IPMI IP address  
```
# Compute Nodes
newton2.pl.pdsea.f5net.com
IPMI = 10.144.19.241
 
newton3.pl.pdsea.f5net.com
IPMI = 10.144.19.239  
```

2.  Navigate to Virtual Console and Open it (bottom right hand side of iDRAC screen)  
3.  Choose the power button and select Reset System (warm boot)  
4.  Enter the System Setup - BIOS configuration by pressing F2  
5.  Select System BIOS > Processor Settings and enable Virtual Technology  

<br/>  

![Image](https://github.com/grmarxer/Openstack/blob/master/VCP_Build_Intructions/illustrations/BIOS-ProcessorSettings.PNG)  

6.  Click Back  
7.  Select Integrated Devices and enable SR-IOV Global Enable  
<br/>  

![Image](https://github.com/grmarxer/Openstack/blob/master/VCP_Build_Intructions/illustrations/BIOS-IntegratedDevices.PNG)  


8.  Click Back then Finish  
9.  From the System Setup Main Menu - select Device Settings  
10. For each NIC Card that is recognized by the Dell BIOS that will be used for SRIOV select that NIC here.  
    __NOTE:__  For this lab only the Intel x520's will be used.  Since the x520's in these servers are not Dell branded they are not recognized by the BIOS so the following steps are not required.  Since there are also Intel x710 NIC cards in these servers that are Dell branded and recognized by the BIOS I have included the steps below for completeness.  
11. Navigate to the Device Level Configuration  
12. For Virtualization Mode choose SR-IOV from the drop down menu  
<br/>  

![Image](https://github.com/grmarxer/Openstack/blob/master/VCP_Build_Intructions/illustrations/BIOS-DeviceLevelSetting.PNG)  

13. Select Back, then Finish, then Finish again, and Finish again  
14. Select Yes to exit and boot.  



## Install RHEL 7.7 using Dell idrac  

1.  Download rhel-server-7.7-x86_64-dvd.iso from Redhat to your local machine
2.  Log into iDRAC using the IPMI IP address  
```
#Controller Node
newton1.pl.pdsea.f5net.com
IPMI = 10.144.19.243

# Compute Nodes
newton2.pl.pdsea.f5net.com
IPMI = 10.144.19.241
 
newton3.pl.pdsea.f5net.com
IPMI = 10.144.19.239  
```
3.  Navigate to Virtual Console and Open it (bottom right hand side of iDRAC screen)  
4.  Select Connect Virtual Media and map the image downloaded above to MAP CD/DVD  

<br/>  

![Image](https://github.com/grmarxer/Openstack/blob/master/VCP_Build_Intructions/illustrations/iDRAC_VirtualMedia.PNG)  

5.  Select Close
6.  Select Boot and double click on Virtual CD/DVD/ISO
<br/>  

![Image](https://github.com/grmarxer/Openstack/blob/master/VCP_Build_Intructions/illustrations/iDRAC_BootControl.PNG) 

7.  iDRAC will ask you to confirm that you want to boot from Virtual CD/DVD/ISO - Select Yes
8.  Choose the power button and select Reset System (warm boot)  
9.  The RHEL Installer UI will begin  
    - Use infastructure server for all nodes  
    - Each server has two virtual disks  
        - For the Controller node use the 446 GB Virtual Disk  
        - For the Compute Nodes use the 3575 GB Virtual Disk  
    - Configure EM1 on each server as the management NIC
    - Use the information below for the server naming convention and IP addressing  
```
#Controller Node
newton1.pl.pdsea.f5net.com
MGMT = 10.144.19.242
Netmask = 255.255.240.0
Gateway = 10.144.31.254
DNS = 10.144.31.146

#Compute Nodes
newton2.pl.pdsea.f5net.com
MGMT = 10.144.19.240
Netmask = 255.255.240.0
Gateway = 10.144.31.254
DNS = 10.144.31.146
 
newton3.pl.pdsea.f5net.com
MGMT = 10.144.19.238
Netmask = 255.255.240.0
Gateway = 10.144.31.254
DNS = 10.144.31.146 
```  

10. Once you have successfully installed RHEL 7.7 and rebooted be sure to unmap the image you mapped above.

## Preparing RHEL servers for OpenStack Installation  

Configure the /etc/hosts file  
```
vi /etc/hosts
```  
Add the following to /etc/hosts
```
# Controller
10.144.19.242 newton1
10.144.19.242 newton1.pl.pdsea.f5net.com

# Compute Nodes
10.144.19.240 newton2
10.144.19.240 newton2.pl.pdsea.f5net.com
10.144.19.238 newton3
10.144.19.238 newton3.pl.pdsea.f5net.com
```  
Setup NTP  
```
vi /etc/chrony.conf
``` 

Remove the existing servers and replace with the following.  
```
server ntp.pdsea.f5net.com
```  

Enable and Start the chronyd.service  
```
systemctl enable chronyd.service
systemctl start chronyd.service
``` 
Verify NTP is working properly  
```
chronyc sources
```  

Stop and Disable the firewalld.service  
```
systemctl stop firewalld.service
systemctl disable firewalld.service
```

Verify the firewalld.service is inactive  
```
systemctl status firewalld.service
```  

Disable SELinux (requires reboot)  

```
vi /etc/selinux/config
```  

Set the following to disabled  
```
SELINUX=disabled
```  
```
reboot
```  

Verify SELinux has been disabled  
```
sestatus
``` 

We need to make sure none of the NICs used for this procedure will be controller by the RHEL Network Manager.  To do so each NIC ifcfg file will need to have "NM_CONTROLLED" set to no.  
- The NICs used for this procedure are EM1, p3p1, p3p2, and p2p1.  
- EM1 is the management interface, and the "p" interfaces are the SR-IOV interfaces  

For example
```
vi /etc/sysconfig/network-scripts/ifcfg-em1
```  
```
TYPE="Ethernet"
BOOTPROTO="none"
NAME="em1"
DEVICE="em1"
ONBOOT="yes"
NM_CONTROLLED="no"
```  
__NOTE:__ You also need to make sure you have "ONBOOT" set to yes and "BOOTPROTO" set to none for each of the NICs above. 

Disable RHEL Network Manager on all Nodes (Controller and Compute) 
```
systemctl disable NetworkManager
systemctl stop NetworkManager
```
Verify Network Manager is inactive
```
systemctl status NetworkManager
``` 

Enable RHEL Network to replace Network Manager on all Nodes (Controller and Compute) 

```
systemctl enable network
systemctl start network
``` 
Verify RHEL Network is active  
```
systemctl status network
```  

We now need to connect our RHEL server to the Redhat Subscription Service.  This steps requires an Active RHEL account.  You will need an active username and password.  

This must be performed on all Nodes (Controller and Compute)  

```
subscription-manager register  --force
```  
```
subscription-manager attach
```  
If any of the two steps fails above you have an issue with your Redhat account.  

We now need to set our Redhat subscription to RHEL 7.7 to ensure the kernel does not get upgrade during a yum update.

```
[root@newton3 ~]# subscription-manager release --list
+-------------------------------------------+
          Available Releases
+-------------------------------------------+
7.0
7.1
7.2
7.3
7.4
7.5
7.6
7.7
7.8
7Server
``` 
```
[root@newton3 ~]# subscription-manager release --set=7.7
Release set to: 7.7
```

Next we need to attach the RHEL Openstack subscription to our nodes (Controller and Compute).  This is done by using a Pool ID.  

To find the Openstack Pool ID for your subscription use the following

```
subscription-manager list --available --all | grep -i -A 50 "Red Hat OpenStack Platform, Standard Support"
``` 

In this example the Pool ID: 8a85f99c71eff3f4017219e2ebca5c3b

```
[root@newton2 ~]# subscription-manager list --available --all | grep -i -A 50 "Red Hat OpenStack Platform, Standard Support"
Subscription Name:   Red Hat OpenStack Platform, Standard Support (4 Sockets, NFR, Partner Only)
Provides:            dotNET on RHEL Beta (for RHEL Server)
                     Red Hat CodeReady Linux Builder for x86_64
                     Red Hat Enterprise Linux FDIO Early Access (RHEL 7 Server)
                     Red Hat Ansible Engine
                     Red Hat Ceph Storage
                     Red Hat OpenStack Certification Test Suite
                     Red Hat Software Collections (for RHEL Server for IBM Power LE)
                     Red Hat Enterprise Linux Atomic Host Beta
                     Red Hat Enterprise Linux Fast Datapath
                     Red Hat OpenStack Beta
                     Red Hat CloudForms
                     Red Hat Software Collections Beta (for RHEL Server for IBM Power LE)
                     Red Hat Enterprise Linux Load Balancer (for RHEL Server)
                     Red Hat Enterprise Linux Advanced Virtualization Beta
                     Red Hat Beta
                     Red Hat Enterprise Linux Fast Datapath (for RHEL Server for IBM Power LE)
                     Red Hat Enterprise Linux High Availability for Power, little endian
                     Red Hat Enterprise Linux High Availability for x86_64
                     Red Hat Single Sign-On
                     dotNET on RHEL (for RHEL Server)
                     Red Hat Certification (for RHEL Server)
                     Red Hat Ceph Storage Calamari
                     Red Hat Developer Tools (for RHEL Server for IBM Power LE)
                     Red Hat OpenStack Beta Certification Test Suite
                     Red Hat Enterprise Linux Advanced Virtualization
                     Red Hat CloudForms Beta
                     Red Hat Developer Tools Beta (for RHEL Server for IBM Power LE)
                     Red Hat Enterprise Linux High Availability (for IBM Power LE) - Extended Update Support
                     Red Hat OpenStack Beta for IBM Power LE
                     Red Hat Enterprise Linux Fast Datapath Beta for Power, little endian
                     Red Hat Software Collections (for RHEL Server)
                     Red Hat OpenStack
                     Red Hat Enterprise Linux Server (for IBM Power LE) - Update Services for SAP Solutions
                     Red Hat Enterprise Linux for Power 9
                     Red Hat Enterprise Linux Atomic Host
                     Red Hat OpenStack for IBM Power
                     Red Hat Enterprise Linux for Real Time for NFV
                     Red Hat Enterprise Linux Fast Datapath Beta for x86_64
                     Red Hat Enterprise MRG Messaging
                     Red Hat Software Collections Beta (for RHEL Server)
                     Red Hat Enterprise Linux Server
                     Red Hat Enterprise Linux for x86_64
                     Red Hat Ceph Storage MON
                     Red Hat Enterprise Linux FDIO (RHEL 7 Server)
SKU:                 SER0505
Contract:            12213256
Pool ID:             8a85f99c71eff3f4017219e2ebca5c3b
Provides Management: No
Available:           75
Suggested:           1
```  

To attach the "Red Hat OpenStack Platform, Standard Support" subscription apply the following based on the above "Pool ID"  

```
subscription-manager attach --pool=8a85f99c71eff3f4017219e2ebca5c3b
``` 

Once the step above completes
```
yum update -y
```
```
reboot
```  

### Enabling SR-IOV Virtual Functions (Compute Nodes Only) 

In the following steps will be enabling the Virtual Functions (VF's) for intel x520 NICs.
In this procedure the x520's are installed in server slots two and three.  Each x520 NIC has two ports, thus we are using p3p1, p3p2, and p2p1.  

__NOTE:__ Since the x520 uses the same driver across all ports we only need to perform these steps for a single port, in this example p3p1.  

__NOTE:__ SR-IOV VF's are only enabled on the Compute Nodes.  

Run this command to determine the driver being used by the x520 NIC  
```
[root@newton2 ~]# ethtool -i p3p1 | grep ^driver
driver: ixgbe
```

Next we will use "modprobe" to add the VF's  
```
modprobe -r ixgbe
``` 
This will create seven VF's per x520 port.  
```
modprobe ixgbe max_vfs=7
```  
```
echo "options ixgbe max_vfs=7" >>/etc/modprobe.d/ixgbe.conf
```

Next we need to create a "modprobe" blacklist so the correct drivers load on the physical NIC (PF) and not the VF's

Create the following file and add the contents below.  
```
vi /etc/modprobe.d/blacklist-intel_virtual.conf
```  
```
# These drivers take over Intel nic virtual-functions, making them
# unavailable for direct assignment to virtual-machines

blacklist ixgbevf
blacklist i40evf
blacklist iavf
``` 

Next we need to rebuild the RHEL ramdisk image to accomidate the changes we made above.  

```
cp /boot/initramfs-$(uname -r).img /boot/initramfs-$(uname -r).bak.$(date +%m-%d-%H%M%S).img
```  
```
dracut -f -v
``` 

You will need to parse the following out of the "dracut" command run above.  This is the last line of output.  

__NOTE:___ This output will vary so you need to make sure you do this step precisely.  

```
*** Creating initramfs image file '/boot/initramfs-3.10.0-1062.18.1.el7.x86_64.img' done ***
```  

You now need to take the output from above and create the following entry.  

__NOTE:__ This step involves adding "3.10.0-1062.18.1.el7.x86_64" to the end of the command  
```
dracut -f /boot/initramfs-3.10.0-1062.18.1.el7.x86_64.img 3.10.0-1062.18.1.el7.x86_64
```

Once the step above completes remake the grub config  

```
grub2-mkconfig -o /boot/grub2/grub.cfg
```
```
grubby --update-kernel=ALL --args="intel_iommu=pt ixgbe.max_vfs=7"
```  

Next we need to enable virutalization passthrough on the Compute host.  This is done by enabling IOMMU by editing the grub configuration file.

Edit the following file  

```
vi /etc/default/grub
```

Add the following to the end of "GRUB_CMDLINE_LINUX"  

__NOTE:___ DO NOT REMOVE ANYTHING from "GRUB_CMDLINE_LINUX"
```
intel_iommu=on iommu=pt
```

When complete your "GRUB_CMDLINE_LINUX" line should look something like this.  
```
GRUB_CMDLINE_LINUX="crashkernel=auto spectre_v2=retpoline rd.lvm.lv=rhel00/root rd.lvm.lv=rhel00/swap rhgb quiet default_hugepagesz=1GB hugepagesz=1G hugepages=12 intel_iommu=on iommu=pt"
```  
Refresh the grub.cfg file and reboot the host for these changes to take effect  
```
grub2-mkconfig -o /boot/efi/EFI/redhat/grub.cfg
```  
```
reboot
```

















