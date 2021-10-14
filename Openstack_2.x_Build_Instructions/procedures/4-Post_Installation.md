
## Source the overcloudrc file  

```
$ source ~/overcloudrc
```

<br/> 

## Accessing overcloud nodes through SSH

You can access each overcloud node through the SSH protocol.  

- Each overcloud node contains a heat-admin user.  

- The stack user on the undercloud has key-based SSH access to the heat-admin user on each overcloud node.  

- All overcloud nodes have a short hostname that the undercloud resolves to an IP address on the control plane network. Each short hostname uses a .ctlplane suffix. For example, the short name for overcloud-controller-0 is overcloud-controller-0.ctlplane  


##### Procedure

1. Log in to the undercloud as the stack user.  

2. Source the overcloudrc file:  
    ```
    $ source ~/stackrc
    ```

3. Find the name of the node that you want to access:  
    ```
    (undercloud) $ openstack server list
    ```  

    ```
    (undercloud) [stack@osp16-undercloud ~]$ openstack server list
    +--------------------------------------+-----------------------+--------+-------------------------+----------------+-----------+
    | ID                                   | Name                  | Status | Networks                | Image          | Flavor    |
    +--------------------------------------+-----------------------+--------+-------------------------+----------------+-----------+
    | 1df68cc2-fce9-48c7-8976-e1404018051c | vz-osp-controller-0   | ACTIVE | ctlplane=192.168.255.24 | overcloud-full | baremetal |
    | 429e1514-eecf-44b3-94d3-46485e5f4b22 | vz-osp-computedpdk-1  | ACTIVE | ctlplane=192.168.255.23 | overcloud-full | baremetal |
    | 2a12ee7f-30a4-4234-b0d7-60657e8355d6 | vz-osp-computesriov-0 | ACTIVE | ctlplane=192.168.255.37 | overcloud-full | baremetal |
    | 5ff529f6-8654-4c11-991f-3e09780577a9 | vz-osp-computedpdk-0  | ACTIVE | ctlplane=192.168.255.15 | overcloud-full | baremetal |
    | 4daced04-6bb6-4d07-bf11-e32cad16e2bf | vz-osp-computesriov-1 | ACTIVE | ctlplane=192.168.255.31 | overcloud-full | baremetal |
    +--------------------------------------+-----------------------+--------+-------------------------+----------------+-----------+
    ```  

4. Connect to the node as the heat-admin user and use the IP or short hostname of the node:  
    ```
    (undercloud) $ ssh heat-admin@192.168.255.24
    ```  


<br/> 

<br/> 

<br/> 

```
(overcloud) [stack@osp16-undercloud ~]$ openstack user create --password default grmarxer
```  

```
openstack role add --user grmarxer --project admin admin
```

