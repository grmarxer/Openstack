# Configuring MAC Masquerade for BIG-IP Inside Openstack
<br/>  

## Summary  
In this procedure we will provide the steps necessary to configure Openstack to support a BIG-IP MAC Masquerade configuration.  

In this example we have a single standard Virtual server configured on port 80 to demonstrate http traffic (external side).  We will not configure a floating self-ip on the external side.  

We have a single web server in our pool, also on port 80 (internal side).  We will configure a floating self-ip on the internal side.  On the VIP we are using SNAT auto-map.  

All self-ip's and floating self-ips have port lockdown set to `allow none`  

This procedure assumes you have a good understanding of how to configure BIG-IP.  This procedure does not provide step by step instructions for the BIG-IP configuration.  

<br/>  

__NOTE:__ This procedure assumes that the database key `tm.macmasqaddr_per_vlan` is set to __false__, its default value.  If you are using per-VLAN MAC masquerade this procedure will not work as written.  The MAC addresses assigned as allowed address pairs will be different in a per-VLAN MAC masquerade configuration.

[K35390915: Overview of the per-VLAN MAC masquerade feature](https://support.f5.com/csp/article/K35390915)  

<br/>  

##  Diagram of the lab configuration  

<br/>  

![lab diagram](https://github.com/grmarxer/Openstack/blob/master/Configuring_MAC_Masquerade/diagrams/MAC-Masquerade-lab.png)  

<br/>  

##  Configuration Steps


1. Assign the MAC Masquerade Address you wish to use to BIG-IP.  In this example the MAC Masquerade Address is `fa:16:3e:ae:00:00`  

    ```
    [root@host-172:Active:In Sync] config # tmsh list cm traffic-group traffic-group-1 mac
    cm traffic-group traffic-group-1 {
        mac fa:16:3e:ae:00:00
    }
    ```  
2. On the external side create the OpenStack Fixed IP that you will use for your BIG-IP VIP.  In this example the VIP IP is `172.16.3.50`  
    ```
    neutron port-create --fixed-ip ip_address=172.16.3.50  --security-group demo network3
    ```  
    ```
    [root@controller ~]# neutron port-show d5f91327-d7e8-4b3d-9d26-5d9a5567b1bc
    +-----------------------+------------------------------------------------------------------------------------+
    | Field                 | Value                                                                              |
    +-----------------------+------------------------------------------------------------------------------------+
    | admin_state_up        | True                                                                               |
    | allowed_address_pairs |                                                                                    |
    | binding:vnic_type     | normal                                                                             |
    | created_at            | 2020-08-28T21:01:57Z                                                               |
    | description           |                                                                                    |
    | device_id             |                                                                                    |
    | device_owner          |                                                                                    |
    | extra_dhcp_opts       |                                                                                    |
    | fixed_ips             | {"subnet_id": "02c87a9d-7fc1-434b-a0a1-268cd7d1bee5", "ip_address": "172.16.3.50"} |
    | id                    | d5f91327-d7e8-4b3d-9d26-5d9a5567b1bc                                               |
    | mac_address           | fa:16:3e:04:f5:7c                                                                  |
    | name                  |                                                                                    |
    | network_id            | 98b425af-d019-401f-bfd6-ae261ebcf0b8                                               |
    | port_security_enabled | True                                                                               |
    | project_id            | 6d0a81ec951f41fe957fe08ec5c50ae1                                                   |
    | revision_number       | 5                                                                                  |
    | security_groups       | aefc1d1c-b419-4e86-b884-afd00a2197e3                                               |
    | status                | DOWN                                                                               |
    | tenant_id             | 6d0a81ec951f41fe957fe08ec5c50ae1                                                   |
    | updated_at            | 2020-08-28T21:01:57Z                                                               |
    +-----------------------+------------------------------------------------------------------------------------+
    ```  
3.  Update the Openstack fixed IP that is BIG-IP1's external self IP with the allowed address pair of that of the VIP IP and the MAC Masquerade Address  

    ```
    neutron port-update a3a65777-238d-452c-a885-c7bd48a53182 --allowed_address_pairs list=true type=dict ip_address=172.16.3.50,mac_address=fa:16:3e:ae:00:00
    ```  
    ```
    [root@controller ~]# neutron port-show a3a65777-238d-452c-a885-c7bd48a53182
    +-----------------------+-------------------------------------------------------------------------------------+
    | Field                 | Value                                                                               |
    +-----------------------+-------------------------------------------------------------------------------------+
    | admin_state_up        | True                                                                                |
    | allowed_address_pairs | {"ip_address": "172.16.3.50", "mac_address": "fa:16:3e:ae:00:00"}                   |
    | binding:vnic_type     | normal                                                                              |
    | created_at            | 2018-10-02T22:30:48Z                                                                |
    | description           |                                                                                     |
    | device_id             | 3ee1d044-6885-48e0-affa-e0979eaf5112                                                |
    | device_owner          | compute:nova                                                                        |
    | extra_dhcp_opts       |                                                                                     |
    | fixed_ips             | {"subnet_id": "02c87a9d-7fc1-434b-a0a1-268cd7d1bee5", "ip_address": "172.16.3.110"} |
    | id                    | a3a65777-238d-452c-a885-c7bd48a53182                                                |
    | mac_address           | fa:16:3e:ae:d1:82                                                                   |
    | name                  |                                                                                     |
    | network_id            | 98b425af-d019-401f-bfd6-ae261ebcf0b8                                                |
    | port_security_enabled | True                                                                                |
    | project_id            | 6d0a81ec951f41fe957fe08ec5c50ae1                                                    |
    | revision_number       | 85                                                                                  |
    | security_groups       | aefc1d1c-b419-4e86-b884-afd00a2197e3                                                |
    |                       | b8813eb3-895c-4340-acbe-a3ecb32a9fd8                                                |
    | status                | ACTIVE                                                                              |
    | tenant_id             | 6d0a81ec951f41fe957fe08ec5c50ae1                                                    |
    | updated_at            | 2020-08-28T21:34:31Z                                                                |
    +-----------------------+-------------------------------------------------------------------------------------+
    ```  
4. Update the Openstack fixed IP that is BIG-IP2's external self IP with the allowed address pair of that of the VIP IP and the MAC Masquerade Address 

    ```
    neutron port-update ad791a04-5b61-451d-959c-69f7208443d6 --allowed_address_pairs list=true type=dict ip_address=172.16.3.50,mac_address=fa:16:3e:ae:00:00
    ```  
    ```
    [root@controller ~]# neutron port-show ad791a04-5b61-451d-959c-69f7208443d6
    +-----------------------+-------------------------------------------------------------------------------------+
    | Field                 | Value                                                                               |
    +-----------------------+-------------------------------------------------------------------------------------+
    | admin_state_up        | True                                                                                |
    | allowed_address_pairs | {"ip_address": "172.16.3.50", "mac_address": "fa:16:3e:ae:00:00"}                   |
    | binding:vnic_type     | normal                                                                              |
    | created_at            | 2018-10-02T22:18:17Z                                                                |
    | description           |                                                                                     |
    | device_id             | d8ab5f63-c102-4d97-917e-a0fa55a877c4                                                |
    | device_owner          | compute:nova                                                                        |
    | extra_dhcp_opts       |                                                                                     |
    | fixed_ips             | {"subnet_id": "02c87a9d-7fc1-434b-a0a1-268cd7d1bee5", "ip_address": "172.16.3.105"} |
    | id                    | ad791a04-5b61-451d-959c-69f7208443d6                                                |
    | mac_address           | fa:16:3e:39:09:7b                                                                   |
    | name                  |                                                                                     |
    | network_id            | 98b425af-d019-401f-bfd6-ae261ebcf0b8                                                |
    | port_security_enabled | True                                                                                |
    | project_id            | 6d0a81ec951f41fe957fe08ec5c50ae1                                                    |
    | revision_number       | 53                                                                                  |
    | security_groups       | aefc1d1c-b419-4e86-b884-afd00a2197e3                                                |
    |                       | b8813eb3-895c-4340-acbe-a3ecb32a9fd8                                                |
    | status                | ACTIVE                                                                              |
    | tenant_id             | 6d0a81ec951f41fe957fe08ec5c50ae1                                                    |
    | updated_at            | 2020-08-28T21:34:39Z                                                                |
    +-----------------------+-------------------------------------------------------------------------------------+
    ```  

5.  On the internal side create the OpenStack Fixed IP that you will use for your BIG-IP floating self-ip.  In this example the floating self-ip is `172.16.4.100`  

    ```
    neutron port-create --fixed-ip ip_address=172.16.4.100  --security-group demo network4
    ```  
    ```
    [root@controller ~]# neutron port-show a1504786-9529-45a1-b4f8-480dc4583c83
    +-----------------------+-------------------------------------------------------------------------------------+
    | Field                 | Value                                                                               |
    +-----------------------+-------------------------------------------------------------------------------------+
    | admin_state_up        | True                                                                                |
    | allowed_address_pairs |                                                                                     |
    | binding:vnic_type     | normal                                                                              |
    | created_at            | 2017-02-11T00:28:15Z                                                                |
    | description           |                                                                                     |
    | device_id             | dhcpd3377d3c-a0d1-5d71-9947-f17125c357bb-0ffaa280-578c-45e7-a8b2-a0c6bbace482       |
    | device_owner          | network:dhcp                                                                        |
    | extra_dhcp_opts       |                                                                                     |
    | fixed_ips             | {"subnet_id": "2c42b9bb-93eb-4566-b4fc-b2cfad040e83", "ip_address": "172.16.4.100"} |
    | id                    | a1504786-9529-45a1-b4f8-480dc4583c83                                                |
    | mac_address           | fa:16:3e:b0:62:27                                                                   |
    | name                  |                                                                                     |
    | network_id            | 0ffaa280-578c-45e7-a8b2-a0c6bbace482                                                |
    | port_security_enabled | False                                                                               |
    | project_id            | 6d0a81ec951f41fe957fe08ec5c50ae1                                                    |
    | revision_number       | 267                                                                                 |
    | security_groups       |                                                                                     |
    | status                | ACTIVE                                                                              |
    | tenant_id             | 6d0a81ec951f41fe957fe08ec5c50ae1                                                    |
    | updated_at            | 2020-08-28T19:18:00Z                                                                |
    +-----------------------+-------------------------------------------------------------------------------------+
    ```  
6. Update the Openstack fixed IP that is BIG-IP1's internal self IP with the allowed address pair of that of the floating self-ip and the MAC Masquerade Address  
    ```
    neutron port-update be37f8c3-d8af-44a9-90f2-aa4534cdd0bc --allowed_address_pairs list=true type=dict ip_address=172.16.4.100,mac_address=fa:16:3e:ae:00:00
    ```  
    ```
    [root@controller ~]# neutron port-show be37f8c3-d8af-44a9-90f2-aa4534cdd0bc
    +-----------------------+-------------------------------------------------------------------------------------+
    | Field                 | Value                                                                               |
    +-----------------------+-------------------------------------------------------------------------------------+
    | admin_state_up        | True                                                                                |
    | allowed_address_pairs | {"ip_address": "172.16.4.100", "mac_address": "fa:16:3e:ae:00:00"}                  |
    | binding:vnic_type     | normal                                                                              |
    | created_at            | 2018-10-02T22:30:49Z                                                                |
    | description           |                                                                                     |
    | device_id             | 3ee1d044-6885-48e0-affa-e0979eaf5112                                                |
    | device_owner          | compute:nova                                                                        |
    | extra_dhcp_opts       |                                                                                     |
    | fixed_ips             | {"subnet_id": "2c42b9bb-93eb-4566-b4fc-b2cfad040e83", "ip_address": "172.16.4.111"} |
    | id                    | be37f8c3-d8af-44a9-90f2-aa4534cdd0bc                                                |
    | mac_address           | fa:16:3e:e1:dd:26                                                                   |
    | name                  |                                                                                     |
    | network_id            | 0ffaa280-578c-45e7-a8b2-a0c6bbace482                                                |
    | port_security_enabled | True                                                                                |
    | project_id            | 6d0a81ec951f41fe957fe08ec5c50ae1                                                    |
    | revision_number       | 77                                                                                  |
    | security_groups       | aefc1d1c-b419-4e86-b884-afd00a2197e3                                                |
    |                       | b8813eb3-895c-4340-acbe-a3ecb32a9fd8                                                |
    | status                | ACTIVE                                                                              |
    | tenant_id             | 6d0a81ec951f41fe957fe08ec5c50ae1                                                    |
    | updated_at            | 2020-08-28T21:34:45Z                                                                |
    +-----------------------+-------------------------------------------------------------------------------------+
    ```  

7. Update the Openstack fixed IP that is BIG-IP2's internal self IP with the allowed address pair of that of the floating self-ip and the MAC Masquerade Address 

    ```
    neutron port-update 467e2dbc-d599-42a8-8445-f921d0d8abe3 --allowed_address_pairs list=true type=dict ip_address=172.16.4.100,mac_address=fa:16:3e:ae:00:00
    ```
    ```
    [root@controller ~]# neutron port-show 467e2dbc-d599-42a8-8445-f921d0d8abe3
    +-----------------------+-------------------------------------------------------------------------------------+
    | Field                 | Value                                                                               |
    +-----------------------+-------------------------------------------------------------------------------------+
    | admin_state_up        | True                                                                                |
    | allowed_address_pairs | {"ip_address": "172.16.4.100", "mac_address": "fa:16:3e:ae:00:00"}                  |
    | binding:vnic_type     | normal                                                                              |
    | created_at            | 2018-10-02T22:18:18Z                                                                |
    | description           |                                                                                     |
    | device_id             | d8ab5f63-c102-4d97-917e-a0fa55a877c4                                                |
    | device_owner          | compute:nova                                                                        |
    | extra_dhcp_opts       |                                                                                     |
    | fixed_ips             | {"subnet_id": "2c42b9bb-93eb-4566-b4fc-b2cfad040e83", "ip_address": "172.16.4.105"} |
    | id                    | 467e2dbc-d599-42a8-8445-f921d0d8abe3                                                |
    | mac_address           | fa:16:3e:f8:57:3a                                                                   |
    | name                  |                                                                                     |
    | network_id            | 0ffaa280-578c-45e7-a8b2-a0c6bbace482                                                |
    | port_security_enabled | True                                                                                |
    | project_id            | 6d0a81ec951f41fe957fe08ec5c50ae1                                                    |
    | revision_number       | 265                                                                                 |
    | security_groups       | aefc1d1c-b419-4e86-b884-afd00a2197e3                                                |
    |                       | b8813eb3-895c-4340-acbe-a3ecb32a9fd8                                                |
    | status                | ACTIVE                                                                              |
    | tenant_id             | 6d0a81ec951f41fe957fe08ec5c50ae1                                                    |
    | updated_at            | 2020-08-28T21:34:53Z                                                                |
    +-----------------------+-------------------------------------------------------------------------------------+
    ```

8.  Be sure to create the VIP and floating self-ip on the BIG-IP itself  

9.  tcpdumps taken from BIG-IP 1 and BIG-IP 2 for this example  

    - [BIG-IP 1 tcpdump -- select download on this link](https://github.com/grmarxer/Openstack/blob/master/Configuring_MAC_Masquerade/tcpdumps/mac-masq-flow-BIG-IP1.pcap)  

    - [BIG-IP 2 tcpdump -- select download on this link](https://github.com/grmarxer/Openstack/blob/master/Configuring_MAC_Masquerade/tcpdumps/mac-masq-flow-BIG-IP2.pcap)  

10.  You have completed this procedure.