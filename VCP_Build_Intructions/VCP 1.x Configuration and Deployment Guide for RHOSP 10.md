# VCP 1.x Configuration and Deployment Guide for Openstack Newton (RHOSP 10) on RHEL 7.7
- RHEL 7.7 is required to match VCP environment  
- This deployment is meant for SR-IOV only on the Intel x520 NIC  
- This guide builds everything using the admin tenant  
- This deployment consists of one controller node and two compute nodes all of which are  Dell PowerEdge R640 servers  

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

## Preparing RHEL servers for Openstack Installation  

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

Disable permanently   
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





