#!/bin/bash

########### Block students from VMs
# Poweroff all VMs using PowerCLI script
# Turn off all entitled actions in vRA for service, including:
# Administration > Catalog Management > Entitlements > `group` >
# Items & Approvals > Entitled Actions > Remove all actions

########### Script starts here...

# Get student login from uploaded text file
student=$(head -n 1 /tmp/student.txt)

# Set and make export dir
export_dir="/tmp/"$student
mkdir $export_dir

# Install sshpass package for SCP transfer
sudo apt-get install sshpass -y

##########################################
# PERFORM SCRIPT TASKS HERE
##########################################

############################################ PERFORM INITIAL INFO GATHERING
echo -e "============================"
echo -e "==================== TASK 0:"
echo -e "============================"

############################################ DUMP HISTORY FOR ALL USERS
echo -e "# TASK 0: Dumping history for all users..."

sudo cp /home/student/.bash_history $export_dir"/.bash_history_student"
if [ $? != 0 ]; then 
    echo -e "# ERROR: Could not dump history file for student..."
else
    echo -e "# SUCCESS: Dumped history for student..."
fi

sudo cp /home/manager/.bash_history $export_dir"/.bash_history_manager"
if [ $? != 0 ]; then 
    echo -e "# ERROR: Could not dump history file for manager..."
else
    echo -e "# SUCCESS: Dumped history for manager..."
fi

sudo cp /root/.bash_history $export_dir"/.bash_history_root"
if [ $? != 0 ]; then 
    echo -e "# ERROR: Could not dump history file for root..."
else
    echo -e "# SUCCESS: Dumped history for root..."
fi

############################################ FINISH UP
echo -e "============================"
echo -e "================== TASK 999:"
echo -e "============================"

user="myusername"
server="myipaddress"
port="mysshportnumber"
password="somesecurepassword"

archive_file="/tmp/"$student".tar.gz"
# Set very slack permissions
sudo chmod -R 770 $export_dir
# Make sure account is owner
sudo chown -R $user:$user $export_dir
# Create archive of all exported material
tar -czvf $archive_file $export_dir

# Transfer data
sshpass -p $password scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -P $port $archive_file $user@$server:$archive_file
if [ $? == 0 ]; then
    echo -e "# SUCCESSFUL: Archive SCP transfer performed."
else
    echo -e "# ERROR: Archive SCP transfer failed."
fi
