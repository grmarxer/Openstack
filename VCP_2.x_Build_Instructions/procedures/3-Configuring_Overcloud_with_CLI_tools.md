
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

5.  Also confirm that the MAC addresses are correct for each node.  This is the MAC of the provisioning network.  

    __NOTE:__ The physical_network must be `ctlplane` and not the name of the interface found in ifconfig  
    
    ```
    (undercloud) [stack@osp16-undercloud var]$ openstack baremetal port list
    +--------------------------------------+-------------------+
    | UUID                                 | Address           |
    +--------------------------------------+-------------------+
    | 01048226-2285-4d46-857a-f2f9752a2da2 | b0:26:28:44:91:41 |
    | 962d2cf7-334d-4465-91ce-1c4b5dfbfa7f | b0:26:28:3e:73:11 |
    | e89bb783-a734-444d-a3dd-25aa31cf7674 | b0:26:28:45:fd:81 |
    +--------------------------------------+-------------------+
    (undercloud) [stack@osp16-undercloud var]$ openstack baremetal port show 01048226-2285-4d46-857a-f2f9752a2da2
    +-----------------------+--------------------------------------+
    | Field                 | Value                                |
    +-----------------------+--------------------------------------+
    | address               | b0:26:28:44:91:41                    |
    | created_at            | 2021-06-02T21:18:38+00:00            |
    | extra                 | {}                                   |
    | internal_info         | {}                                   |
    | is_smartnic           | False                                |
    | local_link_connection | {}                                   |
    | node_uuid             | 70edb09e-7338-48b0-9707-edfdf8e115b9 |
    | physical_network      | ctlplane                             |
    | portgroup_uuid        | None                                 |
    | pxe_enabled           | True                                 |
    | updated_at            | None                                 |
    | uuid                  | 01048226-2285-4d46-857a-f2f9752a2da2 |
    +-----------------------+--------------------------------------+
    (undercloud) [stack@osp16-undercloud var]$ openstack baremetal port show 962d2cf7-334d-4465-91ce-1c4b5dfbfa7f
    +-----------------------+--------------------------------------+
    | Field                 | Value                                |
    +-----------------------+--------------------------------------+
    | address               | b0:26:28:3e:73:11                    |
    | created_at            | 2021-06-02T21:18:39+00:00            |
    | extra                 | {}                                   |
    | internal_info         | {}                                   |
    | is_smartnic           | False                                |
    | local_link_connection | {}                                   |
    | node_uuid             | b6f8faac-0b35-4ee2-8680-62223349c61e |
    | physical_network      | ctlplane                             |
    | portgroup_uuid        | None                                 |
    | pxe_enabled           | True                                 |
    | updated_at            | None                                 |
    | uuid                  | 962d2cf7-334d-4465-91ce-1c4b5dfbfa7f |
    +-----------------------+--------------------------------------+
    (undercloud) [stack@osp16-undercloud var]$ openstack baremetal port show e89bb783-a734-444d-a3dd-25aa31cf7674
    +-----------------------+--------------------------------------+
    | Field                 | Value                                |
    +-----------------------+--------------------------------------+
    | address               | b0:26:28:45:fd:81                    |
    | created_at            | 2021-06-02T21:18:40+00:00            |
    | extra                 | {}                                   |
    | internal_info         | {}                                   |
    | is_smartnic           | False                                |
    | local_link_connection | {}                                   |
    | node_uuid             | 73716eb2-791d-4f03-a9d5-aeb49acc89ce |
    | physical_network      | ctlplane                             |
    | portgroup_uuid        | None                                 |
    | pxe_enabled           | True                                 |
    | updated_at            | None                                 |
    | uuid                  | e89bb783-a734-444d-a3dd-25aa31cf7674 |
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

## Inspecting the hardware of nodes for IPv4 provisioning  

Director can run an introspection process on each node. This process boots an introspection agent over PXE on each node. The introspection agent collects hardware data from the node and sends the data back to director. Director then stores this introspection data in the OpenStack Object Storage (swift) service running on director. Director uses hardware information for various purposes such as profile tagging, benchmarking, and manual root disk assignment.  

#### Procedure  

1. Make sure all the Overcloud Compute and Controller nodes are powered off  

    ```
    (undercloud) [stack@osp16-undercloud ~]$ openstack baremetal node list
    +--------------------------------------+------------+---------------+-------------+--------------------+-------------+
    | UUID                                 | Name       | Instance UUID | Power State | Provisioning State | Maintenance |
    +--------------------------------------+------------+---------------+-------------+--------------------+-------------+
    | 146bb426-2a52-4cba-b12b-b3f46749462b | controller | None          | power off   | manageable         | False       |
    | 86da6986-443c-4135-9bc6-bc00653502b8 | compute1   | None          | power off   | manageable         | False       |
    | 96eb9d6f-e52e-4388-90cb-b793c39dc588 | compute2   | None          | power off   | manageable         | False       |
    +--------------------------------------+------------+---------------+-------------+--------------------+-------------+
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

    <br/> 

    The `openstack overcloud node introspect --all-manageable --provide`  command won’t poll for the introspection result, use the following command to check the current introspection state for each UUID:  

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

    Repeat it for every node until you see __True__ in the finished field. The error field will contain an error message if introspection failed, or __None__ if introspection succeeded for this node.  

    <br/> 

    __IMPORTANT READ THIS:__   This process is incredibly unreliable, sometimes it works and sometimes it doesn't.  

    The PXE boot can fail because the PXE client (Controller and Compute nodes) does not send the TCP SYN to start the TCP connection required to perform the `HTTP GET /inspector.ipxe HTTP/1.1\r\n`, full URL `http://192.168.255.1:8088/inspector.ipxe` from the PXE server (undercloud director).   

    If this occurs the PXE client should keep trying, after timing out, and eventually correct itself.  
    
    The best way to know if this is working or not is to watch the IDRAC console for the node in question.  If it fails the PXE boot, the boot cycle will be short and it will either try to load the image from the hard disk or go into a restart state after timing out.        
    
    If this issue occurs and either the process does not restart or you just don't want to wait for it to timeout, you can force the process to start again by issuing  the `openstack baremetal introspection start` command for the node in question.  You do not need to do anything else other than issue the `openstack baremetal introspection start` command `(example for the controller node -- openstack baremetal introspection start 146bb426-2a52-4cba-b12b-b3f46749462b)` to restart the process.
    
  
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
    Introspection of node completed:146bb426-2a52-4cba-b12b-b3f46749462b. Status:SUCCESS. Errors:None
    Introspection of node completed:86da6986-443c-4135-9bc6-bc00653502b8. Status:SUCCESS. Errors:None
    Introspection of node completed:96eb9d6f-e52e-4388-90cb-b793c39dc588. Status:SUCCESS. Errors:None

    Introspection completed.
    Waiting for messages on queue 'tripleo' with no timeout.
    3 node(s) successfully moved to the "available" state.
    ```  

7.  Issue the `openstack baremetal node list` command again.  This is the desired result.  Provisioning state will transition to `clean failed`, that is expected.  

    ```
    (undercloud) [stack@osp16-undercloud ~]$ openstack baremetal node list
    +--------------------------------------+------------+---------------+-------------+--------------------+-------------+
    | UUID                                 | Name       | Instance UUID | Power State | Provisioning State | Maintenance |
    +--------------------------------------+------------+---------------+-------------+--------------------+-------------+
    | 146bb426-2a52-4cba-b12b-b3f46749462b | controller | None          | power off   | available          | False       |
    | 86da6986-443c-4135-9bc6-bc00653502b8 | compute1   | None          | power off   | available          | False       |
    | 96eb9d6f-e52e-4388-90cb-b793c39dc588 | compute2   | None          | power off   | available          | False       |
    +--------------------------------------+------------+---------------+-------------+--------------------+-------------+
    ```  

<br/> 

##  Tagging nodes into profiles  

After you register and inspect the hardware of each node, tag the nodes into specific profiles. These profile tags match your nodes to flavors, which assigns the flavors to deployment roles.  

Default profile flavors compute, control, swift-storage, ceph-storage, and block-storage are created during undercloud installation and are usable without modification in most environments.  

#### Procedure  

1.  To tag a node into a specific profile, add a profile option to the properties/capabilities parameter for each node. For example, to tag a specific node to use a specific profile.  The commands below are specific to this environment.  

    ```
    (undercloud) [stack@osp16-undercloud ~]$ openstack baremetal node set --property capabilities="profile:control,boot_option:local" controller
    ```  

    ```
    (undercloud) [stack@osp16-undercloud ~]$ openstack baremetal node set --property capabilities="profile:compute,boot_option:local" compute1
    ```  

    ```
    (undercloud) [stack@osp16-undercloud ~]$ openstack baremetal node set --property capabilities="profile:compute,boot_option:local" compute2
    ```  

2.  After you complete node tagging, check the assigned profiles or possible profiles:

    ```
    (undercloud) $ openstack overcloud profiles list
    ```  
    ```
    (undercloud) [stack@osp16-undercloud ~]$ openstack overcloud profiles list
    +--------------------------------------+------------+-----------------+-----------------+-------------------+
    | Node UUID                            | Node Name  | Provision State | Current Profile | Possible Profiles |
    +--------------------------------------+------------+-----------------+-----------------+-------------------+
    | 146bb426-2a52-4cba-b12b-b3f46749462b | controller | available       | control         |                   |
    | 86da6986-443c-4135-9bc6-bc00653502b8 | compute1   | available       | compute         |                   |
    | 96eb9d6f-e52e-4388-90cb-b793c39dc588 | compute2   | available       | compute         |                   |
    +--------------------------------------+------------+-----------------+-----------------+-------------------+
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

##  Creating an environment file that defines node counts and flavors  

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
openstack overcloud deploy --templates -e /home/stack/templates/node-info.yaml -e /home/stack/containers-prepare-parameter.yaml -e /usr/share/openstack-tripleo-heat-templates/environments/services/neutron-ovs.yaml --validation-errors-nonfatal
openstack overcloud deploy --templates -e /home/stack/templates/node-info.yaml -e /home/stack/containers-prepare-parameter.yaml -e /usr/share/openstack-tripleo-heat-templates/environments/services/neutron-ovs.yaml --validation-warnings-fatal
openstack overcloud deploy --templates -e /home/stack/templates/node-info.yaml -e /home/stack/containers-prepare-parameter.yaml -e /usr/share/openstack-tripleo-heat-templates/environments/services/neutron-ovs.yaml --dry-run
```  

```
openstack overcloud status
openstack overcloud delete overcloud
openstack baremetal node list
openstack baremetal port list
openstack baremetal node delete 607b6f1c-adcc-45e5-8068-36efb1497e93
openstack baremetal port delete
```  