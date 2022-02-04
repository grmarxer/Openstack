
# Configuring the Overcloud with CLI Tools


<br/> 


## Registering nodes for the overcloud  

Director requires a node definition template, which you create manually. This template uses a JSON or YAML format, and contains the hardware and power management details for your nodes.

#### Procedure  

1. Create the following template named `my-nodes.json` in the `/home/stack/templates` directory which identifies your Overcloud nodes. This template has been created for you and is specific to this environment.  The `my-nodes.json` file can be found [here](https://github.com/grmarxer/Openstack/tree/master/Openstack_2.x_Build_Instructions/config_files/my-nodes.json)  


2. After you create the template, run the following commands to verify the formatting and syntax:  
    ```
    $ source ~/stackrc
    ```  
    ```
    (undercloud) $ openstack overcloud node import --validate-only /home/stack/templates/my-nodes.json
    ```  
    ```
    (undercloud) [stack@osp16-undercloud ~]$ openstack overcloud node import --validate-only /home/stack/templates/my-nodes.json
    Waiting for messages on queue 'tripleo' with no timeout.

    Successfully validated environment file
    ```  

3. Run the following commands to import the template to director:  
    ```
    (undercloud) $ openstack overcloud node import /home/stack/templates/my-nodes.json
    ```  

    This command registers each node from the template into director.  

4. Wait for the node registration and configuration to complete. When complete, confirm that director has successfully registered the nodes:  
    ```
    (undercloud) $ openstack baremetal node list
    ```  
    ```
    (undercloud) [stack@osp16-undercloud templates]$ openstack baremetal node list
    +--------------------------------------+-------------------+---------------+-------------+--------------------+-------------+
    | UUID                                 | Name              | Instance UUID | Power State | Provisioning State | Maintenance |
    +--------------------------------------+-------------------+---------------+-------------+--------------------+-------------+
    | 3dcdfc03-2209-4b39-95ed-c3f5aa83f4b3 | compute1-intel    | None          | power on    | manageable         | False       |
    | fd8cb86e-1b85-44a1-84bc-bf144de71481 | compute2-intel    | None          | power on    | manageable         | False       |
    | a464f58c-2af3-4d9b-a10e-66eadf9e085a | compute3-mellanox | None          | power on    | manageable         | False       |
    | 6fd40403-fd4f-41c0-811a-7f94a5cc1d7f | compute4-mellanox | None          | power on    | manageable         | False       |
    | a753d67e-072d-4500-bc14-965822fa4089 | controller        | None          | power on    | manageable         | False       |
    +--------------------------------------+-------------------+---------------+-------------+--------------------+-------------+
    ```  

5.  Also confirm that the MAC addresses are correct for each node.  This is the MAC of the provisioning network.  

    __NOTE:__ The physical_network must be `ctlplane` and not the name of the interface found in ifconfig  
    
    ```
    (undercloud) [stack@osp16-undercloud templates]$ openstack baremetal port list
    +--------------------------------------+-------------------+
    | UUID                                 | Address           |
    +--------------------------------------+-------------------+
    | fee46fa9-1b6d-4070-9bd1-22d991a26fe0 | b0:26:28:3e:73:11 |
    | 567bc2b0-1ace-4d86-8be3-7eccd69b0db7 | b0:26:28:3b:71:a1 |
    | 769c785e-a6a0-421c-b3cd-0de6f77ce969 | b0:26:28:44:91:41 |
    | 9c7f2ae4-9afb-4402-a971-a90149e2f938 | b0:26:28:45:fd:81 |
    | 4b3f1224-eda5-4c29-a91d-28afe08f0f93 | 14:18:77:70:0c:fa |
    +--------------------------------------+-------------------+
    (undercloud) [stack@osp16-undercloud templates]$ openstack baremetal port show fee46fa9-1b6d-4070-9bd1-22d991a26fe0
    +-----------------------+--------------------------------------+
    | Field                 | Value                                |
    +-----------------------+--------------------------------------+
    | address               | b0:26:28:3e:73:11                    |
    | created_at            | 2021-10-12T18:14:03+00:00            |
    | extra                 | {}                                   |
    | internal_info         | {}                                   |
    | is_smartnic           | False                                |
    | local_link_connection | {}                                   |
    | node_uuid             | 3dcdfc03-2209-4b39-95ed-c3f5aa83f4b3 |
    | physical_network      | ctlplane                             |
    | portgroup_uuid        | None                                 |
    | pxe_enabled           | True                                 |
    | updated_at            | None                                 |
    | uuid                  | fee46fa9-1b6d-4070-9bd1-22d991a26fe0 |
    +-----------------------+--------------------------------------+
    (undercloud) [stack@osp16-undercloud templates]$ openstack baremetal port show 567bc2b0-1ace-4d86-8be3-7eccd69b0db7
    +-----------------------+--------------------------------------+
    | Field                 | Value                                |
    +-----------------------+--------------------------------------+
    | address               | b0:26:28:3b:71:a1                    |
    | created_at            | 2021-10-12T18:14:04+00:00            |
    | extra                 | {}                                   |
    | internal_info         | {}                                   |
    | is_smartnic           | False                                |
    | local_link_connection | {}                                   |
    | node_uuid             | fd8cb86e-1b85-44a1-84bc-bf144de71481 |
    | physical_network      | ctlplane                             |
    | portgroup_uuid        | None                                 |
    | pxe_enabled           | True                                 |
    | updated_at            | None                                 |
    | uuid                  | 567bc2b0-1ace-4d86-8be3-7eccd69b0db7 |
    +-----------------------+--------------------------------------+
    (undercloud) [stack@osp16-undercloud templates]$ openstack baremetal port show 769c785e-a6a0-421c-b3cd-0de6f77ce969
    +-----------------------+--------------------------------------+
    | Field                 | Value                                |
    +-----------------------+--------------------------------------+
    | address               | b0:26:28:44:91:41                    |
    | created_at            | 2021-10-12T18:14:05+00:00            |
    | extra                 | {}                                   |
    | internal_info         | {}                                   |
    | is_smartnic           | False                                |
    | local_link_connection | {}                                   |
    | node_uuid             | a464f58c-2af3-4d9b-a10e-66eadf9e085a |
    | physical_network      | ctlplane                             |
    | portgroup_uuid        | None                                 |
    | pxe_enabled           | True                                 |
    | updated_at            | None                                 |
    | uuid                  | 769c785e-a6a0-421c-b3cd-0de6f77ce969 |
    +-----------------------+--------------------------------------+
    (undercloud) [stack@osp16-undercloud templates]$ openstack baremetal port show 9c7f2ae4-9afb-4402-a971-a90149e2f938
    +-----------------------+--------------------------------------+
    | Field                 | Value                                |
    +-----------------------+--------------------------------------+
    | address               | b0:26:28:45:fd:81                    |
    | created_at            | 2021-10-12T18:14:06+00:00            |
    | extra                 | {}                                   |
    | internal_info         | {}                                   |
    | is_smartnic           | False                                |
    | local_link_connection | {}                                   |
    | node_uuid             | 6fd40403-fd4f-41c0-811a-7f94a5cc1d7f |
    | physical_network      | ctlplane                             |
    | portgroup_uuid        | None                                 |
    | pxe_enabled           | True                                 |
    | updated_at            | None                                 |
    | uuid                  | 9c7f2ae4-9afb-4402-a971-a90149e2f938 |
    +-----------------------+--------------------------------------+
    (undercloud) [stack@osp16-undercloud templates]$ openstack baremetal port show 4b3f1224-eda5-4c29-a91d-28afe08f0f93
    +-----------------------+--------------------------------------+
    | Field                 | Value                                |
    +-----------------------+--------------------------------------+
    | address               | 14:18:77:70:0c:fa                    |
    | created_at            | 2021-10-12T18:14:06+00:00            |
    | extra                 | {}                                   |
    | internal_info         | {}                                   |
    | is_smartnic           | False                                |
    | local_link_connection | {}                                   |
    | node_uuid             | a753d67e-072d-4500-bc14-965822fa4089 |
    | physical_network      | ctlplane                             |
    | portgroup_uuid        | None                                 |
    | pxe_enabled           | True                                 |
    | updated_at            | None                                 |
    | uuid                  | 4b3f1224-eda5-4c29-a91d-28afe08f0f93 |
    +-----------------------+--------------------------------------+
    ```  


<br/> 

## Validating the introspection requirements  

Run the pre-introspection validation group to check the introspection requirements.  

#### Procedure  

1. Source the stackrc file.  
    ```
    $ source ~/stackrc
    ```  

2. Run the openstack tripleo validator run command with the --group pre-introspection option:  
    ```
    $ openstack tripleo validator run --group pre-introspection
    ```  
    ```
    (undercloud) [stack@osp16-undercloud ~]$ openstack tripleo validator run --group pre-introspection
    Running Validations without Overcloud settings.
    WARNING:tripleo_common.inventory:Stack not found: overcloud. Only the undercloud will be added to the inventory.
    +--------------------------------------+---------------------------------+--------+------------+----------------+-------------------+-------------+
    |                 UUID                 |           Validations           | Status | Host_Group | Status_by_Host | Unreachable_Hosts |   Duration  |
    +--------------------------------------+---------------------------------+--------+------------+----------------+-------------------+-------------+
    | 5a155cb7-e5de-43d7-8593-8d5617ceca22 |            check-cpu            | PASSED |    all     |                |                   |             |
    | cfb02f75-3f64-4e6c-814b-f71c6459b1d4 |         check-disk-space        | PASSED |    all     |                |                   |             |
    | aff39015-1c74-4adb-a772-e72d3153e7a8 |            check-ram            | PASSED |    all     |                |                   |             |
    | 670b9025-4ac0-4dab-a5a4-2fbb40f0eb68 |        check-selinux-mode       | PASSED |    all     |                |                   |             |
    | aa469cb6-036a-4f0c-bb59-4336d7060e26 |      check-network-gateway      | PASSED | undercloud |   undercloud   |                   | 0:00:01.902 |
    | a1f84261-85ae-41ca-a898-fd545299976d |        ctlplane-ip-range        | PASSED | undercloud |   undercloud   |                   | 0:00:01.591 |
    | c6a6f226-9a63-4d01-9f50-ae223c44bb15 |        dhcp-introspection       | PASSED | undercloud |   undercloud   |                   | 0:00:05.940 |
    | 29cb898e-1ab5-4921-aa8e-4cadff6e2a28 |      undercloud-disk-space      | PASSED | undercloud |   undercloud   |                   | 0:00:02.495 |
    | 206da79d-ef07-4d10-8fb9-162c5544f18e |      undercloud-tokenflush      | PASSED | undercloud |   undercloud   |                   | 0:00:00.752 |
    | 57897b6c-3a0c-4d2f-8b36-f225a11b708a | undercloud-neutron-sanity-check | PASSED | undercloud |   undercloud   |                   | 0:00:05.664 |
    +--------------------------------------+---------------------------------+--------+------------+----------------+-------------------+-------------+
    ```  
    <br/> 

3. Review the results of the validation report. To view detailed output from a specific validation, run the openstack tripleo validator show run command against the UUID of the specific validation from the report:  
    ```
    $ openstack tripleo validator show run <UUID>
    ```  

    __IMPORTANT__  All validations should have a status of `passed`  

<br/> 

## Inspecting the openstack nodes hardware for IPv4 provisioning  

The undercloud director can run an introspection process on each node. This process boots an introspection agent on each node via PXE. The introspection agent collects hardware data on each node and sends the data back to director. The director then stores this introspection data in the OpenStack Object Storage (swift) service running on the director. Director uses hardware information for various purposes such as profile tagging, benchmarking, and manual root disk assignment.  

#### Procedure  

1. For this procedure the nodes can either be powered on or off, it doesn't matter.  

    ```
    (undercloud) [stack@osp16-undercloud ~]$ openstack baremetal node list
    +--------------------------------------+----------------+---------------+-------------+--------------------+-------------+
    | UUID                                 | Name           | Instance UUID | Power State | Provisioning State | Maintenance |
    +--------------------------------------+----------------+---------------+-------------+--------------------+-------------+
    | 199a6ae0-c39a-4bfa-ad23-54280a3bac38 | compute1-intel | None          | power on    | manageable         | False       |
    | 5115e19f-9b81-44ca-8423-b3b1949807e5 | compute2-intel | None          | power on    | manageable         | False       |
    | e2645014-ebed-4184-ae01-c782823b100a | compute3-mel   | None          | power on    | manageable         | False       |
    | 10e49aaa-fdd2-49dc-b009-0da398b4f5d7 | compute4-mel   | None          | power on    | manageable         | False       |
    | 3d19a65f-6699-484a-9298-c63c5d9068fe | controller     | None          | power on    | manageable         | False       |
    +--------------------------------------+----------------+---------------+-------------+--------------------+-------------+
    ```  
    <br/> 

2.  Make sure the `tripleo_ironic_inspector_dnsmasq.service` is running and not in a failed state.  This service is required for the Openstack Director to answer the PXE client's BOOTP requests.  

    ```
    sudo systemctl status tripleo_ironic_inspector_dnsmasq.service
    ```   
    ```
    [stack@osp16-undercloud ~]$ systemctl status tripleo_ironic_inspector_dnsmasq.service
    ● tripleo_ironic_inspector_dnsmasq.service - ironic_inspector_dnsmasq container
    Loaded: loaded (/etc/systemd/system/tripleo_ironic_inspector_dnsmasq.service; enabled; vendor preset: disabled)
    Active: active (running) since Fri 2021-04-30 09:58:42 PDT; 1h 30min ago
    ```  
    <br/> 

    __ONLY IF__ the `tripleo_ironic_inspector_dnsmasq.service`  has failed complete the following steps to resolve the issue.  
  
    __Note:__  Must be logged in as root to issue netstat and kill commands  

    ```
    [root@osp16-undercloud stack]# sudo netstat -anup | grep :67
    udp        0      0 0.0.0.0:67              0.0.0.0:*                           29922/dnsmasq
    ```  
    ```
    sudo kill 29922
    ```  
    ```
    sudo systemctl restart tripleo_ironic_inspector_dnsmasq.service
    ```  
    ```
    sudo systemctl status tripleo_ironic_inspector_dnsmasq.service
    ```   
    <br/> 

3.  (Optional) I recommend opening a new terminal window and starting a tcpdump on interface `eno4` to ensure the openstack director is answering the BOOTP requests  
    ```
    sudo tcpdump -s0 -nni eno4 port 67 or port 68 or port 8088
    ```  

    <br/> 


4. Run the following command to inspect the hardware attributes of each node: 

    ```
    (undercloud) [stack@osp16-undercloud ~]$ openstack overcloud node introspect --all-manageable --provide
    ```  

    - Use the --all-manageable option to introspect only the nodes that are in a managed state. In this example, all nodes are in a managed state.  

    - Use the --provide option to reset all nodes to an available state after introspection.  

    The `openstack overcloud node introspect --all-manageable --provide`  command won’t poll for real-time introspection status, you can use the following command to check the current introspection state for each UUID:  

    ```
    (undercloud) [stack@osp16-undercloud ~]$ openstack baremetal introspection status 146bb426-2a52-4cba-b12b-b3f46749462b
    +-------------+--------------------------------------+
    | Field       | Value                                |
    +-------------+--------------------------------------+
    | error       | None                                 |
    | finished    | True                                 |
    | finished_at | 2021-04-22T18:51:30                  |
    | started_at  | 2021-04-22T18:44:04                  |
    | state       | finished                             |
    | uuid        | 146bb426-2a52-4cba-b12b-b3f46749462b |
    +-------------+--------------------------------------+
    ```  

    <br/>

    __IMPORTANT READ THIS:__  

    The command above does not provide any real-time useful information.  The best way to know what is going on is to monitor the iDRAC console for each of the Openstack Nodes.  If you see tons of data flying across the screen things are working as it should.  

    The process is slow, here are the steps so you know what to look for:  

    1. The Undercloud director will PXE boot each Openstack Node -- this takes time to start as each server has to go through its bootstrap to get to the PXE boot.  

    2. Then the Openstack Node will attempt to get an IP address from the undercloud director.  Once complete,  

    3. The Openstack Node will issue a TFTP read to the undercloud director, then  

    4. The Openstack Node will issue a HTTP GET for the inspector.ipxe image  

    This process regularly fails between step 3 and step 4, you will know this by monitoring the iDRAC console.  If you see the PXE start but then fail, the server will try to boot from `disk` which is the next option in the boot sequence.  If this occurs it is best to use iDRAC to reboot the node immediately and kickoff the PXE boot again.  This can be done by selecting `PXE` from boot option inside iDRAC or from the BIOS.  
    You do not want a failed PXE boot on a Openstack Node to linger as the introspect command has a time limit.  So if it fails a Openstack Node and the entire process times-out you will need to start the process again for all nodes.  

    __The take home message here is if the PXE boot fails for a Openstack Node kick it off again manually as quickly as possible.__  

    <br/>


5. Monitor the introspection progress logs in a separate terminal window:  The logs are not real helpful in telling you if something failed.  I have found they are only good at telling you if it was successful.  Monitoring IDRAC is the best method to see what is going on.  

    ```
    (undercloud) $ sudo tail -f /var/log/containers/ironic-inspector/ironic-inspector.log
    ```  
    <br/> 

    These are the log messages you will see when the `Introspection finished successfully` for each __UUID__    

    ```    
    cat /var/log/containers/ironic-inspector/ironic-inspector.log | egrep -i "146bb426-2a52-4cba-b12b-b3f46749462b state finished"
    ```  
    ```
    2021-04-22 11:51:30.867 7 DEBUG ironic_inspector.node_cache [-] [node: 146bb426-2a52-4cba-b12b-b3f46749462b state finished] Committing fields: {'finished_at': datetime.datetime(2021, 4, 22, 18, 51, 30, 803571), 'error': None} _commit /usr/lib/python3.6/site-packages/ironic_inspector/node_cache.py:150
    2021-04-22 11:51:31.008 7 INFO ironic_inspector.process [-] [node: 146bb426-2a52-4cba-b12b-b3f46749462b state finished MAC b0:26:28:44:91:41 BMC 10.144.19.237] Introspection finished successfully
    ```

    __Note:__ This process usually takes __~10__ minutes per node.    
    <br/> 

6.  When complete you should see this output from the initial `openstack overcloud node introspect --all-manageable --provide` command:

    ```
    (undercloud) [stack@osp16-undercloud ~]$ openstack overcloud node introspect --all-manageable --provide
    Waiting for introspection to finish...
    Waiting for messages on queue 'tripleo' with no timeout.
    Introspection of node completed:3dcdfc03-2209-4b39-95ed-c3f5aa83f4b3. Status:SUCCESS. Errors:None
    Introspection of node completed:fd8cb86e-1b85-44a1-84bc-bf144de71481. Status:SUCCESS. Errors:None
    Introspection of node completed:a464f58c-2af3-4d9b-a10e-66eadf9e085a. Status:SUCCESS. Errors:None
    Introspection of node completed:6fd40403-fd4f-41c0-811a-7f94a5cc1d7f. Status:SUCCESS. Errors:None
    Introspection of node completed:a753d67e-072d-4500-bc14-965822fa4089. Status:SUCCESS. Errors:None
    Successfully introspected 5 node(s).

    Introspection completed.
    Waiting for messages on queue 'tripleo' with no timeout.
    5 node(s) successfully moved to the "available" state.
    ```  

7.  Issue the `openstack baremetal node list` command again.  This is the desired result.  Provisioning state will transition to `available` and the nodes will be powered off.  

    ```
    (undercloud) [stack@osp16-undercloud ~]$ openstack baremetal node list
    +--------------------------------------+-------------------+---------------+-------------+--------------------+-------------+
    | UUID                                 | Name              | Instance UUID | Power State | Provisioning State | Maintenance |
    +--------------------------------------+-------------------+---------------+-------------+--------------------+-------------+
    | 3dcdfc03-2209-4b39-95ed-c3f5aa83f4b3 | compute1-intel    | None          | power off   | available          | False       |
    | fd8cb86e-1b85-44a1-84bc-bf144de71481 | compute2-intel    | None          | power off   | available          | False       |
    | a464f58c-2af3-4d9b-a10e-66eadf9e085a | compute3-mellanox | None          | power off   | available          | False       |
    | 6fd40403-fd4f-41c0-811a-7f94a5cc1d7f | compute4-mellanox | None          | power off   | available          | False       |
    | a753d67e-072d-4500-bc14-965822fa4089 | controller        | None          | power off   | available          | False       |
    +--------------------------------------+-------------------+---------------+-------------+--------------------+-------------+
    ```  

<br/> 

##  Create Custom Roles Specific to this environment  

TripleO offers the option of deploying with a user-defined list of roles, each running a user defined list of services (where “role” means group of nodes, e.g “Controller”, and “service” refers to the individual services or configurations e.g “Nova API”).  

Each role is defined in the roles_data.yaml file. There is a sample file in /usr/share/openstack-tripleo-heat-templates, or the  tripleo-heat-templates git repository.

The data in roles_data.yaml is used to perform templating with jinja2 such that arbitrary user-defined roles may be added, and the default roles may be modified or removed.  

The steps to define your __custom roles__ configuration are:  

#### Procedure  

1.  Login as the `stack` user  

    ```
    source stackrc
    ```  

2. Make the following directory to copy the Triple0 Heat Template default roles to -- `/home/stack/copy-of-default-tripleo-heat-templates/roles`  

    ```
    mkdir -p /home/stack/copy-of-default-tripleo-heat-templates/roles/
    ```  

3. Copy the default roles into `/home/stack/copy-of-default-tripleo-heat-templates/roles` folder

    ```
    cp /usr/share/openstack-tripleo-heat-templates/roles/* /home/stack/copy-of-default-tripleo-heat-templates/roles
    ```  

4. Create the `my-custom_roles_data.yaml` with the following specific roles Controller, ComputeSriov, and ComputeOvsDpdk  

    ```
    openstack overcloud roles generate -o /home/stack/templates/my-custom_roles_data.yaml --roles-path /home/stack/copy-of-default-tripleo-heat-templates/roles Controller ComputeSriov ComputeOvsDpdk ComputeSriov:ComputeSriovN3000SmartNic  
    ```  

5.  Verify that the `my-custom_roles_data.yaml` file was created with the specified roles outlined above  

    ```
    less /home/stack/templates/my-custom_roles_data.yaml
    ```  


<br/> 

##  Create Flavors to Match Roles  

```
openstack flavor create ComputeSriov --ram 6144 --disk 40 --vcpu 1
openstack flavor set --property "cpu_arch"="x86_64" --property "capabilities:boot_option"="local" --property "capabilities:profile"="ComputeSriov" --property resources:CUSTOM_BAREMETAL='1' --property resources:DISK_GB='0' --property resources:MEMORY_MB='0' --property resources:VCPU='0' ComputeSriov


openstack flavor create ComputeOvsDpdk --ram 6144 --disk 40 --vcpu 1
openstack flavor set --property "cpu_arch"="x86_64" --property "capabilities:boot_option"="local" --property "capabilities:profile"="ComputeOvsDpdk" --property resources:CUSTOM_BAREMETAL='1' --property resources:DISK_GB='0' --property resources:MEMORY_MB='0' --property resources:VCPU='0' ComputeOvsDpdk


openstack flavor create ComputeSriovN3000SmartNic --ram 6144 --disk 40 --vcpu 1
openstack flavor set --property "cpu_arch"="x86_64" --property "capabilities:boot_option"="local" --property "capabilities:profile"="ComputeSriovN3000SmartNic" --property resources:CUSTOM_BAREMETAL='1' --property resources:DISK_GB='0' --property resources:MEMORY_MB='0' --property resources:VCPU='0' ComputeSriovN3000SmartNic
```  


<br/> 

<br/> 

##  Controlling Node Placement and IP Assignment   

[Controlling Node Placement and IP Assignment Documentation](https://docs.openstack.org/project-deploy-guide/tripleo-docs/latest/provisioning/node_placement.html)  

By default, nodes are assigned randomly via the Nova scheduler, either from a generic pool of nodes, or from a subset of nodes identified via specific profiles which are mapped to Nova flavors (See [Baremetal Environment](https://docs.openstack.org/project-deploy-guide/tripleo-docs/latest/environments/baremetal.html) and [Advanced Profile Matching](https://docs.openstack.org/project-deploy-guide/tripleo-docs/latest/provisioning/profile_matching.html) for further information).  

However in some circumstances, you may wish to control node placement more directly, which is possible by combining the same capabilities mechanism used for per-profile placement with per-node scheduler hints.  

#### Procedure  

1.  Assign per-node capabilities  The first step is to assign a unique per-node capability which may be matched by the Nova scheduler on deployment.  
    ```
    openstack baremetal node set --property capabilities="node:vz-osp-controller-0,boot_option:local" controller
    openstack baremetal node set --property capabilities="node:vz-osp-computesriov-0,boot_option:local" compute1-intel
    openstack baremetal node set --property capabilities="node:vz-osp-computesriov-1,boot_option:local" compute2-intel
    openstack baremetal node set --property capabilities="node:vz-osp-computedpdk-0,boot_option:local" compute3-mellanox
    openstack baremetal node set --property capabilities="node:vz-osp-computedpdk-1,boot_option:local" compute4-mellanox
    openstack baremetal node set --property capabilities="node:vz-osp-computeN3000-0,boot_option:local" compute5-N3000
    openstack baremetal node set --property capabilities="node:vz-osp-computeN3000-1,boot_option:local" compute6-N3000
    ```  

2.   After you assign the per-node capability to each node, verify it was set properly.  Example below for the controller  

    ```
    (undercloud) [stack@osp16-undercloud ~]$ openstack baremetal node show controller
    +------------------------+----------------------------------------------------------------------------------------------------------------------------------------------
    | Field                  | Value                                                                                                                                        |
    +------------------------+----------------------------------------------------------------------------------------------------------------------------------------------
    | allocation_uuid        | None                                                                                                                                         |
    | automated_clean        | None                                                                                                                                         |
    | bios_interface         | no-bios                                                                                                                                      |
    | boot_interface         | ipxe                                                                                                                                         |
    |                                                                                                                                                                       |
    |   <snippet removed > ...                                                                                                                                              |
    |                                                                                                                                                                       |
    | properties             | {'local_gb': '930', 'cpus': '24', 'cpu_arch': 'x86_64', 'memory_mb': '65536', 'capabilities': 'node:vz-osp-controller-0,boot_option:local'}  |
    | protected              | False                                                                                                                                        |
    | protected_reason       | None                                                                                                                                         |
    | provision_state        | available                                                                                                                                    |
    +------------------------+----------------------------------------------------------------------------------------------------------------------------------------------
    ``` 


<br/> 

##  Environment files  

The undercloud includes a set of heat templates that form the plan for your overcloud creation. You can customize aspects of the overcloud with environment files, which are YAML-formatted files that override parameters and resources in the core heat template collection. You can include as many environment files as necessary. However, the order of the environment files is important because the parameters and resources that you define in subsequent environment files take precedence. Use the following list as an example of the environment file order:

The number of nodes and the flavors for each role. It is vital to include this information for overcloud creation.
The location of the container images for containerized OpenStack services.
Any network isolation files, starting with the initialization file (environments/network-isolation.yaml) from the heat template collection, then your custom NIC configuration file, and finally any additional network configurations. For more information, see the following chapters in the Advanced Overcloud Customization guide:

"Basic network isolation"
"Custom composable networks"
"Custom network interface templates"
Any external load balancing environment files if you are using an external load balancer. For more information, see External Load Balancing for the Overcloud.
Any storage environment files such as Ceph Storage, NFS, or iSCSI.
Any environment files for Red Hat CDN or Satellite registration.
Any other custom environment files.
Red Hat recommends that you organize your custom environment files in a separate directory, such as the templates directory.

For more information about customizing advanced features for your overcloud, see the Advanced Overcloud Customization guide.

IMPORTANT
A basic overcloud uses local LVM storage for block storage, which is not a supported configuration. It is recommended to use an external storage solution, such as Red Hat Ceph Storage, for block storage.

NOTE
The environment file extension must be .yaml or .template, or it will not be treated as a custom template resource.

The next few sections contain information about creating some environment files necessary for your overcloud.  


<br/> 

##  Think this can be removed Creating an environment file that defines node counts and flavors  

By default, director deploys an overcloud with 1 Controller node and 1 Compute node using the baremetal flavor. However, this is only suitable for a proof-of-concept deployment. You can override the default configuration by specifying different node counts and flavors. For a small-scale production environment, deploy at least 3 Controller nodes and 3 Compute nodes, and assign specific flavors to ensure that the nodes have the appropriate resource specifications. Complete the following steps to create an environment file named node-info.yaml that stores the node counts and flavor assignments.  

#### Procedure  

1.  Create a `node-info.yaml` file in the /home/stack/templates/ directory:  
    ```
    (undercloud) $ vi /home/stack/templates/node-info.yaml
    ```  


2. Edit the file to include the node counts and flavors that you need. This specific environment contains 1 Controller node and 2 Compute nodes:

    ```yaml
    parameter_defaults:
      OvercloudControllerFlavor: control
      OvercloudComputeFlavor: compute
      ControllerCount: 1
      ComputeCount: 2
    ```  

<br/> 


## Deployment command  

The final stage in creating your OpenStack environment is to run the openstack overcloud deploy command to create the overcloud.  

https://access.redhat.com/documentation/en-us/red_hat_openstack_platform/16.1/html/director_installation_and_usage/creating-a-basic-overcloud-with-cli-tools#sect-Including_Environment_Files_in_Overcloud_Creation  

This command contains the following additional options:

--templates  
Creates the overcloud using the heat template collection in /usr/share/openstack-tripleo-heat-templates as a foundation.  

-e /home/stack/templates/node-info.yaml  
Adds an environment file to define how many nodes and which flavors to use for each role.  

-e /home/stack/containers-prepare-parameter.yaml  
Adds the container image preparation environment file. You generated this file during the undercloud installation and can use the same file for your overcloud creation.  

-e /home/stack/inject-trust-anchor-hiera.yaml  
Adds an environment file to install a custom certificate in the undercloud.  

-r /home/stack/templates/roles_data.yaml  
(Optional) The generated roles data if you use custom roles or want to enable a multi architecture cloud. For more information, see Section 7.10, “Creating architecture specific roles”.  

Director requires these environment files for re-deployment and post-deployment functions. Failure to include these files can result in damage to your overcloud.  

To modify the overcloud configuration at a later stage, perform the following actions:  

- Modify parameters in the custom environment files and heat templates.  
- Run the openstack overcloud deploy command again with the same environment files.  

Do not edit the overcloud configuration directly because director overrides any manual configuration when you update the overcloud stack.

```
(undercloud) $ openstack overcloud deploy --templates -e /home/stack/templates/node-info.yaml  -e /home/stack/containers-prepare-parameter.yaml
```  

This is the output of a deployment that completed successfully

```
PLAY RECAP *********************************************************************
overcloud-controller-0     : ok=335  changed=204  unreachable=0    failed=0    skipped=165  rescued=0    ignored=0
overcloud-novacompute-0    : ok=272  changed=160  unreachable=0    failed=0    skipped=166  rescued=0    ignored=0
overcloud-novacompute-1    : ok=269  changed=160  unreachable=0    failed=0    skipped=166  rescued=0    ignored=0
undercloud                 : ok=95   changed=39   unreachable=0    failed=0    skipped=9    rescued=0    ignored=0

Friday 02 July 2021  13:44:22 -0700 (0:00:00.056)       0:22:21.912 ***********
===============================================================================
Wait for containers to start for step 2 using paunch ------------------ 203.69s
Wait for containers to start for step 3 using paunch ------------------ 110.22s
Pre-fetch all the containers ------------------------------------------ 106.00s
Pre-fetch all the containers ------------------------------------------- 97.49s
Wait for containers to start for step 4 using paunch ------------------- 81.88s
Wait for container-puppet tasks (generate config) to finish ------------ 55.55s
Wait for puppet host configuration to finish --------------------------- 42.62s
Run tripleo-container-image-prepare logged to: /var/log/tripleo-container-image-prepare.log -- 39.32s
Wait for containers to start for step 5 using paunch ------------------- 35.96s
tripleo-container-tag : Pull osp16-undercloud.ctlplane.localdomain:8787/rhosp-rhel8/openstack-cinder-volume:16.1 image -- 23.88s
Run puppet on the host to apply IPtables rules ------------------------- 23.63s
Wait for puppet host configuration to finish --------------------------- 19.81s
Wait for container-puppet tasks (bootstrap tasks) for step 4 to finish -- 16.60s
Wait for containers to start for step 1 using paunch ------------------- 16.53s
tripleo-network-config : Run NetworkConfig script ---------------------- 13.86s
Wait for puppet host configuration to finish --------------------------- 13.38s
Wait for puppet host configuration to finish --------------------------- 13.27s
Wait for puppet host configuration to finish --------------------------- 13.27s
Wait for container-puppet tasks (bootstrap tasks) for step 3 to finish -- 10.06s
Manage Cinder Volume Type ----------------------------------------------- 9.17s

Ansible passed.
Overcloud configuration completed.
Overcloud Endpoint: http://192.168.255.24:5000
Overcloud Horizon Dashboard URL: http://192.168.255.24:80/dashboard
Overcloud rc file: /home/stack/templates/overcloudrc
Overcloud Deployed without error
```  





<br/> 
<br/> 
<br/> 
<br/> 
<br/> 
<br/> 

## Notes



```
openstack overcloud profiles list
openstack overcloud status
openstack overcloud delete overcloud
openstack baremetal node list
openstack baremetal port list
openstack baremetal node delete 607b6f1c-adcc-45e5-8068-36efb1497e93
openstack baremetal port delete
```  


```
openstack baremetal node set --property capabilities="profile:compute,boot_option:local" compute1-intel
openstack baremetal node set --property capabilities="profile:compute,boot_option:local" compute2-intel
openstack baremetal node set --property capabilities="profile:compute,boot_option:local" compute3-mellanox
openstack baremetal node set --property capabilities="profile:compute,boot_option:local" compute4-mellanox
openstack baremetal node set --property capabilities="profile:control,boot_option:local" controller
```    

```
openstack baremetal node set --property capabilities="node:vz-osp-controller-0,boot_option:local" controller
openstack baremetal node set --property capabilities="node:vz-osp-computesriov-0,boot_option:local" compute1-intel
openstack baremetal node set --property capabilities="node:vz-osp-computesriov-1,boot_option:local" compute2-intel
openstack baremetal node set --property capabilities="node:vz-osp-computesriov-2,boot_option:local" compute3-mellanox
openstack baremetal node set --property capabilities="node:vz-osp-computesriov-3,boot_option:local" compute4-mellanox
```  



```
sudo systemctl status tripleo_ironic_inspector_dnsmasq.service
sudo netstat -anup | grep :67
sudo kill 29922
sudo systemctl restart tripleo_ironic_inspector_dnsmasq.service
```  