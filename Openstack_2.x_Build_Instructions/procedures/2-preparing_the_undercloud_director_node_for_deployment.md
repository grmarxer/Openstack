# Preparing the OSP 16.1 UnderCloud Director Node for Openstack Deployment

https://access.redhat.com/documentation/en-us/red_hat_openstack_platform/16.1/html/director_installation_and_usage/chap-introduction  


<br/>  


## Preparing the undercloud  

Before you can install director, you must complete some basic configuration on the host machine.  


#### Procedure  

1. Log in to your undercloud as the root user.  

2. Create the stack user:   
    ```
    [root@osp16-undercloud ~]# useradd stack
    ```  

3. Set a password for the user:  
    ```
    [root@osp16-undercloud ~]# passwd stack
    ```  

4. Disable password requirements when using sudo:  
    ```
    [root@osp16-undercloud ~]# echo "stack ALL=(root) NOPASSWD:ALL" | tee -a /etc/sudoers.d/stack
    [root@osp16-undercloud ~]# chmod 0440 /etc/sudoers.d/stack
    ``` 

5. Switch to the new stack user:  
    ```
    [root@osp16-undercloud ~]# su - stack
    [stack@osp16-undercloud ~]$
    ```  

6. Create directories for system images and heat templates:  
    ```
    [stack@osp16-undercloud ~]$ mkdir ~/images
    [stack@osp16-undercloud ~]$ mkdir ~/templates
    ```  

    Director uses system images and heat templates to create the overcloud environment. Red Hat recommends creating these directories to help you organize your local file system.  

7.  Check the base and full hostname of the undercloud:  
    ```
    [stack@osp16-undercloud ~]$ hostname
    [stack@osp16-undercloud ~]$ hostname -f
    ```  
    If either of the previous commands do not report the correct fully-qualified hostname `osp16-undercloud.pl.pdsea.f5net.com` go back and correct your etc/hosts file.


<br/>  

## Registering the undercloud and attaching subscriptions 

Before you can install director, you must run subscription-manager to register the undercloud and attach a valid Red Hat OpenStack Platform subscription.  


#### Procedure  

1. Log in to your undercloud as the stack user.  

2. Register your system either with the Red Hat Content Delivery Network or with a Red Hat Satellite. For example, run the following command to register the system to the Content Delivery Network. Enter your Customer Portal user name and password when prompted:
    ```
    [stack@osp16-undercloud ~]$ sudo subscription-manager register --force
    ```  

3. Find the entitlement pool ID for Red Hat OpenStack Platform (RHOSP) director:  

    ```
    sudo subscription-manager list --available --all --matches="Red Hat OpenStack"
    ```  
    ```
    [stack@osp16-undercloud ~]$ sudo subscription-manager list --available --all --matches="Red Hat OpenStack"
    +-------------------------------------------+
        Available Subscriptions
    +-------------------------------------------+
    Subscription Name:   Red Hat OpenStack Platform, Standard Support (4 Sockets, NFR, Partner Only)
    Provides:            Red Hat Enterprise Linux FDIO Early Access (RHEL 7 Server)
                        Red Hat Ansible Engine
                        Red Hat OpenStack Certification Test Suite
                        Red Hat CodeReady Linux Builder for Power, little endian
                        Red Hat Enterprise Linux Fast Datapath
                        Red Hat CloudForms
                        Red Hat Software Collections Beta (for RHEL Server for IBM Power LE)

    ...  <snippet removed>  ...

    SKU:                 SER0505
    Contract:            12213256
    Pool ID:             8a85f99c71eff3f4017219e2ebca5c3b
    Provides Management: No
    Available:           56
    Suggested:           1
    Service Type:        L1-L3
    Roles:
    Service Level:       Standard
    Usage:
    Add-ons:
    Subscription Type:   Standard
    Starts:              05/15/2020
    Ends:                05/15/2021
    Entitlement Type:    Physical
    ```  


4.  Locate the Pool ID value and attach the Red Hat OpenStack Platform 16.1 entitlement:  
    ```
    [stack@osp16-undercloud ~]$ sudo subscription-manager attach --pool=8a85f99c71eff3f4017219e2ebca5c3b
    ```  

5. Lock the undercloud to Red Hat Enterprise Linux 8.2:  
    ```
    [stack@osp16-undercloud ~]$ sudo subscription-manager release --set=8.2
    ```  

<br/>  

## Enabling repositories for the undercloud  

Enable the repositories that are required for the undercloud, and update the system packages to the latest versions.  

#### Procedure  

1.  Log in to your undercloud as the stack user.  

