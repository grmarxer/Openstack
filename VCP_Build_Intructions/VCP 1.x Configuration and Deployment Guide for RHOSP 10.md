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
- Change "boot protocol" to none - BOOTPROTO="none"

<br/>  

__Controller Node (NIC - EM1 Only)__ 

```
vi /etc/sysconfig/network-scripts/ifcfg-em1
```  
```
BOOTPROTO="none"
ONBOOT="yes"
NM_CONTROLLED="no"
```  

<br/>  

__Compute Nodes (NIC - EM1, p3p1, p3p2, p2p1)__ 

```
vi /etc/sysconfig/network-scripts/ifcfg-xxx
```  
```
BOOTPROTO=none
ONBOOT=yes
NM_CONTROLLED=no
```  

<br/>  

### Disable RHEL Network Manager on all Nodes (Controller and Compute) 
```
systemctl disable NetworkManager
systemctl stop NetworkManager
```
Verify Network Manager is inactive
```
systemctl status NetworkManager
``` 
<br/>   

### Enable RHEL Network to replace Network Manager on all Nodes (Controller and Compute) 

```
systemctl enable network
systemctl start network
``` 
Verify RHEL Network is active  
```
systemctl status network
```  
<br/>   

### Enable Redhat Subscription Service  

We now need to connect our RHEL server to the Redhat Subscription Service.  This steps requires an Active RHEL account.  You will need an active username and password.  

__This must be performed on all Nodes (Controller and Compute)__  

```
subscription-manager register  --force
```  
```
subscription-manager attach
```  
If any of the two steps above fail you have an issue with your Redhat account.  
<br/>  

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
<br/>  

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
<br/>  

### Enabling SR-IOV Virtual Functions (Compute Nodes Only)  

