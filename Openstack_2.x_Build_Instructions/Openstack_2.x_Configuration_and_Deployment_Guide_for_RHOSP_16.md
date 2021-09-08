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

## Openstack 2.x Mandated VLANs

<br/>  


| **Openstack VLAN Name** |  **VLAN TAG** | **IPv4 Network** | **IPv6 Network**     |**blank**        |  **blank**     |
| :---------:             | :----------:  | :----------:     | :----------:         | :----------:    |  :----------:  |  
| External                | 1150          | 10.255.240.0/24  | fd00:10:255:240::/64 |                 |                |  
| Management              | 1151          | 10.255.241.0/24  | fd00:10:255:241::/64 |                 |                |  
| InternalAPI             | 1152          | 10.255.242.0/24  | fd00:10:255:242::/64 |                 |                |
| Tenant                  | 1153          | 10.255.243.0/24  | fd00:10:255:243::/64 |                 |                |  
| Storage                 | 1154          | 10.255.244.0/24  | fd00:10:255:244::/64 |                 |                |  
| StorageMgmt             | 1155          | 10.255.245.0/24  | fd00:10:255:245::/64 |                 |                |  

<br/> 

## Openstack 2.x IPv4 Proxy IP's to Manage Nodes

<br/>  


| **Node**            |  **NIC** | **Proxy IP address** | **IP Address Proxy Maps to** |**blank**     |  **blank**   |
| :---------:         | :------: | :----------:         | :----------:                 | :----------: |  :--------:  |  
| Undercloud Director | eno3     | 10.144.16.59/20      | 10.255.240.10                |              |              |  
| Controller          | en03     | 10.144.22.12/20      | 10.255.240.11                |              |              |  
| Compute Node 1      | eno1np0  | 10.144.19.234/20     | 10.255.240.12                |              |              |
| Compute Node 2      | eno1np0  | 10.144.19.230/20     | 10.255.240.13                |              |              |  
| Compute Node 3      | eno1np0  | 10.144.19.236/20     | 10.255.240.14                |              |              |  
| Compute Node 4      | eno1np0  | 10.144.19.232/20     | 10.255.240.15                |              |              |  

<br/>  

## BIG-IP's that are being used as the Proxy  

Due to how Openstack allocates VLANs and IP networks in OSP 16 (TripleO) a Proxy (BIG-IP) is required to map F5 internal routable IP address's to the internal Openstack IP network that will be assigned to guest management IP addresses.  The BIG-IP config has a FastL4 VIP with a F5 internal routable IP address and a single pool member which is the back end Openstack Internal IP which it maps to.  

The BIG-IP configuration has been completed to support this configuration, so it should not have to be touched.  If there are issues please reach out to Gregg Marxer (g.marxer@f5.com)  

<br/>  


| **BIG-IP Node Name**           | **IP for Mgmt**  |
| :-------------:                | :------:         |  
| spk-proxy-1.pl.pdsea.f5net.com | 10.144.19.85     |
| spk-proxy-2.pl.pdsea.f5net.com | 10.144.21.233    |


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

