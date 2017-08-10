#!/bin/bash
#
## set the proxy
export http_proxy=http://xxx.xxx.xxx.xxx:8080
export ftp_proxy=http://xxx.xxx.xxx.xxx:8080
#
## some variables
CURDATE=`date +%y%m%d-%H%M`     # get date for log filename
LOGPATH=/home/crls/workaround/logs           # log path
LOCKFILE=/tmp/crls_download.lck
#
## redirect stdout and stderr to log file
exec &> >(tee $LOGPATH/crls_download_$CURDATE.log)
#
# create lock file if it doesn't exist
if [ ! -e $LOCKFILE ]; then
        touch $LOCKFILE
#
## clean out old crls
	rm -rf /home/crls/workaround/downloads/*.crl
#
## get new crls
	wget --secure-protocol=TLSv1 -nv -i /home/crls/workaround/crl_sources.list -P /home/crls/workaround/downloads
#
## copy crls to auto folder
	cp /home/crls/workaround/downloads/*.crl /home/crls/CRLAutoCache/crls/
#
## remove lock file
        rm $LOCKFILE
#
## if lock file exists
else
        echo "Lock file exists, exiting."
fi
#
## email on 404
if cat $LOGPATH/crls_download_$CURDATE.log | grep 404 ; then
	cat $LOGPATH/crls_download_$CURDATE.log | grep -B 1 404 >> $LOGPATH/mail_body_$CURDATE.txt
	mailx -s "CRL Failure" -r addy@ress.com addy@ress.com < $LOGPATH/mail_body_$CURDATE.txt
	echo "!!! 404 found, email sent !!!"
else
	echo "All CRLS downloaded"
fi

## close redirect and exit
 >&2
exit
