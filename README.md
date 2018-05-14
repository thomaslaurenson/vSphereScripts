# vSphereScripts

A collection of PowerShell scripts for managing vSphere/vRealize virtual machines in a tertiary learning environment. This repository provides a variety of PowerShell scripts to accomplish a variety of tasks including check VM networking connectivity (ping, SSH), dumping VM IP addresses, enabling copy/paste in VMRC, removing VM ownership, and very simple batch jobs such as powering on, power off, checking and searching VMs hosted in vSphere.

## Requirements

The provided PowerShell scripts only requirement are:

1. PowerShell
2. PowerCLI

PowerCLI is a Windows PowerShell interface for managing VMware vSphere. The project is developed and maintained by VMWare. The provide PowerShell scripts have been implemented and tested using PowerCLI version 10.1.0, released in February 2018. You can view the [primary documentation](https://www.vmware.com/support/developer/PowerCLI/) and download the product from [VMWare](https://code.vmware.com/web/dp/tool/vmware-powercli/10.1.0).

## Provided Scripts

This repository provides a variety of tools to help create, delete, manage and configure Virtual Machines managed using VMWare vSphere. Below is a brief summary of the directory structure of this project. 

- docs: A collection of code snippets and documentation on small snippets and one-line function examples
- modules: A collection of PowerShell modules (functions) used in the scripts provided in this project
- scripts: The primary part of this project. Contains various scripts for common Virtual Machine creation, deletion, management and configuration
- tool: A collection of open-source tools used in this project. The primary tools are plink and pscp to perform a variety of SSH-based tasks.

More detailed information can be found in the documentation provided in each of the scripts. Please see the header for a description of functionality and usage, and the code comments for a more comprehensive description.

## Install PowerCLI

There is an installer provided for the PowerCLI module, however, now there is an option to install the module directly in PowerShell using the `Install-Module` command. To install PowerCLI, execute the following steps:

- Open a PowerShell windows as Administrator
- Install the module using:

`Install-Module -Name VMware.PowerCLI`

You may receive an warning message about the trusted module. The warning is specified below:

```
You are installing the modules from an untrusted repository. If you trust this repository, change its InstallationPolicy value by running the Set-PSRepository cmdlet. Are you sure you want to install the modules from 'PSGallery'?
```

We can accept the warning, and select Yes to continue.

If you wish to upgrade the PowerCLI version, you need to run the same command, but add a `-Force` to the end. For example:

`Install-Module -Name VMware.PowerCLI -Force`

# Allowing PowerShell Scripts to Run

A good security feature added by Microsoft is stopping PowerShell scripts the ability to run by default. Since we need to run scripts, we have to enable this setting. This can be achieved with the following command:

`Set-ExecutionPolicy Unrestricted`

Below is a summary of the different configuration that can be specified:

- Restricted - No scripts can be run. Windows PowerShell can be used only in interactive mode.
- AllSigned - Only scripts signed by a trusted publisher can be run.
- RemoteSigned - Downloaded scripts must be signed by a trusted publisher before they can be run.
- Unrestricted - No restrictions; all Windows PowerShell scripts can be run.
