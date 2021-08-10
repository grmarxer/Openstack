
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

4. Connect to the node as the heat-admin user and use the short hostname of the node:  
```
(undercloud) $ ssh heat-admin@overcloud-controller-0.ctlplane
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

