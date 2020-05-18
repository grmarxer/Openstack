# VCP 1.x Configuration and Deployment Guide for Openstack Newton (RHOSP 10) on RHEL 7.7
- RHEL 7.7 is required to match VCP environment  
- This deployment is meant for SR-IOV only on the Intel x520 NIC  
- This guide builds everything using the admin tenant  
- This deployment consists of one controller node and two compute nodes all of which are  Dell PowerEdge R640 servers  

## Enable SR-IOV in the BIOS on the PowerEdge R640 using iDRAC (Compute Nodes Only)  

1.  Log into iDRAC using the IPMI IP address  
2.  Navigate to Virtual Console and Open it (bottom right hand side of iDRAC screen)  
3.  Choose the power button and select Reset System (warm boot)  
4.  Enter the System Setup - BIOS configuration by pressing F2  
5.  Select System BIOS > Processor Settings and enable Virtual Technology  

<br/>  

![Image](https://github.com/grmarxer/Openstack/blob/master/VCP_Build_Intructions/illustrations/BIOS-ProcessorSettings.PNG)  

6.  Click Back  
7.  Select Integrated Devices and enable SR-IOV Global Enable  
<br/>  

![Image](https://github.com/grmarxer/Openstack/blob/master/VCP_Build_Intructions/illustrations/BIOS-IntegratedDevices.PNG)  


8.  Click Back then Finish  
9.  From the System Setup Main Menu - select Device Settings  
10. For each NIC Card that is recognized by the Dell BIOS that will be used for SRIOV select that NIC here.  
    __NOTE:__  For this lab only the Intel x520's will be used.  Since the x520's in these servers are not Dell branded they are not recognized by the BIOS so the following steps are not required.  Since there are also Intel x710 NIC cards in these servers that are Dell branded and recognized by the BIOS I have included the steps below for completeness.  
11. Navigate to the Device Level Configuration  
12. For Virtualization Mode choose SR-IOV from the drop down menu  
<br/>  

![Image](https://github.com/grmarxer/Openstack/blob/master/VCP_Build_Intructions/illustrations/BIOS-DeviceLevelSetting.PNG)  

13. Select Back, then Finish, then Finish again, and Finish again  
14. Select Yes to exit and boot.  



## Install RHEL 7.7 using Dell idrac  
