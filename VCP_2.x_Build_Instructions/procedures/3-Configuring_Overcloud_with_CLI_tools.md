



## Registering nodes for the overcloud  

Director requires a node definition template, which you create manually. This template uses a JSON or YAML format, and contains the hardware and power management details for your nodes.

#### Procedure  

1. Create the following template named `nodes.yaml` in the `/home/stack` directory which identifies your Overcloud nodes. This template has been created for you and is specific to this environment.  The `nodes.yaml` file can be found [here](https://github.com/grmarxer/Openstack/tree/master/VCP_2.x_Build_Instructions/config_files)  


2. After you create the template, run the following commands to verify the formatting and syntax:  
    ```
    $ source ~/stackrc
    ```  
    ```
    (undercloud) $ openstack overcloud node import --validate-only ~/nodes.yaml
    ```  

3. Run the following commands to import the template to director:  
    ```
    (undercloud) $ openstack overcloud node import ~/nodes.yaml
    ```  

    This command registers each node from the template into director.  

4. Wait for the node registration and configuration to complete. When complete, confirm that director has successfully registered the nodes:  
    ```
    (undercloud) $ openstack baremetal node list
    ```  

