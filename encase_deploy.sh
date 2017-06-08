#!/bin/bash

##############################################################
#
# encase_deploy.sh
#
# This script deploys the encase agent, and /etc/init.d/
# script and creates a symlink to it from /etc/rc3.d/
#
#    By: Greg Sanders
#    Last Mod Date: 2017-05-23
#
#    Version 1.0.0
#
##############################################################

LOG_PATH="/home/zeedo/logs"
CUR_DATE=`date +%y%m%d-%H%M`
ORIG_HOSTS_FILE="/home/zeedo/remote_admin/sysinfo/lists/combined.linux.list"
HOSTS_FILE="/tmp/tmp.encase.list"
DEPLOYER_FILE_DIR="/home/zeedo/files"
AGENT_FILE="enlinuxpc64"
INITD_SCRIPT="encase"
REMOTE_UPLOAD_DIR="/home/zeedo/files/"
REMOTE_PARENT_DIR="/usr/local/encase"
REMOTE_AGENT_DIR="/usr/local/encase/agent"
REMOTE_INITD_DIR="/etc/init.d"
REMOTE_RC_DIR="/etc/rc3.d"
REMOTE_LINK_NAME="S94enlinuxpc"

`cat $ORIG_HOSTS_FILE > $HOSTS_FILE`

exec &> >(tee "$LOG_PATH/encase_deploy_$CUR_DATE.log")

echo "Reading host logins from $HOSTS_FILE"
echo
echo "Starting."
echo "---------------------------"


for HOST in `cat "$HOSTS_FILE"`; do
        if [ -z "$HOST" ]; then
                continue;
        fi
	echo "Connecting to $HOST"
	echo " "
	echo " "
	if  ssh -q zeedo@$HOST ls /home/zeedo/ \> /dev/null 2\>\&1
	then
        	echo "---------------------------"
		#Stop service
		ssh -q -t zeedo@$HOST sudo service encase stop
		#Check if agent folder exists and create it if it doesn't
	        if  ssh -q -t zeedo@$HOST sudo ls $REMOTE_AGENT_DIR \> /dev/null 2\>\&1
		then
			echo "$REMOTE_AGENT_DIR folder already exists on $HOST, skipping this step"
		else
	        	echo "Creating $REMOTE_AGENT_DIR folder on $HOST"
			ssh -q -t "zeedo@$HOST" sudo mkdir $REMOTE_PARENT_DIR
	        	ssh -q -t "zeedo@$HOST" sudo mkdir $REMOTE_AGENT_DIR

		fi
		#Copy agent and init.d script to host
		scp -q "$DEPLOYER_FILE_DIR/$AGENT_FILE" "zeedo@$HOST:$REMOTE_UPLOAD_DIR/"
		scp -q "$DEPLOYER_FILE_DIR/$INITD_SCRIPT" "zeedo@$HOST:$REMOTE_UPLOAD_DIR/"
		ssh -q -t zeedo@$HOST sudo cp $REMOTE_UPLOAD_DIR/$AGENT_FILE $REMOTE_AGENT_DIR
		ssh -q -t zeedo@$HOST sudo cp $REMOTE_UPLOAD_DIR/$INITD_SCRIPT $REMOTE_INITD_DIR
		ssh -q -t zeedo@$HOST sudo chown -R daemon:daemon $REMOTE_PARENT_DIR
		ssh -q -t zeedo@$HOST sudo chmod 755 $REMOTE_AGENT_DIR/$AGENT_FILE
		ssh -q -t zeedo@$HOST sudo chmod 755 $REMOTE_INITD_DIR/$INITD_SCRIPT
		#Create service
		ssh -q -t zeedo@$HOST sudo chkconfig --add encase
		ssh -q -t zeedo@$HOST sudo chkconfig --levels 345 encase on
		#Start service
		ssh -q -t zeedo@$HOST sudo service encase start


	        echo "--------------------------"
	else
		echo "--------------------------"
		echo "Could not connect to $HOST"
		echo "--------------------------"
	fi
done
echo "---------------------------"
echo "All hosts processed"
echo "---------------------------"
echo "Done"
for i in `cat "$HOSTS_FILE"`
	do echo $i; ssh -q -t $i ps -ef | grep enlinux | grep -v grep
done
rm -f $HOSTS_FILE
>&2
exit
