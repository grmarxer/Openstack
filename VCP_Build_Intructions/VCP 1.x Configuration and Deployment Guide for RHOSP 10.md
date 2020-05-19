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

<br/>  

## Preparing RHEL servers for OpenStack Installation  

### Configure the /etc/hosts file  
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
<br/>  

### Setup NTP  

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
<br/>  

### Stop and Disable the firewalld.service  
```
systemctl stop firewalld.service
systemctl disable firewalld.service
```

Verify the firewalld.service is inactive  
```
systemctl status firewalld.service
```  
<br/>  

### Disable SELinux (requires reboot)  

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
<br/>  

### Create Bridge Interface -- Compute Nodes Only  

Although we will use EM1 to manage the Compute and Controller nodes directly, we need a mechanism for passing that same management network into an Openstack tenant so it can be assigned to the mgmt interface of a BIG-IP instance.  

The way we will do that is by creating a bridge interface on each of the compute nodes and linking that bridge interface to EM2.  EM2 will be a layer 2 connection only to the same switch vlan that is connected to EM1.  Thus when we assign the mgmt network to a BIG-IP instance it will bridge through OVS > br-mgmt > EM2.  

<br/>
Create the bridge interface on both Compute Nodes.

```
vi /etc/sysconfig/network-scripts/ifcfg-br-mgmt
``` 

```
DEVICE=br-mgmt
TYPE=OVSBridge
DEVICETYPE=ovs
ONBOOT=yes
NM_CONTROLLED=no
BOOTPROTO=none
```  
<br/>

Update the EM2 ifcfg file on both Compute nodes to make sure the settings below are included  

```
vi  /etc/sysconfig/network-scripts/ifcfg-em2
```  
```
BOOTPROTO=none
ONBOOT=yes
NM_CONTROLLED=no
TYPE=OVSPort
DEVICETYPE=ovs
OVS_BRIDGE=br-mgmt
```  

<br/>

### Update NIC Settings --  ALL Nodes  

We need to ensure that we fine tune the settings for all of the NIC cards we will be using in this solution.  We have already updated EM2 on the Compute nodes.    
We now need to update EM1 on the Controller Node and EM1, p3p1, p3p2, p2p1 on the Compute nodes  

Summary of changes required: 
- Disable RHEL Network Manager  - NM_CONTROLLED=no
- Change "onboot" to yes - ONBOOT=yes
- Change "boot" protocol to none - BOOTPROTO="none"

<br/>  
Controller Node (NIC - EM1 Only)
```
vi /etc/sysconfig/network-scripts/ifcfg-em1
```  
```
BOOTPROTO="none"
ONBOOT="yes"
NM_CONTROLLED="no"
```  
<br/>  
Compute Nodes (NIC - EM1, p3p1, p3p2, p2p1)  

```
vi /etc/sysconfig/network-scripts/ifcfg-xxx
```  
```
BOOTPROTO=none
ONBOOT=yes
NM_CONTROLLED=no
```  



### Disable RHEL Network Manager on all Nodes (Controller and Compute) 
```
systemctl disable NetworkManager
systemctl stop NetworkManager
```
Verify Network Manager is inactive
```
systemctl status NetworkManager
``` 

### Enable RHEL Network to replace Network Manager on all Nodes (Controller and Compute) 

```
systemctl enable network
systemctl start network
``` 
Verify RHEL Network is active  
```
systemctl status network
```  

### Enable Redhat Subscription Service  

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

__NOTE:__ DO NOT REMOVE ANYTHING from "GRUB_CMDLINE_LINUX"
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

### Verify Virtualization and SR-IOV is configured properly  

Once the server has rebooted we need to ensure virtualization and SR-IOV has been configured properly.  If your output varies from what I have below a step did not complete.

Verify the VF's have been enabled for each PF.

