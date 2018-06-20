<#
Author:  Thomas Laurenson
Email:   thomas@thomaslaurenson.com
Website: thomaslaurenson.com
Date:    2018/06/20
Description:
vSphere_EnableVMRCCopyPaste.ps1 is PowerShell script to enable copy
and pasting in the VMRC console. By default, after vRA creation, all VMs
do not have copy paste enabled (unless configured on the base VM). This
 script will search VMs and then enable copy paste on the VMRC console.

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

# Process the array of discovered VMs
Write-Host ">>> Enabling Copy/Paste in VMRC..."
ForEach ($vm in $sorted_vms) {
    
    # Print name of VM that is currently being proceesed...
    Write-Host ">>> Processing VM: $vm"

    # First check if paste is enabled
    $paste_enabled = Get-AdvancedSetting -Entity $vm -Name *tools.paste*
    $paste_enabled = $paste_enabled.Value
    #Write-Host "  > Paste disabled: $paste_enabled"
    if ($paste_enabled -eq "False")
    {
        Write-Host "  > Skipping VM. Paste is already enabled."
    }
    else
    {
        Write-Host "  > Enabling paste in VMRC..."
        Write-Verbose -Message "$vm - Setting the isolation.tools.copy.disable AdvancedSetting to $false..."
        New-AdvancedSetting `
            -Entity $vm `
            -Name isolation.tools.paste.disable `
            -Value $false `
            -confirm:$false `
            -force:$true `
            -errorAction 'Continue'
    }

    # First check if copy is enabled
    $copy_enabled = Get-AdvancedSetting -Entity $vm -Name *tools.copy*
    $copy_enabled = $copy_enabled.Value
    #Write-Host "  > Paste disabled: $copy_enabled"
    if ($copy_enabled -eq "False")
    {
        Write-Host "  > Skipping VM. Copy is already enabled."
    }
    else
    {
        Write-Host "  > Enabling copy in VMRC..."
        Write-Verbose -Message "$vm - Setting the isolation.tools.copy.disable AdvancedSetting to $false..."
        New-AdvancedSetting `
            -Entity $vm `
            -Name isolation.tools.copy.disable `
            -Value $false `
            -confirm:$false `
            -force:$true `
            -errorAction 'Continue'
    }
}
