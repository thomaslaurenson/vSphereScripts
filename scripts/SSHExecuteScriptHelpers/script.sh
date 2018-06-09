#!/bin/bash

# Get student login from scpd file
student=$(head -n 1 /tmp/student.txt)

export_dir="/tmp/"$student

mkdir $export_dir

##########################################
# PERFORM SCRIPT TASKS HERE
##########################################

# Create archive file of all saved material

# Set file name
archive_file="/tmp/"$student".tar"
# Set very slack permissions for dir
sudo chmod -R 777 $export_dir
# Make sure specific user account (user) is owner
sudo chown -R user:user $export_dir
# Create archive of all exported material
tar -cvf $archive_file -C $export_dir .

# SCP Transfer all data from export_dir

# Set properties for SCP transfer
user="myusername"
server="myipaddress"
port="mysshportnumber"

sshpass -p "mypassword" scp -P $port $archive_file $user@$server:$archive_file
if [ $? == 0 ]; then
    echo -e "# SUCCESSFUL: Archive SCPd"
else
    echo -e "# ERROR: Archive not SCPd"
fi
