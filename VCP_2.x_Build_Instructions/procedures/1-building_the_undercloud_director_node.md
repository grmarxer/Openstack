# Building the Undercloud Director Node  

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

