## Verizon VCP 2.x Openstack Configuration and Deployment Guide  

<br/> 

### VCP 2.x Lab drawing

![Image](https://github.com/grmarxer/Openstack/blob/master/VCP_2.x_Build_Instructions/illustrations/vcp2-x-lab-drawing.png)  

<br/> 

### Verizon VCP 2.x Requirements

- RHEL 8.2   
- OSP 16.1  (TRAIN)  
- OVS-DPDK (host) - Mellanox NICs MCX512A-ACAT  
    - OVS-DPDK queue size 1024  
- SRIOV - Intel NICs XXV710  
- virtio bridge - eno1np0  
- Neutron Networks  
   #### - OVS-DPDK (host)
    - name: external-dpdk, --external, network-type flat = (Node train 3, NIC Slot 1 MCX512A-ACAT P1), (Node train 2, NIC Slot 3 MCX512A-ACAT P1)  
    - name: internal-dpdk, --internal, network-type flat = (Node train 3, NIC Slot 1 MCX512A-ACAT P2), (Node train 2, NIC Slot 3 MCX512A-ACAT P2)  
    - name: mirroring-dpdk, --internal, network-type flat = (Node train 3, NIC Slot 2 MCX512A-ACAT P1)  

    - SRIOV  
    - name external-sriov, --external, network-type flat = (Node train 2, NIC slot 1 Intel XXV710 P1), (Node train 3, NIC slot 3 Intel XXV710 P1)  
    - name internal-sriov, --internal, network-type flat = (Node train 2, NIC slot 1 Intel XXV710 P2), (Node train 3, NIC slot 3 Intel XXV710 P2)  
    - name mirroring-sriov, --internal, network-type flat = ((Node train 2, NIC slot 2 Intel XXV710 P1)

    - VIRTIO  
    - name management, internal, network-type flat = bridge linked to train 2 and train 3 NIC eno1np0

<br/> 

### [Link to Procedures List](https://github.com/grmarxer/Openstack/tree/master/VCP_2.x_Build_Instructions/procedures)

