<#
Author:  Thomas Laurenson
Email:   thomas@thomaslaurenson.com
Website: thomaslaurenson.com
Date:    2018/05/11
Description:
A simple PowerShell script to search vSphere for VMs with a specific
name, then ping each VM to check it is network accessible.

Copyright (c) 2018, Thomas Laurenson
###############################################################################
This file is part of vSphereScripts.
vSphereScripts is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.
This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.
You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
###############################################################################
#>

# Get the script directory
$pwd = $PSScriptRoot

# Import the vSphere connect module from the scripts directory
Import-Module $pwd\..\modules\vSphereConnect

# Import the vSphere connect module from the scripts directory
Import-Module $pwd\..\modules\SimplePing

# First, get a list of servers you are connected to
$serverlist = $global:DefaultVIServer

# Check the list of connected servers to the server
if($serverlist -eq $null) {
   Write-Host ">>> Not connected to server."
   Write-Host ">>> Attempting to connect now..."
   VSphereConnect
} 

# Excellent, we are connected... continue

# Input field to specify search term for VMs
$input_name = Read-Host -Prompt '>>> Please input the VM search term'
$vms = Get-VM -Name $input_name

# First find all the VMs in vSphere that match a given pattern
# The input_name line can be commented out and the string directly
# added to the command below.
# Examples:

# Get all VMs using the * wildcard
#$vms = Get-VM -Name *

# Get VMs with a name containing Assignment2
#$vms = Get-VM -Name *Assignment2*

# Sort the VM by alphabetical order
$sorted_vms = $vms | Sort-Object 

# Process the array of discovered VMs
Write-Host ">>> Pinging VMs:"
ForEach ($vm in $sorted_vms) {
    # Get the VM name
    $VMName = $vm.Name
    # Gets the first IP address of the VM (usually the IP4 address)
    $VMIP4 = $vm.Guest.IPAddress[0]
    # Get the VM Owner
    $VMOwner = $vm.CustomFields["VRM Owner"]
    
    # | SimplePing passes the IP address to the SimplePing function
    # The function returns true if pingable, or false if not
    if (-Not ($VMIP4 | SimplePing))
    {
        # If a VM was not replying print the details
        Write-Host ">>> PING ERROR! VM details:" -ForegroundColor red
        Write-Host "  > ${VMName}"
        Write-Host "  > ${VMOwner}"
        Write-Host "  > ${VMIP4}"      
    }
    else
    {
        # If a VM was replying print the details
        Write-Host ">>> PING SUCESSFUL! VM details:" -ForegroundColor DarkGreen
        Write-Host "  > ${VMName}"
        Write-Host "  > ${VMOwner}"
        Write-Host "  > ${VMIP4}"          
    }
}
