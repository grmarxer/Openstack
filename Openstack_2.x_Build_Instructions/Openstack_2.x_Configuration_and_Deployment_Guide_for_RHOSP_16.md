## OpenStack 2.x Openstack Configuration and Deployment Guide  

<br/> 

## Openstack 2.x Lab drawing

![Image](https://github.com/grmarxer/Openstack/blob/master/Openstack_2.x_Build_Instructions/illustrations/lab-drawing.png)  


<br/> 


## Openstack 2.x Nodes

<br/>  


| **Node**            |  **Location** | **NIC Configuraion** | **Accerlation Technology** | **IDRAC IP**    |**IDRAC user/password**  |
| :---------:         | :----------:  |:----------:          | :----------:               | :----------:    | :----------:            |    
| Undercloud Director | L25-A08-U13   |N/A                   | N/A                        | 10.144.20.6     | root / calvin           |  
| Controller          | L25-A08-U14   |N/A                   | N/A                        | 10.144.22.13    | root / calvin           |  
| Compute Node 1      | L25-A15-U25   |Intel XXV710          | SRIOV                      | 10.144.19.235   | root / calvin           |
| Compute Node 2      | L25-A15-U27   |Intel XXV710          | SRIOV                      | 10.144.19.231   | root / calvin           |  
| Compute Node 3      | L25-A15-U24   |Mellanox MCX512A-ACAT | OVS-DPDK Host              | 10.144.19.237   | root / calvin           |  
| Compute Node 4      | L25-A15-U26   |Mellanox MCX512A-ACAT | OVS-DPDK Host              | 10.144.19.233   | root / calvin           |  

<br/>  

## Openstack 2.x Node -- Switch Port assignments for Management (mgmt) and Provisioning (prov)

<br/>  

| **Node**            | **Location** | **eno3 (mgmt)** | **eno1np0 (mgmt)** | **eno4 (prov)** |  **eno2np1 (prov)** |
| :---------:         | :----------: | :----------:    | :----------:       | :----------:    |  :----------:       |  
| Undercloud Director | L25-A08-U13  | Arista1G-P46    | N/A                | Arista1G-P48    | N/A                 |  
| Controller          | L25-A08-U14  | Arista1G-P45    | N/A                | Arista1G-P47    | N/A                 |  
| Compute Node 1      | L25-A15-U25  | N/A             | CORE5/6/25/2       | N/A             | CORE3/10/12/3       |  
| Compute Node 2      | L25-A15-U27  | N/A             | CORE5/6/25/4       | N/A             | CORE3/10/12/4       |  
| Compute Node 3      | L25-A15-U24  | N/A             | CORE5/6/25/1       | N/A             | CORE3/10/12/2       |  
| Compute Node 4      | L25-A15-U26  | N/A             | CORE5/6/25/3       | N/A             | CORE3/10/12/1       |  

<br/> 

## Openstack 2.x Node -- Switch Port assignments for SRIOV and DPDK

<br/>  

#### SRIOV NIC Card Switch Ports -- Intel XXV710 -- All connected to Access VLAN 1090

| **Node**        | **Location** | **ens1f0**      | **ens1f1**      | **ens2f0**      |  **ens2f1**       |  
| :---------:     | :----------: | :----------:    | :----------:    | :----------:    |  :----------:     |  
| Compute Node 1  | L25-A15-U25  | CORE3/6/2/3     | CORE3/6/2/4     | CORE3/5/21/3    | CORE3/5/22/4      |  
| Compute Node 2  | L25-A15-U27  | CORE3/5/21/1    | CORE3/5/21/2    | CORE3/6/2/1     | **CORE3/10/1/3      |  

** CORE3/10/1/3 is not configured with a 100G connection on the switch, it has a 40G broken out to 10G


<br/> 

#### OVS-DPDK NIC Card Switch Ports -- Mellanox MCX512A-ACAT  

| **Node**        | **Location** | **ens1f0**    | **ens1f1**    | **ens2f0**    |  **ens2f1**   |
| :---------:     | :----------: | :----------:  | :----------:  | :----------:  |  :----------: |  
| Compute Node 3  | L25-A15-U24  | CORE3/5/22/1  | CORE3/5/22/2  | CORE3/5/22/3  | CORE3/6/2/2   |  
| Compute Node 4  | L25-A15-U26  | CORE3/6/1/1   | CORE3/6/1/2   | CORE3/6/1/3   | CORE3/6/1/4   |  

__NOTE:__  ens1f0 and ens1f1 are in a bond -- LACP trunk with miimon=100  

<br/> 

## Openstack 2.x Mandated VLANs

<br/>  


| **Openstack VLAN Name** |  **VLAN TAG** | **IPv4 Network** | **IPv6 Network**     |**blank**        |  **blank**     |
| :---------:             | :----------:  | :----------:     | :----------:         | :----------:    |  :----------:  |  
| External                | 1150          | 10.255.240.0/24  | fd00:10:255:240::/64 |                 |                |  
| InternalAPI             | 1151          | 10.255.241.0/24  | fd00:10:255:241::/64 |                 |                |
| Tenant                  | 1152          | 10.255.242.0/24  | fd00:10:255:242::/64 |                 |                |  
| Storage                 | 1153          | 10.255.243.0/24  | fd00:10:255:243::/64 |                 |                |  
| StorageMgmt             | 1154          | 10.255.244.0/24  | fd00:10:255:244::/64 |                 |                | 
| Management (see note)   | 1155          | 10.255.245.0/24  | fd00:10:255:245::/64 |                 |                |   

Note: Management is only included for backward compatibility -- it is not used in OSP 16 by default

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

Due to how Openstack allocates VLANs and IP networks in OSP 16 (TripleO) a Proxy (BIG-IP) is required to map routable IP address's to the internal Openstack IP network that will be assigned to guest management IP addresses.  The BIG-IP config has a FastL4 VIP with a routable IP address and a single pool member which is the back end Openstack Internal IP which it maps to.  

The BIG-IP configuration has been completed to support this configuration, so it should not have to be touched.  If there are issues please reach out to Gregg Marxer (g.marxer@f5.com)  

<br/>  


| **BIG-IP Node Name**           | **IP for Mgmt**  |
| :-------------:                | :------:         |  
| spk-proxy-1.pl.pdsea.f5net.com | 10.144.19.85     |
| spk-proxy-2.pl.pdsea.f5net.com | 10.144.21.233    |


<br/>  

## Mapping of BIG-IP Guest Management IP's to Routable Addresses   

These are the only routable IP addresses we have for Guest mgmt access.  Thus the current configuration will support a maximum of 8 BIG-IP's on this Openstack cluster

<br/>  


| **Internal Openstack Mgmt Network IP** |  **Routable IP Address** |  
| :---------:                            | :------:                 |  
| 10.255.240.24                          | 10.144.22.24             |    
| 10.255.240.25                          | 10.144.22.25             |    
| 10.255.240.26                          | 10.144.22.26             |  
| 10.255.240.27                          | 10.144.22.27             |  
| 10.255.240.28                          | 10.144.22.28             |    
| 10.255.240.29                          | 10.144.22.29             |  
| 10.255.240.30                          | 10.144.22.30             |    
| 10.255.240.31                          | 10.144.22.31             |      

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

