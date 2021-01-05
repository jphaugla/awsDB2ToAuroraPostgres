# Convert DB2 to Aurora Postgres

## Purpose

Demo converting DB2 database to postgresql using DB2 on an EC2 instance with SCT and DMS.

&nbsp;

## Outline

- [Overview](#overview)
- [AWS Services Used](#aws-services-used)
- [Technical Overview](#technical-overview)
- [Instructions](#instructions)
  - [Create Environment](#create-environment)
  - [Add DB2 EC2 instance](#add-db2-ec2-instance)
  - [Edit Security Group Settings](#edit-security-group-settings)
  - [Setup VNC](#setup-vnc)
  - [Troubleshoot VNC](#troubleshoot-vnc)
- [DB2 Setup](#db2-setup)
  - [Install DB2](#install-db2)
  - [Troubleshoot DB2 install](#troubleshoot-vnc)
  - [DB2 sample database](#db2-sample-database)
  - [Setup VNC for db2inst1](#setup-vnc-for-db2inst1)
- [Windows Steps](#windows-steps)
  - [Install Windows DB2 Client](#install-windows-db2-client)
  - [SCT](#sct)
  - [Troubleshooting Windows](#troubleshooting-windows)
- [Cleaning up](#cleaning-up)
  

&nbsp;

## Overview

Use CloudFormation template from [Data Migration Immersion Day](https://dms-immersionday.workshop.aws/en).
  Add an IBM DB2 instance and demo using SCT/DMS to convert DB2 sample database to Aurora PostgreSQL.

## AWS Services Used

* [AWS DMS Database Migration Service](https://aws.amazon.com/dms/)
* [AWS SCT Schema Conversion Tool](https://aws.amazon.com/dms/schema-conversion-tool/)
* [AWS Cloudformation](https://aws.amazon.com/cloudformation/)
* [AWS DMS Workshop](https://dms-immersionday.workshop.aws/en)

## Technical Overview

* Bring up DMS/SCT environment using immersion days template
* Review Security Group Settings
* Setup VNC viewer on redhat instance.  VNC Viewer is needed for IBM DB2 installation
* Install DB2 and create sample DB2 database
* Convert sample DB2 database to Aurora PostgreSQL

&nbsp;

---

&nbsp;

## Instructions

***IMPORTANT NOTE**: Creating this demo application in your AWS account will create and consume AWS resources, which **will cost money**.  Costing information is available at [AWS Transcribe Pricing](https://aws.amazon.com/transcribe/pricing/?nc=sn&loc=3)

&nbsp;

### Create Environment

* Start with [AWS Account instructions](https://dms-immersionday.workshop.aws/en/envconfig/regular.html)
* After reviewing  "Introduction" and "Getting Started", follow the Regular AWS Account instructions. ![Regular AWS Account](README_PHOTOS/InitialNavigation.jpg)
* Complete the "Login to the AWS Console" and "Create an EC2 Key Pair" steps
* In the "Configure the Environment" step, use the provided ./templates/DMSWorkshop.yaml file instead of the link.  Choose SQL Server for the source database

### Edit Security Group Settings
Additional ports need to be open to allow VNC connectivity to the redhat 8 instance to install DB2.  Additionally, using additional agents for DMS, can require additional ports to be open
* Find the security group.  There are two security group created with the template.  Click on the InstanceSecurityGroup (not the DMSSecurityGroup)
* Tighten security on the RDP rule.  Currently it is open to public 
    * two choices-can open the ports to amazon ip using the amazon VPN.  *problem* vnc will not work while on amazon VPN.  vnc is needed for DB2 install.
        * it is best to log out of amazon vpn and use the non-amazon ip address
        * get amazon ip address using [amazon checkip URL](http://checkip.amazonaws.com) 
        * get ip address using a "get my ip" search
        * a separate option is to use tightvnc client on the windows VM (vnc viewer is flaky on windows)
    * Click "Edit Inbound Rules"
    * on the RDP inbound rule, remove "0.0.0.0/16" and put in the address obtained in checkip with a /32  e.g.  "1.2.3.4/32"
    * open all internal communication on private.  Easy way is to change the inbound rule with Access Type of Oracle-RDS to All TCP.
    * Click Add Rule and add a new rule for VNC access from the address found in checkip.  Use port range of 5900-6000
    * Click Add Rule and add a new rule for SSH access from the address found in checkip.  Use inbound rule type "SSH"
    * Click "save rules"

### Setup VNC
VNC is needed to do the IBM install on the redhat instance.

To login from client to redhat instance
```bash
ssh -i keypairFile ec2-user@redhatIPaddress
```
* Install needed packages to redhat instance
```bash
sudo yum groupinstall 'Server with GUI'
sudo yum install pixman pixman-devel
sudo yum -y install tigervnc-server
``` 
* change ssd to allow password login with ssh
```bash
sudo vi /etc/ssh/sshd_config
Set the ChallengeResponseAuthentication yes
Set the PasswordAuthentication yes
# save the file
# restart sshd
sudo systemctl restart sshd.service
``` 
* disable firewalld
```bash
sudo systemctl stop firewalld
sudo systemctl disable firewalld
```
* define port 1 for ec2-user
```bash
sudo bash
echo ":1=ec2-user" >> /etc/tigervnc/vncserver.users
```
* set up VNC password as ec2-user
```bash
vncpasswd
Password:
Verify:
Would you like to enter a view-only password (y/n)? n
```
* set up an os password for ec2-user  probably easier if you choose same password as VNC password
(be logged in as ec2-user)
```bash
sudo passwd ec2-user
```
* add a vnc config file as ec2-user 
```bash
echo "session=gnome" >> ~/.vnc/config
echo "alwaysshared" >> ~/.vnc/config
```
* ensure these two lines in  /etc/tigervnc/vncserver-config-mandatory
```bash
session=gnome
alwaysshared
```
* setup mandatory vncserver 
* change vi /etc/gdm/custom.conf under the default section
WaylandEnable=false
DefaultSession=gnome-xorg.desktop
* start and enable tigervnc
```bash
sudo systemctl start vncserver@:1
sudo systemctl enable vncserver@:1
sudo systemctl set-default graphical
```
* follow [disable se linux URL](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/security-enhanced_linux/sect-security-enhanced_linux-enabling_and_disabling_selinux-disabling_selinux)

### Troubleshoot VNC

* Check the vnc process to ensure it is fully running

```bash
sudo systemctl status vncserver@:1
● vncserver@:1.service - Remote desktop service (VNC)
   Loaded: loaded (/usr/lib/systemd/system/vncserver@.service; enabled; vendor preset: disabled)
   Active: active (running) since Tue 2021-01-05 02:37:52 UTC; 26s ago
  Process: 2599 ExecStart=/usr/libexec/vncsession-start :1 (code=exited, status=0/SUCCESS)
 Main PID: 2605 (vncsession)
    Tasks: 1 (limit: 98872)
   Memory: 1.8M
   CGroup: /system.slice/system-vncserver.slice/vncserver@:1.service
           ‣ 2605 /usr/sbin/vncsession ec2-user :1

Jan 05 02:37:52 xxxxx.ec2.internal systemd[1]: Starting Remote desktop service (VNC)...
Jan 05 02:37:52 xxxxx.ec2.internal systemd[1]: Started Remote desktop service (VNC). 
```
* [Redhat 8 PDF on gnmome and remote access](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/pdf/using_the_desktop_environment_in_rhel_8/Red_Hat_Enterprise_Linux-8-Using_the_desktop_environment_in_RHEL_8-en-US.pdf)
* screen saver lock out says "Cloud User"  this is actually ec2-user so enter the OS password for ec2-user
* TightVNC on windows is easiest connection (VNC Viewer on windows did not work)
* VNC Viewer on Mac seems to work but not with Amazon VPN so it becomes inconvenient especially with mac port used in security group

## DB2 Setup

### Install DB2

DB2 needs VNC to do the install.  There is also a silent option not needing vnc with a response file

* Using the VNC connection to the IBM server, go to download page for DB2 software [free DB2 software](https://www.ibm.com/analytics/db2/trials)
* Scroll down to "Download for free" button and fill out IBMID information (it is free)  
* Some errors on missing 32bit libraries will be generated but IBM says to ignore those error.  Easiest to install them ahead of time!
```bash
sudo bash
yum install libstdc++.i686
yum install pam.i686
yum install gcc-c++ cpp gcc kernel-devel make patch
```
* create holding file for DB2 Software (not necessary but makes later documentation easier)
```bash
sudo bash
cd /home
mkdir software
chmod 777 software
exit
```
    * Download using Linux (x64), move the file to the /home/software and decompress the file using tar -xvzf 
    * rename directory so what was the server_dec directory becomes ibm-db2
* Do a root based install using ./db2setup 
* validate the licence and run a db2 install validation
```bash
sudo bash
su - db2inst1
db2licm -a /home/software/ibm-db2/license/db2trial.lic
db2val
```

### Troubleshoot DB2 install
* this IBM link [IBM troubleshoot](https://www.ibm.com/support/knowledgecenter/en/SS4KMC_2.5.0/com.ibm.ico.doc_2.5/c_ts_installation.html) is helpful.  Odd that it says to ignore the 32 bit libraries.
* here are some maybe overly complex install instructions [complex install instructions](https://www.ibm.com/support/producthub/db2/docs/content/SSEPGG_11.5.0/com.ibm.db2.luw.qb.server.doc/doc/t0008875.html)

### DB2 sample database
* create sample database.  For more information look at documentation sample database [db2sampl](https://www.ibm.com/support/knowledgecenter/SSEPGG_11.5.0/com.ibm.db2.luw.admin.cmd.doc/doc/r0001934.html)
```bash
sudo bash
su - db2inst1
db2sampl
```

* get familiar with DB2 and sample database using this [document](https://www.tutorialspoint.com/db2/db2_quick_guide.htm)  The install directions are dated but the rest is very good. Be careful what steps you run as some of these commands are "impactful"
### Setup VNC for db2inst1

This is a very optional step but handy for using VNC type tools with db2inst1

* define port 2 for db2inst1
```bash
sudo bash
echo ":2=db2inst1" >> /etc/tigervnc/vncserver.users
```
* set up VNC password as db2inst1
(be logged in as db2inst1)
```bash
vncpasswd
Password:
Verify:
Would you like to enter a view-only password (y/n)? n
```
* start and enable tigervnc second session
```bash
sudo systemctl start vncserver@:2
sudo systemctl enable vncserver@:2
sudo systemctl set-default graphical
```


## Windows Steps

### Install Windows DB2 Client

* download free trial download [db2 trials](https://www.ibm.com/analytics/db2/trials)
* click on download for free
* select "Microsoft Windows(x64) Download"
* expand the software zip file
* expand in software tree to find "setup.exe" and double click
* find "Install Data Server Client".  follow prompts to install

### SCT
Return back to the DMS and SCT steps using the SQL Server to Amazon Aurora PostgreSQL

* Start back at this point in the guide [guide](https://dms-immersionday.workshop.aws/en/sqlserver-aurora-postgres.html)
* Perform the following Part 1 Schema Conversion Steps: "Connect to the EC2 Instance", "Install the AWS Schema Conversion Tool (AWS SCT)"
* Restart the Windows Server (this seems to be important after the SCT install)
* Create a New Project using New Project Wizard ![Create Project](README_PHOTOS/DefineProject.jpg)
* Connect to DB2 ![Connect to DB2](README_PHOTOS/ConnectToDB2.jpg)
* Accept the risks
* Click on the "DB2INST1" instance on the left panel and click "Next" to generate the assessment report
* Click Next and enter parameters for Aurora PostgreSQL connection ![Aurora Connection](README_PHOTOS/SCTAuroraConnection.jpg)
    * To find the password, look back in the original templates/DMSWorkshop.yaml in the repository home
    * Click "Finish"
* Right click on the "DB2INST1" database in the left panel and select Convert Schema to generate the data definition language (DDL) statements for the target database.
* Right click on the db2inst1 schema in the right-hand panel, and click Apply to database. click Yes

### Troubleshooting Windows
* if can't connect through ports
    * Disable Windows Defender [Disable Defender](https://support.microsoft.com/en-us/windows/turn-microsoft-defender-firewall-on-or-off-ec0844f7-aebd-0583-67fe-601ecf5d774f)
    * Restart the windows machine (yep, it is not 1995 but restarting a windows machine never hurts!)
    
    
### Cleaning up

Remove all files from S3 to avoid accruing unnecessary charges

&nbsp;

---

&nbsp;
