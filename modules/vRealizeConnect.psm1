<#
Author:  Thomas Laurenson
Email:   thomas@thomaslaurenson.com
Website: thomaslaurenson.com
Date:    2018/11/01
Description:
vRealizeConnect.psm1 is module to connect to the REST API of a vRealize server.
The module should return the Bearer ID to be used in subsequent API use.

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

function vRealizeConnect($vra_server) {
    # Check that there is a supplied vRealize hostname
    if ([string]::IsNullOrEmpty($vra_server))
    {
        Write-Host ">>> ERROR: No vRealize hostname configured..."
        Write-Host "  > You must pass a valid vRealize hostname to vRealizeConnect.psm1"
        Write-Host "  > Exiting."
        exit
    }

    # Append forward slash if vRealize hostname does not end with a forward slash
    if (-Not $vra_server.endswith("/")) {
        $vra_server = $vra_server + "/"
    }
    
    Write-Host "  > vRealize address:" $vra_server

    # Get user input for username and password
    $credentials=Get-Credential -Message "Please enter your vRealize credentials"

    # Set the tenant address
    $tenant = "vsphere.local"

    # Create a hashtable containing username, password (in plaintext) and tenant address
    $data = @{
     username=$credentials.username
     password=$credentials.GetNetworkCredential().password
     tenant=$tenant
    }
    # Convert the hashtable to JSON
    $data = $data | ConvertTo-Json

    # Create a URI object for API interaction
    # This will be updated in future API called
    # $vra_server is the base URL for the vRealize server
    # "identity/api/tokens" is the specific API request for getting the Bearer ID
    $uri = $vra_server + "identity/api/tokens"

    Write-Host ">>> Current URI:" $uri

    # Configure the REST request header flags
    $header = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $header.Add("Accept", 'application/json')
    $header.Add("Content-Type", 'application/json')


    Write-Host ">>> Attempting to get Bearer token..."
    try {
        $response = Invoke-RestMethod -Method Post -Uri $uri -Headers $header -Body $data
    } catch {
        # Catch any exception and print status code.
        # Also exit if failed
        Write-Host "StatusCode:" $_.Exception.Response.StatusCode.value__
        Write-Host "StatusDescription:" $_.Exception.Response.StatusDescription
        exit
    }

    # Prepend "Bearer " to the token
    $bearer_token = "Bearer " + $response.id

    Write-Host ">>> Successful"
    Write-Host "  > Returning bearer token..."
    return $bearer_token
}
