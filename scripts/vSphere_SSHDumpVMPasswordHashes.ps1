<#
Author:  Thomas Laurenson
Email:   thomas@thomaslaurenson.com
Website: thomaslaurenson.com
Date:    2018/06/08
Description:
A simple PowerShell script to search vSphere for VMs with a specific
name, then SSH each VM and dump the hashed password of the student user 
account. This is to check if they have correctly changed the password 
to somthing suitable. The output will dump passwords from the /etc/shadow 
file in a format ready for input into the hashcat tool.

Copyright (c) 2018, Thomas Laurenson
###############################################################################
This file is part of vSphereResources.
vSphereResources is free software: you can redistribute it and/or modify
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

########### VM PROCESSING CHECK

# Display a list of all VMs to the user
Write-Host ">>> You are about to process the following machines:"
Foreach ($vm in $sorted_vms) {
    Write-Host "  >"$vm.CustomFields["VRM Owner"] $vm.Name
}
$total_vm_count = $sorted_vms.Length
Write-Host ">>> There are $total_vm_count VMs.`n"

Read-Host -Prompt ">>> Press any key to continue or CTRL+C to quit" 

########### SSH CONFIGURATION HERE

# Set the variable for PLINK executable
$plinkCmd = "$pwd\..\tools\plink.exe"

# Set the username, password for the SSH connection
$username = 'myusername'
$password = 'mypassword'

# Set the port for the SSH connection
$sshPort = '22'

########### MAIN SSH CHECK TASK HERE

$scriptHelperDirectory = "$pwd/SSHExecuteScriptHelpers/"

# Process the array of discovered VMs
Write-Host ">>> SSH Hashed Password Dumping:"
foreach($vm in $sorted_vms){
    # Get the VM name
    $VMName = $vm.Name
    # Gets the first IP address of the VM (usually the IP4 address)
    $VMIP4 = $vm.Guest.IPAddress[0]

    Write-Host $vm.Name
    $ProcessInfo = New-Object System.Diagnostics.ProcessStartInfo 
    $ProcessInfo.FileName = $plinkCmd
    $ProcessInfo.Arguments =  "-P $sshPort $username@${VMIP4} -batch -pw $password -m ${scriptHelperDirectory}shadowCmd"
    $ProcessInfo.RedirectStandardError = $true 
    $ProcessInfo.RedirectStandardOutput = $true 
    $ProcessInfo.UseShellExecute = $false 
    $Process = New-Object System.Diagnostics.Process 
    $Process.StartInfo = $ProcessInfo 
    $Process.Start() | Out-Null 
    $Process.WaitForExit() 
    $output = $Process.StandardOutput.ReadToEnd() 
    $output 
}
