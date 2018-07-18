<#
Author:  Thomas Laurenson
Email:   thomas@thomaslaurenson.com
Website: thomaslaurenson.com
Date:    2018/07/18
Description:
A simple PowerShell script to search vRealize for VMs with a specific
name, then print out properties of the VM.

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

# Set the base URL for the vRealize server
Do {
    $vra_server = Read-host "Enter the hostname for your vRealize server"
    } While ($vra_server -eq "")

# Enter hard-coded vRealize server here and comment above Do statement
#$vra_server

# Get the script directory
$pwd = $PSScriptRoot

# Import the vRealize connect module from the module directory
Import-Module $pwd\..\modules\vRealizeConnect

Write-Host ">>> Attempting to connect now..."
$bearer_token = vRealizeConnect($vra_server)
Write-Host "  > Continuing..."

# Update URI to request available resources
$uri = $vra_server + "catalog-service/api/consumer/resources/?page=1&limit=5000&$orderby=name"

Write-Host ">>> Current URI:" $uri

# Create request header
$header = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$header.Add("Accept", 'application/json')
$header.Add("Authorization", $bearer_token)

Write-Host ">>> Fetching Entitled Catalog Items..."

$response = Invoke-RestMethod -Method Get -Uri $uri -Headers $header

Write-Host ">>> Found the following vRealize Deployments..."
ForEach ($vm in $response.content)
    {
        Write-Host "  >" $vm.name
    }
