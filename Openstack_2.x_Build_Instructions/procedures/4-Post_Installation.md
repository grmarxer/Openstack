
## Building out the Openstack Environment now that the OpenStack cluster has been deployed  

<br/> 

### There is a bug in OSP 16 where you need to set any compute node processing DPDK traffic selinux to permissive -- only perform this action after successful deployment of the overcloud

```
sudo vi /etc/selinux/config  
SELINUX=permissive  
SELINUXTYPE=targeted  
```
<br/> 

### Accessing overcloud nodes through SSH

You can access each overcloud node through the SSH protocol from the undercloud director

- Each overcloud node contains a heat-admin user.  

- The stack user on the undercloud has key-based SSH access to the heat-admin user on each overcloud node.  

- The simpliest way to do this is create alias's on the undercloud director for each node in the openstack cluster

1. Create the following alias's by editing the /home/stack/.bashrc file

    ```
    vi /home/stack/.bashrc
    ```
    ```
    alias c0="ssh heat-admin@192.168.255.11"
    alias s0="ssh heat-admin@192.168.255.12"
    alias s1="ssh heat-admin@192.168.255.13"
    alias d0="ssh heat-admin@192.168.255.14"
    alias d1="ssh heat-admin@192.168.255.15"
    alias n0="ssh heat-admin@192.168.255.16"
    alias n1="ssh heat-admin@192.168.255.17"
    ```  

    ```
    exec bash
    ```  

2.  SSH to a particular node by entering `s0' for example -- from bash.  This will SSH you into SRIOV node 0  

    ```
    [stack@osp16-undercloud git_clone]$ s0
    This system is not registered to Red Hat Insights. See https://cloud.redhat.com/
    To register this system, run: insights-client --register

    Last login: Thu Mar 17 11:06:06 2022 from 192.168.255.1
    [heat-admin@vz-osp-computesriov-0 ~]$
    ```

<br/>  

### Accessing the Openstack Horizon GUI.  

1. Link and credentials -- Username admin, password f5default

  ```
  http://10.144.22.12/dashboard/auth/login/?next=/dashboard/
  ```  


<br/>  

### Build out Openstack flavors, networks, etc. using the Command Line.

1. Log in to the undercloud director as the stack user.  

2. Cut and paste the following:  

    __NOTE:__ If you have not downloaded the qcow2 images you require for guest instances, and they do not exist in /home/stack/images on the undercloud director be sure to download them before proceeding.  

```
# Source the overcloud credentials to configure the Openstack instance
cd
source overcloudrc


# Create a backup user, admin-backup, and set the admin-backup password
openstack user create --password default admin-backup
openstack role add --user admin-backup --project admin admin


# Set the quotas for the numbers of cores, RAM, and instances inside the admin project
openstack quota set --cores 80 admin
openstack quota set --ram 393216 admin
openstack quota set --instances 20 admin


# Create the security groups that we will assign to the instances.  These allow all traffic
openstack security group create permit.all
openstack security group rule create --ingress --ethertype IPv4 --protocol icmp permit.all
openstack security group rule create --ingress --ethertype IPv4 --protocol tcp permit.all  
openstack security group rule create --ingress --ethertype IPv4 --protocol udp permit.all


# Create the management network and subnet.  This network attaches to vlan 1150 which has external connectivity.
# this is the network that you will use for the BIG-IP management ports
openstack network create --share --project admin --external --provider-network-type vlan --provider-physical-network management --provider-segment 1150 management
openstack subnet create --project admin --subnet-range 10.255.240.0/24 --dhcp --ip-version 4 --allocation-pool start=10.255.240.24,end=10.255.240.31 --allocation-pool start=10.255.240.230,end=10.255.240.230 --allocation-pool start=10.255.240.232,end=10.255.240.232 --allocation-pool start=10.255.240.234,end=10.255.240.234 --allocation-pool start=10.255.240.236,end=10.255.240.236 --dns-nameserver 8.8.8.8 --gateway 10.255.240.1 --network management management-subnet