In the following steps will be enabling the Virtual Functions (VF's) for intel x520 NICs.
In this procedure the x520's are installed in server slots two and three.  Each x520 NIC has two ports, thus we are using p3p1, p3p2, and p2p1.  

__NOTE:__ Since the x520 uses the same driver across all ports we only need to perform these steps for a single port, in this example p3p1.  

__NOTE:__ SR-IOV VF's are only enabled on the Compute Nodes.  
<br/> 

Run this command to determine the driver being used by the x520 NIC  
```
[root@newton2 ~]# ethtool -i p3p1 | grep ^driver
driver: ixgbe
```
<br/> 

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
<br/> 

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
<br/> 

Next we need to rebuild the RHEL ramdisk image to accomidate the changes we made above.  

```
cp /boot/initramfs-$(uname -r).img /boot/initramfs-$(uname -r).bak.$(date +%m-%d-%H%M%S).img
```  
```
dracut -f -v
``` 
<br/> 

You will need to parse the following out of the "dracut" command run above.  This is the last line of output.  

__NOTE:__ This output will vary so you need to make sure you do this step precisely.  

```
*** Creating initramfs image file '/boot/initramfs-3.10.0-1062.18.1.el7.x86_64.img' done ***
```  
<br/> 

You now need to take the output from above and create the following entry.  

__NOTE:__ This step involves adding "3.10.0-1062.18.1.el7.x86_64" to the end of the command  
```
dracut -f /boot/initramfs-3.10.0-1062.18.1.el7.x86_64.img 3.10.0-1062.18.1.el7.x86_64
```
<br/> 

Once the step above completes remake the grub config  

```
grub2-mkconfig -o /boot/grub2/grub.cfg
```
```
grubby --update-kernel=ALL --args="intel_iommu=pt ixgbe.max_vfs=7"
```  
<br/> 

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
<br/>  

### Verify Virtualization and SR-IOV is configured properly  

Once the server has rebooted we need to ensure virtualization and SR-IOV has been configured properly.  If your output varies from what I have below a step did not complete.

Verify the VF's have been enabled for each PF.
<br/>  

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
<br/>  

Verify that virtualization has been enable on the Compute hosts

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
<br/>  

We will now make sure the appropriate drivers were installed for both the PF's and the VF's  
<br/> 

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
<br/>  

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

<br/>  

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
<br/>  

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

<br/>  

##  Fine Tuning the Openstack-packstack Installation  
<br/>  

__Compute Nodes only__ 

We need to modify the Compute nodes to use the right directory for instance creation.  
  
```
vi /etc/nova/nova.conf
```  

Change the `instances_path` to match the following  

```
instances_path=/home
```
```
wq!
``` 
<br/>  

We now need to change the permission on the /home directory  
```
chmod 777 /home
```  


__Note:__ For future troubleshooting and tracking please recall that all instances will be created in the /home directory on the compute nodes.  
<br/>  

We need to restart nova for the change above to take effect  

```
systemctl restart openstack-nova-*
``` 

<br/>  

__Controller Node only__ 

Configure the `nova.conf` file to support SR-IOV on the Controller Node 
```  
vi /etc/nova/nova.conf  
```  
<br/>  

On every controller node which is running the nova-scheduler service, we need to make sure we have the correct `scheduler_default_filters` configured.  Make sure your `scheduler_default_filters` matches the example below.     

```
scheduler_default_filters = scheduler_default_filters=RetryFilter,AvailabilityZoneFilter,RamFilter,ComputeFilter,ComputeCapabilitiesFilter,ImagePropertiesFilter,ServerGroupAntiAffinityFilter,ServerGroupAffinityFilter,PciPassthroughFilter,NUMATopologyFilter,AggregateInstanceExtraSpecsFilter,CoreFilter,DiskFilter
```
<br/>  

 We also need to add another entry for 'scheduler_available_filters' for the `PciPassthroughFilter` parameter.  Be sure your `scheduler_available_filters` matches the example below.  
``` 
scheduler_available_filters = nova.scheduler.filters.all_filters
scheduler_available_filters = nova.scheduler.filters.pci_passthrough_filter.PciPassthroughFilter
```  
```
wq!
```  
<br/>  

We now need to restart the openstack nova services  
```
systemctl restart openstack-nova-*
```  

<br/>  

##  Configuring Openstack Nova, Neutron, and Glance  

In this solution we will create everything in the admin tenant.  The demo tenant will not be used.  Also we do not need to create a neutron router as it is not required for this environment  
<br/> 

### Log into the Controller Node and source the admin credentials  

```
source keystone_admin
```

<br/>  

### Set the openstack nova quota for cores  

```
openstack quota set --cores 80 demo
```  
<br/>  

### Create the openstack neutron networks  
```
openstack network create --share --project demo --external --provider-network-type flat --provider-physical-network public public
openstack network create --share --project demo --internal --provider-network-type flat --provider-physical-network private private
openstack network create --share --project demo --internal --provider-network-type flat --provider-physical-network mirroring mirroring
openstack network create --share --project demo --internal --provider-network-type flat --provider-physical-network management management
```  
<br/>  

### Create the openstack neutron subnets

__Note:__ Use the IP addressing, DHCP ranges below as this was what assigned to this project from lab management

```
openstack subnet create --project demo --subnet-range 10.20.0.0/16 --dhcp --ip-version 4 --allocation-pool start=10.20.255.245,end=10.20.255.252 --dns-nameserver 8.8.8.8 --network public public-subnet
openstack subnet create --project demo --subnet-range 10.10.30.0/24 --dhcp --ip-version 4 --allocation-pool start=10.10.30.245,end=10.10.30.252 --dns-nameserver 8.8.8.8 --network private private-subnet
openstack subnet create --project demo --subnet-range 10.10.40.0/24 --dhcp --ip-version 4 --allocation-pool start=10.10.40.10,end=10.10.40.200 --dns-nameserver 8.8.8.8 --network mirroring mirroring-subnet
openstack subnet create --project demo --subnet-range 10.144.16.0/20 --dhcp --ip-version 4 --allocation-pool start=10.144.20.24,end=10.144.20.33 --dns-nameserver 10.144.31.146 --gateway 10.144.31.254 --network management management-subnet
```  
<br/>  

### Create the openstack neutron sr-iov ports

```
neutron port-create public --name public-sriov-p1 --binding:vnic-type direct
neutron port-create public --name public-sriov-p2 --binding:vnic-type direct
neutron port-create private --name private-sriov-p1 --binding:vnic-type direct
neutron port-create private --name private-sriov-p2 --binding:vnic-type direct
neutron port-create mirroring --name mirror-sriov-p1 --binding:vnic-type direct
neutron port-create mirroring --name mirror-sriov-p2 --binding:vnic-type direct
```
<br/>  

### Create the openstack fixed IP's that will be used by a VIP

In order for openstack to function properly you need to tell it about each IP address you want to use.  In this case we want to assign a VIP to IP address `10.20.40.200`.  Thus we need to create a fixed IP using the command below and assign it to the public network.

__Note:__ Since we are using automap in this environment we do not need to create fixed-ip's for the SNAT IP's.  If you do plan to use a SNAT pool you will need to create fixed IP's for each address in the SNAT Pool and assign them to the private network.  

```
neutron port-create --fixed-ip ip_address=10.20.40.200  public
```

__Note:__ For those of you familiar with openstack, the next step is usually assigned the fixed-ip we created above as an allowed-address pair.  We do not need to do that step in this environment as we are not using security-groups.  




### Create the openstack nova flavors

```
openstack flavor create bigip.10G --ram 16384 --disk 100 --vcpus 8
```  

### Create the openstack glance image

In order to build an openstack BIG-IP instance we need to build a openstack glance image.  To do so I recommend you download a BIG-IP VE qcow2 image to the controller.  Once the image is on the controller you can run the following command to load it into glance.

```
openstack image create "BIG-IP LTM 1-slot 15.1.0.3" \
  --file BIGIP-15.1.0.3-0.0.12-1slot.qcow2 \
  --disk-format qcow2 --container-format bare \
  --public
```  

In this example we are using BIG-IP image `BIGIP-15.1.0.3-0.0.12-1slot.qcow2`, the name of this image inside glance will be `BIG-IP LTM 1-slot 15.1.0.3` and we have made the image using the `public` property.  




```
[root@newton1 ~(keystone_admin)]# neutron port-list
+--------------------------------------+------------------+-------------------+--------------------------------------------------------------------------------------+
| id                                   | name             | mac_address       | fixed_ips                                                                            |
+--------------------------------------+------------------+-------------------+--------------------------------------------------------------------------------------+
| 055b78cf-b3c8-43ee-9c34-fa16f58c742a |                  | fa:16:3e:9d:7e:4a | {"subnet_id": "179c6604-b613-40b9-92bc-d0a88300ff00", "ip_address": "10.20.255.245"} |
| 3480c209-a158-421a-8741-636fa2aaf8fd | public-sriov-p1  | fa:16:3e:d5:1c:a8 | {"subnet_id": "179c6604-b613-40b9-92bc-d0a88300ff00", "ip_address": "10.20.255.246"} |
| 5403cfb8-a1eb-44b3-948d-fca921956f42 |                  | fa:16:3e:4a:8a:be | {"subnet_id": "8d3fbb08-2881-43c8-a795-30e344886b06", "ip_address": "10.144.20.24"}  |
| 5ffd2600-8313-4f05-b281-eab6b94c232b |                  | fa:16:3e:9f:02:18 | {"subnet_id": "7f5929c1-53ec-4bee-973b-c66f743607ca", "ip_address": "10.10.40.10"}   |
| 60e1c955-288d-4530-a491-358cc8848607 | private-sriov-p1 | fa:16:3e:f7:12:ff | {"subnet_id": "6368afb8-a25c-4a76-8341-5858705bce08", "ip_address": "10.10.30.249"}  |
| b4209819-4bff-4689-896a-ef66d11a628c |                  | fa:16:3e:e0:ca:bd | {"subnet_id": "6368afb8-a25c-4a76-8341-5858705bce08", "ip_address": "10.10.30.245"}  |
| cc20b5e7-52af-4da4-ad75-bd73aea795ed | mirror-sriov-p2  | fa:16:3e:eb:74:ee | {"subnet_id": "7f5929c1-53ec-4bee-973b-c66f743607ca", "ip_address": "10.10.40.23"}   |
| d109110e-d36c-421c-9589-1f21272d1c70 | private-sriov-p2 | fa:16:3e:ce:78:8f | {"subnet_id": "6368afb8-a25c-4a76-8341-5858705bce08", "ip_address": "10.10.30.246"}  |
| d285ef67-607e-4f15-9e64-3229d95d7d68 | public-sriov-p2  | fa:16:3e:02:31:10 | {"subnet_id": "179c6604-b613-40b9-92bc-d0a88300ff00", "ip_address": "10.20.255.247"} |
| e56c198e-7d97-4fe1-9b21-fcf16ada657a | mirror-sriov-p1  | fa:16:3e:e2:41:7f | {"subnet_id": "7f5929c1-53ec-4bee-973b-c66f743607ca", "ip_address": "10.10.40.13"}   |
+--------------------------------------+------------------+-------------------+--------------------------------------------------------------------------------------+
```  



__Note:__ We are purposely not using security groups, as you can see below we are not attaching a security group to this instance.  Since SR-IOV bypasses the openstack security groups there is no reason to apply one.  In addition if you attempt to apply a security group instance creation will error out.  


```
nova boot --flavor bigip.10G --image bigip.ltm.1-slot.15.1.0.3 \
  --nic net-name=management --nic port-id=60e1c955-288d-4530-a491-358cc8848607 \
  --nic port-id=3480c209-a158-421a-8741-636fa2aaf8fd --nic port-id=e56c198e-7d97-4fe1-9b21-fcf16ada657a    bigip.1
```  

<br/>

## CPU Pinning and NUMA Node Affinity

Rather than attempt to fool around with the Openstack settings to enable CPU pinning on instance creation it is easier to modify the BIG-IP instance created by Openstack using virsh.

This way we can easily add and remove CPU pinning at will.

In order to know what cores to pin the BIG-IP instance to you must first determine which numa node your public and private networks is attached to.  

In this example we are using `p3p1` for public and '`p3p2` for private.  

Using the following command we can see what numa node p3p1 and p3p2 is attached to

```
[root@newton3 ~]# cat /sys/class/net/p3p1/device/numa_node
1
[root@newton3 ~]# cat /sys/class/net/p3p2/device/numa_node
1
```

Using the following command we can now see what CPU's are linked to NUMA node 1

```
[root@newton3 ~]# lscpu
Architecture:          x86_64
CPU op-mode(s):        32-bit, 64-bit
Byte Order:            Little Endian
CPU(s):                80
On-line CPU(s) list:   0-79
Thread(s) per core:    2
Core(s) per socket:    20
Socket(s):             2
NUMA node(s):          2
Vendor ID:             GenuineIntel
CPU family:            6
Model:                 85
Model name:            Intel(R) Xeon(R) Gold 6138 CPU @ 2.00GHz
Stepping:              4
CPU MHz:               2000.000
BogoMIPS:              4000.00
Virtualization:        VT-x
L1d cache:             32K
L1i cache:             32K
L2 cache:              1024K
L3 cache:              28160K
NUMA node0 CPU(s):     0,2,4,6,8,10,12,14,16,18,20,22,24,26,28,30,32,34,36,38,40,42,44,46,48,50,52,54,56,58,60,62,64,66,68,70,72,74,76,78
NUMA node1 CPU(s):     1,3,5,7,9,11,13,15,17,19,21,23,25,27,29,31,33,35,37,39,41,43,45,47,49,51,53,55,57,59,61,63,65,67,69,71,73,75,77,79
```  

In our example we can see the following CPU's are attached to NUMA node 1

```
NUMA node1 CPU(s):     1,3,5,7,9,11,13,15,17,19,21,23,25,27,29,31,33,35,37,39,41,43,45,47,49,51,53,55,57,59,61,63,65,67,69,71,73,75,77,79
``` 
Although all the odd numbers are listed (1-79) we cannot use all of these to pin because the numbers greater than 39 represent hyerthreads.  Based on the output of the lscpu command above we know we have 2 sockets with 20 cores each for a total of 80 CPU's 

```
CPU(s):                80
Thread(s) per core:    2
Core(s) per socket:    20
Socket(s):             2
```  


 For optimal performance you never want TMM sharing sibling CPU's.  Thus when we assign the CPU's we want to pin we will use the following:    
```
7,9,11,13,15,17,19,21,23,25,27,29,31,33,35,37,39
```
The reason we do not use CPU 1,3, or 5 is that we want those reserved for the hosts linux operating system.  If we attempt to pin those CPU's we could step ontop of host linux processes that will decrease the performance of BIG-IP and the Host system.  The host system in this example is newton3.


In order to determine what instance we want to apply CPU pinning an NUMA node Affinity to we will use the `virsh` comamnd on the compute node that is running the BIG-IP instance in question.

To determine which compute node is running the BIG-IP instance running the following command from the controller.  

The name of the instance we built earlier above is `bigip.1`  

```
[root@newton1 ~(keystone_admin)]# nova show bigip.1
+--------------------------------------+------------------------------------------------------------------+
| Property                             | Value                                                            |
+--------------------------------------+------------------------------------------------------------------+
| OS-DCF:diskConfig                    | MANUAL                                                           |
| OS-EXT-AZ:availability_zone          | nova                                                             |
| OS-EXT-SRV-ATTR:host                 | newton2.pl.pdsea.f5net.com                                       |
| OS-EXT-SRV-ATTR:hostname             | bigip.1                                                          |
| OS-EXT-SRV-ATTR:hypervisor_hostname  | newton2.pl.pdsea.f5net.com                                       |
| OS-EXT-SRV-ATTR:instance_name        | instance-00000079                                                |
| OS-EXT-SRV-ATTR:kernel_id            |                                                                  |
| OS-EXT-SRV-ATTR:launch_index         | 0                                                                |
| OS-EXT-SRV-ATTR:ramdisk_id           |                                                                  |
| OS-EXT-SRV-ATTR:reservation_id       | r-jitk5so9                                                       |
| OS-EXT-SRV-ATTR:root_device_name     | /dev/vda                                                         |
| OS-EXT-SRV-ATTR:user_data            | -                                                                |
| OS-EXT-STS:power_state               | 1                                                                |
| OS-EXT-STS:task_state                | -                                                                |
| OS-EXT-STS:vm_state                  | active                                                           |
| OS-SRV-USG:launched_at               | 2020-05-21T23:18:35.000000                                       |
| OS-SRV-USG:terminated_at             | -                                                                |
| accessIPv4                           |                                                                  |
| accessIPv6                           |                                                                  |
| config_drive                         |                                                                  |
| created                              | 2020-05-21T23:18:26Z                                             |
| description                          | -                                                                |
| flavor                               | bigip.10G (f6c900f0-90f3-4da6-b024-768030abe226)                 |
| hostId                               | 2bf7e38934de370d834c0ae91cce70553a9a8d4d93e28b4384d10ddf         |
| host_status                          | UP                                                               |
| id                                   | bcca10a1-8551-4ba9-a8a1-866c675c457f                             |
| image                                | bigip.ltm.1-slot.15.1.0.3 (12db7981-4b2a-4306-ac3f-8be48891f8f8) |
| key_name                             | -                                                                |
| locked                               | False                                                            |
| management network                   | 10.144.20.27                                                     |
| metadata                             | {}                                                               |
| mirroring network                    | 10.10.40.13                                                      |
| name                                 | bigip.1                                                          |
| os-extended-volumes:volumes_attached | []                                                               |
| private network                      | 10.10.30.249                                                     |
| progress                             | 0                                                                |
| public network                       | 10.20.255.246                                                    |
| status                               | ACTIVE                                                           |
| tags                                 | []                                                               |
| tenant_id                            | 25040f3eb32f48638914d1107352d6f2                                 |
| updated                              | 2020-05-21T23:18:35Z                                             |
| user_id                              | 260a5d0804d64b91a75075969e0b90d2                                 |
+--------------------------------------+------------------------------------------------------------------+
```  

From this output we can see the ID of this instance is `bcca10a1-8551-4ba9-a8a1-866c675c457f`.  Now that we have this information we can go look in the `/home` directory on each of our compute nodes to see where this instance was built.

```
[root@newton2 ~]# ll /home
total 4
drwxr-xr-x 2 nova nova 54 May 19 13:50 _base
drwxr-xr-x 2 nova nova 54 May 21 16:18 bcca10a1-8551-4ba9-a8a1-866c675c457f
-rw-r--r-- 1 nova nova 49 May 21 09:52 compute_nodes
drwxr-xr-x 2 nova nova 93 May 19 13:49 locks
```  

Based on this information we now know that we want to run the `virsh` commands on newton2.

```
[root@newton2 ~]# virsh list
 Id    Name                           State
----------------------------------------------------
 1     instance-00000079              running
```  

In this step we will use the `virsh` commands below to assign the CPU ranges we want to be used for each of the 8 TMM interfaces (0-7)  

__Note:__ The BIG-IP instance needs to be running for you to assign the `virsh vcpupin`.  You DO NOT need to reboot BIG-IP for these changes to take effect.

```
virsh vcpupin instance-00000079 0 7,9,11,13,15,17,19,21,23,25,27,29,31,33,35,37,39
virsh vcpupin instance-00000079 1 7,9,11,13,15,17,19,21,23,25,27,29,31,33,35,37,39
virsh vcpupin instance-00000079 2 7,9,11,13,15,17,19,21,23,25,27,29,31,33,35,37,39
virsh vcpupin instance-00000079 3 7,9,11,13,15,17,19,21,23,25,27,29,31,33,35,37,39
virsh vcpupin instance-00000079 4 7,9,11,13,15,17,19,21,23,25,27,29,31,33,35,37,39
virsh vcpupin instance-00000079 5 7,9,11,13,15,17,19,21,23,25,27,29,31,33,35,37,39
virsh vcpupin instance-00000079 6 7,9,11,13,15,17,19,21,23,25,27,29,31,33,35,37,39
virsh vcpupin instance-00000079 7 7,9,11,13,15,17,19,21,23,25,27,29,31,33,35,37,39
```  

Using this command we can ensure that the virsh commands executed above we applied properly 

```
[root@newton2 ~]# virsh vcpupin instance-00000079
VCPU: CPU Affinity
----------------------------------
   0: 7,9,11,13,15,17,19,21,23,25,27,29,31,33,35,37,39
   1: 7,9,11,13,15,17,19,21,23,25,27,29,31,33,35,37,39
   2: 7,9,11,13,15,17,19,21,23,25,27,29,31,33,35,37,39
   3: 7,9,11,13,15,17,19,21,23,25,27,29,31,33,35,37,39
   4: 7,9,11,13,15,17,19,21,23,25,27,29,31,33,35,37,39
   5: 7,9,11,13,15,17,19,21,23,25,27,29,31,33,35,37,39
   6: 7,9,11,13,15,17,19,21,23,25,27,29,31,33,35,37,39
   7: 7,9,11,13,15,17,19,21,23,25,27,29,31,33,35,37,39

```  

Using this command you can see exactly which CPU was assigned to each of the TMM's (0-7).  

```
[root@newton2 ~]# virsh vcpuinfo instance-00000079
VCPU:           0
CPU:            7
State:          running
CPU time:       1382.9s
CPU Affinity:   -------y------------------------------------------------------------------------

VCPU:           1
CPU:            9
State:          running
CPU time:       1345.7s
CPU Affinity:   ---------y----------------------------------------------------------------------

VCPU:           2
CPU:            33
State:          running
CPU time:       1347.9s
CPU Affinity:   ---------------------------------y----------------------------------------------

VCPU:           3
CPU:            13
State:          running
CPU time:       1338.1s
CPU Affinity:   -------------y------------------------------------------------------------------

VCPU:           4
CPU:            31
State:          running
CPU time:       1341.5s
CPU Affinity:   -------------------------------y------------------------------------------------

VCPU:           5
CPU:            17
State:          running
CPU time:       1344.2s
CPU Affinity:   -----------------y--------------------------------------------------------------

VCPU:           6
CPU:            21
State:          running
CPU time:       1347.9s
CPU Affinity:   ---------------------y----------------------------------------------------------

VCPU:           7
CPU:            29
State:          running
CPU time:       1341.9s
CPU Affinity:   -----------------------------y--------------------------------------------------
```  

If you wish to remove CPU pinning it is as simple as appling a new `virsh vcpupin`.  These commands will remove all CPU pinning and NUMA node Affinity.  Once again remember that the image must be running and you do not need to reboot for these changes to take effect.

```
virsh vcpupin instance-00000079 0 0-79
virsh vcpupin instance-00000079 1 0-79
virsh vcpupin instance-00000079 2 0-79
virsh vcpupin instance-00000079 3 0-79
virsh vcpupin instance-00000079 4 0-79
virsh vcpupin instance-00000079 5 0-79
virsh vcpupin instance-00000079 6 0-79
virsh vcpupin instance-00000079 7 0-79
```  

You can verify that the changes were executed properly using the commands above.  






 
