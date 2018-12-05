<#
Author:  Thomas Laurenson
Email:   thomas@thomaslaurenson.com
Website: thomaslaurenson.com
Date:    2018/12/05
Description:
vSphere_CheckDiskUsage.ps1 is PowerShell script to automate the
checking of all Virtual Machines (VMs) on vSphere and provide a
list of disk usage.

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
#$input_name = Read-Host -Prompt '>>> Please input the VM search term'
#$vms = Get-VM -Name $input_name

$vms = Get-VM -Name *

# Sort the VM by alphabetical order
$sorted_vms = $vms | Sort-Object

########### START ACTUAL VM PROCESSING
$FinalResult = @() 

# Loop each of the found VMs
Foreach ($vm in $sorted_vms) {
    
    Write-Host ">>> Processing VM: $vm"
    
    $object = New-Object -TypeName PSObject
    $object | Add-Member -MemberType NoteProperty -Name "Name" -Value $vm.Name
    $object | Add-Member -MemberType NoteProperty -Name "MemoryGB" -Value $vm.MemoryGB
    $object | Add-Member -MemberType NoteProperty -Name "ProvisionedSpaceGB" -Value $vm.ProvisionedSpaceGB
    $object | Add-Member -MemberType NoteProperty -Name "UsedSpaceGB" -Value $vm.UsedSpaceGB
    $object | Add-Member -MemberType NoteProperty -Name "NumCpu" -Value $vm.NumCpu
    $finalResult += $object
}

$reportName = $pwd + "\DiskUsageReport.csv"
Write-Host ">>> Saving report to:" $reportName
$finalResult | Export-Csv $reportName  -NoTypeInformation -UseCulture
