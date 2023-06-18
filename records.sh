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
	
	echo "$0 [-B] [-b] [-t TIMEFRAME]\n"
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
		(crontab -l; echo "@daily tar -czf ~/.local/share/records.gpg.bk ~/.local/share/records.gpg")|crontab -
		
		R_BCKUP="$1"
		export R_BCKUP

	elif [[ $R_BCKUP -gt 0 && $1 -eq 0 ]]; then
		#Remove crontab for backup
		crontab -l| sed "/records.gpg$/d"|crontab -	
	fi

	return  0;
}



function main(){
	# Main function
	
	# Check if R_BACKUP is set
	if [[ -z $R_BCKUP ]]; then
		setBackup 1
	fi

	while getopts :Bbh opts; do
		case $opts in
			"B")
				setBackup 1
				;;
			"b")	
				setBackup 0
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

	exit 0
}



main $@

	

