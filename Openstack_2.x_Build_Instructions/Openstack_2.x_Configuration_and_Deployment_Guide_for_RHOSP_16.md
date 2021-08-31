## OpenStack 2.x Openstack Configuration and Deployment Guide  

<br/> 

## Openstack 2.x Lab drawing

![Image](https://github.com/grmarxer/Openstack/blob/master/Openstack_2.x_Build_Instructions/illustrations/lab-drawing.png)  

<br/> 

## Openstack 2.x Nodes

<br/>  


| **Node**            |  **NIC Configuraion** | **Accerlation Technology** | **IDRAC IP**    |**IDRAC username**  |  **IDRAC password**   |
| :---------:         | :----------:          | :----------:               | :----------:    | :----------:        |  :----------:        |  
| Undercloud Director | N/A                   | N/A                        | 10.144.20.6     | root                | calvin               |  
| Controller          | N/A                   | N/A                        | 10.144.22.13    | root                | calvin               |  
| Compute Node 1      | Intel XXV710          | SRIOV                      | 10.144.19.235   | root                | calvin               |
| Compute Node 2      | Intel XXV710          | SRIOV                      | 10.144.19.231   | root                | calvin               |  
| Compute Node 3      | Mellanox MCX512A-ACAT | OVS-DPDK Host              | 10.144.19.237   | root                | calvin               |  
| Compute Node 4      | Mellanox MCX512A-ACAT | OVS-DPDK Host              | 10.144.19.233   | root                | calvin               |  

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

