#!/bin/bash
##############################################################
#
# splunk_remote_deploy.sh
#
# This script installs and enables the splunk forwarder agent.
#
#    By: Greg Sanders
#    Last Mod Date: 2017-02-23
#
#    Version 1.0.0
#
##############################################################

LOG_PATH="/home/zeedo/logs"
CUR_DATE=`date +%y%m%d-%H%M`
LOCAL_FILE_DIR="/home/zeedo/files"
LOCAL_INSTALL_FILE="splunkforwarder-6.5.2-67571ef4b87d-Linux-x86_64.tgz"
HOST=`hostname`
exec &> >(tee "$LOG_PATH/splunk_forwarder_upgrade_$CUR_DATE.log")
echo "Deploying $LOCAL_INSTALL_FILE..."
echo
echo "Starting."
cd /opt
sudo tar xvfz $LOCAL_FILE_DIR/$LOCAL_INSTALL_FILE
sudo chown -R splunk:splunk /opt/splunkforwarder
sudo /opt/splunkforwarder/bin/splunk stop
sudo /opt/splunkforwarder/bin/splunk start --accept-license --answer-yes
sudo /opt/splunkforwarder/bin/splunk enable boot-start
echo "---------------------------"
echo "Deployed to $HOST"
echo "--------------------------"
echo "Done"
>&2
exit
