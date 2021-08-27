## OpenStack 2.x Openstack Configuration and Deployment Guide  

<br/> 

## Openstack 2.x Lab drawing

![Image](https://github.com/grmarxer/Openstack/blob/master/Openstack_2.x_Build_Instructions/illustrations/lab-drawing.png)  

<br/> 

## Openstack 2.x Requirements

### Openstack Environment Requirements:  
- RHEL 8.2   
- OSP 16.1 (TRAIN) 
- Hyperthreading for guests disabled  
- CPU pinning on NUMA node   

### Neutron Requirements:  
- OVS-DPDK (host) - Mellanox NICs MCX512A-ACAT, OVS-DPDK queue size 1024, enable 1G huge pages, multi-queue enabled  
- SRIOV - Intel NICs XXV710  
- virtio bridge - eno1np0  

<br/> 

### [Link to Procedures List for OSP 16 deployment](https://github.com/grmarxer/Openstack/tree/master/Openstack_2.x_Build_Instructions/procedures)

