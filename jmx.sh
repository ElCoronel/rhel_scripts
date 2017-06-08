#!/bin/bash
##############################################################
#
# jmx.sh
#
# Script to list jmx port of Tomcat instances.
# Useful exercise for learning while loops operating
# on multiple fields.
#
#    NOTES: depends on tomcat.list 
#
#    By: Greg Sanders
#    Last Mod Date: 2017-01-26
#
#    Version 0.0.1
#
##############################################################
#
### variables ###
ORIG_HOSTS_FILE="/home/zeedo/remote_admin/sysinfo/lists/tomcat.list"
HOSTS_FILE="/tmp/tmp.tomcat.list"

### create a temp hosts file - editing out the header line ###
`cat $ORIG_HOSTS_FILE | sed '1d' > $HOSTS_FILE`

### grep for jmx port ###
while IFS=$'\t' read -r value1 value2 value3 value4 value5 value6 value7 value8 value9 value10 value11 value12
	do
		echo $value2 $value3
		ssh -qn zeedo@$value2 "cat $value3/bin/catalina.sh | grep jmxremote.port"
		echo " "
	done < $HOSTS_FILE
	echo "DONE BUDDY"

### delete the temp hosts file ###
rm -f $HOSTS_FILE
