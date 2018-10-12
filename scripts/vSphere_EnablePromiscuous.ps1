<#
Author:  Thomas Laurenson
Email:   thomas@thomaslaurenson.com
Website: thomaslaurenson.com
Date:    2018/10/12
Description:
vSphere_EnablePromiscuous.ps1 is PowerShell script to automate the enable flag
for promiscuous mode and forged transmits of Virtual Port Groups (VPGs). 

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
$input_name = Read-Host -Prompt '>>> Please input the VPG search term'
$vpgs = Get-VDPortgroup -Name $input_name

# Sort the VPGs by alphabetical order
$sorted_vpgs = $vpgs | Sort-Object

########### PRINT TARGET VPGs AND CHECK WITH USER

Write-Host ">>> You are about to MODIFY the following VPGs:"
Foreach ($vpg in $sorted_vpgs) {
    Write-Host "  >" $vpg.name
}
$total_vpg_count = $sorted_vpgs.Length
Write-Host ">>> There are $total_vpg_count VPGs.`n"

Write-Host ">>> WARNING!!! You are about to MODIFY VPGs..."
Read-Host -Prompt ">>> Press any key to continue or CTRL+C to quit" 

########### START ACTUAL VPG PROCESSING

# Loop each of the found VPGs
Foreach ($vpg in $sorted_vpgs) {
    
    Write-Host ">>> Processing VPG: $vpg"

    $vpgName = $vpg.Name

    Get-VDPortgroup -Name $vpgName | Get-VDSecurityPolicy | Set-VDSecurityPolicy -AllowPromiscuous $true
    Get-VDPortgroup -Name $vpgName | Get-VDSecurityPolicy | Set-VDSecurityPolicy -ForgedTransmits $true
}