# Create the SRIOV networks and subnets.  There are 3 SRIOV networks sriov-public, sriov-private, and sriov-mirror
openstack network create --share --project admin --external --provider-network-type flat --provider-physical-network sriov-public sriov-public
openstack network create --share --project admin --internal --provider-network-type flat --provider-physical-network sriov-private sriov-private
openstack network create --share --project admin --internal --provider-network-type flat --provider-physical-network sriov-mirror sriov-mirror
openstack subnet create --project admin --subnet-range 10.10.20.0/24 --dhcp --ip-version 4 --allocation-pool start=10.10.20.200,end=10.10.20.250 --dns-nameserver 8.8.8.8 --network sriov-public sriov-public-subnet
openstack subnet create --project admin --subnet-range 10.10.30.0/24 --dhcp --ip-version 4 --allocation-pool start=10.10.30.200,end=10.10.30.250 --dns-nameserver 8.8.8.8 --network sriov-private sriov-private-subnet
openstack subnet create --project admin --subnet-range 10.10.40.0/24 --dhcp --ip-version 4 --allocation-pool start=10.10.40.200,end=10.10.40.250 --dns-nameserver 8.8.8.8 --network sriov-mirror sriov-mirroring-subnet


# Create the SRIOV ports, this maps a SRIOV VF to a neutron port
openstack port create --network sriov-public --vnic-type direct public-sriov-p1
openstack port create --network sriov-public --vnic-type direct public-sriov-p2
openstack port create --network sriov-public --vnic-type direct public-sriov-p3
openstack port create --network sriov-public --vnic-type direct public-sriov-p4
openstack port create --network sriov-public --vnic-type direct public-sriov-p5
openstack port create --network sriov-public --vnic-type direct public-sriov-p6
openstack port create --network sriov-public --vnic-type direct public-sriov-p7
openstack port create --network sriov-public --vnic-type direct public-sriov-p8
openstack port create --network sriov-public --vnic-type direct public-sriov-p9
openstack port create --network sriov-public --vnic-type direct public-sriov-p10
openstack port create --network sriov-public --vnic-type direct public-sriov-p11
openstack port create --network sriov-public --vnic-type direct public-sriov-p12
openstack port create --network sriov-private --vnic-type direct private-sriov-p1
openstack port create --network sriov-private --vnic-type direct private-sriov-p2
openstack port create --network sriov-private --vnic-type direct private-sriov-p3
openstack port create --network sriov-private --vnic-type direct private-sriov-p4
openstack port create --network sriov-private --vnic-type direct private-sriov-p5
openstack port create --network sriov-private --vnic-type direct private-sriov-p6
openstack port create --network sriov-private --vnic-type direct private-sriov-p7
openstack port create --network sriov-private --vnic-type direct private-sriov-p8
openstack port create --network sriov-private --vnic-type direct private-sriov-p9
openstack port create --network sriov-private --vnic-type direct private-sriov-p10
openstack port create --network sriov-private --vnic-type direct private-sriov-p11
openstack port create --network sriov-private --vnic-type direct private-sriov-p12
openstack port create --network sriov-mirror --vnic-type direct mirror-sriov-p1
openstack port create --network sriov-mirror --vnic-type direct mirror-sriov-p2
openstack port create --network sriov-mirror --vnic-type direct mirror-sriov-p3
openstack port create --network sriov-mirror --vnic-type direct mirror-sriov-p4
openstack port create --network sriov-mirror --vnic-type direct mirror-sriov-p5
openstack port create --network sriov-mirror --vnic-type direct mirror-sriov-p6
openstack port create --network sriov-mirror --vnic-type direct mirror-sriov-p7
openstack port create --network sriov-mirror --vnic-type direct mirror-sriov-p8
openstack port create --network sriov-mirror --vnic-type direct mirror-sriov-p9
openstack port create --network sriov-mirror --vnic-type direct mirror-sriov-p10
openstack port create --network sriov-mirror --vnic-type direct mirror-sriov-p11
openstack port create --network sriov-mirror --vnic-type direct mirror-sriov-p12


