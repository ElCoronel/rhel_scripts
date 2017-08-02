#!/bin/bash
##############################################################
#
# post_install_checks.sh
#
# Script to check post installation configuration of
# RHEL Systems.  Mirrors notes in initial MOTD.
#
#    NOTES: depends on rhel.list 
#
#    By: Greg Sanders
#    Last Mod Date: 2016-12-28
#
#    Version 0.0.3
#
##############################################################
#
### variables ###
LOG_PATH="/home/user/logs/RHEL_install_check"
CUR_DATE=`date +%y%m%d-%H%M`
ORIG_HOSTS_FILE="/home/user/remote_admin/sysinfo/lists/rhel.list"
HOSTS_FILE="/tmp/tmp.rhel.list"
RECIPIENTS="admin@addr.ess
MASTER_SERVER="xxx.xxx.xxx.xxx"
SCP_DIR="/home/user/RHEL_install_reports"
BODY=""
ISSUE_LIST=""
TMP_FILE_PATH=""
RAVMONTH="$(cat /home/user/remote_admin/sysinfo/av.datdate.newest | awk '{print$2}' | awk '$0*=1')"
RAVYEAR="$(cat /home/user/remote_admin/sysinfo/av.datdate.newest | awk '{print$1}')"
RAVDAY="$(cat /home/user/remote_admin/sysinfo/av.datdate.newest | awk '{print$3}' | awk '$0*=1')"

	
`cat $ORIG_HOSTS_FILE | sed '1d' > $HOSTS_FILE`

