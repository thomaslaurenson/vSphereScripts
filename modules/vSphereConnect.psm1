<#
Author:  Thomas Laurenson
Email:   thomas@thomaslaurenson.com
Website: thomaslaurenson.com
Date:    2018/05/11
Description:
vSphereConnect.psm1 is module to connect to a vSphere server.

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

function VSphereConnect {
    # Address of the vSphere server
    $server = Read-Host -Prompt 'Enter your vSphere IP/hostname'

    # Set vSphere credentials
    # Fetch username input (from above) and request password from user 
    $credentials=Get-Credential -Message "Please enter your vCenter credentials"

    # Connect to vSphere
    Connect-VIServer -Server $server -Credential $credentials -ErrorAction Inquire > $null

    # Get a list of servers you are connected to
    $serverList = $global:DefaultVIServer

    # Check the list of connected servers
    # If the list if NULL, report error and exit
    if($serverList -eq $null) 
    {
       write-host ">>> >>> ERROR: Unable to connect to $server. Null List."
       BREAK
    } 
    else 
    {
        # Loop the list of connected servers to check connection
        foreach ($server in $serverList) 
        {       
            $serverName = $server.Name
            if ($serverName -eq $server)
            {
                write-Host ">>> Connected to $serverName"
            } 
            else 
            {
                write-host ">>> ERROR: Unable to connect to $server. No Server Match."
                BREAK
            }
        }
    }
}
