<#
Author:  Thomas Laurenson
Email:   thomas@thomaslaurenson.com
Website: thomaslaurenson.com
Date:    2018/06/10
Description:
A simple PowerShell script to search vSphere for VMs with a specific
name, then SSH to each, copy a script to /tmp, run the script, and 
collect all output. Great script for marking assignment VMs.

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

# Set the variable for PLINK and PSCP executable
$plinkCmd = "$pwd\..\tools\plink.exe"
$pscpCmd = "$pwd\..\tools\pscp.exe"

# Set the username, password for the SSH connection
$username = 'myusername'
$password = 'mypassword'

# Set the port for the SSH connection
$sshPort = '22'

########### MAIN SSH TASK: Prepare input/output

# The folder on the VM to copy script to
# /tmp/ is a suitable location
$targetFolder = "/tmp/" 

# Set directory of help scripts to execute on the target VM
# This folder includes files of commands to:
# 1) Set chmod of scriptToRun to executable for $username
# 2) Execute the scriptToRun
# 3) Contains the actual scriptToRun
$scriptHelperDirectory = "$pwd/SSHExecuteScriptHelpers/"

# The script to run on the target VM
# This code expects 'marking_script.sh' to be in the same folder as the script
$scriptToRun = "$scriptHelperDirectory/marking_script.sh" 

# The base output folder to contain
# 1) Logs (stdout, stderr)
# 2) Copy of the tarball of extracted files
$outputFolder = "$pwd/output/"

#Test for target output folder and create if not exists
if(!(Test-Path ${outputFolder})){
    New-Item ${outputFolder} -ItemType directory | Out-Null
}

########### MAIN SSH TASK: Start looping through VMs

# Process the array of discovered VMs
foreach($vm in $sorted_vms){
    # Get the VM name
    $VMName = $vm.Name
    # Gets the first IP address of the VM (usually the IP4 address)
    $VMIP4 = $vm.Guest.IPAddress[0]
    # Get the VM Owner
    $VMOwner = $vm.CustomFields["VRM Owner"]

    Write-Host ">>> Processing VM: $VMName"
    Write-Host "  > VM Owner: $VMOwner"
    Write-Host "  > IP address: $VMIP4"

    #### CHECK SSH CONNECTION
    # Form a command for executing plink.exe
    # echo y: This auto replies yes to unknown SSH keys
    # Then plink to port, username, password, IP and execute command
    Write-Host "  > Checking SSH connection for VM: $VMName"
    $CommandExit = "exit"
    Invoke-Expression -Command "echo y | $plinkCmd -P $sshPort -l $username -pw $password $VMIP4 $CommandExit"
    
    # Check the exit code
    if ( $LastExitCode -ne 0 )
    {
        # If exit code is not 0, there was a conneciton problem
        Write-Host "  > ERROR: Cannot connect to: ${VMName}" -ForegroundColor red
        Write-Host ">>> MOVING ON TO NEXT VM..." -ForegroundColor red
        break
    }
    else
    {
        Write-Host "  > SUCCESS: SSH connection passed, continuing..." -ForegroundColor DarkGreen
    }

    #### CREATE A LOG OUTPUT STRUCTURE FOR SPECIFIC VM
    # Extract student name/login
    $studentName = $VMName.split("_")[0]
    
    $studentFolder = "$outputFolder/$studentName/"

    # Test for target output folder and create if not exists
    if(!(Test-Path ${studentFolder})){
        New-Item ${studentFolder} -ItemType directory | Out-Null
    }

    #### Set log files for all output
    # Redirect all standard output (STDOUT) to the Out.txt file
    $outFile = "${studentFolder}Out.txt"
    # Redirect all standard error (STDERR) to the Err.txt file
    $errFile = "${studentFolder}Err.txt"

    #### COPY SCRIPT TO VM USING SCP
    # Form a command for executing pscp.exe
    Write-Host "  > Copying script to VM"
    Start-Process ($pscpCmd) `
        -ArgumentList ("-scp -P $sshPort -batch -r -pw $password $scriptToRun $username@${VMIP4}:$targetFolder") `
        -RedirectStandardOutput $outFile -RedirectStandardError $errFile -NoNewWindow -Wait
    # Check the exit code
    if ( $LastExitCode -ne 0 )
    {
        # If exit code is not 0, there was a conneciton problem
        Write-Host "  > ERROR: Cannot copy script to: ${VMName}" -ForegroundColor red
        Write-Host ">>> MOVING ON TO NEXT VM..." -ForegroundColor red
        break
    }
    else
    {
        Write-Host "  > SUCCESS: Script copy passed, continuing..." -ForegroundColor DarkGreen
    }

    #### SCP A FILE CONTIAING STUDENT NAME/LOGIN TO VM
    Write-Host "  > Setting student username/login on the VM"
    # First, set the variable for the student.txt file
    $studentFile = "${studentFolder}/student.txt"
    if(!(Test-Path ${studentFile})){
        # First, create a file to SCP    
        New-Item $studentFile -ItemType file | Out-Null
        # Now, populate file with student username
        Set-Content -Value $studentName -Path $studentFile -NoNewline
    }
    # Now, SCP student.txt file to VM
    Start-Process ($pscpCmd) `
        -ArgumentList ("-scp -P $sshPort -batch -r -pw $password $studentFile $username@${VMIP4}:$targetFolder") `
        -RedirectStandardOutput $outFile -RedirectStandardError $errFile -NoNewWindow -Wait
    # Check the exit code
    if ( $LastExitCode -ne 0 )
    {
        # If exit code is not 0, there was a conneciton problem
        Write-Host "  > ERROR: Cannot copy student name to: ${VMName}" -ForegroundColor red
        Write-Host ">>> MOVING ON TO NEXT VM..." -ForegroundColor red
        break
    }
    else
    {
        Write-Host "  > SUCCESS: Student name copy passed, continuing..." -ForegroundColor DarkGreen
    }

    #### ENABLE EXECUTION OF SCRIPT ON VM
    Write-Host "  > Setting appropriate script permissions on VM"
    Start-Process ($plinkCmd) `
        -ArgumentList ("-P $sshPort $username@${VMIP4} -batch -pw $password -m ${scriptHelperDirectory}chmodCmd") `
        -RedirectStandardOutput $outFile -RedirectStandardError $errFile -NoNewWindow -Wait 

    # Check the exit code
    if ( $LastExitCode -ne 0 )
    {
        # If exit code is not 0, there was a conneciton problem
        Write-Host "  > ERROR: Could not chmod script: ${VMName}" -ForegroundColor red
        Write-Host ">>> MOVING ON TO NEXT VM..." -ForegroundColor red
        break
    }
    else
    {
        Write-Host "  > SUCCESS: chmod test passed, continuing..." -ForegroundColor DarkGreen
    }

    #### EXECUTE SCRIPT ON VM
    Write-Host "  > Executing script on VM"
    Start-Process ($plinkCmd) `
        -ArgumentList ("-P $sshPort $username@${VMIP4} -batch -pw $password -m ${scriptHelperDirectory}bashCmd") `
        -RedirectStandardOutput $outFile -RedirectStandardError $errFile -NoNewWindow -Wait 

    # Check the exit code
    if ( $LastExitCode -ne 0 )
    {
        # If exit code is not 0, there was a conneciton problem
        Write-Host "  > ERROR: Could not execute script: ${VMName}" -ForegroundColor red
        Write-Host ">>> MOVING ON TO NEXT VM..." -ForegroundColor red
        break
    }
    else
    {
        Write-Host "  > SUCCESS: script execution passed, continuing..." -ForegroundColor DarkGreen
    }
}
