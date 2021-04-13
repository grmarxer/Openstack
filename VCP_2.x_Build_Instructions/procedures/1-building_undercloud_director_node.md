## Building the OSP 16.1 UnderCloud Director Node  

https://access.redhat.com/documentation/en-us/red_hat_openstack_platform/16.1/html/director_installation_and_usage/chap-introduction  


<br/>  


## Preparing the undercloud  

Before you can install director, you must complete some basic configuration on the host machine.  


#### Procedure  

1. Log in to your undercloud as the root user.  

2. Create the stack user:   
    ```
    [root@director ~]# useradd stack
    ```  

3. Set a password for the user:  
    ```
    [root@director ~]# passwd stack
    ```  

4. Disable password requirements when using sudo:  
    ```
    [root@director ~]# echo "stack ALL=(root) NOPASSWD:ALL" | tee -a /etc/sudoers.d/stack
    [root@director ~]# chmod 0440 /etc/sudoers.d/stack
    ``` 

5. Switch to the new stack user:  
    ```
    [root@director ~]# su - stack
    [stack@director ~]$
    ```  

6. Create directories for system images and heat templates:  
    ```
    [stack@director ~]$ mkdir ~/images
    [stack@director ~]$ mkdir ~/templates
    ```  

    Director uses system images and heat templates to create the overcloud environment. Red Hat recommends creating these directories to help you organize your local file system.  

7.  Check the base and full hostname of the undercloud:  
    ```
    [stack@director ~]$ hostname
    [stack@director ~]$ hostname -f
    ```  
    If either of the previous commands do not report the correct fully-qualified hostname `osp16-undercloud.pl.pdsea.f5net.com` go back and correct your etc/hosts file.


<br/>  

## Registering the undercloud and attaching subscriptions 

Before you can install director, you must run subscription-manager to register the undercloud and attach a valid Red Hat OpenStack Platform subscription.  


#### Procedure  

1. Log in to your undercloud as the stack user.  

2. Register your system either with the Red Hat Content Delivery Network or with a Red Hat Satellite. For example, run the following command to register the system to the Content Delivery Network. Enter your Customer Portal user name and password when prompted:
    ```
    [stack@director ~]$ sudo subscription-manager register
    ```  

3. Find the entitlement pool ID for Red Hat OpenStack Platform (RHOSP) director:  

    ```
    sudo subscription-manager list --available --all --matches="Red Hat OpenStack"
    ```  

4.  Locate the Pool ID value and attach the Red Hat OpenStack Platform 16.1 entitlement:  
    ```
    [stack@director ~]$ sudo subscription-manager attach --pool=Valid-Pool-Number-123456
    ```  

5. Lock the undercloud to Red Hat Enterprise Linux 8.2:  
    ```
    [stack@director ~]$ sudo subscription-manager release --set=8.2
    ```  

<br/>  

## Enabling repositories for the undercloud  

Enable the repositories that are required for the undercloud, and update the system packages to the latest versions.  

#### Procedure  

1.  Log in to your undercloud as the stack user.  

2. Disable all default repositories, and enable the required Red Hat Enterprise Linux repositories:  
    ```
    [stack@director ~]$ sudo subscription-manager repos --disable=*
    [stack@director ~]$ sudo subscription-manager repos --enable=rhel-8-for-x86_64-baseos-eus-rpms --enable=rhel-8-for-x86_64-appstream-eus-rpms --enable=rhel-8-for-x86_64-highavailability-eus-rpms --enable=ansible-2.9-for-rhel-8-x86_64-rpms --enable=openstack-16.1-for-rhel-8-x86_64-rpms --enable=fast-datapath-for-rhel-8-x86_64-rpms --enable=advanced-virt-for-rhel-8-x86_64-rpms
    ```  

    These repositories contain packages that the director installation requires.  

3. Set the container-tools repository module to version 2.0:  
    ```
    [stack@director ~]$ sudo dnf module disable -y container-tools:rhel8
    [stack@director ~]$ sudo dnf module enable -y container-tools:2.0
    ```  

4. Set the virt repository module to version 8.2:  
    ```
    [stack@director ~]$ sudo dnf module disable -y virt:rhel
    [stack@director ~]$ sudo dnf module enable -y virt:8.2
    ```  

