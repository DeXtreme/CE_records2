#!/bin/bash
# 
# Personal Record Management System
# This script stores, deletes and searches
# usernames,email address and passwords.
# The data is encrypted and stored in the 
# ~/.local/share/records.gpg file
#
# **********************************
# Author: Emmanuel Akolbire
# Website: https://github.com/DeXtreme
#
# **********************************


function usage(){
	# Print usage message
	
	echo "$0 [-B] [-b]\n"
	echo "Options:"
	echo "	-B		Enable regular backups. Enabled by default"
	echo " 	-b		Disable regualar backups"

	exit 0
}

function setBackup(){
	# Set R_BCKUP environment variable and
	# schedule records.gpg file backup

	if [[ ! $R_BCKUP -gt 0 && $1 -gt 0  ]]; then
		# Add crontab to run backup
		(crontab -l; echo "@daily tar -czf ~/.records.tar.gz ~/.records/records")|crontab -
		
		R_BCKUP=1
		echo "R_BCKUP=1" > ~/.records/config
	elif [[ $R_BCKUP -gt 0 && $1 -eq 0 ]]; then
		#Remove crontab for backup
		crontab -l| sed "/records$/d"|crontab -		
		
		R_BCKUP=0
		echo "R_BCKUP=0" > ~/.records/config

	fi

	return  0;
}


function add_record(){
	# Add new record
	
	read -p "Username: " name
	read -p "Email Address: " email
	read -sp "Password: " passwd

	echo "Username: $name, Email Address: $email, Password: $passwd" >> ~/.records/records
	echo ""
	echo -e "\e[1;34m...Record saved...\e[m"
}

function delete_record(){
	# Delete record

	read -p "Enter Username or Email: " by
	
	sed -in /$by/d ~/.records/records
	echo -e "\e[1;31m...Deleted record...\e[m"
}

function search_record(){
	# Print record

	read -p "Enter Username or Email: " by

	sed -n /$by/p ~/.records/records
}



function main(){
	# Main function
	
	# Create .records directory and files
	if [[ ! -d ~/.records ]]; then
		mkdir ~/.records
		touch ~/.records/records
		setBackup 1
	else	
		# source config
		source ~/.records/config
	fi


	while getopts :Bbh opts; do
		case $opts in
			"B")
				setBackup 1
				exit 0
				;;
			"b")	
				setBackup 0
				exit 0
				;;
			"h")
				usage
				;;
			*)
				echo "$(basename $0): invalid option -- $opts"
				echo "Try '$0 -h' for more information"
				exit 1
				;;
		esac
	done
	
	echo -e "\e[1;33m....Personal Records Management System...\e[m"
	while [[ 1 -eq 1 ]]; do
		echo ""
		read -p "[A]dd,[D]elete,[S]earch,[Q]uit:" cmd
		case $cmd in
			[Aa]*)
				add_record
				;;
			[Dd]*)
				delete_record
				;;
			[Ss]*)
				search_record
				;;
			[Qq]*)
				exit 0
				;;
			*)
				echo "Invalid option"
				;;
		esac
	done

	exit 0
}



main $@

	