# Create the DPDK networks and subets
openstack network create --share --project admin --internal dpdk-net1
openstack network create --share --project admin --internal dpdk-net2
openstack network create --share --project admin --internal dpdk-net3
openstack network create --share --project admin --internal dpdk-net4
openstack network create --share --project admin --internal dpdk-net5
openstack network create --share --project admin --internal dpdk-net6
openstack network create --share --project admin --internal dpdk-net7
openstack network create --share --project admin --internal dpdk-net8
openstack network create --share --project admin --internal dpdk-net9
openstack network create --share --project admin --internal dpdk-net10
openstack network create --share --project admin --internal dpdk-net11
openstack network create --share --project admin --internal dpdk-net12
openstack subnet create --project admin --subnet-range 10.10.110.0/24 --dhcp --ip-version 4 --allocation-pool start=10.10.110.230,end=10.10.110.250 --dns-nameserver 8.8.8.8 --network dpdk-net1 dpdk-net1-subnet
openstack subnet create --project admin --subnet-range 10.10.120.0/24 --dhcp --ip-version 4 --allocation-pool start=10.10.120.230,end=10.10.120.250 --dns-nameserver 8.8.8.8 --network dpdk-net2 dpdk-net2-subnet
openstack subnet create --project admin --subnet-range 10.10.130.0/24 --dhcp --ip-version 4 --allocation-pool start=10.10.130.230,end=10.10.130.250 --dns-nameserver 8.8.8.8 --network dpdk-net3 dpdk-net3-subnet
openstack subnet create --project admin --subnet-range 10.10.140.0/24 --dhcp --ip-version 4 --allocation-pool start=10.10.140.230,end=10.10.140.250 --dns-nameserver 8.8.8.8 --network dpdk-net4 dpdk-net4-subnet
openstack subnet create --project admin --subnet-range 10.10.150.0/24 --dhcp --ip-version 4 --allocation-pool start=10.10.150.230,end=10.10.150.250 --dns-nameserver 8.8.8.8 --network dpdk-net5 dpdk-net5-subnet
openstack subnet create --project admin --subnet-range 10.10.160.0/24 --dhcp --ip-version 4 --allocation-pool start=10.10.160.230,end=10.10.160.250 --dns-nameserver 8.8.8.8 --network dpdk-net6 dpdk-net6-subnet
openstack subnet create --project admin --subnet-range 10.10.170.0/24 --dhcp --ip-version 4 --allocation-pool start=10.10.170.230,end=10.10.170.250 --dns-nameserver 8.8.8.8 --network dpdk-net7 dpdk-net7-subnet
openstack subnet create --project admin --subnet-range 10.10.180.0/24 --dhcp --ip-version 4 --allocation-pool start=10.10.180.230,end=10.10.180.250 --dns-nameserver 8.8.8.8 --network dpdk-net8 dpdk-net8-subnet
openstack subnet create --project admin --subnet-range 10.10.190.0/24 --dhcp --ip-version 4 --allocation-pool start=10.10.190.230,end=10.10.190.250 --dns-nameserver 8.8.8.8 --network dpdk-net9 dpdk-net9-subnet
openstack subnet create --project admin --subnet-range 10.10.200.0/24 --dhcp --ip-version 4 --allocation-pool start=10.10.200.230,end=10.10.200.250 --dns-nameserver 8.8.8.8 --network dpdk-net10 dpdk-net10-subnet
openstack subnet create --project admin --subnet-range 10.10.210.0/24 --dhcp --ip-version 4 --allocation-pool start=10.10.210.230,end=10.10.210.250 --dns-nameserver 8.8.8.8 --network dpdk-net11 dpdk-net11-subnet
openstack subnet create --project admin --subnet-range 10.10.220.0/24 --dhcp --ip-version 4 --allocation-pool start=10.10.220.230,end=10.10.220.250 --dns-nameserver 8.8.8.8 --network dpdk-net12 dpdk-net12-subnet


# Create the following openstack flavors
openstack flavor create bigip.2cpu.4GB --ram 4096 --disk 100 --vcpus 2
openstack flavor create bigip.8cpu.16GB --ram 16384 --disk 100 --vcpus 8
openstack flavor create bigip.2cpu.4GB.dpdk --ram 4096 --disk 100 --vcpus 2
openstack flavor set --property aggregate_instance_extra_specs:dpdk=true --property hw:cpu_policy=dedicated --property hw:mem_page_size=1GB bigip.2cpu.4GB.dpdk
openstack flavor create bigip.8cpu.16GB.dpdk --ram 16384 --disk 100 --vcpus 8
openstack flavor set --property aggregate_instance_extra_specs:dpdk=true --property hw:cpu_policy=dedicated --property hw:mem_page_size=1GB bigip.8cpu.16GB.dpdk
openstack flavor create bigip.8cpu.32GB.dpdk --ram 32768 --disk 100 --vcpus 8
openstack flavor set --property aggregate_instance_extra_specs:dpdk=true --property hw:cpu_policy=dedicated --property hw:mem_page_size=1GB bigip.8cpu.32GB.dpdk
openstack flavor create bigip.8cpu.64GB.dpdk --ram 65536 --disk 100 --vcpus 8
openstack flavor set --property aggregate_instance_extra_specs:dpdk=true --property hw:cpu_policy=dedicated --property hw:mem_page_size=1GB bigip.8cpu.64GB.dpdk


