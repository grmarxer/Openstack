
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

1. Make sure all the Overcloud Compute and Controller nodes are power off

1. Run the following command to inspect the hardware attributes of each node:  
    ```
    (undercloud) $ openstack overcloud node introspect --all-manageable --provide
    ```  

    - Use the --all-manageable option to introspect only the nodes that are in a managed state. In this example, all nodes are in a managed state.  
    - Use the --provide option to reset all nodes to an available state after introspection.  
    <br/> 


openstack baremetal introspection start


2. Monitor the introspection progress logs in a separate terminal window:  
    ```
    (undercloud) $ sudo tail -f /var/log/containers/ironic-inspector/ironic-inspector.log
    ```  

    __IMPORTANT__ Ensure that this process runs to completion. This process usually takes 30 minutes for bare metal nodes.  After the introspection completes, all nodes change to an available state.
