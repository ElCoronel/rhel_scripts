#!/bin/bash
CURDATE=`date +%y%m%d-%H%MA`
LOCKFILE=/tmp/dd_checksums.lck
JOBID=JID4508ea21-9723-4f53-8bc8-72da78dfe647
FOLDER=pdf_data_vol_013

exec &> >(tee /snowball_scripts/checksum_out/dd_checksums_"$JOBID"_"$FOLDER"_$CURDATE.log)

if [ ! -e $LOCKFILE ]; then
        touch $LOCKFILE

        echo "Begin" `date`

        for i in `find /snowball_stage/$JOBID/ -depth -type f | sort `; do
                md5sum $i >> /snowball_stage/$JOBID/$FOLDER/pdf_data_checksums.txt
        done

        echo "Completed" `date`

        rm $LOCKFILE

else

        echo "Lockfile exists, exiting."

fi

 >&2
exit
