
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
    | cd518d86-b003-49f1-9a73-d23009cbb7a6 | controller | None          | power on    | manageable         | False       |
    | 2e3e9a7a-ff26-4a69-8951-2aa6348048c3 | compute1   | None          | power on    | manageable         | False       |
    | 109a3162-a312-4eb7-96d7-9f25f61d9b75 | compute2   | None          | power on    | manageable         | False       |
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
    | 352d85d4-ba61-4d6f-81af-e2e76618301a |            check-cpu            | PASSED |    all     |                |                   |             |
    | 6895a8ad-351c-49de-805d-3983f5e07aea |         check-disk-space        | PASSED |    all     |                |                   |             |
    | dac3a1d6-87fc-4761-9074-a0ae4b60904c |            check-ram            | PASSED |    all     |                |                   |             |
    | 7c221a87-27b4-43e4-8211-b577e6471530 |        check-selinux-mode       | PASSED |    all     |                |                   |             |
    | 6183a73d-e7e1-494b-acac-dcfe23cdacd1 |      check-network-gateway      | PASSED | undercloud |   undercloud   |                   | 0:00:01.752 |
    | d3f52d85-a71b-4884-97fa-ee9488087da6 |        ctlplane-ip-range        | FAILED | undercloud |   undercloud   |                   | 0:00:01.594 |
    | 6050c6cd-29c6-4cf0-bb84-3a1ec953708e |        dhcp-introspection       | PASSED | undercloud |   undercloud   |                   | 0:00:06.095 |
    | 146aafe8-2a3c-496c-a8dc-2b9434ebc3e4 |      undercloud-disk-space      | PASSED | undercloud |   undercloud   |                   | 0:00:02.700 |
    | 25dc55d9-be5d-48ea-b71a-f5ea98d355bb |      undercloud-tokenflush      | PASSED | undercloud |   undercloud   |                   | 0:00:00.754 |
    | d76a0f4c-4ae6-4235-9aef-6bb356a76e98 | undercloud-neutron-sanity-check | PASSED | undercloud |   undercloud   |                   | 0:00:05.863 |
    +--------------------------------------+---------------------------------+--------+------------+----------------+-------------------+-------------+
    ```  
    ### add new scrape  to fixed failed ip-range

3. Review the results of the validation report. To view detailed output from a specific validation, run the openstack tripleo validator show run command against the UUID of the specific validation from the report:  
    ```
    $ openstack tripleo validator show run <UUID>
    ```  

IMPORTANT
A FAILED validation does not prevent you from deploying or running Red Hat OpenStack Platform. However, a FAILED validation can indicate a potential issue with a production environment.