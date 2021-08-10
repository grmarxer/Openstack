## OpenStack 2.x Openstack Configuration and Deployment Guide  

<br/> 

## Openstack 2.x Lab drawing

![Image](https://github.com/grmarxer/Openstack/blob/master/VCP_2.x_Build_Instructions/illustrations/vcp2-x-lab-drawing.png)  

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

### Neutron Networks Specifics:   

- __OVS-DPDK (host)__
    - `name: external-dpdk`, --external, network-type flat = (Node train 3, NIC Slot 1 MCX512A-ACAT P1), (Node train 2, NIC Slot 3 MCX512A-ACAT P1)  
    - `name: internal-dpdk`, --internal, network-type flat = (Node train 3, NIC Slot 1 MCX512A-ACAT P2), (Node train 2, NIC Slot 3 MCX512A-ACAT P2)    

- __SRIOV__  
    - `name: external-sriov`, --external, network-type flat = (Node train 2, NIC slot 1 Intel XXV710 P1), (Node train 3, NIC slot 3 Intel XXV710 P1)  
    - `name: internal-sriov`, --internal, network-type flat = (Node train 2, NIC slot 1 Intel XXV710 P2), (Node train 3, NIC slot 3 Intel XXV710 P2)  

- __SRIOV and OVS-DPDK (host) combined__  
    - `name: mirroring`, --internal, network-type flat = (Node train 2, SRIOV NIC slot 2 Intel XXV710 P1), (Node train 3, OVS-DPDK NIC Slot 2 MCX512A-ACAT P1)  

- __VIRTIO__  
    - `name: management`, --internal, network-type flat = bridge (br-mgmt) linked to train 2 and train 3 NIC eno1np0  

<br/> 

### [Link to Procedures List for OSP 16 deployment](https://github.com/grmarxer/Openstack/tree/master/VCP_2.x_Build_Instructions/procedures)

