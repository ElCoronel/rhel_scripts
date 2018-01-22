#!/bin/bash
CURDATE=`date +%y%m%d-%H%MA`
LOCKFILE=/tmp/dd_split.lck
JOBID=JID4508ea21-9723-4f53-8bc8-72da78dfe647
FOLDER=pdf_data_vol_013

exec &> >(tee /snowball_scripts/split_out/dd_split_"$JOBID"_"$FOLDER"_$CURDATE.log)

if [ ! -e $LOCKFILE ]; then
        touch $LOCKFILE

        echo "Begin" `date`

        dd if=/dev/sdc conv=noerror,sync | split -b 1024G - /snowball_stage/$JOBID/$FOLDER/pdf_data.img

        echo "Completed" `date`

        rm $LOCKFILE

else

        echo "Lockfile exists, exiting."

fi

 >&2
exit
