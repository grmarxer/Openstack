# Building the Nodes for Openstack deployment  

There are four nodes in this deployment, the Undercloud Director, the Controller, and two Compute nodes.  
<br/>  

## Build the Undercloud Director Node  

<br/>  

### Node Information  
  
| **Undercloud Director Hostname**    | **IDRAC IP**  |**NIC eno3 IP Address**  |  **Netmask**   | **Gateway**   | **DNS**                |  
| :---------------------:             | :----------:  | :----------:            |  :----------:  | :----------:  | :----------:           |  
| osp16-undercloud.pl.pdsea.f5net.com | 10.144.20.6   | 10.144.16.59            |  255.255.240.0 | 10.144.31.254 | 10.144.31.146, 8.8.8.8 |  

<br/>  

### Install RHEL 8.2 on Undercloud Director  

1. Log into IDRAC IP above -- username root, password calvin  

2.  Using the IDRAC console install `rhel-8.2-x86_64-dvd.iso` on the Undercloud Node  

    - Choose server install with GUI
    - Pacific time zone  
    - hostname `osp16-undercloud.pl.pdsea.f5net.com`  
    - Configure NIC eno3 with the IP information above  
    - set the root user password to `default`  

3. Once the OS installation is complete reboot the server and ssh into the Undercloud Director using `root`
<br/>  

### Configure NTP on the Undercloud Director

1.  Edit the chrony.conf file 
    ```
    vi /etc/chrony.conf
    ```  

2. Replace the redhat ntp pool with the following  
    ```
    server ntp.pdsea.f5net.com
    ```  

3. Start and enable the chronyd service  
    ```
    systemctl enable chronyd.service
    systemctl start chronyd.service
    ```  

4. Verify NTP is working properly  
    ```
    [root@osp16-undercloud stack]# chronyc sources
    210 Number of sources = 1
    MS Name/IP address         Stratum Poll Reach LastRx Last sample
    ===============================================================================
    ^* time.pd.f5net.com             5   6   377    25   -133us[ -167us] +/-  392ms
    ```  
<br/>  

### Disable firewall on the Undercloud Director

1. Stop the firewalld service  
    ```
    systemctl stop firewalld.service
    ```  

2.  Disable the firewalld service  
    ```
    systemctl disable firewalld.service
    ```  

3.  Verify that the firewall has been disabled  
    ```
    [root@osp16-undercloud stack]# systemctl status firewalld.service
    ● firewalld.service - firewalld - dynamic firewall daemon
    Loaded: loaded (/usr/lib/systemd/system/firewalld.service; disabled; vendor preset: enabled)
    Active: inactive (dead)
        Docs: man:firewalld(1)
    ```  
<br/>  
<br/>  
<br/>  

## Configure the Controller and Compute Nodes to PXE boot from NIC eno2np1  

The Undercloud Controller pushed the OS and Openstack Configuration to the Controller and Compute Nodes via PXE boot.  You must configure the BIOS of each of the nodes below to PXE boot from NIC eno2np1.  
<br/>  


| **Node**       | **IDRAC IP**    |**IDRAC username**  |  **IDRAC password**   |
| :---------:    | :----------:    | :----------:        |  :----------:        |  
| Controller     | 10.144.19.237   | root                | calvin               |  
| Compute Node 1 | 10.144.19.235   | root                | calvin               |
| Compute Node 2 | 10.144.19.233   | root                | calvin               |  

<br/> 

__NOTE:__ The following steps must be completed on the controller and each of the compute nodes  

