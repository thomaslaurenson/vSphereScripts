<#
Author:  Thomas Laurenson
Email:   thomas@thomaslaurenson.com
Website: thomaslaurenson.com
Date:    2018/11/09
Description:
A simple PowerShell script to search vRealize for deployments with a specific
name, then delete the deployment.

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
Do 
{
    $vra_server = Read-host "Enter the hostname for your vRealize server"
} 
While ($vra_server -eq "")

# Enter hard-coded vRealize server here and comment above Do statement
#$vra_server = "https://vra-server.com"

# Get the script directory
$pwd = $PSScriptRoot

# Import the vRealize connect module from the module directory
Import-Module $pwd\..\modules\vRealizeConnect -Force

Write-Host ">>> Attempting to connect now..."
$bearer_token = vRealizeConnect($vra_server)
Write-Host "  > Continuing..."

# Append forward slash if vRealize hostname does not end with a forward slash
if (-Not $vra_server.endswith("/")) {
    $vra_server = $vra_server + "/"
}

# Update URI to request available resources
$uri = $vra_server + "catalog-service/api/consumer/resources/?page=1&limit=5000&$orderby=name"

Write-Host "  > Current URI:" $uri

# Create request header
$header = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$header.Add("Accept", 'application/json')
$header.Add("Authorization", $bearer_token)

Write-Host ">>> Fetching Entitled Catalog Items..."

# This request will return an array of every catalog item the user has entitlements for
$response = Invoke-RestMethod -Method Get -Uri $uri -Headers $header

# Input field to specify search term for items
$search_term = Read-Host -Prompt '>>> Please input the search term'
Write-Host "  > Search term:" $search_term
if (-Not $search_term.endswith("*")) {
    $search_term = $search_term + "*"
    }
if (-Not $search_term.startswith("*")) {
    $search_term = "*" + $search_term
    }
Write-Host "  > Search term:" $search_term

# Loop through the array of entitled items
ForEach ($deployment in $response.content) {
       
    # Check if the deployment name contains the keyword
    if ($deployment.name -Like $search_term) 
    {
        # Get the id of the deployment
        $deployment_id = $deployment.id
        Write-Host ""
        Write-Host ">>> Deployment name:" $deployment.name
        Write-Host "  > Deployment id:" $deployment_id

        # Strict check for deletion
        Write-Host ">>> ARE YOU SURE YOU WANT TO DELETE THIS DEPLOYMENT???" -ForegroundColor red
        $continue = Read-Host -Prompt "  > Press [Y] or [y] to continue, or anything else to skip..."

        if (!$continue.Contains("y") -OR !$continue.Contains("Y"))
        {
            Write-Host ">>> Skipping this deployment..."
            continue
        }

        # Get the actions available for a specific deployment
        $uri = $vra_server + "catalog-service/api/consumer/resources/" `
                           + $deployment_id `
                           + "/actions"
        $response = Invoke-RestMethod -Method Get -Uri $uri -Headers $header
        $deployment_actions = $response.content

        # Loop through actions available for the deployment
        ForEach ($deployment_action in $deployment_actions) 
        {
            # Find the action named "Destroy"
            if ($deployment_action.name -eq "Destroy") 
            {
                Write-Host "  > Discovered the Destroy action..."
                
                # Get the ID of the Destory action
                $deployment_destroy_id = $deployment_action.id
                Write-Host "  > Destroy action id:" $deployment_destroy_id
                
                # Fetch the Destroy template
                $uri = $vra_server + "catalog-service/api/consumer/resources/" `
                                    + $deployment_id `
                                    + "/actions/" `
                                    + $deployment_destroy_id `
                                    + "/requests/template"
                $data = Invoke-RestMethod -Method Get -Uri $uri -Headers $header
                $data_json = $data | ConvertTo-Json

                # The previous response contains the data needed to send to invoke a destroy action
                $uri = $vra_server + "catalog-service/api/consumer/resources/" `
                + $deployment_id `
                                    + "/actions/" `
                                    + $deployment_destroy_id `
                                    + "/requests"
                $response = Invoke-RestMethod -Method Post -Uri $uri -Headers $header -Body $data_json -ContentType "application/json"

                Write-Host "  > Deleted: " + $deployment.name
                Write-Host ""
            }
        }

    }
}