2. Disable all default repositories, and enable the required Red Hat Enterprise Linux repositories:  
    ```
    [stack@osp16-undercloud ~]$ sudo subscription-manager repos --disable=*
    [stack@osp16-undercloud ~]$ sudo subscription-manager repos --enable=rhel-8-for-x86_64-baseos-eus-rpms --enable=rhel-8-for-x86_64-appstream-eus-rpms --enable=rhel-8-for-x86_64-highavailability-eus-rpms --enable=ansible-2.9-for-rhel-8-x86_64-rpms --enable=openstack-16.1-for-rhel-8-x86_64-rpms --enable=fast-datapath-for-rhel-8-x86_64-rpms --enable=advanced-virt-for-rhel-8-x86_64-rpms
    ```  

    These repositories contain packages that the director installation requires.  

3. Set the container-tools repository module to version 2.0:  
    ```
    [stack@osp16-undercloud ~]$ sudo dnf module disable -y container-tools:rhel8
    [stack@osp16-undercloud ~]$ sudo dnf module enable -y container-tools:2.0
    ```  

4. Set the virt repository module to version 8.2:  
    ```
    [stack@osp16-undercloud ~]$ sudo dnf module disable -y virt:rhel
    [stack@osp16-undercloud ~]$ sudo dnf module enable -y virt:8.2
    ```  

5. Perform an update on your system to ensure that you have the latest base system packages:  
    ```
    [stack@osp16-undercloud ~]$ sudo dnf update -y
    [stack@osp16-undercloud ~]$ sudo reboot
    ```  
<br/>  

## Installing director packages  

Install packages relevant to Red Hat OpenStack Platform director.

#### Procedure

1. Install the command line tools for director installation and configuration:  
    ```
    [stack@osp16-undercloud ~]$ sudo dnf install -y python3-tripleoclient
    ```  

<br/>  

## Preparing container images  

The undercloud installation requires an environment file to determine where to obtain container images and how to store them. Generate and customize this environment file that you can use to prepare your container images.  

#### Procedure