1. Using the IDRAC console boot each server into BIOS setup  

    ![Image](https://github.com/grmarxer/Openstack/blob/master/Openstack_2.x_Build_Instructions/illustrations/idrac-boot-bios-setup.png)  

<br/> 

2. Select device settings  

    ![Image](https://github.com/grmarxer/Openstack/blob/master/Openstack_2.x_Build_Instructions/illustrations/device-settings.png)  
<br/> 

3. Select Integrated NIC 1 Port 1:Broadcom Adv Dual 25GB Ethernet > NIC Settings > and ensure Legacy Boot Protocol is set to none  

    __Note:__ If you make any changes the BIOS will prompt you to save those changes.  

    ![Image](https://github.com/grmarxer/Openstack/blob/master/Openstack_2.x_Build_Instructions/illustrations/nic1-port1.png)  

    ![Image](https://github.com/grmarxer/Openstack/blob/master/Openstack_2.x_Build_Instructions/illustrations/nic1-port1-nic-config.png) 

    ![Image](https://github.com/grmarxer/Openstack/blob/master/Openstack_2.x_Build_Instructions/illustrations/nic1-port1-pxe-none.png)  
<br/> 

4. Select Integrated NIC 1 Port 2:Broadcom Adv Dual 25GB Ethernet > NIC settings > and ensure Legacy Boot Protocol is set to PXE  

    ![Image](https://github.com/grmarxer/Openstack/blob/master/Openstack_2.x_Build_Instructions/illustrations/nic1-port2.png)  

    ![Image](https://github.com/grmarxer/Openstack/blob/master/Openstack_2.x_Build_Instructions/illustrations/nic1-port2-nic-config.png)

    ![Image](https://github.com/grmarxer/Openstack/blob/master/Openstack_2.x_Build_Instructions/illustrations/nic1-port2-pxe-on.png)  
<br/> 

5. Enter System BIOS > Boot Settings and make sure Boot Mode is set to BIOS  

    ![Image](https://github.com/grmarxer/Openstack/blob/master/Openstack_2.x_Build_Instructions/illustrations/system-bios.png)  

    ![Image](https://github.com/grmarxer/Openstack/blob/master/Openstack_2.x_Build_Instructions/illustrations/boot-settings.png)  

    ![Image](https://github.com/grmarxer/Openstack/blob/master/Openstack_2.x_Build_Instructions/illustrations/boot-settings-BIOS.png)  
<br/> 

6. Select BIOS Boot Settings and make sure that both hard drive C and Integrated NIC 1 Port 2 are checked  

    ![Image](https://github.com/grmarxer/Openstack/blob/master/Openstack_2.x_Build_Instructions/illustrations/bios-boot-settings.png)  

    ![Image](https://github.com/grmarxer/Openstack/blob/master/Openstack_2.x_Build_Instructions/illustrations/bios-boot-settings-enable-hdc-nic1p2.png)

<br/> 

7.  Select Boot Sequence and rearrange the boot order so Integrated NIC 1 Port 2 is first in the boot order  

    ![Image](https://github.com/grmarxer/Openstack/blob/master/Openstack_2.x_Build_Instructions/illustrations/boot-sequence-rearrange-1.png) 
    
    ![Image](https://github.com/grmarxer/Openstack/blob/master/Openstack_2.x_Build_Instructions/illustrations/boot-sequence-rearrange-2a.png) 

    ![Image](https://github.com/grmarxer/Openstack/blob/master/Openstack_2.x_Build_Instructions/illustrations/boot-sequence-rearrange-3.png)  

    ![Image](https://github.com/grmarxer/Openstack/blob/master/Openstack_2.x_Build_Instructions/illustrations/boot-sequence-rearrange-4.png)  
<br/> 

8.  Save your changes, exit the BIOS setup and reboot  

    ![Image](https://github.com/grmarxer/Openstack/blob/master/Openstack_2.x_Build_Instructions/illustrations/exit-bios-1.png)  

    ![Image](https://github.com/grmarxer/Openstack/blob/master/Openstack_2.x_Build_Instructions/illustrations/exit-bios-2.png)  

    ![Image](https://github.com/grmarxer/Openstack/blob/master/Openstack_2.x_Build_Instructions/illustrations/exit-bios-3.png)  

    ![Image](https://github.com/grmarxer/Openstack/blob/master/Openstack_2.x_Build_Instructions/illustrations/exit-bios-4.png)    

9.  You have completed this procedure, all further configuration work will be completed on the Undercloud Director __ONLY__  