# Create the following images to use for guest instances, this will create openstack images with and without multiqueue enabled
# If you have not already done so you will need to download each of the necessary qcow images to the underloud director /home/stack/images folder.
# best to cut and paste these one at a time, only proceeding after the previous completes

openstack image create "bigip.all.15.1.3.1.multiqueue-enabled" \
  --file /home/stack/images/BIGIP-15.1.3.1-0.0.18-all.qcow2 \
  --disk-format qcow2 --container-format bare \
  --public
openstack image set --property hw_vif_multiqueue_enabled=true bigip.all.15.1.3.1.multiqueue-enabled


openstack image create "bigip.all.1-slot.15.1.3.1.multiqueue-enabled" \
  --file /home/stack/images/BIGIP-15.1.3.1-0.0.18-all-1slot.qcow2 \
  --disk-format qcow2 --container-format bare \
  --public
openstack image set --property hw_vif_multiqueue_enabled=true bigip.all.1-slot.15.1.3.1.multiqueue-enabled


openstack image create "rhel-8.5.multiqueue-enabled" \
  --file /home/stack/images/rhel-8.5-x86_64-kvm.qcow2 \
  --disk-format qcow2 --container-format bare \
  --public
openstack image set --property hw_vif_multiqueue_enabled=true rhel-8.5.multiqueue-enabled


openstack image create "bigip.all.15.1.3.1" \
  --file /home/stack/images/BIGIP-15.1.3.1-0.0.18-all.qcow2 \
  --disk-format qcow2 --container-format bare \
  --public


openstack image create "bigip.all.1-slot.15.1.3.1" \
  --file /home/stack/images/BIGIP-15.1.3.1-0.0.18-all-1slot.qcow2 \
  --disk-format qcow2 --container-format bare \
  --public


openstack image create "rhel-8.5" \
  --file /home/stack/images/rhel-8.5-x86_64-kvm.qcow2 \
  --disk-format qcow2 --container-format bare \
  --public
```  

<br/>  

### Boot an Openstack Instance  

1.  There are several fields inside the NOVA boot command that you will need to manipulate depending on what you are attempting to achieve, this includes the image, networks, flavor, DPDK, SRIOV, etc.  Below is only an example.  You will need to modify based on your needs.  

 -  __DPDK Example__ - 1 mgmt network, 10 TMM networks, booting on hypervisor vz-osp-computedpdk-0.osp.16.customer.lab, named bigip.5-dpdk.n0.8cpu.16GB  

    ```
    nova boot --flavor bigip.8cpu.16GB.dpdk --image bigip.all.1-slot.15.1.3.1.multiqueue-enabled \
      --nic net-name=management --nic net-name=dpdk-net1  --nic net-name=dpdk-net2 --nic net-name=dpdk-net3 \
      --nic net-name=dpdk-net4 --nic net-name=dpdk-net5 --nic net-name=dpdk-net6  --nic net-name=dpdk-net7  \
      --nic net-name=dpdk-net8 --nic net-name=dpdk-net9 --nic net-name=dpdk-net10 \
      --security-group permit.all --hypervisor-hostname vz-osp-computedpdk-0.osp.16.customer.lab   bigip.5-dpdk.n0.8cpu.16GB
    ```

-  __SRIOV Example__ - Each NIC has to be the UUID for the neutron port your created mapping the SRIOV VF

   ```
   nova boot --flavor bigip.8cpu.16GB --image bigip.all.1-slot.15.1.3.1 \
    --nic net-name=management --nic port-id=7beeb8cb-0d63-49e8-a11b-b9de94ca7a73 \
    --nic port-id=080e4074-e41b-44e7-a820-dc985871f2f0 --nic port-id=668d221d-1bf0-44dd-ad6c-3edd1d3edd7f \
    --security-group permit.all --hypervisor-hostname vz-osp-computesriov-1.osp.16.customer.lab bigip.6-sriov.s1.8cpu.16GB
   ```  


