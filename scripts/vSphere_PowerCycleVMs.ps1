<#
Author:  Thomas Laurenson
Email:   thomas@thomaslaurenson.com
Website: thomaslaurenson.com
Date:    2018/08/17
Description:
vSphere_PowerCycleVMs.ps1 is PowerShell script to automate the
powercycle (reboot) of Virtual Machines (VMs). 

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

########### PRINT TARGET VMS AND CHECK WITH USER

Write-Host ">>> You are about to PowerOn the following VMs:"
Foreach ($vm in $sorted_vms) {
    Write-Host "  >" $vm.name
}
$total_vm_count = $sorted_vms.Length
Write-Host ">>> There are $total_vm_count VMs.`n"

Read-Host -Prompt ">>> Press any key to continue or CTRL+C to quit" 

########### START ACTUAL VM PROCESSING

# Display a list of all VMs to the user
Write-Host ">>> You are about to process the following machines:"
Foreach ($vm in $sorted_vms) {
    Write-Host "  >"$vm.CustomFields["VRM Owner"] $vm.Name
}
$total_vm_count = $sorted_vms.Length
Write-Host ">>> There are $total_vm_count VMs.`n"

Read-Host -Prompt ">>> Press any key to continue or CTRL+C to quit" 

# Loop each of the found VMs
Foreach ($vm in $sorted_vms) {
    
    Write-Host ">>> Processing VM: $vm"

    $power_state = $vm.PowerState
    Write-Host "  > Current power state: $power_state"
    
    if ($power_state -eq "PoweredOn")
    {
        Write-Host "  > Powering off now..."
        Restart-VM -VM $vm -Confirm:$false
    }

    Write-Host "----------------------------"
}