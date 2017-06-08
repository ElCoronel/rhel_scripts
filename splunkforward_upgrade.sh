#!/bin/bash
##############################################################
#
# splunkforward_upgrade.sh
#
# This script deploys/upgrades the splunk forwarder agent.
#
#    By: Greg Sanders
#    Last Mod Date: 2017-04-20
#
#    Version 1.0.0
#
##############################################################

LOG_PATH="/home/zeedo/logs"
CUR_DATE=`date +%y%m%d-%H%M`
ORIG_HOSTS_FILE="/home/zeedo/remote_admin/sysinfo/lists/foo.list"
#ORIG_HOSTS_FILE="/home/zeedo/remote_admin/sysinfo/lists/rhel.list"
HOSTS_FILE="/tmp/tmp.rhel.list"
LOCAL_FILE_DIR="/home/zeedo/files"
REMOTE_FILE_DIR="/home/zeedo/files"
LOCAL_SCRIPT_DIR="/home/zeedo/remote_admin/scripts"
REMOTE_SCRIPT_DIR="/home/zeedo/scripts"
LOCAL_INSTALL_FILE="splunkforwarder-6.5.2-67571ef4b87d-Linux-x86_64.tgz"
REMOTE_SCRIPT="splunk_remote_deploy.sh"

`cat $ORIG_HOSTS_FILE | sed '1d' > $HOSTS_FILE`

exec &> >(tee "$LOG_PATH/splunk_forwarder_upgrade_$CUR_DATE.log")
echo "Reading host logins from $HOSTS_FILE"
echo
echo "Starting."

for HOST in `cat "$HOSTS_FILE"`; do
        if [ -z "$HOST" ]; then
                continue;
        fi
	echo "Connecting to $HOST"
	echo " "
	echo " "
	if  ssh -q zeedo@$HOST ls /opt/splunkforwarder
	then
        	echo "---------------------------"
	        echo "Copying install file to $HOST"
	        scp -q "$LOCAL_FILE_DIR/$LOCAL_INSTALL_FILE" "zeedo@$HOST:$REMOTE_FILE_DIR/$LOCAL_INSTALL_FILE" 
	        scp -q "$LOCAL_SCRIPT_DIR/$REMOTE_SCRIPT" "zeedo@$HOST:$REMOTE_SCRIPT_DIR/$REMOTE_SCRIPT" 
	        echo "Installing to zeedo@$HOST"
	        ssh -q -t "zeedo@$HOST" "$REMOTE_SCRIPT_DIR/$REMOTE_SCRIPT"
	        echo "--------------------------"
	else
		echo "--------------------------"
		echo "Splunk Forwarder not installed to $HOST"
		echo "--------------------------"
	fi
done
echo "---------------------------"
echo "All hosts processed"
echo "---------------------------"
echo "Done"
rm -f $HOSTS_FILE
>&2
exit
