RHEL 8.2  
Train 16.1  

rhosp 16.1 is openstack rel 15 train   

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


# Controller  
10.144.19.236 train1  
10.144.19.236 train1.pl.pdsea.f5net.com  
  
# Compute Nodes  
10.144.19.234 train2  
10.144.19.234 train2.pl.pdsea.f5net.com  
10.144.19.232 train3  
10.144.19.232 train3.pl.pdsea.f5net.com  
  

2: eno1np0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether b0:26:28:45:fd:80 brd ff:ff:ff:ff:ff:ff
    inet 10.144.19.232/20 brd 10.144.31.255 scope global dynamic noprefixroute eno1np0




Controller Node				EM1 IP Address	Netmask			Gateway			DNS  
train3.pl.pdsea.f5net.com	10.144.19.232	255.255.240.0	10.144.31.254	10.144.31.146  
Compute Nodes				EM1 IP Address	Netmask			Gateway			DNS  
train2.pl.pdsea.f5net.com	10.144.19.234	255.255.240.0	10.144.31.254	10.144.31.146  
train1.pl.pdsea.f5net.com	10.144.19.236	255.255.240.0	10.144.31.254	10.144.31.146  


https://www.rdoproject.org/install/packstack/  

sudo dnf install -y https://www.rdoproject.org/repos/rdo-release.el8.rpm  
sudo dnf update -y  
subscription-manager repos --enable codeready-builder-for-rhel-8-x86_64-rpms  
sudo dnf install -y openstack-packstack  