5. Perform an update on your system to ensure that you have the latest base system packages:  
    ```
    [stack@director ~]$ sudo dnf update -y
    [stack@director ~]$ sudo reboot
    ```  
<br/>  

## Installing director packages  

Install packages relevant to Red Hat OpenStack Platform director.

#### Procedure

1. Install the command line tools for director installation and configuration:  
    ```
    [stack@director ~]$ sudo dnf install -y python3-tripleoclient
    ```  

<br/>  

## Preparing container images  

The undercloud installation requires an environment file to determine where to obtain container images and how to store them. Generate and customize this environment file that you can use to prepare your container images.  

#### Procedure

1.  This file has already been created and modified for this specific environment.  Copy [this file](https://github.com/grmarxer/Openstack/blob/master/VCP_2.x_Build_Instructions/config_files/containers-prepare-parameter.yaml) `containers-prepare-parameter.yaml` into the `/home/stack/` directory on the undercloud director node.  

__Note:__ Do not change this files name.  

__Note:__ This file requires a redhat login username and password.   

__Note:__ This file is currently configured to install OSP 16.1  


<br/>  


## Installing Director Steps

The director installation process requires certain settings in the undercloud.conf configuration file, which director reads from the home directory of the stack user. 

<br/>  

### Configuring director  

The director installation process requires certain settings in the undercloud.conf configuration file, which director reads from the home directory of the stack user. This file has been created and modified for this specific Vz VCP 2.x environment  


#### Procedure  

1. Copy [this file](https://github.com/grmarxer/Openstack/blob/master/VCP_2.x_Build_Instructions/config_files/undercloud.final.conf) `undercloud.final.conf` into the `/home/stack/` directory on the undercloud director node and rename it to `undercloud.conf`.  

    __Note:__ For your reference this is the [link](https://github.com/grmarxer/Openstack/blob/master/VCP_2.x_Build_Instructions/config_files/undercloud.conf.original) to the unedited original undercloud.conf file.  Use this file and follow the procedure [here](https://access.redhat.com/documentation/en-us/red_hat_openstack_platform/16.1/html/director_installation_and_usage/installing-the-undercloud#director-configuration-parameters) if you wish to modify this deployment.  

<br/> 


### Configuring the undercloud with environment files  

You configure the main parameters for the undercloud through the undercloud.conf file. You can also perform additional undercloud configuration with an environment file that contains heat parameters.  This file has been created and modified for this specific Vz VCP 2.x environment  


#### Procedure  

1. Copy [this file](https://github.com/grmarxer/Openstack/blob/master/VCP_2.x_Build_Instructions/config_files/custom-undercloud-params.yaml) `custom-undercloud-params.yaml` into the `/home/stack/templates` directory on the undercloud director node.  

    __Note:__ If you wish to make any additions to this file, follow this procedure as a reference -- [link](https://access.redhat.com/documentation/en-us/red_hat_openstack_platform/16.1/html/director_installation_and_usage/installing-the-undercloud#director-configuration-parameters)  

    __Note:__ Do not change the name of this file  


<br/> 

### Install director  

Complete the following steps to install director and perform some basic post-installation tasks.  

#### Procedure  

1. Run the following command to install director on the undercloud:  
    ```
    [stack@director ~]$ openstack undercloud install
    ```  

    This command launches the director configuration script. Director installs additional packages and configures its services according to the configuration in the undercloud.conf. This script takes ~10-15 minutes to complete.  

    The script generates two files:  
    - undercloud-passwords.conf - A list of all passwords for the director services.  

    - stackrc - A set of initialization variables to help you access the director command line tools.  

<br/> 

2. The script also starts all OpenStack Platform service containers automatically. You can check the enabled containers with the following command:  
    ```
    [stack@director ~]$ sudo podman ps
    ```  


3. To initialize the stack user to use the command line tools, run the following command:  
    ```
    [stack@director ~]$ source ~/stackrc
    ```  

4. The prompt now indicates that OpenStack commands authenticate and execute against the undercloud;  
    ```
    (undercloud) [stack@director ~]$
    ```  

    The director installation is complete. You can now use the director command line tools.  