1.  This file has already been created and modified for this specific environment.  Copy [this file](https://github.com/grmarxer/Openstack/blob/master/Openstack_2.x_Build_Instructions/config_files/my-containers-prepare-parameter.yaml) `my-containers-prepare-parameter.yaml` into the `/home/stack/` directory on the undercloud director node.  

    __Note:__ Do not change this files name.  

    __Note:__ This file requires a redhat login username and password.   

    __Note:__ This file is currently configured to install OSP 16.1  


<br/>  


## Installing Director Steps

The director installation process requires certain settings in the undercloud.conf configuration file, which director reads from the home directory of the stack user. 

<br/>  

### Configuring director  

The director installation process requires certain settings in the undercloud.conf configuration file, which director reads from the home directory of the stack user. This file has been created and modified for this specific Openstack 2.x environment  


#### Procedure  

1. Copy [this file](https://github.com/grmarxer/Openstack/blob/master/Openstack_2.x_Build_Instructions/config_files/undercloud.final.conf) `undercloud.final.conf` into the `/home/stack/` directory on the undercloud director node and rename it to `undercloud.conf`  

    __Note:__ For your reference this is the [link](https://github.com/grmarxer/Openstack/blob/master/Openstack_2.x_Build_Instructions/config_files/undercloud.conf.original) to the unedited original undercloud.conf file.  Use this file and follow the procedure [here](https://access.redhat.com/documentation/en-us/red_hat_openstack_platform/16.1/html/director_installation_and_usage/installing-the-undercloud#director-configuration-parameters) if you wish to modify this deployment.  

<br/> 


### Configuring the undercloud with environment files  

You configure the main parameters for the undercloud through the undercloud.conf file. You can also perform additional undercloud configuration with an environment file that contains heat parameters.  This file has been created and modified for this specific Openstack 2.x environment  


#### Procedure  

1. Copy [this file](https://github.com/grmarxer/Openstack/blob/master/Openstack_2.x_Build_Instructions/config_files/custom-undercloud-params.yaml) `custom-undercloud-params.yaml` into the `/home/stack/templates` directory on the undercloud director node.  

    __Note:__ If you wish to make any additions to this file, follow this procedure as a reference -- [link](https://access.redhat.com/documentation/en-us/red_hat_openstack_platform/16.1/html/director_installation_and_usage/installing-the-undercloud#director-configuration-parameters)  

    __Note:__ Do not change the name of this file  


<br/> 

### Install director  

Complete the following steps to install director and perform some basic post-installation tasks.  

#### Procedure  

1. Run the following command to install director on the undercloud:  
    ```
    [stack@osp16-undercloud ~]$ openstack undercloud install
    ```  

    This command launches the director configuration script. Director installs additional packages and configures its services according to the configuration in the undercloud.conf. This script takes __~40__ minutes to complete.  

    The script generates two files:  
    - undercloud-passwords.conf - A list of all passwords for the director services.  

    - stackrc - A set of initialization variables to help you access the director command line tools.  

    <br/> 

    __Installation is complete when you see the following:__  

    ```
    ##########################################################

    The Undercloud has been successfully installed.

    Useful files:

    Password file is at /home/stack/undercloud-passwords.conf
    The stackrc file is at ~/stackrc

    Use these files to interact with OpenStack services, and
    ensure they are secured.

    ##########################################################
    ```  

<br/> 

2. The script also starts all OpenStack Platform service containers automatically. You can check the enabled containers with the following command:  
    ```
    [stack@osp16-undercloud ~]$ sudo podman ps
    ```  

    ```
    [stack@osp16-undercloud ~]$ sudo podman ps
    CONTAINER ID  IMAGE                                                                                            COMMAND               CREATED         STATUS             PORTS  NAMES
    46dcd4654e87  osp16-undercloud.ctlplane.localdomain:8787/rhosp-rhel8/openstack-neutron-dhcp-agent:16.1         /usr/sbin/dnsmasq...  3 minutes ago   Up 3 minutes ago          neutron-dnsmasq-qdhcp-b0447c90-be4d-48a9-b1c2-71d254907c32
    ab656a46d3dc  osp16-undercloud.ctlplane.localdomain:8787/rhosp-rhel8/openstack-nova-compute-ironic:16.1        kolla_start           4 minutes ago   Up 4 minutes ago          nova_compute
    9115225aba54  osp16-undercloud.ctlplane.localdomain:8787/rhosp-rhel8/openstack-ironic-inspector:16.1           kolla_start           5 minutes ago   Up 5 minutes ago          ironic_inspector
    063e425ab735  osp16-undercloud.ctlplane.localdomain:8787/rhosp-rhel8/openstack-ironic-pxe:16.1                 kolla_start           5 minutes ago   Up 5 minutes ago          ironic_pxe_http
    5cf02a65e2ae  osp16-undercloud.ctlplane.localdomain:8787/rhosp-rhel8/openstack-ironic-pxe:16.1                 /bin/bash -c BIND...  5 minutes ago   Up 5 minutes ago          ironic_pxe_tftp
    90ae14b0cb4d  osp16-undercloud.ctlplane.localdomain:8787/rhosp-rhel8/openstack-ironic-neutron-agent:16.1       kolla_start           5 minutes ago   Up 5 minutes ago          ironic_neutron_agent
    4878e1b78d17  osp16-undercloud.ctlplane.localdomain:8787/rhosp-rhel8/openstack-ironic-conductor:16.1           kolla_start           5 minutes ago   Up 5 minutes ago          ironic_conductor
    efceb88b1be1  osp16-undercloud.ctlplane.localdomain:8787/rhosp-rhel8/openstack-mistral-api:16.1                kolla_start           5 minutes ago   Up 5 minutes ago          mistral_api
    df68399c6cff  osp16-undercloud.ctlplane.localdomain:8787/rhosp-rhel8/openstack-neutron-openvswitch-agent:16.1  kolla_start           5 minutes ago   Up 5 minutes ago          neutron_ovs_agent
    ... <snippet removed> ...
    ```  


3. To initialize the stack user to use the command line tools, run the following command:  
    ```
    [stack@osp16-undercloud ~]$ source ~/stackrc
    ```  

4. The prompt now indicates that OpenStack commands authenticate and execute against the undercloud;  
    ```
    (undercloud) [stack@osp16-undercloud ~]$
    ```  

    The director installation is complete. You can now use the director command line tools.  

<br/> 

## Obtaining images for overcloud nodes  

Director requires several disk images to provision overcloud nodes:  

- An introspection kernel and ramdisk for bare metal system introspection over PXE boot.  

- A deployment kernel and ramdisk for system provisioning and deployment.  

- An overcloud kernel, ramdisk, and full image, which form a base overcloud system that is written to the hard disk of the node.  

These images and procedures are necessary for deployment of the overcloud with the default CPU architecture, x86-64.  

#### Procedure  

1. Source the stackrc file to enable the director command line tools:  
    ```
    [stack@osp16-undercloud ~]$ source ~/stackrc
    ```  

2. Install the rhosp-director-images and rhosp-director-images-ipa packages:  
    ```
    (undercloud) [stack@osp16-undercloud ~]$ sudo dnf install rhosp-director-images rhosp-director-images-ipa -y
    ```  

3. Extract the images archives to the images directory in the home directory of the stack user (/home/stack/images):  
    ```
    (undercloud) [stack@osp16-undercloud ~]$ cd ~/images
    ```  
    ```
    (undercloud) [stack@osp16-undercloud images]$ for i in /usr/share/rhosp-director-images/overcloud-full-latest-16.1.tar /usr/share/rhosp-director-images/ironic-python-agent-latest-16.1.tar; do tar -xvf $i; done
    ```  

4. Import these images into director:  
    ```
    (undercloud) [stack@osp16-undercloud images]$ openstack overcloud image upload --image-path /home/stack/images/
    ```  

    This script uploads the following images into director:  

    - overcloud-full  
    - overcloud-full-initrd  
    - overcloud-full-vmlinuz  

    The script also installs the introspection images on the director PXE server.  
    <br/> 

5. Verify that the images uploaded successfully:  
    ```
    (undercloud) [stack@osp16-undercloud templates]$ openstack image list
    +--------------------------------------+------------------------+--------+
    | ID                                   | Name                   | Status |
    +--------------------------------------+------------------------+--------+
    | 9bdf5e4f-5f70-43bd-8649-765848b29207 | overcloud-full         | active |
    | 53b061ef-36a1-4229-bca4-e7bf689d0c32 | overcloud-full-initrd  | active |
    | cf06afa0-39d9-41f6-80ad-c38ff812ea45 | overcloud-full-vmlinuz | active |
    +--------------------------------------+------------------------+--------+
    ```  
    <br/> 


    This list does not show the introspection PXE images. Director copies these files to /var/lib/ironic/httpboot.  

    ```
    (undercloud) [stack@osp16-undercloud templates]$ ls -l /var/lib/ironic/httpboot
    total 559132
    -rwxr-xr-x. 1 root  root    8924528 Apr 12 16:19 agent.kernel
    -rw-r--r--. 1 root  root  563615353 Apr 12 16:19 agent.ramdisk
    -rw-r--r--. 1 42422 42422       758 Apr 12 15:02 boot.ipxe
    -rw-r--r--. 1 42422 42422       473 Apr 12 14:53 inspector.ipxe
    ```  


<br/> 

## Setting a nameserver for the control plane  

We need to set the nameserver in this step so the overcloud can resolve external hostnames, such as cdn.redhat.com. Complete the following procedure to define the nameserver for this environment.  

#### Procedure  

1.  Source the stackrc file to enable the director command line tools:  
    ```
    [stack@osp16-undercloud ~]$ source ~/stackrc
    ```  

2. Set the nameservers for the ctlplane-subnet subnet:  
    ```
    (undercloud) [stack@osp16-undercloud images]$ openstack subnet set --dns-nameserver 10.144.31.146 --dns-nameserver 8.8.8.8 ctlplane-subnet
    ```  

3. View the subnet to verify the nameserver:  
    ```
    (undercloud) [stack@osp16-undercloud ~]$  openstack subnet show ctlplane-subnet  
    +-------------------+--------------------------------------------------------------+
    | Field             | Value                                                        |
    +-------------------+--------------------------------------------------------------+
    | allocation_pools  | 192.168.255.10-192.168.255.24                                |
    | cidr              | 192.168.255.0/24                                             |
    | created_at        | 2021-04-12T19:04:06Z                                         |
    | description       |                                                              |
    | dns_nameservers   | 10.144.31.146, 8.8.8.8                              |
    | ...               | <snippet removed>                                            |
    | tags              |                                                              |
    | updated_at        | 2021-04-13T21:00:16Z                                         |
    +-------------------+--------------------------------------------------------------+
    ```  

    <br/> 

## Undercloud container registry  

Red Hat Enterprise Linux 8.2 no longer includes the docker-distribution package, which installed a Docker Registry v2. To maintain the compatibility and the same level of feature, the director installation creates an Apache web server with a vhost called image-serve to provide a registry. This registry also uses port 8787/TCP with SSL disabled. The Apache-based registry is not containerized, which means that you must run the following command to restart the registry:  

```
$ sudo systemctl restart httpd
```  

You can find the container registry logs in the following locations:  

- /var/log/httpd/image_serve_access.log  
- /var/log/httpd/image_serve_error.log  

The image content is served from /var/lib/image-serve. This location uses a specific directory layout and apache configuration to implement the pull function of the registry REST API.  

