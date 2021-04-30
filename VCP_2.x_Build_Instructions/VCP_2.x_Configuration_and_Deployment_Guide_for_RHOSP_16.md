RHEL 8.2  
Train 16.1  
rhosp 16.1 is openstack rel 15 train 

rhel-8.2-x86_64-dvd.iso  

2X@@agDTaGpUBvc



  

10.144.19.233 - openshift  
10.144.19.235 - centos 7.8 root/default  
10.144.19.237  


lspci -v | grep Ethernet -A 1  
lspci | egrep -i --color 'network|ethernet'  

sudo lshw -class disk  

train1.pl.pdsea.f5net.com  
IPMI = 10.144.19.237  
MGMT = 10.144.19.236  
Netmask = 255.255.240.0  
Gateway = 10.144.31.254  
DNS = 10.144.31.146  
  
   
train2.pl.pdsea.f5net.com  
IPMI = 10.144.19.235  
MGMT = 10.144.19.234  
Netmask = 255.255.240.0  
Gateway = 10.144.31.254  
DNS = 10.144.31.146  
 
 
train3.pl.pdsea.f5net.com  
IPMI = 10.144.19.233  
MGMT = 10.144.19.232  
Netmask = 255.255.240.0  
Gateway = 10.144.31.254  
DNS = 10.144.31.146   






Controller Node				EM1 IP Address	Netmask			Gateway			DNS  
train3.pl.pdsea.f5net.com	10.144.19.232	255.255.240.0	10.144.31.254	10.144.31.146  
Compute Nodes				EM1 IP Address	Netmask			Gateway			DNS  
train2.pl.pdsea.f5net.com	10.144.19.234	255.255.240.0	10.144.31.254	10.144.31.146  
train1.pl.pdsea.f5net.com	10.144.19.236	255.255.240.0	10.144.31.254	10.144.31.146  



nmcli con mod eno3 ipv4.addresses 10.144.16.59/20  
nmcli con mod eno3 ipv4.gateway 10.144.31.254  
nmcli con mod eno3 ipv4.dns “10.144.31.146”  
nmcli con mod eno3 ipv4.method manual  
nmcli con up eno3  
  
```
nmcli con mod eno2np1 ipv4.addresses 172.16.10.10/24
nmcli con mod eno2np1 ipv4.method manual
nmcli con mod eno2np1 ipv4.gateway 0.0.0.0
nmcli con down eno2np1
nmcli con up eno2np1



nmcli con mod eno2np1 ipv4.addresses 172.16.10.20/24
nmcli con mod eno2np1 ipv4.method manual
nmcli con mod eno2np1 ipv4.gateway 0.0.0.0
nmcli con down eno2np1
nmcli con up eno2np1



nmcli con mod eno2np1 ipv4.addresses 172.16.10.30/24
nmcli con mod eno2np1 ipv4.method manual
nmcli con mod eno2np1 ipv4.gateway 0.0.0.0
nmcli con down eno2np1
nmcli con up eno2np1


sudo nmcli dev set eno4 managed yes
nmcli con mod eno4 ipv4.addresses 172.16.10.40/24
nmcli con mod eno4 ipv4.method manual
nmcli con mod eno4 ipv4.gateway 0.0.0.0
nmcli con down eno4
nmcli con up eno4
```  


```  
# Undercloud Director OSP16.1 Machine
10.144.16.59 osp16-undercloud
10.144.16.59 osp16-undercloud.pl.pdsea.f5net.com

# Controller
10.144.19.236 train1  
10.144.19.236 train1.pl.pdsea.f5net.com

# Compute Nodes
10.144.19.234 train2
10.144.19.234 train2.pl.pdsea.f5net.com
10.144.19.232 train3
10.144.19.232 train3.pl.pdsea.f5net.com
```   



vi /etc/chrony.conf  
server ntp.pdsea.f5net.com  
systemctl enable chronyd.service  
systemctl start chronyd.service  
chronyc sources  


systemctl stop firewalld.service  
systemctl disable firewalld.service  
systemctl status firewalld.service  




https://access.redhat.com/documentation/en-us/red_hat_openstack_platform/16.1/html/director_installation_and_usage/preparing-for-director-installation  

stack default




