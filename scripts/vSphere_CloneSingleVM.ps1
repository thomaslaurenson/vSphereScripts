<#
Author:  Thomas Laurenson
Email:   thomas@thomaslaurenson.com
Website: thomaslaurenson.com
Date:    2019/04/10
Description:
A simple PowerShell script to clone a specific virtual machine for a
complete class of students. Good for single virtual machine assessments.
Takes a CSV as input with one student username per line.

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

# CSV file to import
# Script expects first row to be a header (named "USERNAME")
$csvFile = $pwd + "/IMPORT-FILE.csv"

# Import the CSV file
$studentUsers = Import-Csv -Path $csvFile

Write-Host ">>> You are about to create VMs the following users:"
Foreach ($user in $studentUsers) {
    Write-Host "  >"$user.USERNAME
}
$total_vm_count = $studentUsers.Length
Write-Host ">>> There are $total_vm_count VMs.`n"

Read-Host -Prompt ">>> Press any key to continue or CTRL+C to quit" 

# Pull template from vSphere, used for every VM
$VMTemplate = Get-Template -Name 'VM-TEMPLATE'

# Set vSphere variables
$VMHost = 'VSPHERE-HOST'       # Domain name/IP of the host (find in vSphere > Hosts and Clusters)
$Datastore = 'DATASTORE-NAME'  # Name of the datastore (find in vSphere > Storage)

ForEach ($user in $studentUsers)
{
    $username = $user.USERNAME
    Write-Host ">>> Creating new VM for:", $username
    $VMName = "VM-NAME-PREFIX" + $username
    
    New-VM -Name $VMName -Template $VMTemplate -VMHost $VMHost -Datastore $Datastore
    Start-VM –VM $VMName   
}
exit
