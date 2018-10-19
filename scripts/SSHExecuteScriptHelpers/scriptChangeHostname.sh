#!/bin/bash

# Get student login from scpd file
student=$(head -n 1 /tmp/student.txt)

##########################################
# SCRIPT TASKS BELOW
##########################################

# Change the hostname in /etc/hostname
echo $student | sudo tee /etc/hostname

# Change the hostname in /etc/hosts
echo "127.0.0.1       localhost" | sudo tee /etc/hosts
newLocalLoopbackHostname="127.0.0.1       $student"
echo $newLocalLoopbackHostname | sudo tee -a /etc/hosts
echo "# The following lines are desirable for IPv6 capable hosts" | sudo tee -a /etc/hosts
echo "::1     localhost ip6-localhost ip6-loopback" | sudo tee -a /etc/hosts
echo "ff02::1 ip6-allnodes" | sudo tee -a /etc/hosts
echo "ff02::2 ip6-allrouters" | sudo tee -a /etc/hosts
