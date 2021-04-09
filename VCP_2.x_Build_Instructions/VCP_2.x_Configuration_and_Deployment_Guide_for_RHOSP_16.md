RHEL 8.2  
Train 16.1  

rhosp 16.1 is openstack rel 15 train   

10.144.19.233 - openshift  
10.144.19.235 - centos 7.8 root/default  
10.144.19.237  


lspci -v | grep Ethernet -A 1  
lspci | egrep -i --color 'network|ethernet'  

sudo lshw -class disk  

osp16-undercloud.pl.pdsea.f5net.com  
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


2: eno1np0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether b0:26:28:45:fd:80 brd ff:ff:ff:ff:ff:ff
    inet 10.144.19.232/20 brd 10.144.31.255 scope global dynamic noprefixroute eno1np0




Controller Node				EM1 IP Address	Netmask			Gateway			DNS  
train3.pl.pdsea.f5net.com	10.144.19.232	255.255.240.0	10.144.31.254	10.144.31.146  
Compute Nodes				EM1 IP Address	Netmask			Gateway			DNS  
train2.pl.pdsea.f5net.com	10.144.19.234	255.255.240.0	10.144.31.254	10.144.31.146  
train1.pl.pdsea.f5net.com	10.144.19.236	255.255.240.0	10.144.31.254	10.144.31.146  




# Undercloud OSP16 Machine
10.144.19.236 osp16-undercloud  
10.144.19.236 osp16-undercloud.pl.pdsea.f5net.com  

# Controller  

# Compute Nodes  
10.144.19.234 train2  
10.144.19.234 train2.pl.pdsea.f5net.com  
10.144.19.232 train3  
10.144.19.232 train3.pl.pdsea.f5net.com  




vi /etc/chrony.conf  
server ntp.pdsea.f5net.com  
systemctl enable chronyd.service  
systemctl start chronyd.service  
chronyc sources  


systemctl stop firewalld.service  
systemctl disable firewalld.service  
systemctl status firewalld.service  


vi /etc/selinux/config
Set the following to disabled  
SELINUX=disabled  
  
reboot  
  
Verify SELinux has been disabled  
sestatus  


https://access.redhat.com/documentation/en-us/red_hat_openstack_platform/16.1/html/director_installation_and_usage/preparing-for-director-installation  