
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

3. Review the results of the validation report. To view detailed output from a specific validation, run the openstack tripleo validator show run command against the UUID of the specific validation from the report:  
    ```
    $ openstack tripleo validator show run <UUID>
    ```  

IMPORTANT
A FAILED validation does not prevent you from deploying or running Red Hat OpenStack Platform. However, a FAILED validation can indicate a potential issue with a production environment.