#!/bin/bash
##############################################################
#
# leap_second_deploy.sh
#
# This script deploys and runs the leap second issue detector
#
#    By: Greg Sanders
#    Last Mod Date: 2017-01-09
#
#    Version 1.0.0
#
##############################################################

LOG_PATH="/home/zeedo/logs/"
LOG_NAME="leap_second_detector"
CUR_DATE=`date +%y%m%d-%H%M`
ORIG_HOSTS_FILE="/home/zeedo/remote_admin/sysinfo/lists/rhel.list"
HOSTS_FILE="/tmp/tmp.rhel.list"
HOSTS_FILE="/home/zeedo/remote_admin/sysinfo/lists/rhel.list"
LOCAL_SCRIPT_DIR="/home/zeedo/remote_admin/scripts"
REMOTE_SCRIPT_DIR="/home/zeedo/scripts"
REMOTE_SCRIPT="leap_second_issue_detector.sh"

`cat $ORIG_HOSTS_FILE | sed '1d' > $HOSTS_FILE`

exec &> >(tee "$LOG_PATH$LOG_NAME_$CUR_DATE.log")
echo "Reading host logins from $HOSTS_FILE"
echo
echo "Starting."

for HOST in `cat "$HOSTS_FILE"`; do
        if [ -z "$HOST" ]; then
                continue;
        fi
	LOG_FILE="$LOG_PATH$LOG_NAME"_"$HOST"_"$CUR_DATE.log"
	echo "$LOG_FILE"
	echo "Connecting to $HOST"
	echo " "
	echo " "
       	echo "---------------------------"
        echo "Copying script to $HOST"
        scp -q "$LOCAL_SCRIPT_DIR/$REMOTE_SCRIPT" "zeedo@$HOST:$REMOTE_SCRIPT_DIR/$REMOTE_SCRIPT" 
        echo "Running script as zeedo@$HOST"
        ssh -q -t "zeedo@$HOST" "$REMOTE_SCRIPT_DIR/$REMOTE_SCRIPT >> $LOG_FILE"
	scp -q "zeedo@$HOST:$LOG_FILE" "$LOG_FILE"
        echo "--------------------------"
done
echo "---------------------------"
echo "All hosts processed"
echo "---------------------------"
echo "Done"
rm -f $HOSTS_FILE
>&2
exit
