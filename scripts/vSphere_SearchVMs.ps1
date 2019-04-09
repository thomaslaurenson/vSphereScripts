<#
Author:  Thomas Laurenson
Email:   thomas@thomaslaurenson.com
Website: thomaslaurenson.com
Date:    2019/04/10
Description:
A simple PowerShell script to search vSphere for VMs with a specific
name, then print out properties of the VM.

Copyright (c) 2019, Thomas Laurenson
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

# Import the vSphere connect module from the module directory
Import-Module $pwd\..\modules\vSphereConnect

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
Write-Host ">>> Search reuslts:\n"
ForEach ($vm in $sorted_vms) {
    # Print the name of the VM  
    Write-Host $vm.Name
}
