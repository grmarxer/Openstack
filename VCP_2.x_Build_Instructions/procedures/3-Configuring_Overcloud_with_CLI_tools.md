
# Configuring the Overcloud with CLI Tools


<br/> 


## Registering nodes for the overcloud  

Director requires a node definition template, which you create manually. This template uses a JSON or YAML format, and contains the hardware and power management details for your nodes.

#### Procedure  

1. Create the following template named `nodes.json` in the `/home/stack` directory which identifies your Overcloud nodes. This template has been created for you and is specific to this environment.  The `nodes.json` file can be found [here](https://github.com/grmarxer/Openstack/tree/master/VCP_2.x_Build_Instructions/config_files/nodes.json)  


2. After you create the template, run the following commands to verify the formatting and syntax:  
    ```
    $ source ~/stackrc
    ```  
    ```
    (undercloud) $ openstack overcloud node import --validate-only ~/nodes.json
    ```  
    ```
    (undercloud) [stack@osp16-undercloud ~]$ openstack overcloud node import --validate-only ~/nodes.json
    Waiting for messages on queue 'tripleo' with no timeout.

    Successfully validated environment file
    ```  

3. Run the following commands to import the template to director:  
    ```
    (undercloud) $ openstack overcloud node import ~/nodes.json
    ```  

    This command registers each node from the template into director.  

4. Wait for the node registration and configuration to complete. When complete, confirm that director has successfully registered the nodes:  
    ```
    (undercloud) $ openstack baremetal node list
    ```  
    ```
    (undercloud) [stack@osp16-undercloud ~]$ openstack baremetal node list
    +--------------------------------------+------------+---------------+-------------+--------------------+-------------+
    | UUID                                 | Name       | Instance UUID | Power State | Provisioning State | Maintenance |
    +--------------------------------------+------------+---------------+-------------+--------------------+-------------+
    | 70edb09e-7338-48b0-9707-edfdf8e115b9 | controller | None          | power off   | manageable         | False       |
    | b6f8faac-0b35-4ee2-8680-62223349c61e | compute1   | None          | power off   | manageable         | False       |
    | 73716eb2-791d-4f03-a9d5-aeb49acc89ce | compute2   | None          | power off   | manageable         | False       |
    +--------------------------------------+------------+---------------+-------------+--------------------+-------------+
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

## Inspecting the hardware of nodes for IPv4 provisioning  

Director can run an introspection process on each node. This process boots an introspection agent over PXE on each node. The introspection agent collects hardware data from the node and sends the data back to director. Director then stores this introspection data in the OpenStack Object Storage (swift) service running on director. Director uses hardware information for various purposes such as profile tagging, benchmarking, and manual root disk assignment.  

#### Procedure  

1. Make sure all the Overcloud Compute and Controller nodes are powered off  

    ```
    (undercloud) [stack@osp16-undercloud ~]$ openstack baremetal node list
    +--------------------------------------+------------+---------------+-------------+--------------------+-------------+
    | UUID                                 | Name       | Instance UUID | Power State | Provisioning State | Maintenance |
    +--------------------------------------+------------+---------------+-------------+--------------------+-------------+
    | 70edb09e-7338-48b0-9707-edfdf8e115b9 | controller | None          | power off   | manageable         | False       |
    | b6f8faac-0b35-4ee2-8680-62223349c61e | compute1   | None          | power off   | manageable         | False       |
    | 73716eb2-791d-4f03-a9d5-aeb49acc89ce | compute2   | None          | power off   | manageable         | False       |
    +--------------------------------------+------------+---------------+-------------+--------------------+-------------+
    ```  
    <br/> 

2. Run the following command, one at a time, to inspect the hardware attributes of each node using the Nodes `UUID`:  

    __IMPORTANT READ THIS:__   This process is incredibly unreliable.  Sometimes it works and sometimes it doesn't.  
    
    During my testing I found that the PXE boot fails because the PXE client (Controller and Compute nodes) do not send the TCP SYN to start the TCP connection required to perform the HTTP __GET /inspector.ipxe HTTP/1.1\r\n__, full URL __http://192.168.255.1:8088/inspector.ipxe__ from the PXE server (undercloud director).  Why this occurs I have no idea, but without it the PXE boot fails and the node boots to the hard disk.  
    
    If this issue occurs just try and try again until it works by reissuing the `openstack baremetal introspection start` command for the node in question.  You do not need to anything else other than issue the `openstack baremetal introspection start` command __(example -- openstack baremetal introspection start 70edb09e-7338-48b0-9707-edfdf8e115b9)__ to restart the process.
    
    The best way to know if this is working or not is to watch the IDRAC console for the node in question.  If it fails the PXE boot, the boot cycle will be short as the image on the hard disk is loaded.  If you see a ton of information scrolling across the screen for a minute or two the PXE boot worked.  Wait for one node to finish completely before starting the introspection on the next node.  __GOOD LUCK!__  
    <br/> 

    ```
    (undercloud) [stack@osp16-undercloud ~]$ openstack baremetal introspection start 70edb09e-7338-48b0-9707-edfdf8e115b9
    ```  
    ```
    (undercloud) [stack@osp16-undercloud ~]$ openstack baremetal introspection start b6f8faac-0b35-4ee2-8680-62223349c61e
    ```  
    ```
    (undercloud) [stack@osp16-undercloud ~]$ openstack baremetal introspection start 73716eb2-791d-4f03-a9d5-aeb49acc89ce
    ```  
    <br/>

    The above command won’t poll for the introspection result, use the following command to check the current introspection state:  
    
    __Note:__  You should also monitor the console from each nodes IDRAC interface during this process.  This will help you know in real time if something has failed.  

    ```
    (undercloud) [stack@osp16-undercloud ~]$ openstack baremetal introspection status 70edb09e-7338-48b0-9707-edfdf8e115b9
    +-------------+--------------------------------------+
    | Field       | Value                                |
    +-------------+--------------------------------------+
    | error       | None                                 |
    | finished    | True                                 |
    | finished_at | 2021-04-22T15:32:02                  |
    | started_at  | 2021-04-22T15:24:52                  |
    | state       | finished                             |
    | uuid        | 70edb09e-7338-48b0-9707-edfdf8e115b9 |
    +-------------+--------------------------------------+
    ```  

    Repeat it for every node until you see __True__ in the finished field. The error field will contain an error message if introspection failed, or __None__ if introspection succeeded for this node.  

    <br/> 


3. Monitor the introspection progress logs in a separate terminal window:  The logs are not real helpful in telling you if something failed.  I have found they are only good at telling you if it was successful.  Monitoring IDRAC is the best method to see what is going on.  

    ```
    (undercloud) $ sudo tail -f /var/log/containers/ironic-inspector/ironic-inspector.log
    ```  

    This is the log message you will see when the `Introspection finished successfully` for each UUID  

    ```    
    [root@osp16-undercloud ironic-inspector]#  cat ironic-inspector.log | egrep -i "70edb09e-7338-48b0-9707-edfdf8e115b9 state finished"
    ```  

    ```
    2021-04-22 08:32:02.763 7 DEBUG ironic_inspector.node_cache [-] [node: 70edb09e-7338-48b0-9707-edfdf8e115b9 state finished] Committing fields: {'finished_at': datetime.datetime(2021, 4, 22, 15, 32, 2, 734703), 'error': None} _commit /usr/lib/python3.6/site-packages/ironic_inspector/node_cache.py:150
    2021-04-22 08:32:02.839 7 INFO ironic_inspector.process [-] [node: 70edb09e-7338-48b0-9707-edfdf8e115b9 state finished MAC b0:26:28:44:91:41 BMC 10.144.19.237] Introspection finished successfully
    ```

    __IMPORTANT__ Ensure that this process runs to completion. This process usually takes __~10__ minutes per node.    
    <br/> 

4.  Once the introspection has completely successfully for each of the nodes above, we need to make those nodes available for deployment using the following command  

    ```
    openstack baremetal node provide 70edb09e-7338-48b0-9707-edfdf8e115b9
    openstack baremetal node provide b6f8faac-0b35-4ee2-8680-62223349c61e
    openstack baremetal node provide 73716eb2-791d-4f03-a9d5-aeb49acc89ce
    ```  
    <br/> 