Run this command for each port: p3p1, p3p2, and p2p1  
```
[root@newton2 ~]# ip l show dev p3p1
8: p3p1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP mode DEFAULT group default qlen 1000
    link/ether f8:f2:1e:88:e2:bc brd ff:ff:ff:ff:ff:ff
    vf 0 MAC 00:00:00:00:00:00, spoof checking on, link-state auto, trust off, query_rss off
    vf 1 MAC 00:00:00:00:00:00, spoof checking on, link-state auto, trust off, query_rss off
    vf 2 MAC 00:00:00:00:00:00, spoof checking on, link-state auto, trust off, query_rss off
    vf 3 MAC 00:00:00:00:00:00, spoof checking on, link-state auto, trust off, query_rss off
    vf 4 MAC 00:00:00:00:00:00, spoof checking on, link-state auto, trust off, query_rss off
    vf 5 MAC 00:00:00:00:00:00, spoof checking on, link-state auto, trust off, query_rss off
    vf 6 MAC 00:00:00:00:00:00, spoof checking on, link-state auto, trust off, query_rss off
```  

You should see 7 VF's were created for each PF (vf0-vf6)  

Verify that virtualization has been enable on the Compute host

```
[root@newton2 ~]# virt-host-validate
  QEMU: Checking for hardware virtualization                                 : PASS
  QEMU: Checking if device /dev/kvm exists                                   : PASS
  ...
  ...
  QEMU: Checking if IOMMU is enabled by kernel                               : PASS
  ...
```  

The only item that should fail above is the following:  
```
LXC: Checking if device /sys/fs/fuse/connections exists
```

We will now make sure the appropriate drivers were installed for both the PF's and the VF's  

Check the Physical Functions (PF's)  

__Note:__ You should have 4 entries returned, one for each x520 physical port  

```
lspci -v | grep -A 15 "Intel Corporation 82599ES 10-Gigabit SFI/SFP+ Network Connection"
```  
You should see the following at the bottom of each entry  

```
        Kernel driver in use: ixgbe
        Kernel modules: ixgbe
```  

Check the Virtual Functions (VF's)  

__Note:__ You should have 28 entries returned, seven VF's for each x520 physical port  

```
lspci -v | grep -A 15 "82599 Ethernet Controller Virtual Function"
```  

You should see the following at the bottom of each entry 

```
        Capabilities: [150] Alternative Routing-ID Interpretation (ARI)
        Kernel modules: ixgbevf
```  
__NOTICE:__ The VF's do not have a "Kernel driver in use"  


## Install the following Repositories and Packages (Controller and Compute Nodes)

```
subscription-manager repos --enable=rhel-7-server-rh-common-rpms
subscription-manager repos --enable=rhel-7-server-extras-rpms
subscription-manager repos --enable=rhel-7-server-openstack-10-rpms
subscription-manager repos --enable=rhel-7-server-openstack-10-devtools-rpms
``` 

```
yum install yum-utils
```

```
yum install -y openstack-heat-* python-heatclient openstack-utils
```
```
yum install python-setuptools
```
```
yum update -y
```
```
reboot
```

## Install Openstack-Packstack on the Controller Only  

We will use openstack-packstack to install Openstack Newton (RHOSP 10) for simplicity sake.  Openstack-packstack is a utility that will perform approximately 90% of the necessary Openstack Configuration.  It's a much less painless process then attempting a manual installtion of Openstack.  Once we deploy the "answer-file" and the openstack-packstack installation is complete we will have to make a few minor chnages.  The opentack-packstack "answer-file" is used to push the configuration objects we want to use to the openstack-packstack installer.  

__Note:__ Packstack and its answer file are only used on the Controller node.

```
yum install -y openstack-packstack
```  

Generate the openstack packstack answer file.  The openstack-packstack "answer-file" will be generated in the root directory with the name "packstack-answer"  

```
packstack --gen-answer-file=packstack-answer
```  

We will not use the "packstack-answer" file created above.  I have a configured "packstack-answer" file that has been configured with the settings to use in this lab.  If you wish you can do a diff on the two files to note the changes.  


Use this command to deploy the openstack-packstack "answer-file"

```
packstack --answer-file=
```  




To use right disk for building instances (done on each compute)
vi /etc/nova/nova.conf
instances_path=/home
chmod 777 /home