### local clean up ###
rm -f $LOG_PATH/*

### begin checks ###
echo "P O S T   I N S T A L L   C H E C K S"
echo "-------------------------------------"
echo "Reading host logins from $HOSTS_FILE..."
echo
echo "Starting."

for HOST in `cat "$HOSTS_FILE"`; do
### write a log ###
	{
### get to work ###
	echo "BEGIN $HOST POST INSTALL CHECK"
	echo "------------------------------"
	echo "Connecting to $HOST..."
	echo " "
	echo " "
       	echo "---------------------------"
	### hostname routine ###
        echo "Hostname... (should not be all-stig-image-rhel-6x)"
	if [ "$(ssh -q user@$HOST hostname)" != "" ]
		then
	        ssh -q user@$HOST hostname
			if $(ssh -q user@$HOST hostname | grep -q all-stig-image-rhel-6x)
				then
					echo "ISSUE: HOSTNAME NEEDS TO BE UPDATED"
			else
				LONGNAME=`ssh -q user@$HOST hostname`
				echo "Hostname looks good."
			fi
		else
			echo "ISSUE: HOSTNAME IS NOT SET"
	fi
	echo " "
	echo " "
	### /etc/hosts routine ###
	echo "Checking /etc/hosts for IP/Hostname..."
	if $(ssh -q user@$HOST cat /etc/hosts | grep -q "$HOST")
		then
			echo "$HOST found in /etc/hosts."
		else
			echo "ISSUE: $HOST NOT FOUND"
	fi
	if $(ssh -q user@$HOST cat /etc/hosts | grep -q "$LONGNAME")
		then
			echo "$LONGNAME found in /etc/hosts."
		else
			echo "ISSUE: $LONGNAME NOT FOUND"
	fi
	echo " "
	echo " "
	### nagios routine ###
	echo "Checking NAGIOS configuration..."
	if [ $HOST != "xxx.xxx.xxx.xxx" ]
		then
			if ssh -q user@$HOST stat  /usr/local/nagios/etc/nrpe.cfg \> /dev/null 2\>\&1
				then
					if $(ssh -q user@$HOST cat /usr/local/nagios/etc/nrpe.cfg | grep -q show_users)
						then 
							echo "show_users found in config, appears to be configured."
						else
							echo "ISSUE: show_users NOT FOUND. $HOST NEEDS CONFIGURATION"
					fi
				else
					echo "ISSUE: NAGIOS NOT INSTALLED"
			fi
		else
			echo "This is the Nagios server."
	fi
	echo " "
	echo " "
	### netbackup routine ###
	echo "Getting Netbackup version... (should be Netbackup-RedHat2.6.18 7.7.2)"
	if ssh -q user@$HOST stat  /usr/openv/netbackup/bin/version \> /dev/null 2\>\&1
		then
			ssh -q  user@$HOST cat /usr/openv/netbackup/bin/version
			if $(ssh -q user@$HOST cat /usr/openv/netbackup/bin/version | grep -q "NetBackup-RedHat2.6.18 7.7.2")
			then
			       echo "Netbackup version is correct."
			else
				echo "ISSUE: NETBACKUP IS NOT CORRECT VERSION"
			fi
		else
			echo "ISSUE: NETBACKUP IS NOT INSTALLED"
		fi
	echo " "
	echo " "
	### avscan routine ###
	echo "Checking avscan data file timestamp..."
	if ssh -q user@$HOST stat /usr/local/uvscan/avvscan.dat \> /dev/null 2\>\&1
		then
			ssh -q user@$HOST 'ls -la --time-style="+%Y %m %d"' "/usr/local/uvscan/avvscan.dat" | awk '{print $9 " " $7 " " $8 " " $6}'
			LAVMONTH=`ssh -q user@$HOST 'ls -la --time-style="+%Y %m %d"' "/usr/local/uvscan/avvscan.dat" | awk '{print$7}' | awk '$0*=1'`
			LAVYEAR=`ssh -q user@$HOST 'ls -la --time-style="+%Y %m %d"' "/usr/local/uvscan/avvscan.dat" | awk '{print $6}'`
			LAVDAY=`ssh -q user@$HOST 'ls -la --time-style="+%Y %m %d"' "/usr/local/uvscan/avvscan.dat" | awk '{print $8}' | awk '$0*=1'`
			if (($LAVYEAR != $RAVYEAR))
				then
					echo "ISSUE: AV DATA FILE MAY BE OUT OF DATE"
					else
					if (($LAVMONTH < $RAVMONTH))
						then
							echo "ISSUE: AV DATA FILE MAY BE OUT OF DATE"
						else
							if (($LAVDAY < $RAVDAY))
								then
									echo "ISSUE: AV DATA FILE MAY BE OUT OF DATE"
								else
									echo "AV data file looks good."
							fi
					fi
			fi
		else
			echo "ISSUE: AV DATA FILE MAY NOT BE INSTALLED"
		fi
	echo " "
	echo " "
	### splunk routine ###
	echo "Checking for splunkforwarder and version..."
	if [ $HOST != "xxx.xxx.xxx.xxx" ]
		then
			if ssh -q user@$HOST stat /opt/splunkforwarder/bin/splunk \> /dev/null 2\>\&1
				then
					ssh -q -t user@$HOST sudo /opt/splunkforwarder/bin/splunk version
					if $(ssh -q -t user@$HOST sudo /opt/splunkforwarder/bin/splunk version | grep -q "Splunk Universal Forwarder 6.5.1 (build f74036626f0c)")
						then
							echo "Splunkforwarder is up to date."
						else
							echo "ISSUE: NEED TO UPDATE SPLUNKFORWARDER"
						fi
				else
					echo "Splunk not installed. Should it be?"
			fi
		else
			echo "This is the Splunk server."
	fi
	echo " "
	echo " "
	### ntp conf check ###
	if [ $HOST != "xxx.xxx.xxx.xxx" ]
		then
			if $(ssh -q user@$HOST cat /etc/ntp.conf | grep -q 'xxx.xxx.xxx.xxx')
				then
					echo "NTP configured for xxx.xxx.xxx.xxx."
				else
					echo "ISSUE: NTP NOT CONFIGURED FOR xxx.xxx.xxx.xxx"
			fi
		else
			echo "This is the NTP server."	
	fi
	echo " "
	echo " "
        echo "----------------------------"
	echo "END $HOST POST INSTALL CHECK"
	echo "----------------------------"
	echo " "
	echo " "
	} > $LOG_PATH/$HOST"_post_install_check_"$CUR_DATE.log 2>&1
### close log ###

done
### end checks ###

### mail report routine ###
while true; do
	read -p "Do you want to email the reports? (y/n) " yn
	case $yn in
		[Yy]* ) echo "Sending reports."
			echo "Please find post installation RHEL checks attached. These were run on $CUR
_DATE" >> $LOG_PATH/body.out

			scp -q $LOG_PATH/*_post_install_check_$CUR_DATE.log user@$MASTER_SERVER:$SCP_DI
R/

			for i in `ssh -q user@$MASTER_SERVER ls $SCP_DIR`; do
				TMP_FILE_PATH="$TMP_FILE_PATH -a $SCP_DIR/$i "
			done

			for i in `ls $LOG_PATH`; do
				if [[ $(cat $LOG_PATH/$i | grep "ISSUE") ]]
					then
						echo -e "\n Issue found on $i" >> $LOG_PATH/body.out
				fi
			done

			BODY=$( cat $LOG_PATH/body.out )

			echo "$BODY"


			ssh -q -t user@$MASTER_SERVER "echo \"$BODY\" | sudo /bin/mailx -s \"RHEL Post Install Reports\" $TMP_FILE_PATH -r reply-to@addr.ess $RECIPIENTS" 

			ssh -q user@$MASTER_SERVER rm -f $SCP_DIR/*

		break;;


	[Nn]* ) echo "No email sent. Reports are local only."	

		ssh -q user@$MASTER_SERVER rm -f $SCP_DIR/*
		exit;;
	esac
done
rm -f $HOSTS_FILE
